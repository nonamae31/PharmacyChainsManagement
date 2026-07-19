# Hướng Dẫn Kiểm Thử (Test Guide) - Tính Năng Doanh Thu Chi Nhánh (Branch Revenue)

Tài liệu này tổng hợp các kịch bản kiểm thử (Unit Test) cho luồng Xem Doanh Thu (View Revenue), đảm bảo hệ thống tính toán và hiển thị đúng doanh thu theo chuẩn.

## 1. Luồng Xem Doanh Thu (View Revenue)

### A. Tầng Presentation (`BranchRevenueBloc`)
- **Đường dẫn**: `test/features/branch_revenue/control/branch_revenue_bloc_test.dart`
- **Kịch bản kiểm thử**:
  - `HP-01 (Happy Path)`: Emit `[Loading, LoadSuccess]` khi gọi API thành công, mang theo dữ liệu DTO doanh thu tổng hợp.
  - `SP-01 (Sad Path)`: Emit `[Loading, LoadFailure]` với thông báo lỗi từ server khi backend ném `BranchManagerAppException` (400, 401, 500...).
  - `EH-01 (Exception Handling)`: Emit `[Loading, LoadFailure]` với thông báo mặc định thân thiện khi xảy ra lỗi ngoài ý muốn (Unknown Exception).
  - `EP/BVA (Equivalence Partitioning & Boundary Value Analysis)`: Kiểm tra trường hợp truyền tham số `period = 'custom'` cùng với `fromDate` và `toDate`, đảm bảo BLoC truyền đúng giá trị thời gian xuống tầng API thay vì bỏ qua.

### B. Tầng Data (`BranchRevenueApiClient`)
- **Đường dẫn**: `test/features/branch_revenue/network/branch_revenue_api_client_test.dart`
- **Ghi chú kỹ thuật**: Đã gỡ bỏ từ khóa `final` khỏi lớp `BranchManagerApiClientBase` để cho phép `mocktail` can thiệp (intercept) và tiêm Mock Dio giả lập response mà không cần gọi mạng thật.
- **Kịch bản kiểm thử**:
  - `HP-01`: Parse thành công một JSON object khổng lồ từ API thành entity `BranchRevenueDto` bao gồm các mảng danh mục con, payment methods.
  - `EP/BVA`: Đảm bảo tham số `DateTime` (ví dụ `2023-05-02`) được format chuẩn thành String dạng `yyyy-MM-dd` trước khi append vào query của URL.
  - `SP-01`: Quăng lỗi `BranchManagerServerException` ngược lên trên nếu base client gặp sự cố.
  - `EG-01 (Error Guessing)`: Xử lý an toàn khi gửi thiếu một field thời gian tùy chọn (vd: chỉ có `fromDate` mà không có `toDate`).

---

## Tổng kết
Luồng xem doanh thu (View Revenue) đã được bảo vệ tuyệt đối thông qua **8 kịch bản unit test** (áp dụng đúng kỹ thuật AAA - Arrange/Act/Assert, BVA, và Error Guessing).
