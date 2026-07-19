# Hướng Dẫn Unit Test: Luồng Export Financial/Revenue Report

## Mục Đích
Tài liệu này cung cấp hướng dẫn và các kịch bản kiểm thử (Test Scenarios) theo chuẩn ISTQB (áp dụng skill `flutter-unit-test-generator`) cho tính năng xuất báo cáo doanh thu/tài chính (Export Revenue Report) sang định dạng CSV, PDF, v.v.

Các thành phần được kiểm thử (SUT) bao gồm:
1. `ExportCriteriaModel` (Data Layer - Model)
2. `FinancialRepositoryImpl` (Data Layer - Repository)
3. `ExportFinancialReportUseCase` (Domain Layer - UseCase)
4. `FinancialExportCubit` (Presentation Layer - Cubit)

---

## Các Kịch Bản Kiểm Thử (Test Scenarios)

### 1. ExportCriteriaModel
**Kỹ thuật áp dụng**: Equivalence Partitioning (EP), Boundary Value Analysis (BVA), Error Guessing.

- **Happy Path:**
  - Tạo model từ JSON hợp lệ và đảm bảo các trường (`branchId`, `startDate`, `endDate`, `format`) được parse chính xác.
  - Test phương thức `toJson()` đảm bảo đầu ra map JSON chính xác, với định dạng ngày tháng `toIso8601String()` chuẩn UTC.
- **Boundary/Error Cases:**
  - Thiếu các trường bắt buộc (thiếu `branchId`, `format`, v.v.).
  - Map rỗng (`{}`).
  - Kiểm tra tính năng upper-case tự động của trường `format` khi convert ra JSON (ví dụ: `csv` -> `CSV`).
- **Equality:**
  - Hai đối tượng với cùng dữ liệu phải bằng nhau.
  - Hai đối tượng có dữ liệu khác biệt phải không bằng nhau.

**Đường dẫn file test**: `test/features/finance/data/models/export_criteria_model_test.dart`

### 2. FinancialRepositoryImpl
**Kỹ thuật áp dụng**: Error Guessing, State Transition / HTTP Mocks, Equivalence Partitioning.

- **Happy Path:**
  - Khi gọi `exportFinancialReport`, HTTP call thành công (HTTP 200) trả về body dạng byte array (`List<int>`), repository trả về `Right(Uint8List)`.
- **Sad/Exception Paths:**
  - Lỗi `404 Not Found`: Trả về `ServerFailure('No Data Found')`.
  - Lỗi `500 Internal Server Error`: Trả về `ServerFailure('Generation Failed')`.
  - Có lỗi cấu trúc trả về từ Server trong `DioException`: Bắt và bóc tách nội dung lỗi `utf8` để trả về message tương ứng qua `ServerFailure`.
  - Exception không xác định: Trả về `ServerFailure` mang generic error.

**Đường dẫn file test**: `test/features/finance/data/repositories/financial_repository_impl_test.dart`

### 3. ExportFinancialReportUseCase
**Kỹ thuật áp dụng**: Use Case Testing, Equivalence Partitioning.

- **Happy Path:**
  - Gọi Repository để lấy file bytes, trả về `Right(Uint8List)` khi repo thành công.
- **Sad Path:**
  - Repository trả về `Left(Failure)`, UseCase chuyển tiếp kết quả này.

**Đường dẫn file test**: `test/features/finance/domain/usecases/export_financial_report_usecase_test.dart`

### 4. FinancialExportCubit
**Kỹ thuật áp dụng**: State Transition, Error Guessing.

- **Initial State:**
  - Trạng thái khởi tạo bắt buộc phải là `FinancialExportInitial`.
- **Happy Path Transition:**
  - Gọi `exportReport(criteria)`.
  - Expect: Phát ra `[FinancialExportLoading, FinancialExportSuccess]`.
- **Sad Path Transition:**
  - Gọi `exportReport(criteria)` nhưng UseCase thất bại.
  - Expect: Phát ra `[FinancialExportLoading, FinancialExportError]`.

**Đường dẫn file test**: `test/features/finance/presentation/cubit/financial_export_cubit_test.dart`

---

## Hướng Dẫn Chạy Test

Để chạy bộ Unit Test này và kiểm tra chất lượng (Coverage), hãy dùng lệnh:

```bash
# Chạy tất cả test cho module finance
flutter test test/features/finance/

# Kiểm tra độ bao phủ (Coverage) - Đảm bảo đạt ngưỡng >80% Line Coverage
flutter test test/features/finance/ --coverage
```
