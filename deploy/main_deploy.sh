#!/bin/bash

# Get absolute path to project root
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT" || exit

echo "==== CI/CD: Universal Shell Deployer ===="

# Set the path for storing last repo URL
LAST_REPO_FILE="$PROJECT_ROOT/.last_repo_url"
REPO_URL="$1"

# Try to reuse last used repo URL if none provided
if [[ -z "$REPO_URL" && -f "$LAST_REPO_FILE" ]]; then
  REPO_URL=$(cat "$LAST_REPO_FILE")
  echo "🔁 Reusing last repo: $REPO_URL"
fi

# If still no URL, exit
if [[ -z "$REPO_URL" ]]; then
  echo "❌ No GitHub repo URL provided and no previous repo found."
  echo "Usage: ./deploy/main_deploy.sh <GitHub-Repo-URL>"
  exit 1
fi

# Save current repo URL for future reuse
echo "$REPO_URL" > "$LAST_REPO_FILE"

# Run pipeline
./deploy/git_manager.sh "$REPO_URL"
./deploy/build_manager.sh
./deploy/deploy_manager.sh
./deploy/cleanup_manager.sh

# Save path of the most recent repo clone
echo "$(ls -td "$PROJECT_ROOT"/repos/repo-* | head -n 1)" > "$PROJECT_ROOT/.current_repo"

