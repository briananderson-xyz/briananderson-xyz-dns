#!/bin/bash
# Setup GCP Workload Identity Federation for GitHub OIDC

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  GCP Workload Identity Federation Setup${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ gcloud not found! Please install Google Cloud SDK.${NC}"
    exit 1
fi

# Get current project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo -e "${YELLOW}⚠️  No project set. Please run:${NC}"
    echo -e "   gcloud config set project YOUR_PROJECT_ID"
    echo ""
    read -p "Enter your GCP Project ID: " PROJECT_ID
    if [ -z "$PROJECT_ID" ]; then
        echo -e "${RED}❌ Project ID is required!${NC}"
        exit 1
    fi
    gcloud config set project "$PROJECT_ID"
fi

echo -e "${GREEN}✅ Using GCP Project: ${PROJECT_ID}${NC}"
echo ""

# Configuration variables
POOL_ID="github-oidc-pool"
PROVIDER_ID="github-provider"
SERVICE_ACCOUNT="terraform-state-sa"
DISPLAY_NAME="Terraform State Management"
DESCRIPTION="Service account for Terraform state management via GitHub OIDC"

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Step 1: Create Service Account${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if service account exists
if gcloud iam service-accounts describe "$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com" &>/dev/null; then
    echo -e "${YELLOW}⚠️  Service account $SERVICE_ACCOUNT already exists${NC}"
else
    gcloud iam service-accounts create "$SERVICE_ACCOUNT" \
        --display-name="$DISPLAY_NAME" \
        --description="$DESCRIPTION"
    echo -e "${GREEN}✅ Service account created: $SERVICE_ACCOUNT${NC}"
fi

SA_EMAIL="$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Step 2: Grant Storage Admin Role${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/storage.admin"

echo -e "${GREEN}✅ Service account granted storage.admin role${NC}"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Step 3: Create Workload Identity Pool${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if gcloud iam workload-identity-pools describe "$POOL_ID" --location="global" &>/dev/null; then
    echo -e "${YELLOW}⚠️  Workload identity pool $POOL_ID already exists${NC}"
else
    gcloud iam workload-identity-pools create "$POOL_ID" \
        --location="global" \
        --display-name="GitHub OIDC Pool" \
        --description="GitHub OIDC pool for Terraform state"
    echo -e "${GREEN}✅ Workload identity pool created: $POOL_ID${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Step 4: Create OIDC Provider${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Get GitHub Organization/Repository info
echo ""
echo -e "${YELLOW}GitHub Configuration${NC}"
echo -e "You can configure OIDC at organization or repository level."
echo ""
echo -e "Options:"
echo -e "  1. Organization level (recommended) - Applies to all repos in org"
echo -e "  2. Repository level - Applies only to this repo"
echo ""
read -p "Which level do you want? (org/repo) [org]: " LEVEL
LEVEL=${LEVEL:-org}

if [ "$LEVEL" = "org" ]; then
    read -p "Enter your GitHub Organization name: " GITHUB_ORG
    if [ -z "$GITHUB_ORG" ]; then
        echo -e "${RED}❌ GitHub Organization name is required!${NC}"
        exit 1
    fi
    SUBJECT="repo:${GITHUB_ORG}/*:${GITHUB_ORG}:*"
    echo -e "${GREEN}✅ Configured for GitHub Organization: ${GITHUB_ORG}${NC}"
    echo -e "${GREEN}   Subject: ${SUBJECT}${NC}"
else
    read -p "Enter your GitHub username: " GITHUB_USER
    read -p "Enter your repository name: " GITHUB_REPO
    if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_REPO" ]; then
        echo -e "${RED}❌ GitHub username and repository name are required!${NC}"
        exit 1
    fi
    SUBJECT="repo:${GITHUB_USER}/${GITHUB_REPO}:ref:refs/heads/main"
    echo -e "${GREEN}✅ Configured for repository: ${GITHUB_USER}/${GITHUB_REPO}${NC}"
    echo -e "${GREEN}   Subject: ${SUBJECT}${NC}"
fi

echo ""
echo -e "${YELLOW}⚠️  Creating provider may take 1-2 minutes...${NC}"

if gcloud iam workload-identity-pools providers describe "$PROVIDER_ID" \
    --location="global" \
    --workload-identity-pool="$POOL_ID" &>/dev/null; then
    echo -e "${YELLOW}⚠️  OIDC provider already exists${NC}"
    echo -e "${YELLOW}   Run: gcloud iam workload-identity-pools providers describe ...${NC}"
else
    gcloud iam workload-identity-pools providers create-oidc "$PROVIDER_ID" \
        --location="global" \
        --workload-identity-pool="$POOL_ID" \
        --display-name="GitHub OIDC Provider" \
        --description="GitHub OIDC provider for Terraform" \
        --attribute-mapping="google.subject=assertion.sub" \
        --attribute-condition="assertion.sub=='${SUBJECT}'"
    echo -e "${GREEN}✅ OIDC provider created: $PROVIDER_ID${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Step 5: Allow Service Account to Impersonate${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/${PROJECT_ID}/locations/global/workloadIdentityPools/${POOL_ID}/subject/${SUBJECT}"

echo -e "${GREEN}✅ Service account can now impersonate via GitHub OIDC${NC}"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Configuration Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}Workload Identity Federation Details:${NC}"
echo -e "  Provider URL: https://token.actions.githubusercontent.com${NC}"
echo -e "  Pool ID: ${POOL_ID}${NC}"
echo -e "  Provider ID: ${PROVIDER_ID}${NC}"
echo -e "  Service Account: ${SA_EMAIL}${NC}"
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Next Steps${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}1. Update GitHub Actions workflow to use OIDC${NC}"
echo -e "${GREEN}2. No need for GOOGLE_APPLICATION_CREDENTIALS secret anymore!${NC}"
echo -e "${GREEN}3. Only CLOUDFLARE_API_TOKEN and CLOUDFLARE_ZONE_ID secrets needed${NC}"
echo ""
echo -e "${GREEN}4. Create GCS buckets:${NC}"
echo -e "   gsutil mb -l us-central1 gs://terraform-state-dev"
echo -e "   gsutil mb -l us-central1 gs://terraform-state-prod"
echo ""
echo -e "${GREEN}5. Push to GitHub to trigger workflow!${NC}"
echo ""

echo -e "${YELLOW}⚠️  Save these values for GitHub Actions configuration:${NC}"
echo ""
echo -e "${YELLOW}PROJECT_ID=${PROJECT_ID}${NC}"
echo -e "${YELLOW}POOL_ID=${POOL_ID}${NC}"
echo -e "${YELLOW}PROVIDER_ID=${PROVIDER_ID}${NC}"
echo -e "${YELLOW}SERVICE_ACCOUNT_EMAIL=${SA_EMAIL}${NC}"
echo ""
