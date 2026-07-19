---
name: pharmacy-chain-flutter-convention
description: >
  Enforcer Coding Convention / Architecture Rules BẮT BUỘC cho dự án "Pharmacy Chain
  Management" (Flutter + Dart + BLoC, kết nối Backend ASP.NET Core RESTful JSON).
  Kích hoạt BẮT BUỘC VÀ NGAY LẬP TỨC mỗi khi Coder Agent (Cursor, Cline, AutoGen,
  CrewAI, hoặc bất kỳ AI Agent nào) chuẩn bị: tạo Screen/Widget mới, viết Bloc/Event/State,
  map DTO từ response JSON, tạo ApiClient mới, sửa flow gọi API, refactor UI, hoặc bất
  kỳ file `.dart` nào trong project. Áp dụng cho MỌI module: Auth, Inventory, POS/Sales,
  Prescription, Customer, Chain/Store Management. KHÔNG được bỏ qua skill này dù task
  chỉ là "sửa 1 dòng", "thêm nút", "fix lỗi UI nhỏ" — mọi thay đổi code Dart trong dự án
  này đều phải đi qua bộ luật trong skill này trước khi coi là hoàn thành.
---

# 💊 PHARMACY CHAIN MANAGEMENT — FLUTTER CONVENTION ENFORCER
## Coding Standard · Architecture Rules · Style Guide (BLoC Edition)

---

## 🎯 A. TỔNG QUAN (OVERVIEW & GOAL)

**Mục đích:** Skill này là **Single Source of Truth (SSOT)** cho mọi quy ước code Flutter/Dart
trong dự án Pharmacy Chain Management. Nó tồn tại vì dự án được code bởi **nhiều AI Coder
Agent khác nhau** (Cursor, Cline, AutoGen, CrewAI...) tại nhiều thời điểm khác nhau — nếu
không có một bộ luật cứng, mỗi Agent sẽ "sáng tạo" theo phong cách riêng, dẫn tới codebase
không đồng nhất, khó bảo trì, và dễ sinh bug khi tích hợp giữa các module (Auth, Inventory,
POS, Prescription...).

**Khi nào PHẢI đọc skill này** (không có ngoại lệ):
- Trước khi tạo bất kỳ Screen, Widget, hoặc file UI mới.
- Trước khi viết Bloc, Event, State, hoặc Cubit mới.
- Trước khi tạo hoặc chỉnh sửa ApiClient / DTO map dữ liệu từ Backend ASP.NET Core.
- Trước khi refactor code cũ (kể cả chỉ đổi tên biến).
- Trước khi quyết định cấu trúc thư mục cho một feature mới.

**Nguyên tắc cốt lõi:** *"Code sinh ra bởi Agent A phải trông như thể được viết bởi Agent B,
cùng ngày, cùng convention, không cách nào phân biệt được."*

```
╔══════════════════════════════════════════════════════════════════╗
║              KHÔNG CÓ NGOẠI LỆ — KHÔNG CÓ "TẠM THỜI"            ║
║   Mọi vi phạm convention, dù nhỏ, đều phải bị coi là code lỗi.  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## 🔤 B. QUY ƯỚC ĐẶT TÊN (NAMING CONVENTIONS)

### B.1 — File & Thư mục: `snake_case`

| Loại | Ví dụ ĐÚNG | Ví dụ SAI |
|---|---|---|
| File Dart | `login_screen.dart` | `LoginScreen.dart`, `loginScreen.dart` |
| File Bloc | `inventory_bloc.dart` | `InventoryBloc.dart` |
| Thư mục feature | `prescription_management/` | `PrescriptionManagement/` |

### B.2 — Class, Enum, Typedef: `PascalCase`

```dart
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> { ... }
enum StockStatus { inStock, lowStock, outOfStock }
typedef OnDrugSelected = void Function(DrugDto drug);
```

### B.3 — Biến, hàm, instance: `camelCase`

```dart
final drugRepository = DrugRepository();
void fetchLowStockDrugs() { ... }
```

### B.4 — Hậu tố BẮT BUỘC theo layer (MUST — không được đặt tên khác đi)

| Hậu tố | Layer | Ví dụ |
|---|---|---|
| `...Screen` | Boundary (UI trang) | `PrescriptionListScreen` |
| `...Bloc` | Control (business logic) | `AuthBloc`, `InventoryBloc` |
| `...Event` | Control (input vào Bloc) | `InventoryFetchRequested` |
| `...State` | Control (output của Bloc) | `InventoryLoadSuccess` |
| `...Dto` | Entity (dữ liệu từ/tới Backend) | `LoginRequestDto`, `ProfileDto` |
| `...ApiClient` | Network layer | `AuthApiClient`, `InventoryApiClient` |
| `...Repository` | Trung gian Bloc ↔ ApiClient (nếu có) | `DrugRepository` |

**Quy tắc đặt tên Event/State (MUST):**
- Event dùng dạng **quá khứ/mệnh lệnh mô tả hành động người dùng**: `LoginSubmitted`,
  `InventoryFetchRequested`, `DrugStockUpdated`.
- State dùng dạng **mô tả trạng thái hiện tại**: `InventoryLoading`, `InventoryLoadSuccess`,
  `InventoryLoadFailure` — KHÔNG đặt tên mơ hồ như `InventoryState2`, `InventoryDone`.

---

## 🏗️ C. KIẾN TRÚC & TỔ CHỨC THƯ MỤC (ARCHITECTURE & FOLDER STRUCTURE)

### C.1 — Nguyên tắc phân lớp (Feature-based + Clean Architecture lai)

```
╔══════════════════════════════════════════════════════════════════╗
║     4 LỚP BẤT KHẢ XÂM PHẠM — MỖI FILE CHỈ THUỘC ĐÚNG 1 LỚP      ║
╚══════════════════════════════════════════════════════════════════╝

[boundary/]   → CHỈ chứa Widget/Screen (UI thuần túy, KHÔNG chứa logic nghiệp vụ)
[control/]    → CHỈ chứa Bloc/Event/State (business logic, KHÔNG chứa Widget)
[entity/]     → CHỈ chứa Dto/Model (data class thuần, KHÔNG chứa logic gọi API)
[network/]    → CHỈ chứa ApiClient (gọi HTTP, parse JSON, KHÔNG chứa business rule)
```

### C.2 — Cấu trúc thư mục chuẩn cho mỗi feature (MANDATORY)

```
lib/
├── core/
│   ├── theme/                      # AppColors, AppTextStyles, AppSpacing
│   ├── constants/                  # ApiEndpoints, AppStrings, ErrorMessages
│   └── network/
│       ├── api_client_base.dart    # Base class dùng chung (headers, base URL, interceptor)
│       └── network_exceptions.dart # Định nghĩa các loại Exception chuẩn
├── shared/
│   └── shared_components/          # ⚠️ Package UI dùng chung — xem mục C.3
├── features/
│   └── inventory/                          # feature = snake_case, số ít hoặc số nhiều nhất quán
│       ├── boundary/
│       │   ├── inventory_list_screen.dart
│       │   └── widgets/
│       │       └── drug_stock_card.dart    # widget con tách nhỏ (xem mục G.3)
│       ├── control/
│       │   ├── inventory_bloc.dart
│       │   ├── inventory_event.dart
│       │   └── inventory_state.dart
│       ├── entity/
│       │   ├── drug_dto.dart
│       │   └── stock_update_request_dto.dart
│       └── network/
│           └── inventory_api_client.dart
```

### C.3 — Bắt buộc tái sử dụng `client.shared_components` (MUST)

```
╔══════════════════════════════════════════════════════════════════╗
║  TRƯỚC KHI VIẾT BẤT KỲ WIDGET UI NÀO: PHẢI KIỂM TRA              ║
║  package `client.shared_components` CÓ SẴN COMPONENT TƯƠNG ỨNG   ║
║  HAY CHƯA (Button, Card, Dialog, Loading, EmptyState, AppBar...) ║
╚══════════════════════════════════════════════════════════════════╝
```

- MUST: Nếu `shared_components` đã có `PrimaryButton`, `AppLoadingIndicator`,
  `AppErrorDialog`, `AppEmptyState`, `AppTextField`... → dùng lại, KHÔNG code cứng UI
  tương đương trong feature.
- MUST: Nếu component cần một biến thể nhỏ (ví dụ đổi màu, đổi icon) → truyền qua
  **tham số (parameter)** của component sẵn có, KHÔNG copy-paste code ra sửa riêng.
- NEVER: Tự tạo `CustomButton`, `MyDialog`, `LoadingWidget`... riêng trong feature nếu
  bản chất giống hệt component đã có trong `shared_components`.
- Nếu thực sự cần component hoàn toàn mới (chưa có pattern tương tự) → tạo trong
  `shared_components` (không phải trong feature riêng lẻ) để feature khác cũng dùng được,
  và phải báo rõ trong output là "đã bổ sung component mới vào shared_components".

---

## 🧠 D. STATE MANAGEMENT — BLoC RULES

### D.1 — Base State bắt buộc cho mọi Bloc (MUST dùng chung 1 pattern)

Mọi Bloc trong dự án PHẢI implement tối thiểu 3 trạng thái sau (đặt tên theo prefix của
feature, KHÔNG dùng tên chung `Loading`/`Success`/`Error` trần trụi để tránh trùng lặp
namespace giữa các feature):

```dart
// inventory_state.dart
sealed class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object?> get props => [];
}

final class InventoryInitial extends InventoryState {}

final class InventoryLoading extends InventoryState {}

final class InventoryLoadSuccess extends InventoryState {
  final List<DrugDto> drugs;
  const InventoryLoadSuccess(this.drugs);
  @override
  List<Object?> get props => [drugs];
}

final class InventoryLoadFailure extends InventoryState {
  final String message;
  const InventoryLoadFailure(this.message);
  @override
  List<Object?> get props => [message];
}
```

- MUST dùng `sealed class` + `Equatable` cho mọi State/Event (Dart 3+), để bắt buộc
  `switch` trong `BlocBuilder` phải xử lý đủ mọi case (compiler tự cảnh báo case thiếu).
- MUST: State PHẢI immutable — mọi field là `final`, không có setter.

### D.2 — UI chỉ được phép dùng `BlocBuilder` / `BlocListener` / `BlocConsumer`

```dart
╔══════════════════════════════════════════════════════════════════╗
║  UI (boundary/) TUYỆT ĐỐI KHÔNG ĐƯỢC GỌI API TRỰC TIẾP            ║
║  UI CHỈ ĐƯỢC "add Event" và "listen State" — KHÔNG CÓ NGOẠI LỆ   ║
╚══════════════════════════════════════════════════════════════════╝
```

- MUST: UI dispatch hành động bằng `context.read<InventoryBloc>().add(InventoryFetchRequested())`.
- MUST: UI render theo State bằng `BlocBuilder<InventoryBloc, InventoryState>`.
- MUST: Side-effect một lần (show SnackBar/Dialog/Navigator) dùng `BlocListener`, KHÔNG
  dùng `BlocBuilder` để trigger side-effect (gây lặp lại mỗi lần rebuild).
- NEVER: Widget tự giữ biến `bool isLoading`, `List data` cục bộ để thay thế cho BLoC State.
- NEVER: Gọi `setState()` để phản ánh dữ liệu nghiệp vụ (chỉ được dùng `setState` cho
  state UI thuần túy không liên quan business logic, ví dụ toggle password visibility).

---

## 🌐 E. GIAO TIẾP API & DỮ LIỆU (NETWORK & DTOs)

### E.1 — ApiClient: CHỈ làm nhiệm vụ HTTP + parse JSON

```dart
class InventoryApiClient {
  final Dio _dio;
  InventoryApiClient(this._dio);

  Future<List<DrugDto>> fetchLowStockDrugs(String storeId) async {
    final response = await _dio.get('/api/inventory/low-stock', queryParameters: {
      'storeId': storeId,
    });
    return (response.data as List)
        .map((json) => DrugDto.fromJson(json))
        .toList();
  }
}
```

- MUST: Mỗi ApiClient tương ứng 1-1 với 1 nhóm endpoint Backend (`AuthApiClient`,
  `InventoryApiClient`, `PrescriptionApiClient`...), KHÔNG gộp nhiều domain vào 1 ApiClient
  "God Class".
- MUST: ApiClient trả về **DTO đã parse** hoặc **throw Exception chuẩn** (xem mục F) —
  KHÔNG được trả về `Map<String, dynamic>` thô ra ngoài lớp network.
- NEVER: ApiClient chứa `if/else` nghiệp vụ (ví dụ: "nếu tồn kho < 10 thì cảnh báo") — đó
  là trách nhiệm của Bloc, không phải Network layer.
- NEVER: ApiClient tự quyết định điều hướng màn hình hoặc show Dialog.

### E.2 — DTO: bắt buộc dùng cho MỌI dữ liệu qua lại với Backend

```dart
class DrugDto extends Equatable {
  final String id;
  final String name;
  final int quantityInStock;
  final double unitPrice;

  const DrugDto({
    required this.id,
    required this.name,
    required this.quantityInStock,
    required this.unitPrice,
  });

  factory DrugDto.fromJson(Map<String, dynamic> json) => DrugDto(
        id: json['id'] as String,
        name: json['name'] as String,
        quantityInStock: json['quantityInStock'] as int,
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantityInStock': quantityInStock,
        'unitPrice': unitPrice,
      };

  @override
  List<Object?> get props => [id, name, quantityInStock, unitPrice];
}
```

- MUST: field trong DTO đặt tên `camelCase` khớp với JSON contract từ Backend ASP.NET Core
  (mặc định Backend trả `camelCase` qua `System.Text.Json`) — KHÔNG tự đổi tên field so
  với response thật.
- MUST: Request body gửi lên Backend cũng phải qua DTO riêng (`...RequestDto`), KHÔNG build
  `Map<String, dynamic>` tay ngay tại nơi gọi API.
- MUST: DTO là immutable, có `fromJson`/`toJson`, kế thừa `Equatable`.
- NEVER: Dùng chung 1 DTO cho cả Request lẫn Response nếu shape dữ liệu khác nhau — phải
  tách `LoginRequestDto` và `LoginResponseDto`/`ProfileDto` riêng biệt.
- NEVER: Bloc hoặc UI parse JSON trực tiếp (`json['field']`) — việc parse CHỈ được xảy ra
  bên trong `factory Dto.fromJson()`.

---

## 🚨 F. XỬ LÝ LỖI (ERROR HANDLING)

### F.1 — Luồng bắt buộc: ApiClient throw → Bloc catch → emit ErrorState → UI hiển thị

```
┌────────────────┐   throw AppException   ┌────────────────┐   emit ...Failure   ┌──────────────┐
│  ApiClient     │ ───────────────────────▶│  Bloc          │────────────────────▶│  UI (Listener)│
│  (network/)    │                          │  (control/)    │                     │  (boundary/)  │
└────────────────┘                          └────────────────┘                     └──────────────┘
```

```dart
// network_exceptions.dart — Exception chuẩn dùng CHUNG toàn dự án
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}
class NetworkTimeoutException extends AppException {
  const NetworkTimeoutException() : super('Kết nối mạng bị gián đoạn.');
}
class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Phiên đăng nhập đã hết hạn.');
}
class ServerException extends AppException {
  const ServerException(super.message);
}
```

```dart
// inventory_bloc.dart
on<InventoryFetchRequested>((event, emit) async {
  emit(InventoryLoading());
  try {
    final drugs = await _inventoryApiClient.fetchLowStockDrugs(event.storeId);
    emit(InventoryLoadSuccess(drugs));
  } on AppException catch (e) {
    emit(InventoryLoadFailure(e.message));
  } catch (e) {
    emit(const InventoryLoadFailure('Đã có lỗi không xác định xảy ra.'));
  }
});
```

```dart
// inventory_list_screen.dart
BlocListener<InventoryBloc, InventoryState>(
  listener: (context, state) {
    if (state is InventoryLoadFailure) {
      showAppErrorDialog(context, message: state.message); // dùng shared_components
    }
  },
  child: ...,
)
```

- MUST: ApiClient chuyển mọi lỗi HTTP (timeout, 401, 500...) thành `AppException` con cháu
  cụ thể — KHÔNG để lộ `DioException`/`SocketException` thô lên tầng Bloc.
- MUST: Bloc luôn có `try/catch` bao quanh lời gọi ApiClient, không để Exception văng lên
  UI thread gây crash app.
- MUST: Lỗi hiển thị cho người dùng dùng component chung `showAppErrorDialog` /
  `showAppErrorSnackBar` từ `shared_components` — không tự viết `AlertDialog` riêng.
- NEVER: `catch (e) {}` nuốt lỗi im lặng không emit State nào — UI sẽ bị treo ở
  `Loading` mãi mãi.

---

## ⛔ G. LUẬT CẤM — ANTI-PATTERNS (NEVER DO)

```
╔══════════════════════════════════════════════════════════════════╗
║        7 IRON LAWS — VI PHẠM = CODE BỊ TỪ CHỐI (REJECTED)       ║
╚══════════════════════════════════════════════════════════════════╝

[G-1: NO DIRECT API CALL IN build()]
  FORBIDDEN: Gọi ApiClient hoặc Repository trực tiếp bên trong hàm build() của Widget.
  ❌  Widget build(context) { apiClient.fetchDrugs(); ... }
  ✅  Dispatch Event trong initState()/khi user tương tác, đọc dữ liệu từ BlocBuilder.

[G-2: NO HARDCODED STRING / COLOR / SIZE]
  FORBIDDEN: Chuỗi text hiển thị cho user, mã màu hex, hoặc số đo cứng viết trực tiếp
  trong Widget.
  ❌  Text('Hết hàng'), Container(color: Color(0xFFE53935), width: 120)
  ✅  Text(AppStrings.outOfStock), Container(color: AppColors.danger, width: AppSpacing.xl)
  Ngoại lệ DUY NHẤT: giá trị debug/log nội bộ không hiển thị cho end-user.

[G-3: NO GOD WIDGET — WIDGET > 100 DÒNG PHẢI TÁCH NHỎ]
  FORBIDDEN: 1 class Widget có build() method vượt quá 100 dòng.
  MANDATORY: Tách thành các private Widget con (`_DrugStockCard`, `_HeaderSection`...)
  hoặc file riêng trong thư mục `boundary/widgets/`.

[G-4: NO BUSINESS LOGIC IN UI]
  FORBIDDEN: Widget tự tính toán nghiệp vụ (ví dụ: tự cộng dồn tổng tiền hóa đơn, tự
  kiểm tra điều kiện tồn kho thấp) thay vì để Bloc xử lý và emit State đã tính sẵn.

[G-5: NO GOD APICLIENT / GOD BLOC]
  FORBIDDEN: Một ApiClient hoặc Bloc xử lý nhiều domain không liên quan (ví dụ
  InventoryBloc xử lý luôn cả logic Authentication).

[G-6: NO RAW JSON OUTSIDE network/]
  FORBIDDEN: Truyền `Map<String, dynamic>` hoặc `response.data` thô ra khỏi ApiClient.
  Mọi ranh giới ra khỏi network/ PHẢI là DTO đã được parse.

[G-7: NO SKIPPING shared_components]
  FORBIDDEN: Tự code lại UI (Button/Dialog/Loading/EmptyState...) đã tồn tại sẵn trong
  `client.shared_components` chỉ vì "dễ hơn" hoặc "nhanh hơn".
```

---

## ✅ H. SELF-CHECK CHECKLIST TRƯỚC KHI TRẢ CODE

Coder Agent PHẢI tự chạy qua checklist này trên chính code vừa sinh ra, trước khi coi
task là hoàn thành:

1. ☐ Tên file/class/biến đúng `snake_case` / `PascalCase` / `camelCase` và đúng hậu suffix
   (`...Screen`, `...Bloc`, `...Event`, `...State`, `...Dto`, `...ApiClient`).
2. ☐ File nằm đúng layer (`boundary/`, `control/`, `entity/`, `network/`) — không lẫn lộn.
3. ☐ Không có Widget nào gọi ApiClient/Repository trực tiếp trong `build()`.
4. ☐ Mọi dữ liệu qua lại với Backend đều đi qua DTO, không có JSON thô rò rỉ ra ngoài.
5. ☐ Bloc có đủ tối thiểu Initial/Loading/Success/Failure State, dùng `Equatable`.
6. ☐ UI chỉ dùng `BlocBuilder`/`BlocListener`/`BlocConsumer`, không tự quản lý state
   nghiệp vụ bằng `setState`.
7. ☐ Mọi lỗi từ ApiClient được bắt và emit thành `...Failure` State, hiển thị qua
   `shared_components` (Dialog/SnackBar chung).
8. ☐ Không có string/color/size hardcode — tất cả tham chiếu `AppStrings`/`AppColors`/
   `AppSpacing`.
9. ☐ Không có Widget nào vượt quá 100 dòng trong `build()` mà chưa được tách nhỏ.
10. ☐ Đã kiểm tra `shared_components` trước khi viết UI mới — không tái tạo component
    đã có sẵn.

```
╔══════════════════════════════════════════════════════════════════╗
║   CHỈ ĐƯỢC TRẢ CODE CHO USER SAU KHI CHECKLIST TRÊN PASS 100%   ║
║        Nếu phát hiện vi phạm → tự sửa (self-correct) trước       ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## 📜 I. ĐIỀU KHOẢN CUỐI

```
[FINAL-1] Skill này là luật tối cao cho mọi code Flutter/Dart trong Pharmacy Chain
  Management. Không có exception theo cảm tính, không có "code tạm cho nhanh".

[FINAL-2] Mọi bất đồng giữa convention cũ trong codebase và skill này → skill này
  THẮNG. Nếu code cũ vi phạm, không tự ý sửa hàng loạt mà không được yêu cầu, nhưng
  code MỚI viết ra phải theo đúng skill này, không được bắt chước code cũ sai.

[FINAL-3] Nếu gặp tình huống chưa được skill này quy định rõ (ví dụ pattern mới hoàn
  toàn) → chọn phương án gần nhất với tinh thần Clean Architecture + BLoC ở trên, và
  PHẢI báo rõ cho người dùng đây là quyết định mới cần bổ sung vào skill, thay vì âm
  thầm tự quyết định vĩnh viễn.

[FINAL-4] Đây là skill dành riêng cho Flutter/Dart Mobile & Web Frontend của Pharmacy
  Chain Management. Không áp dụng cho code Backend ASP.NET Core — nếu yêu cầu lấn sang
  phạm vi đó, flag rõ cho người dùng và chỉ thực hiện phần Flutter.
```

---
*pharmacy-chain-flutter-convention v1.0 — Flutter/Dart BLoC House Style*
*Ngôn ngữ: Tiếng Việt + EN technical terms*
