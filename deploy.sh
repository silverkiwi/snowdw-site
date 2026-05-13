#!/bin/bash
# SnowDW — one-shot deploy to Vercel via GitHub
# Run this from inside the snowdw-site/ folder:
#   cd path/to/snowdw-site && bash deploy.sh

set -e

REPO_NAME="snowdw-site"

echo ""
echo "▶ Step 1: Initialising git..."
git init
git add -A
git commit -m "Initial commit: SnowDW landing page"

echo ""
echo "▶ Step 2: Pushing to GitHub..."
# Requires GitHub CLI: brew install gh && gh auth login
if ! command -v gh &>/dev/null; then
  echo ""
  echo "  ❌  GitHub CLI (gh) not found."
  echo "  Install it with:  brew install gh"
  echo "  Then auth with:   gh auth login"
  echo "  Then re-run this script."
  exit 1
fi

GH_USER=$(gh api user --jq '.login')
REMOTE_URL="https://github.com/${GH_USER}/${REPO_NAME}.git"

# Create the repo if it doesn't exist yet; otherwise just use it
if gh repo view "${GH_USER}/${REPO_NAME}" &>/dev/null; then
  echo "  Repo already exists — pushing to ${REMOTE_URL}"
  git remote remove origin 2>/dev/null || true
  git remote add origin "$REMOTE_URL"
  git branch -M main 2>/dev/null || true
  git push -u origin HEAD --force
else
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
fi

echo ""
echo "▶ Step 3: Deploying to Vercel..."
# Requires Vercel CLI: npm install -g vercel
if ! command -v vercel &>/dev/null; then
  echo ""
  echo "  ❌  Vercel CLI not found."
  echo "  Install it with:  npm install -g vercel"
  echo "  Then re-run this script."
  exit 1
fi
vercel --yes --prod

echo ""
echo "✅  Done! Your site is live on Vercel."
echo "    Connect your custom domain in the Vercel dashboard → Settings → Domains."
