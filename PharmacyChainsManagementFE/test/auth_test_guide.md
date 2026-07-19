# Hướng Dẫn Kịch Bản Kiểm Thử (Unit Test Guide) - Auth Module

Tài liệu này tổng hợp cấu trúc, danh sách kịch bản kiểm thử (Test Cases) và cách chạy Unit Test cho luồng **Xác thực và Đăng nhập (Auth)**. Các kịch bản được xây dựng dựa trên chuẩn ISTQB (State Transition Testing, Error Guessing, Use Case Testing).

---

## 1. Hướng Dẫn Chạy Test

Để chạy toàn bộ các bài test cho luồng đăng nhập (Auth), hãy mở terminal tại thư mục gốc của frontend (`PharmacyChainsManagementFE`) và chạy lệnh sau:

```bash
# Chạy Test cho Auth BLoC (Logic chuyển trạng thái)
flutter test test/features/auth/control/auth_bloc_test.dart

# Chạy Test cho Auth Entity/DTOs
flutter test test/features/auth/auth_test.dart
```

---

## 2. Luồng Đăng Nhập (Login Flow)

### A. Tầng Logic/Presentation (`AuthBloc`)
- **Đường dẫn**: `test/features/auth/control/auth_bloc_test.dart`
- **Kịch bản kiểm thử**:
  - `ST-V1 (State Transition - Valid)`: Xác nhận BLoC phát ra trạng thái `[AuthLoading, AuthAuthenticated]` khi gọi API `LoginRequested` thành công.
  - `ST-V2 (State Transition - Invalid/Sad Path)`: Xác nhận BLoC phát ra trạng thái `[AuthLoading, AuthError]` khi gọi API bị lỗi hoặc server trả về Exception (VD: Unauthorized).
  - `UC-HP (Use Case - Happy Path)`: Luồng đăng nhập bằng sinh trắc học thành công (Biometric Login).
  - `UC-AP1 (Use Case - Alternative Path)`: Xử lý khi người dùng ấn hủy đăng nhập sinh trắc học (User cancels authentication).
  - `UC-EP1 (Use Case - Exception Path)`: Xử lý mượt mà khi thiết bị không hỗ trợ tính năng bảo mật sinh trắc học.
  - `EG-01 (Error Guessing)`: Thử nghiệm truyền chuỗi email và password rỗng (`""`), đảm bảo hệ thống không bị crash và phát lỗi an toàn.
  - `EG-02 (Error Guessing)`: Xử lý Timeout Exception từ phía server khi đang đăng nhập.

### B. Tầng Model/Entity (`LoginRequestDto` & `AuthResultDto`)
- **Đường dẫn**: `test/features/auth/auth_test.dart`
- **Kịch bản kiểm thử**:
  - Đảm bảo `LoginRequestDto.toJson()` mapping chính xác trường `email` và `password`.
  - Khẳng định `AuthResultDto.fromJson()` đọc chuẩn xác JWT `accessToken`, `refreshToken`, `userId`, `role`.
  - Kiểm tra khả năng xử lý fallback mượt mà: Có thể bóc tách Payload từ JSON chuẩn hoặc bóc tách lớp JSON lồng nhau khi có định dạng đặc biệt (Nested role and user schema).
