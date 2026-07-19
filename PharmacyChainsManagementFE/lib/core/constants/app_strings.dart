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

  // Error Messages
  static const String unknownError = 'An unknown error occurred.';
  static const String networkError = 'Network connection issue.';
  static const String unauthorizedError = 'Session expired. Please log in again.';

  // Auth & Forgot Password
  static const String forgotPasswordTitle = 'Quên mật khẩu?';
  static const String forgotPasswordSubtitle = 'Nhập email của bạn để nhận mã xác nhận (OTP) đặt lại mật khẩu.';
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
  static const String otpSentSuccess = 'Mã OTP đã được gửi! Vui lòng kiểm tra hộp thư đến hoặc thư rác.';
  static const String passwordResetSuccess = 'Đổi mật khẩu thành công! Bạn có thể đăng nhập ngay.';
}
