"""
WSGI entry point for PythonAnywhere.
If using ASGI (recommended — PA supports it on all tiers), point to asgi.py instead.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from main import app
from a2wsgi import ASGIMiddleware

application = ASGIMiddleware(app)
