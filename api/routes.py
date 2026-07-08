import uuid
import json
from datetime import datetime, timezone, date
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func, case

from db.database import get_db
from db.models import (
    Product,
    InventoryTransaction,
    B2BOrder,
    B2BOrderItem,
    VendorJobWork,
    VendorJobWorkItem,
    VendorJobStatus,
    ReorderRequest,
    ReorderStatus,
    DailyReport,
    TransactionType,
    ReferenceType,
    OrderStatus,
)
from services.excel_service import parse_products_excel
from services.inventory_service import record_transaction
from services.receipt_service import save_receipt
from auth import require_admin

router = APIRouter(dependencies=[Depends(require_admin)])


# ─── Pydantic schemas ────────────────────────────────────────────────────────


class ProductIn(BaseModel):
    sku: str
    name: str
    category: str
    unit: str
    current_stock: float = 0.0
    unit_price: float = 0.0
    is_critical: bool = False
    reorder_threshold: Optional[float] = None


class B2BOrderIn(BaseModel):
    customer_name: str
    customer_phone: Optional[str] = None
    items: list[dict]  # [{product_id, quantity, unit_price}]
    notes: Optional[str] = None


class VendorIssueIn(BaseModel):
    vendor_name: str
    raw_items: list[dict]  # [{product_id, quantity}]
    notes: Optional[str] = None


class VendorReceiveIn(BaseModel):
    job_work_id: str
    product_id: str
    quantity: float


class ReorderIn(BaseModel):
    product_id: str
    quantity: float
    supplier_name: Optional[str] = None
    notes: Optional[str] = None


# ─── Excel ───────────────────────────────────────────────────────────────────


@router.post("/excel/upload", tags=["Excel"])
async def upload_excel(file: UploadFile = File(...), db: Session = Depends(get_db)):
    ext = (file.filename or "data.xlsx").rsplit(".", 1)[-1].lower()
    if ext not in ("xlsx", "xls"):
        raise HTTPException(400, "Only .xlsx or .xls files accepted")

    file_bytes = await file.read()
    result = parse_products_excel(file_bytes, db)
    if result["errors"]:
        return {"message": "Partially processed", **result}
    return {"message": "Excel processed successfully", **result}


# ─── Products ────────────────────────────────────────────────────────────────


@router.get("/products", tags=["Products"])
def list_products(db: Session = Depends(get_db)):
    products = db.query(Product).order_by(Product.name).all()
    return [
        {
            "id": p.id,
            "sku": p.sku,
            "name": p.name,
            "category": p.category,
            "unit": p.unit,
            "current_stock": p.current_stock,
            "unit_price": p.unit_price,
            "is_critical": p.is_critical,
            "reorder_threshold": p.reorder_threshold,
            "created_at": p.created_at.isoformat() if p.created_at else None,
        }
        for p in products
    ]


@router.post("/products", tags=["Products"])
def create_product(data: ProductIn, db: Session = Depends(get_db)):
    existing = db.query(Product).filter_by(sku=data.sku).first()
    if existing:
        raise HTTPException(400, f"Product with SKU '{data.sku}' already exists")

    product = Product(
        id=str(uuid.uuid4()),
        sku=data.sku,
        name=data.name,
        category=data.category,
        unit=data.unit,
        current_stock=data.current_stock,
        unit_price=data.unit_price,
        is_critical=data.is_critical,
        reorder_threshold=data.reorder_threshold,
        created_at=datetime.now(timezone.utc),
    )
    db.add(product)
    db.commit()
    return {"id": product.id, "sku": product.sku, "message": "Product created"}


@router.get("/products/{product_id}", tags=["Products"])
def get_product(product_id: str, db: Session = Depends(get_db)):
    product = db.query(Product).filter_by(id=product_id).first()
    if not product:
        raise HTTPException(404, "Product not found")
    return {
        "id": product.id,
        "sku": product.sku,
        "name": product.name,
        "category": product.category,
        "unit": product.unit,
        "current_stock": product.current_stock,
        "unit_price": product.unit_price,
        "is_critical": product.is_critical,
        "reorder_threshold": product.reorder_threshold,
        "created_at": product.created_at.isoformat() if product.created_at else None,
    }


@router.put("/products/{product_id}", tags=["Products"])
def update_product(product_id: str, data: ProductIn, db: Session = Depends(get_db)):
    product = db.query(Product).filter_by(id=product_id).first()
    if not product:
        raise HTTPException(404, "Product not found")

    duplicate = (
        db.query(Product)
        .filter(Product.sku == data.sku, Product.id != product_id)
        .first()
    )
    if duplicate:
        raise HTTPException(400, f"SKU '{data.sku}' is already in use")

    product.sku = data.sku
    product.name = data.name
    product.category = data.category
    product.unit = data.unit
    product.unit_price = data.unit_price
    product.is_critical = data.is_critical
    product.reorder_threshold = data.reorder_threshold
    db.commit()
    return {"message": "Product updated"}


@router.delete("/products/{product_id}", tags=["Products"])
def delete_product(product_id: str, db: Session = Depends(get_db)):
    product = db.query(Product).filter_by(id=product_id).first()
    if not product:
        raise HTTPException(404, "Product not found")

    has_transactions = (
        db.query(InventoryTransaction).filter_by(product_id=product_id).first()
        is not None
    )
    has_orders = (
        db.query(B2BOrderItem).filter_by(product_id=product_id).first() is not None
    )
    has_vendor_items = (
        db.query(VendorJobWorkItem).filter_by(product_id=product_id).first()
        is not None
    )
    if has_transactions or has_orders or has_vendor_items:
        raise HTTPException(
            400,
            f"Cannot delete '{product.name}' — it has existing transaction, "
            "order, or vendor job history",
        )

    db.delete(product)
    db.commit()
    return {"message": "Product deleted"}


# ─── Inventory ───────────────────────────────────────────────────────────────


@router.get("/inventory/transactions", tags=["Inventory"])
def list_transactions(
    product_id: str = None,
    limit: int = 100,
    db: Session = Depends(get_db),
):
    q = (
        db.query(InventoryTransaction)
        .options(joinedload(InventoryTransaction.product))
        .order_by(InventoryTransaction.created_at.desc())
    )
    if product_id:
        q = q.filter_by(product_id=product_id)
    txs = q.limit(limit).all()
    return [
        {
            "id": tx.id,
            "product_id": tx.product_id,
            "product_name": tx.product.name if tx.product else None,
            "type": tx.type.value,
            "quantity": tx.quantity,
            "reference_type": tx.reference_type.value,
            "reference_id": tx.reference_id,
            "receipt_path": tx.receipt_path,
            "notes": tx.notes,
            "created_at": tx.created_at.isoformat() if tx.created_at else None,
        }
        for tx in txs
    ]


@router.post("/inventory/adjust", tags=["Inventory"])
async def inventory_adjust(
    product_id: str = Form(...),
    type: str = Form(...),
    quantity: float = Form(...),
    notes: str = Form(None),
    receipt: UploadFile = None,
    db: Session = Depends(get_db),
):
    if type.upper() not in ("IN", "OUT"):
        raise HTTPException(400, "Type must be IN or OUT")

    receipt_path = None
    if receipt:
        ext = (receipt.filename or "receipt.jpg").rsplit(".", 1)[-1].lower()
        file_bytes = await receipt.read()
        receipt_path = save_receipt("ADJUSTMENT", product_id, file_bytes, ext)

    ref_id = f"ADJ-{uuid.uuid4().hex[:8].upper()}"

    try:
        tx = record_transaction(
            db,
            product_id=product_id,
            tx_type=TransactionType(type.upper()),
            quantity=quantity,
            reference_type=ReferenceType.ADJUSTMENT,
            reference_id=ref_id,
            receipt_path=receipt_path,
            notes=notes,
        )
    except ValueError as e:
        raise HTTPException(400, str(e))

    return {"id": tx.id, "reference_id": ref_id, "message": "Stock adjusted"}


# ─── Vendor Job Work ─────────────────────────────────────────────────────────


@router.post("/vendor/issue", tags=["Vendor Job Work"])
def vendor_issue(data: VendorIssueIn, db: Session = Depends(get_db)):
    job = VendorJobWork(
        id=str(uuid.uuid4()),
        vendor_name=data.vendor_name,
        status=VendorJobStatus.ISSUED,
        notes=data.notes,
        issued_at=datetime.now(timezone.utc),
    )
    db.add(job)
    db.flush()

    errors = []
    for item in data.raw_items:
        product = db.query(Product).filter_by(id=item["product_id"]).first()
        if not product:
            errors.append(f"Product {item['product_id']} not found")
            continue
        try:
            record_transaction(
                db,
                product_id=item["product_id"],
                tx_type=TransactionType.OUT,
                quantity=item["quantity"],
                reference_type=ReferenceType.MANUFACTURING,
                reference_id=job.id,
                notes=f"Issued to vendor: {data.vendor_name}",
            )
            vi = VendorJobWorkItem(
                id=str(uuid.uuid4()),
                job_work_id=job.id,
                item_type="RAW",
                product_id=item["product_id"],
                quantity=item["quantity"],
            )
            db.add(vi)
        except ValueError as e:
            errors.append(str(e))

    if errors:
        db.rollback()
        raise HTTPException(400, f"Issue errors: {'; '.join(errors)}")

    db.commit()
    return {
        "job_work_id": job.id,
        "status": job.status.value,
        "message": f"Issued to {data.vendor_name}",
    }


@router.post("/vendor/{job_work_id}/receive", tags=["Vendor Job Work"])
async def vendor_receive(
    job_work_id: str,
    product_id: str = Form(...),
    quantity: float = Form(...),
    receipt: UploadFile = None,
    db: Session = Depends(get_db),
):
    job = db.query(VendorJobWork).filter_by(id=job_work_id).first()
    if not job:
        raise HTTPException(404, "Job work not found")
    if job.status == VendorJobStatus.COMPLETED:
        raise HTTPException(400, "Already fully received")

    receipt_path = None
    if receipt:
        ext = (receipt.filename or "receipt.jpg").rsplit(".", 1)[-1].lower()
        file_bytes = await receipt.read()
        receipt_path = save_receipt("VENDOR", job_work_id, file_bytes, ext)

    product = db.query(Product).filter_by(id=product_id).first()
    if not product:
        raise HTTPException(404, "Product not found")

    record_transaction(
        db,
        product_id=product_id,
        tx_type=TransactionType.IN,
        quantity=quantity,
        reference_type=ReferenceType.MANUFACTURING,
        reference_id=job.id,
        receipt_path=receipt_path,
        notes=f"Received from vendor: {job.vendor_name}",
    )

    vi = VendorJobWorkItem(
        id=str(uuid.uuid4()),
        job_work_id=job.id,
        item_type="FINISHED",
        product_id=product_id,
        quantity=quantity,
    )
    db.add(vi)
    db.flush()

    # Check if all raw items have been fully received (simplified — mark as completed on any receive)
    job.status = VendorJobStatus.COMPLETED
    job.completed_at = datetime.now(timezone.utc)
    if receipt_path:
        job.receipt_path = receipt_path
    db.commit()

    return {
        "job_work_id": job.id,
        "status": job.status.value,
        "message": "Received from vendor",
    }


@router.get("/vendor/jobs", tags=["Vendor Job Work"])
def list_vendor_jobs(db: Session = Depends(get_db)):
    jobs = (
        db.query(VendorJobWork)
        .options(joinedload(VendorJobWork.items).joinedload(VendorJobWorkItem.product))
        .order_by(VendorJobWork.issued_at.desc())
        .all()
    )
    result = []
    for j in jobs:
        raw_items = [
            {
                "product_id": i.product_id,
                "product_name": i.product.name if i.product else None,
                "quantity": i.quantity,
            }
            for i in j.items
            if i.item_type == "RAW"
        ]
        finished_items = [
            {
                "product_id": i.product_id,
                "product_name": i.product.name if i.product else None,
                "quantity": i.quantity,
            }
            for i in j.items
            if i.item_type == "FINISHED"
        ]
        result.append(
            {
                "id": j.id,
                "vendor_name": j.vendor_name,
                "status": j.status.value,
                "raw_items": raw_items,
                "finished_items": finished_items,
                "receipt_path": j.receipt_path,
                "notes": j.notes,
                "issued_at": j.issued_at.isoformat() if j.issued_at else None,
                "completed_at": j.completed_at.isoformat() if j.completed_at else None,
            }
        )
    return result


# ─── Reorder Requests (restock purchase orders) ──────────────────────────────


@router.post("/reorder", tags=["Reorders"])
def create_reorder(data: ReorderIn, db: Session = Depends(get_db)):
    product = db.query(Product).filter_by(id=data.product_id).first()
    if not product:
        raise HTTPException(404, "Product not found")
    if data.quantity <= 0:
        raise HTTPException(400, "Quantity must be greater than zero")

    reorder = ReorderRequest(
        id=str(uuid.uuid4()),
        product_id=data.product_id,
        quantity=data.quantity,
        supplier_name=data.supplier_name,
        status=ReorderStatus.PENDING,
        notes=data.notes,
        created_at=datetime.now(timezone.utc),
    )
    db.add(reorder)
    db.commit()
    return {
        "reorder_id": reorder.id,
        "status": reorder.status.value,
        "message": f"Reorder request sent for {product.name}",
    }


@router.get("/reorder", tags=["Reorders"])
def list_reorders(db: Session = Depends(get_db)):
    reorders = (
        db.query(ReorderRequest)
        .options(joinedload(ReorderRequest.product))
        .order_by(ReorderRequest.created_at.desc())
        .all()
    )
    return [
        {
            "id": r.id,
            "product_id": r.product_id,
            "product_name": r.product.name if r.product else None,
            "product_sku": r.product.sku if r.product else None,
            "quantity": r.quantity,
            "supplier_name": r.supplier_name,
            "status": r.status.value,
            "notes": r.notes,
            "receipt_path": r.receipt_path,
            "created_at": r.created_at.isoformat() if r.created_at else None,
            "received_at": r.received_at.isoformat() if r.received_at else None,
        }
        for r in reorders
    ]


@router.post("/reorder/{reorder_id}/receive", tags=["Reorders"])
async def receive_reorder(
    reorder_id: str,
    quantity: float = Form(...),
    receipt: UploadFile = None,
    db: Session = Depends(get_db),
):
    reorder = db.query(ReorderRequest).filter_by(id=reorder_id).first()
    if not reorder:
        raise HTTPException(404, "Reorder request not found")
    if reorder.status == ReorderStatus.RECEIVED:
        raise HTTPException(400, "Already received")
    if quantity <= 0:
        raise HTTPException(400, "Quantity must be greater than zero")

    receipt_path = None
    if receipt:
        ext = (receipt.filename or "receipt.jpg").rsplit(".", 1)[-1].lower()
        file_bytes = await receipt.read()
        receipt_path = save_receipt("PURCHASE", reorder_id, file_bytes, ext)

    record_transaction(
        db,
        product_id=reorder.product_id,
        tx_type=TransactionType.IN,
        quantity=quantity,
        reference_type=ReferenceType.PURCHASE,
        reference_id=reorder.id,
        receipt_path=receipt_path,
        notes=f"Received from supplier: {reorder.supplier_name or 'unspecified'}",
    )

    reorder.status = ReorderStatus.RECEIVED
    reorder.received_at = datetime.now(timezone.utc)
    if receipt_path:
        reorder.receipt_path = receipt_path
    db.commit()

    return {
        "reorder_id": reorder.id,
        "status": reorder.status.value,
        "message": "Reorder received and stock updated",
    }


# ─── B2B Orders ──────────────────────────────────────────────────────────────


@router.post("/b2b/order", tags=["B2B Orders"])
def create_b2b_order(data: B2BOrderIn, db: Session = Depends(get_db)):
    order = B2BOrder(
        id=str(uuid.uuid4()),
        customer_name=data.customer_name,
        customer_phone=data.customer_phone,
        status=OrderStatus.PENDING,
        notes=data.notes,
        created_at=datetime.now(timezone.utc),
    )
    db.add(order)
    db.flush()

    total = 0.0
    for item in data.items:
        product = db.query(Product).filter_by(id=item["product_id"]).first()
        if not product:
            raise HTTPException(400, f"Product {item['product_id']} not found")

        subtotal = item["quantity"] * item["unit_price"]
        total += subtotal

        order_item = B2BOrderItem(
            id=str(uuid.uuid4()),
            order_id=order.id,
            product_id=item["product_id"],
            quantity=item["quantity"],
            unit_price=item["unit_price"],
            subtotal=subtotal,
        )
        db.add(order_item)

    order.total_amount = total
    db.commit()
    return {"order_id": order.id, "total_amount": total, "message": "B2B order created"}


@router.post("/b2b/order/{order_id}/confirm", tags=["B2B Orders"])
def confirm_b2b_order(order_id: str, db: Session = Depends(get_db)):
    order = db.query(B2BOrder).filter_by(id=order_id).first()
    if not order:
        raise HTTPException(404, "Order not found")
    if order.status != OrderStatus.PENDING:
        raise HTTPException(400, f"Order is already {order.status.value}")

    order.status = OrderStatus.CONFIRMED
    db.commit()
    return {
        "order_id": order.id,
        "status": order.status.value,
        "message": "Order confirmed",
    }


@router.post("/b2b/order/{order_id}/dispatch", tags=["B2B Orders"])
async def dispatch_b2b_order(
    order_id: str,
    receipt: UploadFile = None,
    db: Session = Depends(get_db),
):
    order = db.query(B2BOrder).filter_by(id=order_id).first()
    if not order:
        raise HTTPException(404, "Order not found")
    if order.status != OrderStatus.CONFIRMED:
        raise HTTPException(
            400,
            f"Order must be CONFIRMED before dispatch (current: {order.status.value})",
        )

    receipt_path = None
    if receipt:
        ext = (receipt.filename or "receipt.jpg").rsplit(".", 1)[-1].lower()
        file_bytes = await receipt.read()
        receipt_path = save_receipt("B2B_ORDER", order_id, file_bytes, ext)

    # Deduct stock for each item
    errors = []
    for item in order.items:
        try:
            record_transaction(
                db,
                product_id=item.product_id,
                tx_type=TransactionType.OUT,
                quantity=item.quantity,
                reference_type=ReferenceType.B2B_ORDER,
                reference_id=order.id,
                receipt_path=receipt_path,
                notes=f"Dispatched in order {order.id}",
            )
        except ValueError as e:
            errors.append(f"Product {item.product_id}: {e}")

    if errors:
        raise HTTPException(400, f"Stock deduction errors: {'; '.join(errors)}")

    order.status = OrderStatus.DISPATCHED
    if receipt_path:
        order.receipt_path = receipt_path
    db.commit()
    return {
        "order_id": order.id,
        "status": order.status.value,
        "message": "Order dispatched",
    }


@router.get("/b2b/orders", tags=["B2B Orders"])
def list_b2b_orders(db: Session = Depends(get_db)):
    orders = (
        db.query(B2BOrder)
        .options(joinedload(B2BOrder.items).joinedload(B2BOrderItem.product))
        .order_by(B2BOrder.created_at.desc())
        .all()
    )
    result = []
    for o in orders:
        items = [
            {
                "product_id": i.product_id,
                "product_name": i.product.name if i.product else None,
                "quantity": i.quantity,
                "unit_price": i.unit_price,
                "subtotal": i.subtotal,
            }
            for i in o.items
        ]
        result.append(
            {
                "id": o.id,
                "customer_name": o.customer_name,
                "customer_phone": o.customer_phone,
                "status": o.status.value,
                "total_amount": o.total_amount,
                "items": items,
                "receipt_path": o.receipt_path,
                "notes": o.notes,
                "created_at": o.created_at.isoformat() if o.created_at else None,
            }
        )
    return result


# ─── Dashboard ───────────────────────────────────────────────────────────────


@router.get("/dashboard/summary", tags=["Dashboard"])
def dashboard_summary(db: Session = Depends(get_db)):
    below_threshold_cond = (Product.reorder_threshold.isnot(None)) & (
        Product.current_stock <= Product.reorder_threshold
    )
    product_stats = db.query(
        func.count(Product.id),
        func.sum(case((Product.category.ilike("%raw%"), 1), else_=0)),
        func.sum(case((Product.category.ilike("%finished%"), 1), else_=0)),
        func.sum(case((Product.current_stock <= 0, 1), else_=0)),
        func.sum(Product.current_stock * Product.unit_price),
        func.sum(case((below_threshold_cond, 1), else_=0)),
        func.sum(
            case((below_threshold_cond & Product.is_critical, 1), else_=0)
        ),
    ).one()
    (
        total_products,
        total_raw,
        total_finished,
        low_stock,
        total_stock_value,
        below_threshold,
        critical_alerts,
    ) = (
        product_stats[0] or 0,
        product_stats[1] or 0,
        product_stats[2] or 0,
        product_stats[3] or 0,
        product_stats[4] or 0,
        product_stats[5] or 0,
        product_stats[6] or 0,
    )

    pending_reorders = (
        db.query(ReorderRequest)
        .filter(ReorderRequest.status == ReorderStatus.PENDING)
        .count()
    )

    order_stats = db.query(
        func.sum(case((B2BOrder.status == OrderStatus.PENDING, 1), else_=0)),
        func.sum(case((B2BOrder.status == OrderStatus.CONFIRMED, 1), else_=0)),
        func.sum(case((B2BOrder.status == OrderStatus.DISPATCHED, 1), else_=0)),
    ).one()
    pending_orders, confirmed_orders, dispatched_orders = (
        order_stats[0] or 0,
        order_stats[1] or 0,
        order_stats[2] or 0,
    )

    vendor_stats = db.query(
        func.sum(case((VendorJobWork.status == VendorJobStatus.ISSUED, 1), else_=0)),
        func.sum(
            case((VendorJobWork.status == VendorJobStatus.COMPLETED, 1), else_=0)
        ),
    ).one()
    vendor_issued, vendor_completed = vendor_stats[0] or 0, vendor_stats[1] or 0

    recent_txs = (
        db.query(InventoryTransaction)
        .options(joinedload(InventoryTransaction.product))
        .order_by(InventoryTransaction.created_at.desc())
        .limit(10)
        .all()
    )

    recent_orders = (
        db.query(B2BOrder).order_by(B2BOrder.created_at.desc()).limit(10).all()
    )

    return {
        "products": {
            "total": total_products,
            "raw": total_raw,
            "finished": total_finished,
            "low_stock": low_stock,
            "stock_value": round(total_stock_value, 2),
            "below_threshold": below_threshold,
            "critical_alerts": critical_alerts,
        },
        "reorders": {
            "pending": pending_reorders,
        },
        "orders": {
            "pending": pending_orders,
            "confirmed": confirmed_orders,
            "dispatched": dispatched_orders,
        },
        "vendor_jobs": {
            "issued": vendor_issued,
            "completed": vendor_completed,
        },
        "recent_transactions": [
            {
                "id": tx.id,
                "product_name": tx.product.name if tx.product else None,
                "type": tx.type.value,
                "quantity": tx.quantity,
                "reference_type": tx.reference_type.value,
                "created_at": tx.created_at.isoformat() if tx.created_at else None,
            }
            for tx in recent_txs
        ],
        "recent_orders": [
            {
                "id": o.id,
                "customer_name": o.customer_name,
                "status": o.status.value,
                "total_amount": o.total_amount,
                "created_at": o.created_at.isoformat() if o.created_at else None,
            }
            for o in recent_orders
        ],
        "reports": db.query(DailyReport).count(),
    }


# ─── Daily Reports ────────────────────────────────────────────────────────────


def _build_day_summary(db, target_date: date) -> dict:
    day_start = datetime(
        target_date.year, target_date.month, target_date.day, tzinfo=timezone.utc
    )
    day_end = datetime(
        target_date.year,
        target_date.month,
        target_date.day,
        23,
        59,
        59,
        tzinfo=timezone.utc,
    )

    products_added = (
        db.query(Product)
        .filter(Product.created_at >= day_start, Product.created_at <= day_end)
        .count()
    )

    txs = (
        db.query(InventoryTransaction)
        .filter(
            InventoryTransaction.created_at >= day_start,
            InventoryTransaction.created_at <= day_end,
        )
        .all()
    )
    tx_in = sum(t.quantity for t in txs if t.type == TransactionType.IN)
    tx_out = sum(t.quantity for t in txs if t.type == TransactionType.OUT)

    orders = (
        db.query(B2BOrder)
        .filter(
            B2BOrder.created_at >= day_start,
            B2BOrder.created_at <= day_end,
        )
        .all()
    )
    orders_dispatched = sum(1 for o in orders if o.status == OrderStatus.DISPATCHED)
    orders_pending = sum(1 for o in orders if o.status == OrderStatus.PENDING)

    vendor_jobs = (
        db.query(VendorJobWork)
        .filter(
            VendorJobWork.issued_at >= day_start,
            VendorJobWork.issued_at <= day_end,
        )
        .all()
    )
    vendor_issued = len(vendor_jobs)
    vendor_completed = sum(
        1 for v in vendor_jobs if v.status == VendorJobStatus.COMPLETED
    )

    all_products = db.query(Product).order_by(Product.name).all()
    stock_snapshot = [
        {"sku": p.sku, "name": p.name, "stock": p.current_stock, "unit": p.unit}
        for p in all_products
    ]

    return {
        "date": target_date.isoformat(),
        "products_added": products_added,
        "transactions": {"in": tx_in, "out": tx_out, "total": len(txs)},
        "orders": {
            "dispatched": orders_dispatched,
            "pending": orders_pending,
            "total": len(orders),
        },
        "vendor_jobs": {"issued": vendor_issued, "completed": vendor_completed},
        "products_in_stock": len(stock_snapshot),
        "stock_snapshot": stock_snapshot,
    }


@router.post("/reports/day-end", tags=["Reports"])
def day_end(db: Session = Depends(get_db)):
    today = date.today()
    existing = db.query(DailyReport).filter_by(report_date=today).first()
    if existing:
        raise HTTPException(400, f"Report for {today} already exists")

    summary = _build_day_summary(db, today)
    report = DailyReport(
        id=str(uuid.uuid4()),
        report_date=today,
        summary=json.dumps(summary, default=str),
        created_at=datetime.now(timezone.utc),
    )
    db.add(report)
    db.commit()
    return {"report_id": report.id, "date": today.isoformat(), "summary": summary}


@router.get("/reports", tags=["Reports"])
def list_reports(db: Session = Depends(get_db)):
    reports = db.query(DailyReport).order_by(DailyReport.report_date.desc()).all()
    return [
        {
            "id": r.id,
            "date": r.report_date.isoformat(),
            "summary": json.loads(r.summary),
            "created_at": r.created_at.isoformat() if r.created_at else None,
        }
        for r in reports
    ]


@router.get("/reports/{report_date}", tags=["Reports"])
def get_report(report_date: str, db: Session = Depends(get_db)):
    try:
        dt = date.fromisoformat(report_date)
    except:
        raise HTTPException(400, "Invalid date format (use YYYY-MM-DD)")
    report = db.query(DailyReport).filter_by(report_date=dt).first()
    if not report:
        raise HTTPException(404, f"No report for {report_date}")
    return {
        "id": report.id,
        "date": report.report_date.isoformat(),
        "summary": json.loads(report.summary),
        "created_at": report.created_at.isoformat() if report.created_at else None,
    }


@router.get("/reports/today/preview", tags=["Reports"])
def preview_today(db: Session = Depends(get_db)):
    summary = _build_day_summary(db, date.today())
    return {"date": date.today().isoformat(), "summary": summary}
