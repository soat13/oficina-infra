package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

var authEndpoint string
var serviceToken string

func init() {
	authEndpoint = os.Getenv("AUTH_API_URL")
	if authEndpoint == "" {
		// Fallback se não configurado
		authEndpoint = "http://oficina-auth:8000/auth/validate"
	}
	serviceToken = os.Getenv("SERVICE_TOKEN")
}

func HandleRequest(ctx context.Context, event events.APIGatewayCustomAuthorizerRequest) (events.APIGatewayCustomAuthorizerResponse, error) {
	token := event.AuthorizationToken

	if token == "" {
		return generatePolicy("user", "Deny", event.MethodArn), errors.New("Unauthorized")
	}

	if strings.HasPrefix(strings.ToLower(token), "bearer ") {
		token = token[7:]
	}
	authHeader := fmt.Sprintf("Bearer %s", token)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, authEndpoint, nil)
	if err != nil {
		fmt.Printf("Error creating request: %v\n", err)
		return generatePolicy("user", "Deny", event.MethodArn), errors.New("Unauthorized")
	}

	req.Header.Add("Authorization", authHeader)
	if serviceToken != "" {
		req.Header.Add("X-Service-Token", serviceToken)
	}

	client := &http.Client{}
	res, err := client.Do(req)
	if err != nil {
		fmt.Printf("Error validating token: %v\n", err)
		return generatePolicy("user", "Deny", event.MethodArn), errors.New("Unauthorized")
	}
	defer res.Body.Close()

	if res.StatusCode != http.StatusOK {
		fmt.Printf("Token validation failed with status: %d\n", res.StatusCode)
		return generatePolicy("user", "Deny", event.MethodArn), errors.New("Unauthorized")
	}

	var result map[string]interface{}
	if err := json.NewDecoder(res.Body).Decode(&result); err != nil {
		fmt.Printf("Error decoding auth response: %v\n", err)
		return generatePolicy("user", "Deny", event.MethodArn), errors.New("Unauthorized")
	}

	if valid, ok := result["valid"].(bool); !ok || !valid {
		fmt.Printf("Token validation returned valid=false\n")
		return generatePolicy("user", "Deny", event.MethodArn), errors.New("Unauthorized")
	}

	wildcardResource := getWildcardResource(event.MethodArn)
	return generatePolicy("authorized-user", "Allow", wildcardResource), nil
}

func getWildcardResource(methodArn string) string {
	parts := strings.Split(methodArn, "/")
	if len(parts) < 2 {
		return methodArn
	}
	return fmt.Sprintf("%s/%s/*/*", parts[0], parts[1])
}

func generatePolicy(principalID, effect, resource string) events.APIGatewayCustomAuthorizerResponse {
	authResponse := events.APIGatewayCustomAuthorizerResponse{PrincipalID: principalID}

	if effect != "" && resource != "" {
		authResponse.PolicyDocument = events.APIGatewayCustomAuthorizerPolicy{
			Version: "2012-10-17",
			Statement: []events.IAMPolicyStatement{
				{
					Action:   []string{"execute-api:Invoke"},
					Effect:   effect,
					Resource: []string{resource},
				},
			},
		}
	}

	return authResponse
}

func main() {
	lambda.Start(HandleRequest)
}
