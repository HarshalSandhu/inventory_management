"""
ASGI entry point for PythonAnywhere deployment.
Point your web app's ASGI config to this file.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from main import app
