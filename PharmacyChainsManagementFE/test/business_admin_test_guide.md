# Hướng Dẫn Kịch Bản Kiểm Thử (Unit Test Guide) - Business Admin

Tài liệu này tổng hợp cấu trúc, danh sách kịch bản kiểm thử (Test Cases) và cách chạy Unit Test cho 2 luồng: **Tạo mới (Create)** và **Cập nhật (Update)** Business Admin. Các kịch bản được xây dựng dựa trên chuẩn ISTQB (Equivalence Partitioning, Boundary Value Analysis, Error Guessing, State Transition Testing).

---

## 1. Hướng Dẫn Chạy Test

Để chạy toàn bộ các bài test cho 2 luồng này, hãy mở terminal tại thư mục gốc của frontend (`PharmacyChainsManagementFE`) và chạy lệnh sau:

```bash
# Chạy Test cho luồng Create
flutter test test/features/founder_admin/presentation/cubit/create_admin_cubit_test.dart
flutter test test/features/founder_admin/data/repositories/business_admin_repository_impl_create_test.dart

# Chạy Test cho luồng Update
flutter test test/features/founder_admin/presentation/cubit/business_admin_edit_cubit_test.dart
flutter test test/features/founder_admin/domain/usecases/update_business_admin_usecase_test.dart
flutter test test/features/founder_admin/data/repositories/business_admin_repository_impl_update_test.dart
```

---

## 2. Luồng Tạo Mới (Create Business Admin)

### A. Tầng Presentation (`CreateAdminCubit`)
- **Đường dẫn**: `test/features/founder_admin/presentation/cubit/create_admin_cubit_test.dart`
- **Kịch bản kiểm thử**:
  - `ST-V1 (Happy Path)`: Xác nhận Cubit phát ra trạng thái `[Loading, Success]` khi Repository xử lý thành công.
  - `ST-V2 (Sad Path)`: Xác nhận Cubit phát ra trạng thái `[Loading, Failure]` khi API báo lỗi (VD: trùng email/SĐT).
  - `ST-I1 (Concurrency Guard)`: Chống spam click. Nếu state hiện tại đang là `Loading`, bỏ qua request tiếp theo.
  - `EP/BVA`: Tự động cắt bỏ khoảng trắng (trim) dư thừa ở các trường nhập liệu trước khi gửi xuống Repository.
  - `EG-01 (Error Guessing)`: Xử lý mượt mà và an toàn khi người dùng cố tình gửi chuỗi rỗng (`""`).

### B. Tầng Data (`BusinessAdminRepositoryImpl`)
- **Đường dẫn**: `test/features/founder_admin/data/repositories/business_admin_repository_impl_create_test.dart`
- **Ghi chú kỹ thuật**: Đã refactor repository để có thể Inject (tiêm) `Dio` thông qua constructor. Việc này cho phép dùng thư viện `mocktail` giả lập các HTTP response thay vì gọi API thực.
- **Kịch bản kiểm thử**:
  - `HP-01`: Xử lý đúng khi API trả về mã `200 Success`.
  - `SP-01 / SP-02`: Đọc và ném ra Exception có chứa lỗi từ server khi gặp mã `400` hoặc ném lỗi mặc định với mã `500`.
  - `EH-01 -> EH-03`: Mô phỏng các lỗi mạng `DioException` (Timeout, Connection Error, Conflict 409, FormatException).
  - `EG-01 / EG-02`: Đảm bảo API client gọi đúng JSON Payload ngay cả khi đầu vào là chuỗi tải trọng cực lớn (Large payload) hoặc chứa Emoji, ký tự đặc biệt Unicode.

---

## 3. Luồng Cập Nhật (Update Business Admin)

### A. Tầng Presentation (`BusinessAdminEditCubit`)
- **Đường dẫn**: `test/features/founder_admin/presentation/cubit/business_admin_edit_cubit_test.dart`
- **Kịch bản kiểm thử**:
  - `ST-V1 (Happy Path)`: Emit `[Loading, Success]` khi UpdateUseCase trả về `Right(null)`.
  - `ST-V2 / ST-V3 (Sad Path)`: Emit `[Loading, Error]` khi UpdateUseCase trả về `Left(Failure)` hoặc bất ngờ ném văng Exception mã nguồn.
  - `ST-I1 (Concurrency Guard)`: Bỏ qua request mới nếu đang `Loading`.
  - `EP/BVA`: Trim khoảng trắng ở tên, email, sđt. `ID` của user không cần trim nhưng vẫn được bảo toàn.

### B. Tầng Domain (`UpdateBusinessAdminUseCase`)
- **Đường dẫn**: `test/features/founder_admin/domain/usecases/update_business_admin_usecase_test.dart`
- **Kịch bản kiểm thử**:
  - `HP-01`: Xác nhận UseCase gọi đúng method `updateBusinessAdmin` của Repository và truyền đúng `BusinessAdminRequestModel`.
  - `EP/BVA (Boundary)`: Phân tích đường biên an toàn - Nếu UI không truyền `email` (null param), UseCase sẽ ép kiểu về `""` an toàn khi map qua RequestModel.
  - `SP-01`: Đẩy lỗi `Left(ServerFailure)` về đúng cho Cubit nếu Repository gặp lỗi.

### C. Tầng Data (`BusinessAdminRepositoryImpl`)
- **Đường dẫn**: `test/features/founder_admin/data/repositories/business_admin_repository_impl_update_test.dart`
- **Kịch bản kiểm thử**:
  - `HP-01 / HP-02`: Nhận diện thành công với cả response `HTTP 200` và `HTTP 204 (No Content)`.
  - `SP-01 / SP-02`: Map thành công các HTTP status > 400 thành object `ServerFailure` (tránh ném thẳng exception làm văng app).
  - `EH-01 -> EH-03`: Che chắn hoàn toàn các lỗi mạng `DioException` và `Exception` cục bộ.
  - `EG-01 (Error Guessing)`: Kiểm thử thử thách với tham số `ID` rỗng (`""`), xác nhận mã nguồn không bị treo và handle được việc API trả 404 (Route not found).

---

## 4. Luồng Xem Danh Sách (View Business Admin)

### A. Tầng Presentation (`BusinessAdminCubit`)
- **Đường dẫn**: `test/features/founder_admin/presentation/cubit/business_admin_cubit_test.dart`
- **Kịch bản kiểm thử**:
  - `ST-V1 (Happy Path)`: Xác nhận phát ra trạng thái `[Loading, Loaded]` khi fetch dữ liệu thành công.
  - `ST-V2 (Sad Path)`: Phát ra `[Loading, Error]` khi quá trình fetch gặp lỗi từ Data Layer.
  - `DT-01 -> DT-03 (Decision Table)`: Xác nhận bộ lọc (Filter) danh sách hoạt động chính xác tương ứng với 3 trạng thái: `Active`, `Deactivated`, `All`.
  - `ST-I1`: Trạng thái bị block không filter nếu state chưa `Loaded`.

### B. Tầng Data (`BusinessAdminRepositoryImpl`)
- **Đường dẫn**: `test/features/founder_admin/data/repositories/business_admin_repository_impl_view_test.dart`
- **Kịch bản kiểm thử**:
  - `HP-01 -> HP-03 (Happy Path & Caching)`: Cơ chế cache dùng `FlutterSecureStorage`. Gọi API khi cache trống hoặc khi được yêu cầu `forceRefresh`, và trả về dữ liệu mượt mà từ Cache nếu có.
  - `SP-01 / EH-01`: Xử lý HTTP status lỗi hoặc `DioException` mạng từ quá trình get danh sách.
  - `EG-01 / EG-02 (Error Guessing)`: Fallback an toàn (tự động call API) nếu chuỗi JSON lưu trong cache bị hỏng, và xử lý mượt mà khi mảng trả về là trống `[]`.

---

## Tổng kết

Các luồng tạo và cập nhật Business Admin đã được che chắn tuyệt đối thông qua **31 kịch bản unit test** (bao gồm cả Phase tạo file test chung). Nếu có nhu cầu thay đổi field (VD: thêm Address, cmnd...), Developer bắt buộc phải sửa đổi lại các file Test Model tương ứng trong thư mục này trước khi đưa vào Production.
