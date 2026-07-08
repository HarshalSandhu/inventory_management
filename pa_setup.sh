#!/bin/bash
# ──────────────────────────────────────────────────────────
# PythonAnywhere deployment setup script
# Run this in the PA Bash console after cloning the repo.
# Usage: bash pa_setup.sh
# ──────────────────────────────────────────────────────────

set -e

echo "=== 1. Create virtual environment ==="
python3 -m venv venv
source venv/bin/activate

echo "=== 2. Install dependencies ==="
pip install --upgrade pip
pip install -r requirements.txt

echo "=== 3. Create receipts directory ==="
mkdir -p receipts

echo "=== 4. Create .env from template ==="
if [ ! -f .env ]; then
    cp .env.example .env
    echo ">> .env created from .env.example — EDIT IT with your DB credentials!"
else
    echo ">> .env already exists"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  NEXT STEPS (manual):                                      ║"
echo "║  1. Edit .env with your PythonAnywhere MySQL credentials    ║"
echo "║  2. Go to Web tab → Create new web app → Manual config     ║"
echo "║  3. Set Python version to 3.10                             ║"
echo "║  4. Set working directory to this project path              ║"
echo "║  5. Set WSGI config to point to main:app                   ║"
echo "║  6. Add env vars in Web tab or use dotenv                   ║"
echo "║  7. Reload web app                                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo "After setup, visit: https://YOUR_USERNAME.pythonanywhere.com"
