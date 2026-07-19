class AppStrings {
  AppStrings._();

  static const String appTitle = 'Pharmacy Chains Management';

  // Business Admin
  static const String businessAdminDashboard = 'Business Admin';
  static const String profile = 'Profile';
  static const String branchManagement = 'Branches';
  static const String medicineStatistics = 'Medicine Statistics';
  static const String businessAnalysisReport = 'Business Report';
  static const String forgotPassword = 'Forgot Password';
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String saveChanges = 'Save Changes';
  static const String refresh = 'Refresh';
  static const String exportCsv = 'Export CSV';
  static const String exportPdf = 'Export PDF';
  static const String exportExcel = 'Export Excel';
  static const String search = 'Search';
  static const String retry = 'Retry';
  static const String noData = 'No data';
  static const String notAvailable = 'N/A';
  static const String sessionExpired = 'Your session has expired.';

  // Inventory Generic
  static const String inventoryDashboard = 'Inventory Dashboard';
  static const String receiveGoods = 'Receive Goods';
  static const String issueStock = 'Issue Stock';
  static const String stocktake = 'Stocktake';
  static const String approveTransfer = 'Approve Transfer';
  static const String recallBatch = 'Recall Batch';
  static const String batchTraceability = 'Batch Traceability';
  static const String valuation = 'Valuation';
  static const String lowStockAlerts = 'Low Stock Alerts';

  // Common UI
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String submit = 'Submit';
  static const String close = 'Close';
  static const String confirm = 'Confirm';

  // Staff attendance
  static const String attendanceTitle = 'Attendance';
  static const String attendanceSubtitle =
      'Review your schedule and record today\'s attendance.';
  static const String attendanceStatus = 'Status';
  static const String attendanceCheckInTime = 'Check-in time';
  static const String attendanceCheckOutTime = 'Check-out time';
  static const String attendanceCheckIn = 'Check in';
  static const String attendanceNotCheckedIn = 'Not checked in';
  static const String attendanceCheckedInShort = 'Present';
  static const String attendanceCheckInSuccess =
      'Attendance recorded successfully.';
  static const String attendancePreviousPeriod = 'Previous period';
  static const String attendanceNextPeriod = 'Next period';
  static const List<String> attendanceWeekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  // Staff sales QR payment
  static const String qrPayment = 'Bank transfer via QR';
  static const String qrPaymentDescription =
      'Scan with a supported mobile banking application';
  static const String generatePaymentQr = 'Generate payment QR';
  static const String paymentQrTitle = 'Scan to pay';
  static const String waitingForPayment = 'Waiting for payment';
  static const String paymentPaid = 'Payment successful';
  static const String paymentExpired = 'QR code expired';
  static const String paymentFailed = 'Payment failed';
  static const String paymentAmountMismatch =
      'Transferred amount does not match';
  static const String bank = 'Bank';
  static const String accountName = 'Account name';
  static const String accountNumber = 'Account number';
  static const String transferAmount = 'Transfer amount';
  static const String transferContent = 'Transfer content';
  static const String expiresIn = 'Expires in';
  static const String refreshStatus = 'Refresh status';
  static const String regenerateQr = 'Regenerate QR';
  static const String copyTransferContent = 'Copy transfer content';
  static const String transferContentCopied = 'Transfer content copied.';
  static const String qrLoadFailure = 'Unable to load the payment QR code.';
  static const String qrAutomaticVerification =
      'Payment status is verified automatically and securely.';
  static const String checkingPaymentStatus = 'Checking payment status...';

  // Staff sales invoice
  static const String invoiceGeneration = 'Invoice generation';
  static const String invoiceGenerationDescription =
      'Create an invoice with one or more medicines supplied by this branch.';
  static const String invoiceMedicines = 'Invoice medicines';
  static const String addMedicine = 'Add medicine';
  static const String selectMedicine = 'Select medicine';
  static const String searchMedicine = 'Search by medicine name';
  static const String medicine = 'Medicine';
  static const String category = 'Category';
  static const String unit = 'Unit';
  static const String quantity = 'Quantity';
  static const String unitPrice = 'Unit price';
  static const String itemTotal = 'Item total';
  static const String availableStock = 'Available stock';
  static const String action = 'Action';
  static const String choose = 'Choose';
  static const String removeMedicine = 'Remove medicine';
  static const String noMedicinesAdded =
      'No medicines added. Select Add medicine to begin.';
  static const String noMedicinesFound = 'No medicines found.';
  static const String invoiceSummary = 'Invoice summary';
  static const String selectedItems = 'Selected items';
  static const String subtotal = 'Subtotal';
  static const String generateInvoice = 'Generate invoice';
  static const String invoiceDetails = 'Invoice details';
  static const String invoiceDetailsDescription =
      'Review invoice information and itemized medicines.';
  static const String viewDetails = 'View details';
  static const String backToInvoices = 'Back to invoices';
  static const String invoiceCode = 'Invoice code';
  static const String invoiceDate = 'Invoice date';
  static const String paymentStatus = 'Payment status';
  static const String invoiceStatus = 'Invoice status';
  static const String batchNumber = 'Batch';
  static const String totalAmount = 'Total amount';
  static const String invoiceRequiresMedicine =
      'Add at least one medicine before generating the invoice.';
  static const String invalidMedicineQuantity =
      'Quantity must be a whole number greater than zero.';
  static const String insufficientMedicineStock =
      'Quantity exceeds the available stock.';

  // Error Messages
  static const String unknownError = 'An unknown error occurred.';
  static const String networkError = 'Network connection issue.';
  static const String unauthorizedError =
      'Session expired. Please log in again.';

  // Auth & Forgot Password
  static const String forgotPasswordTitle = 'Quên mật khẩu?';
  static const String forgotPasswordSubtitle =
      'Nhập email của bạn để nhận mã xác nhận (OTP) đặt lại mật khẩu.';
  static const String emailLabel = 'Email cá nhân / công việc';
  static const String emailHint = 'phanmanh14122000@gmail.com';
  static const String sendOtpButton = 'Gửi Mã Xác Nhận';
  static const String otpLabel = 'Mã xác nhận OTP (6 chữ số)';
  static const String otpHint = 'Nhập 6 chữ số từ email';
  static const String newPasswordLabel = 'Mật khẩu mới';
  static const String newPasswordHint = 'Ít nhất 6 ký tự';
  static const String confirmPasswordLabel = 'Xác nhận mật khẩu mới';
  static const String confirmPasswordHint = 'Nhập lại mật khẩu mới';
  static const String resetPasswordButton = 'Xác Nhận Đổi Mật Khẩu';
  static const String otpSentSuccess =
      'Mã OTP đã được gửi! Vui lòng kiểm tra hộp thư đến hoặc thư rác.';
  static const String passwordResetSuccess =
      'Đổi mật khẩu thành công! Bạn có thể đăng nhập ngay.';
}
