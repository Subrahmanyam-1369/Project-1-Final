#!/bin/bash

# Get absolute path to project root
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR=$(cat "$PROJECT_ROOT/.current_repo")

cd "$REPO_DIR" || { echo "❌ Repo directory not found!"; exit 1; }

# Kill existing services
pkill -f "python3 -m http.server" 2>/dev/null
pkill -f "app.py" 2>/dev/null
pkill -f "java -jar" 2>/dev/null

# Create a proper backup in CI-CD/backups/
BACKUP_DIR="$PROJECT_ROOT/backups/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r . "$BACKUP_DIR"
echo "📦 Backup created at $BACKUP_DIR" | tee -a "$PROJECT_ROOT/logs/deploy.log"

# Deployment logic based on extension
if ls *.html > /dev/null 2>&1; then
    echo "🌐 Serving static HTML on port 3000..." | tee -a "$PROJECT_ROOT/logs/deploy.log"
    nohup python3 -m http.server 3000 >> "$PROJECT_ROOT/logs/deploy.log" 2>&1 &
    echo "✅ Static server started." | tee -a "$PROJECT_ROOT/logs/deploy.log"

elif ls *.py > /dev/null 2>&1; then
    MAIN_PY=$(ls *.py | head -n 1)
    echo "🐍 Running Python app: $MAIN_PY" | tee -a "$PROJECT_ROOT/logs/deploy.log"
    nohup python3 "$MAIN_PY" >> "$PROJECT_ROOT/logs/deploy.log" 2>&1 &
    echo "✅ Python app started." | tee -a "$PROJECT_ROOT/logs/deploy.log"

elif [[ -f "target/app.jar" ]]; then
    echo "☕ Running Java JAR..." | tee -a "$PROJECT_ROOT/logs/deploy.log"
    nohup java -jar target/app.jar >> "$PROJECT_ROOT/logs/deploy.log" 2>&1 &
    echo "✅ Java app started." | tee -a "$PROJECT_ROOT/logs/deploy.log"

else
    echo "❌ No supported app type found to deploy." | tee -a "$PROJECT_ROOT/logs/deploy.log"
    exit 1
fi

# Health Check
sleep 2
PORT=3000
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT)

if [[ "$STATUS" == "200" ]]; then
    echo "✅ App is running fine (HTTP $STATUS)" | tee -a "$PROJECT_ROOT/logs/deploy.log"
else
    echo "❌ App failed health check (HTTP $STATUS)" | tee -a "$PROJECT_ROOT/logs/deploy.log"
fi

echo "===== [Deploy Manager] Completed =====" | tee -a "$PROJECT_ROOT/logs/deploy.log"

