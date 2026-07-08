import uuid
from pathlib import Path

from config import UPLOAD_DIR

RECEIPT_DIR = Path(UPLOAD_DIR)
RECEIPT_DIR.mkdir(exist_ok=True)


def save_receipt(
    reference_type: str, reference_id: str, file_bytes: bytes, extension: str = "jpg"
) -> str:
    filename = f"{reference_type}_{reference_id}_{uuid.uuid4().hex}.{extension}"
    filepath = RECEIPT_DIR / filename
    filepath.write_bytes(file_bytes)
    return str(filepath)
