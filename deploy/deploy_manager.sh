#!/bin/bash

echo "===== [Deploy Manager] Starting Deployment Tasks ====="

REPO_DIR=$(cat .current_repo)
cd "$REPO_DIR" || { echo "❌ Repo directory not found!"; exit 1; }

# Kill any previously running related processes
pkill -f "python3 -m http.server" 2>/dev/null
pkill -f "app.py" 2>/dev/null
pkill -f "java -jar" 2>/dev/null

# Create a timestamped backup
BACKUP_DIR="../backups/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r . "$BACKUP_DIR"
echo "📦 Backup created at $BACKUP_DIR"

# Deployment logic based on file type
if ls *.html > /dev/null 2>&1; then
    echo "🌐 Serving static HTML on port 3000..."
    nohup python3 -m http.server 3000 > /dev/null 2>&1 &
    echo "✅ Static server started."

elif ls *.py > /dev/null 2>&1; then
    MAIN_PY=$(ls *.py | head -n 1)
    echo "🐍 Running Python app: $MAIN_PY"
    nohup python3 "$MAIN_PY" > /dev/null 2>&1 &
    echo "✅ Python app started."

elif [[ -f "target/app.jar" ]]; then
    echo "☕ Running Java JAR..."
    nohup java -jar target/app.jar > /dev/null 2>&1 &
    echo "✅ Java app started."

else
    echo "❌ No supported app type found to deploy."
    exit 1
fi

# Health Check (simple curl)
sleep 2
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200"
if [[ $? -eq 0 ]]; then
    echo "✅ App is running fine (HTTP 200)"
else
    echo "⚠️ App might not be responding (non-200 code)"
fi

echo "===== [Deploy Manager] Completed ====="

