#!/bin/bash
#
# check-prerequisites.sh
# Validates prerequisites before running Ansible playbooks
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$(dirname "$ANSIBLE_DIR")/terraform"
INVENTORY_FILE="$ANSIBLE_DIR/inventory/hosts.local.yml"
SSH_KEY="$HOME/.ssh/session_node_key"

ERRORS=0

echo "==> Checking prerequisites for Ansible deployment..."
echo ""

# Check 1: Ansible is installed
echo "[1/8] Checking Ansible installation..."
if command -v ansible-playbook &> /dev/null; then
    ANSIBLE_VERSION=$(ansible-playbook --version | head -n1)
    echo "  ✓ $ANSIBLE_VERSION"
else
    echo "  ✗ Ansible not found. Install with: pip install ansible"
    ((ERRORS++))
fi

# Check 2: jq is installed (needed for inventory generation)
echo "[2/8] Checking jq installation..."
if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version)
    echo "  ✓ $JQ_VERSION"
else
    echo "  ✗ jq not found. Install with: brew install jq (macOS) or apt install jq (Linux)"
    ((ERRORS++))
fi

# Check 3: Terraform directory exists
echo "[3/8] Checking Terraform directory..."
if [ -d "$TERRAFORM_DIR" ]; then
    echo "  ✓ Terraform directory found at $TERRAFORM_DIR"
else
    echo "  ✗ Terraform directory not found at $TERRAFORM_DIR"
    ((ERRORS++))
fi

# Check 4: Terraform state exists
echo "[4/8] Checking Terraform state..."
if [ -d "$TERRAFORM_DIR/.terraform" ]; then
    echo "  ✓ Terraform initialized"
    cd "$TERRAFORM_DIR"
    if terraform output -json > /dev/null 2>&1; then
        echo "  ✓ Terraform state contains outputs"
    else
        echo "  ✗ No Terraform outputs found. Has infrastructure been deployed?"
        ((ERRORS++))
    fi
    cd - > /dev/null
else
    echo "  ✗ Terraform not initialized"
    ((ERRORS++))
fi

# Check 5: Inventory file exists
echo "[5/8] Checking Ansible inventory..."
if [ -f "$INVENTORY_FILE" ]; then
    echo "  ✓ Inventory file exists at $INVENTORY_FILE"

    # Validate inventory
    cd "$ANSIBLE_DIR"
    if ansible-inventory --list -i "$INVENTORY_FILE" > /dev/null 2>&1; then
        HOST_COUNT=$(ansible-inventory --list -i "$INVENTORY_FILE" 2>/dev/null | jq -r '.session_nodes.hosts | length' 2>/dev/null || echo "0")
        echo "  ✓ Inventory validation passed ($HOST_COUNT hosts)"
    else
        echo "  ✗ Inventory validation failed"
        ((ERRORS++))
    fi
    cd - > /dev/null
else
    echo "  ⚠ Inventory file not found. Run: ./scripts/generate-inventory.sh"
    echo "  ℹ This is not an error if you haven't generated inventory yet"
fi

# Check 6: SSH private key exists
echo "[6/8] Checking SSH private key..."
if [ -f "$SSH_KEY" ]; then
    echo "  ✓ SSH key found at $SSH_KEY"

    # Check permissions
    KEY_PERMS=$(stat -f "%OLp" "$SSH_KEY" 2>/dev/null || stat -c "%a" "$SSH_KEY" 2>/dev/null || echo "unknown")
    if [ "$KEY_PERMS" = "600" ] || [ "$KEY_PERMS" = "400" ]; then
        echo "  ✓ SSH key permissions correct ($KEY_PERMS)"
    else
        echo "  ⚠ SSH key permissions should be 600 or 400 (currently: $KEY_PERMS)"
        echo "    Fix with: chmod 600 $SSH_KEY"
    fi
else
    echo "  ✗ SSH key not found at $SSH_KEY"
    echo "    This key should have been created by Terraform"
    ((ERRORS++))
fi

# Check 7: SSH connectivity (if inventory exists)
echo "[7/8] Checking SSH connectivity..."
if [ -f "$INVENTORY_FILE" ] && [ -f "$SSH_KEY" ]; then
    cd "$ANSIBLE_DIR"
    echo "  Testing connection to hosts..."

    if ansible session_nodes -m ping -o 2>&1 | grep -q "SUCCESS"; then
        echo "  ✓ SSH connectivity test passed"
    else
        echo "  ✗ SSH connectivity test failed"
        echo "    Try: ansible session_nodes -m ping"
        ((ERRORS++))
    fi
    cd - > /dev/null
else
    echo "  ⊘ Skipping (inventory or SSH key not available)"
fi

# Check 8: Required variables reminder
echo "[8/8] Checking required variables..."
echo "  ℹ Remember to provide these variables when running playbooks:"
echo "    - l2_provider_url: Arbitrum One RPC endpoint"
echo "    - operator_eth_address: Your Ethereum address"
echo ""
echo "  Example:"
echo "    ansible-playbook playbooks/site.yml \\"
echo "      -e 'l2_provider_url=https://...' \\"
echo "      -e 'operator_eth_address=0x...'"

echo ""
echo "==> Prerequisites check complete"

if [ $ERRORS -eq 0 ]; then
    echo "✓ All checks passed! Ready to deploy."
    echo ""
    echo "Next steps:"
    echo "  1. Ensure you have your RPC provider URL ready"
    echo "  2. Ensure you have your Ethereum address ready"
    echo "  3. Run: ansible-playbook playbooks/site.yml -e 'l2_provider_url=...' -e 'operator_eth_address=...'"
    exit 0
else
    echo "✗ $ERRORS error(s) found. Please fix the issues above before deploying."
    exit 1
fi
