#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Terraform Apply - Local Execution${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if AWS credentials are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo -e "${RED}Error: AWS credentials not set${NC}"
    echo "Please export AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_SESSION_TOKEN"
    echo ""
    echo "Example:"
    echo "  export AWS_ACCESS_KEY_ID=your_key"
    echo "  export AWS_SECRET_ACCESS_KEY=your_secret"
    echo "  export AWS_SESSION_TOKEN=your_token  # if using temporary credentials"
    echo "  export AWS_REGION=us-east-1"
    exit 1
fi

# Set default region if not set
export AWS_REGION=${AWS_REGION:-us-east-1}

echo -e "\n${GREEN}[1/4]${NC} Using AWS Region: ${YELLOW}${AWS_REGION}${NC}"

# Navigate to infra directory
cd infra

echo -e "\n${GREEN}[2/4]${NC} Running Terraform Init..."
terraform init

echo -e "\n${GREEN}[3/4]${NC} Running Terraform Plan..."
terraform plan -out=tfplan

echo -e "\n${YELLOW}========================================${NC}"
echo -e "${YELLOW}Review the plan above.${NC}"
echo -e "${YELLOW}Press ENTER to apply or Ctrl+C to cancel${NC}"
echo -e "${YELLOW}========================================${NC}"
read -r

echo -e "\n${GREEN}[4/4]${NC} Running Terraform Apply..."
terraform apply -auto-approve tfplan

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Terraform Apply Complete!${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${BLUE}Extracting Terraform Outputs...${NC}"
CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "")

if [ -n "$CLUSTER_NAME" ]; then
    echo -e "${GREEN}Cluster Name: ${YELLOW}${CLUSTER_NAME}${NC}"
    
    # Save to a file for the next script
    echo "CLUSTER_NAME=${CLUSTER_NAME}" > ../scripts/.terraform-outputs.env
    echo -e "${GREEN}Saved cluster name to scripts/.terraform-outputs.env${NC}"
else
    echo -e "${YELLOW}Warning: Could not extract cluster_name output${NC}"
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Next Steps:${NC}"
echo -e "${YELLOW}1. Run the Datadog deployment script:${NC}"
echo -e "   ${GREEN}./scripts/local-datadog-deploy.sh${NC}"
echo -e "${YELLOW}2. Or manually update kubeconfig:${NC}"
if [ -n "$CLUSTER_NAME" ]; then
    echo -e "   ${GREEN}aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_REGION}${NC}"
fi
echo -e "${BLUE}========================================${NC}"
