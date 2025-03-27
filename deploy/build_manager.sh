#!/bin/bash
REPO_DIR=$(cat .current_repo)
cd "$REPO_DIR" || exit

echo "===== [Build Manager] Starting Build Detection ====="

# Static HTML Project
if ls *.html > /dev/null 2>&1; then
    echo "🌐 Detected Static HTML project. No build needed."
    exit 0

# Python Project
elif ls *.py > /dev/null 2>&1; then
    echo "🐍 Detected Python project."
    if [[ -f "requirements.txt" ]]; then
        echo "📦 Installing Python dependencies..."
        pip install -r requirements.txt
    fi
    exit 0

# Java Project
elif ls *.java > /dev/null 2>&1 || [[ -f "pom.xml" ]]; then
    echo "☕ Detected Java project."
    if [[ -f "pom.xml" ]]; then
        echo "🔨 Building with Maven..."
        mvn clean package
    fi
    exit 0

# Node.js Project (Optional)
elif [[ -f "package.json" ]]; then
    echo "🟢 Detected Node.js project."
    npm install
    npm run build
    exit 0

else
    echo "❌ Unknown project type (no .html, .py, .java, etc.)"
    exit 1
fi

echo 🔄 Pulling latest changes... | tee -a logs/deploy.log
