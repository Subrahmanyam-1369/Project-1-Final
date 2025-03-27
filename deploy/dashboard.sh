#!/bin/bash

LOG_FILE="logs/deploy.log"
PORT=3000
HEALTH_URL="http://localhost:$PORT"

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

clear
echo "${CYAN}==========================="
echo "     CI/CD DASHBOARD"
echo "===========================${RESET}"

# 📁 Load current repo
if [[ ! -f .current_repo ]]; then
  echo -e "${RED}❌ .current_repo file not found.${RESET}"
  exit 1
fi

REPO_DIR=$(cat .current_repo)

echo -e "\n${YELLOW}📁 Repo:${RESET} $REPO_DIR"

if [[ ! -d "$REPO_DIR" ]]; then
  echo -e "${RED}❌ Repo directory does not exist.${RESET}"
  exit 1
fi

# 🕒 Last Deployed Time
echo -e "${YELLOW}🕒 Last Deployed:${RESET} $(stat -c %y "$REPO_DIR")"

# 🔄 Git Commits
echo -e "\n${YELLOW}🔄 Last 3 Git Commits:${RESET}"
git --git-dir="$REPO_DIR/.git" --work-tree="$REPO_DIR" log -3 --pretty=format:"%h - %an: %s" 2>/dev/null || echo "No Git repo"

# 🛠️ App Status
echo -e "\n${YELLOW}🛠️ App Status:${RESET}"
PROC=$(ps aux | grep -E 'python3 -m http.server|python3 .*\\.py|java -jar' | grep -v grep)
if [[ -n "$PROC" ]]; then
  echo -e "${GREEN}✅ RUNNING${RESET}"
  echo "$PROC"
else
  echo -e "${RED}❌ NOT RUNNING${RESET}"
fi

# 🧪 Health Check
echo -e "\n${YELLOW}🧪 Health Check:${RESET}"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL")
[[ "$STATUS" == "200" ]] && echo "${GREEN}Healthy (HTTP $STATUS)${RESET}" || echo "${RED}Unhealthy (HTTP $STATUS)${RESET}"

# 📄 Logs
echo -e "\n${YELLOW}📄 Log Snippet:${RESET}"
tail -n 10 "$LOG_FILE"

echo -e "\n${CYAN}==========================="
echo "     End of Dashboard"
echo "===========================${RESET}"

