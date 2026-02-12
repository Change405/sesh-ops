# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository manages infrastructure and configuration for Session Service Nodes on the Arbitrum One network. Session is a decentralized, peer-to-peer network for secure messaging where anyone can run a node and participate in the network.

**Tech Stack:**
- **Terraform**: Hardware provisioning and infrastructure as code
- **Ansible**: Configuration management for secure, idempotent node setup
- **Target Network**: Arbitrum One (Ethereum Layer 2)

## Repository Structure

```
terraform/  - Infrastructure provisioning (cloud resources, networking, compute)
ansible/    - Node configuration and deployment playbooks
scripts/    - Helper scripts for common operations
```

## Terraform Infrastructure

**Cloud Provider**: Hetzner Cloud
**State Backend**: S3 (`matts-terraform-states` bucket in us-east-2)
**State Locking**: S3-native locking (Terraform 1.11+)

**Key Details**:
- Uses S3-native state locking, which eliminates the need for DynamoDB
- Lock files (`.tflock`) are created alongside state files in S3
- Hetzner Cloud API token must be retrieved via 1Password CLI (never stored in files)
- Backend configuration is hardcoded in `backend.tf` (Terraform limitation)

## Common Commands

### Terraform Operations

**Prerequisites**: Before running Terraform commands, export the Hetzner Cloud token:
```bash
# Retrieve token from 1Password (requires biometric auth)
export HCLOUD_TOKEN=$(op read "op://[vault]/[item]/[field]")
```

**Common commands**:
```bash
# Initialize Terraform (run first or after config changes)
cd terraform && terraform init

# Plan infrastructure changes (dry-run)
terraform plan

# Apply infrastructure changes
terraform apply

# Destroy infrastructure
terraform destroy

# Format Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate
```

For detailed Terraform operations, troubleshooting, and state management, see `terraform/README.md`.

### Ansible Operations
```bash
# Run playbook (replace <playbook> with actual playbook name)
cd ansible && ansible-playbook <playbook>.yml

# Check playbook syntax
ansible-playbook <playbook>.yml --syntax-check

# Dry-run (check mode)
ansible-playbook <playbook>.yml --check

# Run against specific hosts
ansible-playbook <playbook>.yml --limit <host-pattern>

# List all hosts
ansible-inventory --list
```

## Security Considerations

**Never commit sensitive data:**
- Terraform `.tfvars` files (use `.tfvars.example` templates instead)
- Ansible vault passwords
- Private keys or credentials
- Host-specific inventory files

All sensitive files are already configured in `.gitignore`.

**Credential Management:**
- Hetzner Cloud API token is stored in 1Password and retrieved via CLI
- Requires biometric authentication for each retrieval
- Token is never written to disk (environment variable only)
- Use: `export HCLOUD_TOKEN=$(op read "op://[vault]/[item]/[field]")`

## Workflow

1. **Provision infrastructure**: Use Terraform to create compute resources, networking, and storage
2. **Configure nodes**: Use Ansible to deploy Session node software and configure services
3. **Maintain idempotency**: All configuration should be repeatable and declarative

Changes to infrastructure should be reviewed carefully as they affect running nodes on the live network.