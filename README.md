# sesh-ops

Session is a decentralized, peer-to-peer network for secure messaging. Because of its decentralized nature, anyone can
run a node and participate in the network and get paid for it. This repository contains the infrastructure and
configuration management for Session Service Nodes on the Arbitrum One network. It uses Terraform for hardware
provisioning and Ansible for secure, idempotent node configuration.

## Repository Structure

```
terraform/  - Infrastructure provisioning (Hetzner Cloud servers, networking, firewalls)
ansible/    - Node configuration and deployment (SSH hardening, Session software)
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/)
- [1Password CLI](https://developer.1password.com/docs/cli/get-started/)
- [AWS CLI](https://aws.amazon.com/cli/)
- [jq](https://jqlang.github.io/jq/)

```bash
brew install terraform ansible 1password-cli aws-cli jq
```

## First-Time Setup

```bash
# Authenticate (required for S3 backend)
aws login
eval $(aws configure export-credentials --format env)

# Initialize Terraform
cd terraform && terraform init
```

## Full Deployment

```bash
# 1. Authenticate (clear stale credentials first)
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION
aws login
eval $(aws configure export-credentials --format env)
export HCLOUD_TOKEN=$(op read "op://Private/Hetzner/API Key")

# 2. Provision infrastructure
cd terraform
terraform apply

# 3. Generate Ansible inventory
cd ../ansible
./scripts/generate-inventory.sh

# 4. Deploy and configure nodes
ansible-playbook playbooks/site.yml -e "l2_provider_url=$(op read 'op://Private/DRPC/API URL')"
```

## Rebuild / Re-deploy

```bash
# Auth (clear stale credentials first)
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION
aws login
eval $(aws configure export-credentials --format env)
export HCLOUD_TOKEN=$(op read "op://Private/Hetzner/API Key")

# Destroy and rebuild infrastructure
cd terraform
terraform destroy
terraform apply

# Regenerate inventory and redeploy
cd ../ansible
./scripts/generate-inventory.sh
ansible-playbook playbooks/site.yml -e "l2_provider_url=$(op read 'op://Private/DRPC/API URL')"
```

## Node Registration

After deployment, for each node:

```bash
ssh session_change@<node-ip>
sudo oxend register 0xB0dbd4F71D3635D3F3bd1c39d4f87bd0905Fa392
```

Open the staking URL at https://stake.getsession.org/ and complete within **9-12 minutes**.

## Detailed Documentation

- [Terraform](terraform/README.md) — infrastructure details, state management, troubleshooting
- [Ansible](ansible/README.md) — playbooks, roles, variables reference