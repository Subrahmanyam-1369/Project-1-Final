#!/bin/bash
REPO_URL="$1"
REPO_DIR="repos/repo-$(date +%Y%m%d%H%M%S)"
git clone "$REPO_URL" "$REPO_DIR"
echo "$REPO_DIR" > .current_repo
