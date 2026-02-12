# Terraform Configuration for Session Service Nodes

Infrastructure provisioning for Session Service Nodes on Hetzner Cloud (Arbitrum One network).

**State Backend**: S3 with native locking (no DynamoDB)
**State Location**: `s3://matts-terraform-states/sesh-ops/terraform.tfstate`

## Initial Setup (One-Time)

Install tools:
```bash
brew install terraform 1password-cli aws-cli
```

Initialize Terraform:
```bash
cd terraform
terraform init
```

## Daily Workflow

Before running any Terraform commands:

```bash
# 1. Authenticate to AWS (12 hour session)
aws login

# 2. Export Hetzner token from 1Password
export HCLOUD_TOKEN=$(op read "op://Private/Hetzner/API Key")
```

## Common Commands

**Preview changes:**
```bash
terraform plan
```

**Apply changes:**
```bash
terraform apply
```

**Destroy infrastructure:**
```bash
terraform destroy
```

**View state:**
```bash
# List all resources
terraform state list

# View outputs
terraform output

# Check state in S3
aws s3 ls s3://matts-terraform-states/sesh-ops/
```

## Notes

- AWS credentials expire after 12 hours (re-run `aws login`)
- Hetzner token is session-only (never written to disk)
- State is locked during operations using S3-native locking
- All sensitive files are gitignored
