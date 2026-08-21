#!/bin/bash
set -euo pipefail

REPO_NAME="IAC-On-Prem-Exercise"
USER="gerben1925"
GITHUB_REPO="$USER/$REPO_NAME"

KEY_PATH="$HOME/.ssh/id_ed25519_github"

# Generate the key pair only if it doesn't already exist
if [[ ! -f "$KEY_PATH" ]]; then
    ssh-keygen -t ed25519 -C "github-actions-homelab" -f "$KEY_PATH" -N ""
fi

# Authorize the public key for SSH login on this server
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat "${KEY_PATH}.pub" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Get Tailscale IP, SSH user, and the private key contents (proper command substitution)
HOMELAB_IP=$(tailscale ip -4)
HOMELAB_USER=$(whoami)
HOMELAB_SSH_KEY=$(cat "$KEY_PATH")


echo ""
echo "====== SSH KEY GENERATED & CREDENTIALS READY ======"
echo "HOMELAB_IP:       $HOMELAB_IP"
echo "HOMELAB_USER:     $HOMELAB_USER"
echo "HOMELAB_SSH_KEY:  $HOMELAB_SSH_KEY"
echo ""


# Upload directly to GitHub if GitHub CLI (gh) is logged in
read -p "Do you want to automatically set these as GitHub Secrets using gh CLI? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then

    # Check if gh is installed
    if ! command -v gh &> /dev/null; then
        echo "Error: GitHub CLI (gh) is not installed. Install it first: https://cli.github.com/"
        exit 1
    fi

    # Check if logged in; if not, prompt login
    if ! gh auth status &> /dev/null; then
        echo "You are not logged in to GitHub CLI. Launching 'gh auth login'..."
        gh auth login
    fi

    gh secret set HOMELAB_IP -b"$HOMELAB_IP" --repo "$GITHUB_REPO"
    gh secret set HOMELAB_USER -b"$HOMELAB_USER" --repo "$GITHUB_REPO"
    gh secret set HOMELAB_SSH_KEY -b"$HOMELAB_SSH_KEY" --repo "$GITHUB_REPO"
    echo "GitHub Secrets successfully updated!"
else
    echo "Please manually copy the values above into your GitHub Repository Secrets."
fi