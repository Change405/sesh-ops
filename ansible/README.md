# Ansible Configuration for Session Service Nodes

Configuration management for Session Service Nodes on Ubuntu 24.04 (Hetzner Cloud).

**Admin User**: `session_change`
**SSH Key**: `~/.ssh/session_node_key`

## Initial Setup (One-Time)

This assumes you have already run the Terraform deployment.

Install tools:
```bash
pip install ansible
brew install jq
```

## Before Each Deployment

Regenerate inventory from Terraform outputs (run after any `terraform apply`):
```bash
cd ansible
./scripts/generate-inventory.sh
```

## Deployment

```bash
# Full deployment (bootstrap + security + session node)
ansible-playbook playbooks/site.yml \
  -e "l2_provider_url=$(op read 'op://Private/DRPC/API URL')"
```

## Playbooks

| Playbook | Purpose |
|------------------|--------------------------------------------------|
| `bootstrap.yml` | Create admin user (runs automatically via site.yml) |
| `site.yml` | Full deployment - run this |
| `security.yml` | Security hardening only |
| `session-node.yml` | Session node software only |

## Node Registration

After deployment, for each node:

```bash
# SSH to node
ssh ansible@<node-ip>

# Register (generates staking URL)
sudo oxend register 0xYourEthereumAddress
```

Open the staking URL at https://stake.getsession.org/ and complete within **9-12 minutes**.

## Verification

```bash
# Check service status
sudo systemctl status oxen-node

# Monitor logs
sudo journalctl -u oxen-node -f

# Check node status
sudo oxend status
sudo oxend print_sn_status

# Test QUIC connectivity
# https://quictest.oxen.io/
```

## Notes

- RPC URL stored in 1Password: `op://Private/DRPC/API URL`
- Inventory is generated from Terraform outputs (gitignored)
- Bootstrap runs automatically as part of site.yml
- All playbooks are idempotent (safe to re-run)
- Automatic security updates enabled (security patches only, no auto-reboot)