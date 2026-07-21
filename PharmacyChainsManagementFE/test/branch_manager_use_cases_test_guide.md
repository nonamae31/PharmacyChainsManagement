# Hướng dẫn Unit Test các luồng Branch Manager

Tài liệu này mô tả bộ unit test Flutter cho các use case **UC09, UC10, UC32, UC33 và UC36**. Các test sử dụng `bloc_test` và `mocktail`; không kết nối API, Supabase hoặc database thật.

Các số liệu trong test chỉ là **fixture cô lập** để xác nhận phép ánh xạ và chuyển trạng thái. Đây không phải dữ liệu được gắn cứng vào mã nguồn ứng dụng.

## 1. Cách chạy

Mở terminal tại thư mục `PharmacyChainsManagementFE`:

```powershell
# Chạy toàn bộ test Branch Manager
flutter test test/features/branch_dashboard test/features/branch_revenue test/features/staff_performance test/features/branch_inventory

# Chạy từng nhóm
flutter test test/features/branch_dashboard/control/branch_dashboard_bloc_test.dart
flutter test test/features/branch_revenue/control/branch_revenue_bloc_test.dart
flutter test test/features/staff_performance/control/staff_performance_bloc_test.dart
flutter test test/features/branch_inventory/control/branch_inventory_bloc_test.dart

# Sinh báo cáo coverage
flutter test --coverage test/features/branch_dashboard test/features/branch_revenue test/features/staff_performance test/features/branch_inventory
```

## 2. SUT Analysis

| Use case | System Under Test | Loại | Dependency được mock |
|---|---|---|---|
| UC09 | `BranchDashboardBloc` | BLoC | `BranchDashboardApiClient` |
| UC10 | `BranchRevenueBloc` | BLoC | `BranchRevenueApiClient` |
| UC32 | `StaffPerformanceBloc` | BLoC | `StaffPerformanceApiClient` |
| UC33 | `BranchInventoryBloc` | BLoC | `BranchInventoryApiClient` |
| UC36 | `BranchDashboardBloc` | BLoC | `BranchDashboardApiClient` |

Trạng thái chung được kiểm tra:

```text
Initial -> Loading -> LoadSuccess
Initial -> Loading -> LoadFailure
LoadSuccess -> Operation/Export/ConfirmationSuccess
LoadSuccess -> Operation/Export/ConfirmationFailure
```

## 3. UC09 — View Branch Dashboard

File: `test/features/branch_dashboard/control/branch_dashboard_bloc_test.dart`

Phạm vi:

- Hiển thị doanh thu hôm nay, tỷ lệ thay đổi, nhân viên active/tổng nhân viên, cảnh báo tồn kho và hiệu suất chi nhánh.
- Giữ đầy đủ revenue trend, top staff và inventory alerts từ API.
- Đổi kỳ revenue trend theo `month`, `quarter`, `year`.
- Tìm kiếm nhân viên không phân biệt chữ hoa/thường.
- Bật bộ lọc chỉ cảnh báo `CRITICAL`, sau đó tắt để quay lại toàn bộ dữ liệu.
- Không xử lý search/filter khi dashboard chưa load.
- Xử lý lỗi nghiệp vụ và dữ liệu JSON không hợp lệ.

Kỹ thuật: State Transition, Equivalence Partitioning, Decision Table, Error Guessing, Use Case Testing.

## 4. UC10 — View and Export Branch Revenue Statistics

File: `test/features/branch_revenue/control/branch_revenue_bloc_test.dart`

Phạm vi:

- Load báo cáo theo `daily`, `weekly`, `monthly`, `custom`.
- Giữ đầy đủ tổng doanh thu, số hóa đơn, trend, đóng góp theo category, time block và payment method.
- Boundary custom range: 366 ngày hợp lệ; 367 ngày nhận lỗi validation từ API.
- Export đúng kỳ đang chọn thành CSV bytes.
- Không export khi chưa load báo cáo.
- Không trả file CSV dở dang khi export lỗi.

Lưu ý: điều kiện “paid và non-cancelled invoices” được tính ở backend. Unit test Flutter xác nhận BLoC chỉ hiển thị kết quả đã được API tính và không tự cộng thêm dữ liệu khác.

Kỹ thuật: Equivalence Partitioning, Boundary Value Analysis, State Transition, Error Guessing, Use Case Testing.

## 5. UC32 — Manage Staff and Monitor Performance

File: `test/features/staff_performance/control/staff_performance_bloc_test.dart`

Phạm vi:

- Gửi đúng search/status/sort và load performance của chi nhánh được phân công.
- Load lịch theo tuần, luôn chuẩn hóa ngày chọn về thứ Hai và lấy đến Chủ nhật.
- Tạo tài khoản staff với dữ liệu Unicode hợp lệ.
- Activate/deactivate staff và refresh lại lịch làm sau thao tác.
- Tạo/cập nhật dated shift, gồm lựa chọn áp dụng lịch lặp lại.
- Ghi assessment gồm sales target, rating, attendance, score và notes.
- Giữ dữ liệu đang hiển thị khi một thao tác thất bại.
- Không gọi các API mutation khi dữ liệu màn hình chưa load.

Lưu ý: việc deactivate xóa lịch tuần và hủy ca hiện tại/tương lai là nghiệp vụ backend; test Flutter xác nhận request deactivation được gửi đúng và lịch được tải lại ngay sau khi thành công.

Kỹ thuật: State Transition, Boundary Value Analysis, Decision Table, Error Guessing, Use Case Testing, Classification Tree.

## 6. UC33 — Monitor and Export Branch Inventory

File: `test/features/branch_inventory/control/branch_inventory_bloc_test.dart`

Phạm vi:

- Hiển thị metrics tồn kho, inbound quantity, supplier và inventory value.
- Pairwise search/category/status.
- Boundary phân trang: trang cuối có ít item hơn `pageSize`.
- Nhánh không có inventory vẫn là trạng thái load thành công với danh sách rỗng.
- Export toàn bộ inventory thành CSV bytes.
- Không export trước khi dữ liệu được load và không trả CSV lỗi.
- Xử lý lỗi server và malformed payload.

Kỹ thuật: Pairwise Testing, Boundary Value Analysis, State Transition, Error Guessing, Use Case Testing.

## 7. UC36 — Confirm Daily Revenue

File dùng chung với UC09: `test/features/branch_dashboard/control/branch_dashboard_bloc_test.dart`

Phạm vi:

- Confirm khi actual cash + bank transfer + other khớp system amount.
- Confirm khi chênh lệch và giữ nguyên `differenceReason`.
- Sau confirm phải tải lại dashboard để hiển thị trạng thái đã xác nhận.
- Confirm không làm thay đổi doanh thu hóa đơn trên dashboard.
- Lỗi confirm lần hai được hiển thị từ server.
- Không gửi confirm khi dashboard chưa load.

Lưu ý: quy tắc “mỗi chi nhánh chỉ confirm một lần trong ngày” được bảo vệ ở backend/database. Unit test Flutter mô phỏng lỗi duplicate do API trả về và xác nhận BLoC hiển thị đúng lỗi đó.

Kỹ thuật: Decision Table, State Transition, Error Guessing, Use Case Testing.

## 8. Quy tắc bảo trì test

- Mỗi thay đổi event/state/API của các use case trên phải cập nhật file test tương ứng.
- Không gọi API hoặc database thật trong unit test.
- Không dùng `Future.delayed`; các Future đều được mock trực tiếp.
- Mỗi test phải độc lập và không phụ thuộc thứ tự chạy.
- Khi thêm một trạng thái BLoC mới, bổ sung test cho cả đường thành công và thất bại.
- Chạy `dart format test/features/branch_dashboard test/features/branch_revenue test/features/staff_performance test/features/branch_inventory` trước khi commit.

## 9. Kết quả kiểm tra hiện tại

- Tổng số: **52 test**.
- Kết quả: **52 pass, 0 fail**.
- Dart analyzer: **No issues found**.
- Line coverage của bốn BLoC mục tiêu: **89.27%**.
  - `BranchDashboardBloc`: 97.78%.
  - `BranchRevenueBloc`: 96.77%.
  - `StaffPerformanceBloc`: 81.82%.
  - `BranchInventoryBloc`: 96.77%.
- File coverage: `coverage/branch_manager_lcov.info` (được sinh lại bằng lệnh coverage ở mục 1).
