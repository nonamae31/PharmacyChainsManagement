namespace PharmacyChainsManagementBE.Models;

public enum GeneralStatus { ACTIVE = 1, INACTIVE = 2, DELETED = 3 }
public enum QcStatus { PENDING = 1, APPROVED = 2, REJECTED = 3, EXPIRED = 4, DAMAGED = 5 }
public enum OrderStatus { PENDING = 1, APPROVED = 2, REJECTED = 3, COMPLETED = 4, CANCELLED = 5 }
public enum PrescriptionStatus { ACTIVE = 1, CANCELLED = 2, COMPLETED = 3 }
public enum InvoicePaymentStatus { UNPAID = 1, PAID = 2, FAILED = 3, REFUNDED = 4 }
public enum InvoiceStatus { ACTIVE = 1, CANCELLED = 2 }
public enum PaymentTransactionStatus { PENDING = 1, PAID = 2, FAILED = 3, DECLINED = 4, CANCELLED = 5 }
public enum ReportStatus { PENDING = 1, GENERATED = 2, FAILED = 3 }
