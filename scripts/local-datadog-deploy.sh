#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Datadog Agent Deploy - Local Execution${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if AWS credentials are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo -e "${RED}Error: AWS credentials not set${NC}"
    echo "Please export AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_SESSION_TOKEN"
    exit 1
fi

# Set default region if not set
export AWS_REGION=${AWS_REGION:-us-east-1}

# Try to load cluster name from terraform outputs file
CLUSTER_NAME=""
if [ -f "scripts/.terraform-outputs.env" ]; then
    source scripts/.terraform-outputs.env
    echo -e "${GREEN}Loaded cluster name from previous terraform run: ${YELLOW}${CLUSTER_NAME}${NC}"
fi

# If not found, try to get from terraform directly
if [ -z "$CLUSTER_NAME" ]; then
    echo -e "${YELLOW}Trying to get cluster name from terraform outputs...${NC}"
    cd infra
    CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "")
    cd ..
fi

# If still not found, ask user
if [ -z "$CLUSTER_NAME" ]; then
    echo -e "${YELLOW}Could not find cluster name automatically.${NC}"
    echo -n "Enter EKS cluster name: "
    read -r CLUSTER_NAME
fi

if [ -z "$CLUSTER_NAME" ]; then
    echo -e "${RED}Error: Cluster name is required${NC}"
    exit 1
fi

echo -e "\n${GREEN}[1/5]${NC} Using cluster: ${YELLOW}${CLUSTER_NAME}${NC}"
echo -e "${GREEN}      Region: ${YELLOW}${AWS_REGION}${NC}"

# Check if DD_API_KEY is set
if [ -z "$DD_API_KEY" ]; then
    echo -e "\n${YELLOW}DD_API_KEY not found in environment.${NC}"
    echo -n "Enter your Datadog API Key: "
    read -rs DD_API_KEY
    echo ""
    export DD_API_KEY
fi

if [ -z "$DD_API_KEY" ]; then
    echo -e "${RED}Error: DD_API_KEY is required${NC}"
    exit 1
fi

echo -e "\n${GREEN}[2/5]${NC} Updating kubeconfig..."
aws eks update-kubeconfig \
    --name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}"

echo -e "\n${GREEN}[3/5]${NC} Checking Helm installation..."
if ! command -v helm &> /dev/null; then
    echo -e "${RED}Error: Helm is not installed${NC}"
    echo "Please install Helm: https://helm.sh/docs/intro/install/"
    exit 1
fi

echo -e "Helm version: $(helm version --short)"

echo -e "\n${GREEN}[4/5]${NC} Adding Datadog Helm repository..."
helm repo add datadog https://helm.datadoghq.com
helm repo update

echo -e "\n${GREEN}[5/5]${NC} Creating Datadog secret..."
kubectl create namespace datadog --dry-run=client -o yaml | kubectl apply -f -

# Create or update the secret
kubectl create secret generic datadog-secret \
    --from-literal=api-key="${DD_API_KEY}" \
    --namespace=datadog \
    --dry-run=client -o yaml | kubectl apply -f -

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Deploying Datadog Agent via Helm...${NC}"
echo -e "${BLUE}========================================${NC}"

helm upgrade --install datadog-agent datadog/datadog \
    -f k8s/datadog/values.yaml \
    --set datadog.clusterName="${CLUSTER_NAME}" \
    --namespace datadog \
    --create-namespace \
    --wait \
    --timeout 5m

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Datadog Agent Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${BLUE}Checking Datadog Agent status...${NC}"
kubectl get pods -n datadog

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Useful Commands:${NC}"
echo -e "${YELLOW}View agent pods:${NC}"
echo -e "  ${GREEN}kubectl get pods -n datadog${NC}"
echo -e "${YELLOW}View agent logs:${NC}"
echo -e "  ${GREEN}kubectl logs -n datadog -l app=datadog-agent --tail=50${NC}"
echo -e "${YELLOW}Check agent status:${NC}"
echo -e "  ${GREEN}kubectl exec -it -n datadog daemonset/datadog-agent -- agent status${NC}"
echo -e "${YELLOW}Uninstall agent:${NC}"
echo -e "  ${GREEN}helm uninstall datadog-agent -n datadog${NC}"
echo -e "${BLUE}========================================${NC}"
