import uuid
from datetime import datetime, timezone

from db.models import Product, InventoryTransaction, TransactionType, ReferenceType


def record_transaction(
    db,
    product_id: str,
    tx_type: TransactionType,
    quantity: float,
    reference_type: ReferenceType,
    reference_id: str = None,
    receipt_path: str = None,
    notes: str = None,
) -> InventoryTransaction:
    product = db.query(Product).filter_by(id=product_id).first()
    if not product:
        raise ValueError(f"Product {product_id} not found")

    if tx_type == TransactionType.OUT and product.current_stock < quantity:
        raise ValueError(
            f"Insufficient stock for '{product.name}' ({product.sku}): "
            f"have {product.current_stock}, need {quantity}"
        )

    delta = quantity if tx_type == TransactionType.IN else -quantity
    product.current_stock += delta

    tx = InventoryTransaction(
        id=str(uuid.uuid4()),
        product_id=product_id,
        type=tx_type,
        quantity=quantity,
        reference_type=reference_type,
        reference_id=reference_id,
        receipt_path=receipt_path,
        notes=notes,
        created_at=datetime.now(timezone.utc),
    )
    db.add(tx)
    db.commit()
    return tx
