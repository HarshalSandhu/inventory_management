import enum
from datetime import datetime
from sqlalchemy import (
    Column,
    String,
    Integer,
    Float,
    Boolean,
    DateTime,
    Date,
    Enum,
    ForeignKey,
    Text,
)
from sqlalchemy.orm import relationship
from db.database import Base


class TransactionType(str, enum.Enum):
    IN = "IN"
    OUT = "OUT"


class ReferenceType(str, enum.Enum):
    PURCHASE = "PURCHASE"
    MANUFACTURING = "MANUFACTURING"
    B2B_ORDER = "B2B_ORDER"
    ADJUSTMENT = "ADJUSTMENT"


class OrderStatus(str, enum.Enum):
    PENDING = "PENDING"
    CONFIRMED = "CONFIRMED"
    DISPATCHED = "DISPATCHED"


class VendorJobStatus(str, enum.Enum):
    ISSUED = "ISSUED"
    PARTIALLY_RECEIVED = "PARTIALLY_RECEIVED"
    COMPLETED = "COMPLETED"


class ReorderStatus(str, enum.Enum):
    PENDING = "PENDING"
    RECEIVED = "RECEIVED"


class Product(Base):
    __tablename__ = "products"

    id = Column(String(36), primary_key=True)
    sku = Column(String(50), unique=True, nullable=False)
    name = Column(String(200), nullable=False)
    category = Column(String(100), nullable=False)
    unit = Column(String(50), nullable=False)
    current_stock = Column(Float, default=0.0)
    unit_price = Column(Float, default=0.0)
    is_critical = Column(Boolean, default=False, nullable=False)
    reorder_threshold = Column(Float, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    transactions = relationship("InventoryTransaction", back_populates="product")
    b2b_items = relationship("B2BOrderItem", back_populates="product")
    reorder_requests = relationship("ReorderRequest", back_populates="product")


class InventoryTransaction(Base):
    __tablename__ = "inventory_transactions"

    id = Column(String(36), primary_key=True)
    product_id = Column(String(36), ForeignKey("products.id"), nullable=False)
    type = Column(Enum(TransactionType), nullable=False)
    quantity = Column(Float, nullable=False)
    reference_type = Column(Enum(ReferenceType), nullable=False)
    reference_id = Column(String(100), nullable=True)
    receipt_path = Column(String(500), nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    product = relationship("Product", back_populates="transactions")


class B2BOrder(Base):
    __tablename__ = "b2b_orders"

    id = Column(String(36), primary_key=True)
    customer_name = Column(String(200), nullable=False)
    customer_phone = Column(String(20), nullable=True)
    status = Column(Enum(OrderStatus), default=OrderStatus.PENDING, nullable=False)
    total_amount = Column(Float, default=0.0)
    receipt_path = Column(String(500), nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    items = relationship("B2BOrderItem", back_populates="order")


class B2BOrderItem(Base):
    __tablename__ = "b2b_order_items"

    id = Column(String(36), primary_key=True)
    order_id = Column(String(36), ForeignKey("b2b_orders.id"), nullable=False)
    product_id = Column(String(36), ForeignKey("products.id"), nullable=False)
    quantity = Column(Float, nullable=False)
    unit_price = Column(Float, nullable=False)
    subtotal = Column(Float, nullable=False)

    order = relationship("B2BOrder", back_populates="items")
    product = relationship("Product", back_populates="b2b_items")


class VendorJobWork(Base):
    __tablename__ = "vendor_job_works"

    id = Column(String(36), primary_key=True)
    vendor_name = Column(String(200), nullable=False)
    status = Column(
        Enum(VendorJobStatus), default=VendorJobStatus.ISSUED, nullable=False
    )
    issued_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)
    receipt_path = Column(String(500), nullable=True)
    notes = Column(Text, nullable=True)

    items = relationship("VendorJobWorkItem", back_populates="job_work")


class VendorJobWorkItem(Base):
    __tablename__ = "vendor_job_work_items"

    id = Column(String(36), primary_key=True)
    job_work_id = Column(String(36), ForeignKey("vendor_job_works.id"), nullable=False)
    item_type = Column(String(20), nullable=False)
    product_id = Column(String(36), ForeignKey("products.id"), nullable=False)
    quantity = Column(Float, nullable=False)

    job_work = relationship("VendorJobWork", back_populates="items")
    product = relationship("Product")


class ReorderRequest(Base):
    __tablename__ = "reorder_requests"

    id = Column(String(36), primary_key=True)
    product_id = Column(String(36), ForeignKey("products.id"), nullable=False)
    quantity = Column(Float, nullable=False)
    supplier_name = Column(String(200), nullable=True)
    status = Column(Enum(ReorderStatus), default=ReorderStatus.PENDING, nullable=False)
    notes = Column(Text, nullable=True)
    receipt_path = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    received_at = Column(DateTime, nullable=True)

    product = relationship("Product", back_populates="reorder_requests")


class DailyReport(Base):
    __tablename__ = "daily_reports"

    id = Column(String(36), primary_key=True)
    report_date = Column(Date, unique=True, nullable=False)
    summary = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
