# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository manages infrastructure and configuration for Session Service Nodes on the Arbitrum One network. Session is a decentralized, peer-to-peer network for secure messaging where anyone can run a node and participate in the network.

**Tech Stack:**
- **Terraform**: Hardware provisioning and infrastructure as code (Hetzner Cloud)
- **Ansible**: Configuration management for secure, idempotent node setup
- **Target Network**: Arbitrum One (Ethereum Layer 2)

## Terraform Infrastructure

**Cloud Provider**: Hetzner Cloud
**State Backend**: S3 (`matts-terraform-states` bucket in us-east-2)
**State Locking**: S3-native locking (Terraform 1.11+, no DynamoDB needed)

**Authentication** (required before any Terraform command):
```bash
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION
aws login
eval $(aws configure export-credentials --format env)
export HCLOUD_TOKEN=$(op read "op://Private/Hetzner/API Key")
```

**Common commands:**
```bash
cd terraform
terraform init    # first time or after config changes
terraform plan
terraform apply
terraform destroy
terraform fmt -recursive
```

## Ansible Architecture

The playbook flow is: `site.yml` → imports `bootstrap.yml` → runs roles: `common`, `security`, `session-node`.

**Bootstrap pattern** (3-play adaptive):
1. Tests connection as `session_change` — if it fails, adds host to `need_bootstrap`
2. Connects as root, creates `session_change` user with `password: "*"` (not `!!`) and copies SSH keys
3. Verifies connection as `session_change`

**Critical details:**
- Admin user: `session_change` (set in `inventory/group_vars/all.yml` and `ansible.cfg`)
- `group_vars` must live at `ansible/inventory/group_vars/` (not `ansible/group_vars/`) to load correctly
- Ubuntu 24.04 SSH service name is `ssh` not `sshd`
- `password: "*"` in user creation is intentional — `!!` (default) causes PAM to block SSH key auth after sshd config hardens
- oxend runs as `_loki` user — data dir `/var/lib/oxen` must be owned by `_loki:_loki`
- oxend logs to journald only (not a file) — use `journalctl -u oxen-node -f`
- `session-service-node` package requires debconf pre-seeding before install (questions: `session-service-node/ip-address` and `session-service-node/l2-provider`)

**Run the full deployment:**
```bash
cd ansible
./scripts/generate-inventory.sh  # run after every terraform apply
ansible-playbook playbooks/site.yml -e "l2_provider_url=$(op read 'op://Private/DRPC/API URL')"
```

**Other useful commands:**
```bash
ansible-playbook playbooks/site.yml --syntax-check
ansible-playbook playbooks/site.yml --check
ansible-playbook playbooks/site.yml --limit node-1
ansible-inventory --list
```

## Security Considerations

- SSH private key: `~/.ssh/session_node_key` (gitignored)
- Generated inventory `ansible/inventory/hosts.local.yml` is gitignored
- Hetzner token and RPC URL are never written to disk — environment/1Password only
- `pam_faillock` on Ubuntu 24.04 will lock accounts on brute force attempts — `password: "*"` in bootstrap prevents SSH key auth from being blocked by account lock status

## Node Operations

```bash
# Check node status
sudo oxend status          # shows sync status, registration, pings
sudo oxend print_sn_status # detailed service node status

# Monitor logs
sudo journalctl -u oxen-node -f

# Register node (after full sync)
sudo oxend register 0xYourEthAddress
```

Staking requires 25,000 SESH per node. Complete stake at https://stake.getsession.org/ within 9-12 minutes of running the register command.