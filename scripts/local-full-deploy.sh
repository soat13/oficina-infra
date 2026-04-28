#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Full Infrastructure Deploy (Local)${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if AWS credentials are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo -e "${RED}Error: AWS credentials not set${NC}"
    echo ""
    echo "Please export your AWS credentials:"
    echo "  export AWS_ACCESS_KEY_ID=your_key"
    echo "  export AWS_SECRET_ACCESS_KEY=your_secret"
    echo "  export AWS_SESSION_TOKEN=your_token  # if using temporary credentials"
    echo "  export AWS_REGION=us-east-1"
    exit 1
fi

# Check if DD_API_KEY is set
if [ -z "$DD_API_KEY" ]; then
    echo -e "${YELLOW}DD_API_KEY not found in environment.${NC}"
    echo -n "Enter your Datadog API Key: "
    read -rs DD_API_KEY
    echo ""
    export DD_API_KEY
fi

echo -e "\n${GREEN}Step 1: Running Terraform Apply...${NC}"
./scripts/local-terraform-apply.sh

echo -e "\n${GREEN}Step 2: Running Datadog Deploy...${NC}"
./scripts/local-datadog-deploy.sh

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Full Infrastructure Deploy Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
