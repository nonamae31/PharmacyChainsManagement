# Hướng Dẫn Kiểm Thử (Test Guide) - Tính Năng Thống Kê Dòng Tiền (Cash Flow)

Tài liệu này tổng hợp các kịch bản kiểm thử (Unit Test) cho luồng Xem Thống kê Dòng tiền (Cash Flow), đảm bảo dữ liệu được hiển thị, 캐che (lưu tạm) chính xác và bắt lỗi logic hợp lý.

## 1. Luồng Lấy Thống Kê Dòng Tiền (Get Cash Flow)

### A. Tầng Presentation (`CashFlowBloc`)
- **Đường dẫn**: `test/features/cash_flow/presentation/bloc/cash_flow_bloc_test.dart`
- **Ghi chú kỹ thuật**: BLoC này điều phối đồng thời 2 Use Cases: `GetCashFlowUseCase` và `GetBranches`.
- **Kịch bản kiểm thử**:
  - `HP-01 (Happy Path)`: Khi 2 Use Case đều thành công, BLoC ngay lập tức emit `[Loading, Loaded]` chứa đầy đủ `cashFlow` và `branches`.
  - `SP-01 (Sad Path)`: Nếu `GetCashFlowUseCase` bắn Exception (VD: Server error), BLoC lập tức nhảy vào `catch` block và emit trạng thái `CashFlowError`.
  - `EP/BVA (Equivalence Partitioning & Boundary Value Analysis)`: Chốt an toàn Logic - Cố tình gửi `startDate` (2023-12-31) lớn hơn `endDate` (2023-01-01), BLoC phải đủ thông minh để chặn đứng ngay lập tức bằng lỗi "Start date cannot be after end date" MÀ KHÔNG GỌI Use Case nào hết để tránh lãng phí tài nguyên.

### B. Tầng Data (`CashFlowRepositoryImpl`)
- **Đường dẫn**: `test/features/cash_flow/data/repositories/cash_flow_repository_impl_test.dart`
- **Ghi chú kỹ thuật**: Tầng này được thiết kế với cơ chế Offline-First/Cache-Fallback sử dụng `FlutterSecureStorage` để lưu đệm chuỗi JSON phòng khi mất mạng.
- **Kịch bản kiểm thử**:
  - `HP-01`: Gọi API thành công thông qua `CashFlowRemoteDataSource`, sau đó Repository lập tức `jsonEncode` model này và lưu vào Secure Storage làm dự phòng, trả về dữ liệu chuẩn.
  - `SP-01 (Cache Fallback)`: Chặn đường mạng (giả lập API throw Exception), Repository lập tức quét `FlutterSecureStorage` để lôi Data cũ ra xài tạm. Người dùng vẫn xem được báo cáo cũ mà không bị gián đoạn (offline mode).
  - `SP-02 (Absolute Failure)`: Chặn đường mạng và Cache cũng RỖNG (null). Trường hợp này Repository bắt buộc phải quăng `Exception` ngược lên trên cho BLoC xử lý, đảm bảo ứng dụng không sụp đổ.

---

## Tổng kết
Luồng xem thống kê dòng tiền (Cash Flow) đã được bảo vệ thông qua **7 kịch bản unit test** trải dài từ Presentation (Bloc) xuống Data (Repository). Điểm đặc biệt của luồng này là kiểm thử chặt chẽ khả năng **Cache Fallback (Chống mất mạng)** ở tầng Data, và khả năng chặn điều kiện cực biên ở tầng Bloc.
