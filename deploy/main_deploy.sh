#!/bin/bash

echo "==== CI/CD: Universal Shell Deployer ===="

REPO_URL="$1"

# ✅ Reuse previous repo if no URL passed
if [[ -z "$REPO_URL" && -f ".last_repo_url" ]]; then
  REPO_URL=$(cat .last_repo_url)
  echo "🔁 Reusing last repo: $REPO_URL"
fi

# ❌ Still no URL
if [[ -z "$REPO_URL" ]]; then
  echo "❌ No GitHub repo URL provided and no previous repo found."
  echo "Usage: ./deploy/main_deploy.sh <GitHub-Repo-URL>"
  exit 1
fi

# ✅ Save for future re-runs
echo "$REPO_URL" > .last_repo_url

cd "$(dirname "$0")/.." || exit
source .env

./deploy/git_manager.sh "$REPO_URL"
./deploy/build_manager.sh
./deploy/deploy_manager.sh
./deploy/cleanup_manager.sh


# After clone or reuse
LATEST_REPO=$(ls -td repos/repo-* | head -n 1)
echo "$LATEST_REPO" > .current_repo

