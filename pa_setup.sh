#!/bin/bash
# PythonAnywhere deployment — SQLite free plan
set -e

echo "=== 1. Create virtual environment ==="
python3 -m venv venv
source venv/bin/activate

echo "=== 2. Install dependencies ==="
pip install --upgrade pip
pip install -r requirements.txt

echo "=== 3. Create directories ==="
mkdir -p receipts

echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║  Web App Setup (Manual config)                       ║"
echo "║                                                      ║"
echo "║  1. Web tab → Add new web app                        ║"
echo "║  2. Manual configuration → Python 3.10               ║"
echo "║  3. Source dir: /home/$(whoami)/inventory_management ║"
echo "║  4. Working dir: /home/$(whoami)/inventory_management║"
echo "║  5. PREFERRED: ASGI → asgi.py                        ║"
echo "║     ALTERNATIVE: WSGI → wsgi.py                      ║"
echo "║  6. Env vars (set in Web tab):                       ║"
echo "║     ADMIN_PASSWORD = your-secure-password            ║"
echo "║     SESSION_SECRET = (generate a random hex string)  ║"
echo "║  7. Reload                                           ║"
echo "╚═══════════════════════════════════════════════════════╝"
