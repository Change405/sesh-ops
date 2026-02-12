# sesh-ops

Session is a decentralized, peer-to-peer network for secure messaging. Because of its decentralized nature, anyone can
run a node and participate in the network and get paid for it. This repository contains the infrastructure and
configuration management for Session Service Nodes on the Arbitrum One network. It uses Terraform for hardware
provisioning and Ansible for secure, idempotent node configuration.

## Getting Started

**Infrastructure Provisioning:**
See [`terraform/README.md`](terraform/README.md) for detailed instructions on setting up and deploying Hetzner Cloud infrastructure.

**Node Configuration:**
See [`ansible/`](ansible/) for Ansible playbooks to configure Session nodes.

## Repository Structure

```
terraform/  - Infrastructure provisioning (Hetzner Cloud servers, networking, firewalls)
ansible/    - Node configuration and deployment (SSH hardening, Session software)
```

