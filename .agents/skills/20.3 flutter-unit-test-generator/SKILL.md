---
name: flutter-unit-test-generator
description: >
  Sinh Unit Test đầy đủ tiêu chuẩn chuyên nghiệp cho Flutter/Dart. Kích hoạt skill này BẮT BUỘC khi:
  (1) Coder Agent vừa hoàn thành viết BLoC/Cubit/Repository/Service/Model/UseCase trong Flutter,
  (2) người dùng yêu cầu "viết unit test", "tạo test", "test cho feature", "coverage",
  (3) pipeline cần sinh test trước khi merge code hoặc chuyển sang giai đoạn review,
  (4) có yêu cầu kiểm tra "boundary", "edge case", "coverage", "mutation test", "test quality",
  (5) bất kỳ khi nào file .dart mới được tạo trong thư mục lib/ và cần test tương ứng.
  Skill áp dụng 8 kỹ thuật thiết kế test theo chuẩn ISTQB: Equivalence Partitioning,
  Boundary Value Analysis, Decision Table, State Transition, Error Guessing, Use Case Testing,
  Pairwise Testing, và Classification Tree. Output là file _test.dart hoàn chỉnh, chạy được ngay.
  KHÔNG được bỏ qua skill này sau khi viết code logic — mọi business logic PHẢI có unit test.
---

# Flutter Unit Test Generator — Chuẩn ISTQB + Industry Best Practices

Skill này đóng vai trò **Test Engineer chuyên nghiệp** trong pipeline Flutter/Dart: nhận source code
từ Coder Agent, phân tích logic, và tự động sinh bộ Unit Test đầy đủ tiêu chuẩn — bao gồm
happy path, sad path, boundary, edge case, và error scenario.

---

## Tổng quan quy trình

```
[Source Code (.dart)]
        │
        ▼
┌────────────────────────────────────────────────────┐
│  Phase 1: Phân tích Target (SUT Analysis)          │
│  Phase 2: Chọn kỹ thuật Test Design phù hợp       │
│  Phase 3: Sinh Test Cases theo 8 kỹ thuật ISTQB    │
│  Phase 4: Sinh file _test.dart hoàn chỉnh          │
│  Phase 5: Kiểm tra Coverage & Quality Gate         │
└────────────────────────────────────────────────────┘
        │
        ▼
[Output: *_test.dart files + Coverage Report]
```

---

## Phase 1 — Phân tích Target (SUT Analysis)

### 1.1 Xác định loại SUT (System Under Test)

Đọc source code và phân loại file vào một trong các danh mục sau:

| Loại SUT | Đặc điểm nhận diện | Kỹ thuật test ưu tiên |
|----------|--------------------|-----------------------|
| **BLoC** | Extends `Bloc<Event, State>` | State Transition + Decision Table |
| **Cubit** | Extends `Cubit<State>` | State Transition + Boundary |
| **Repository** | Implements interface, gọi DataSource/API | Error Guessing + Equivalence Partitioning |
| **UseCase / Service** | Chứa business logic, gọi Repository | Decision Table + Boundary + Use Case Testing |
| **Model / Entity** | `fromJson()`, `toJson()`, `copyWith()`, `==` | Equivalence Partitioning + Boundary |
| **Validator** | Hàm validate input, return bool/String | Boundary + Equivalence Partitioning + Pairwise |
| **Mapper / Converter** | Chuyển đổi DTO ↔ Entity | Equivalence Partitioning + Error Guessing |
| **Extension** | Extension methods trên các type | Boundary + Error Guessing |
| **Utility / Helper** | Hàm static tiện ích | Boundary + Pairwise |

### 1.2 Trích xuất thông tin từ source code

Với mỗi file, thu thập:

```
📋 SUT ANALYSIS REPORT
═══════════════════════════════════════
File: [đường dẫn file]
Class/Function: [tên class hoặc top-level function]
Loại SUT: [BLoC/Cubit/Repository/...]
Dependencies (cần mock): [liệt kê interface/class cần mock]
Public methods: [liệt kê hàm public + signature]
Input parameters: [kiểu dữ liệu + ràng buộc mỗi param]
Return types: [kiểu trả về mỗi method]
Exception/Error có thể ném: [liệt kê exceptions]
State transitions (nếu BLoC/Cubit): [diagram transitions]
═══════════════════════════════════════
```

---

## Phase 2 — Chọn kỹ thuật Test Design

### 2.1 Ma trận 8 kỹ thuật ISTQB

Với mỗi public method trong SUT, áp dụng tất cả kỹ thuật phù hợp từ bảng sau:

#### Kỹ thuật 1: Equivalence Partitioning (EP) — Phân lớp tương đương

> **Nguyên tắc**: Chia miền dữ liệu đầu vào thành các lớp tương đương (partitions),
> mỗi lớp chỉ cần test 1 giá trị đại diện.

**Cách áp dụng:**

| Bước | Hành động | Ví dụ |
|------|-----------|-------|
| 1 | Xác định input domain | `age: int` |
| 2 | Chia Valid Partitions | VP1: 18-65 (tuổi hợp lệ) |
| 3 | Chia Invalid Partitions | IP1: < 0 (âm), IP2: 0-17 (quá nhỏ), IP3: > 65 (quá lớn), IP4: null |
| 4 | Chọn 1 đại diện mỗi lớp | VP1→30, IP1→-5, IP2→10, IP3→80, IP4→null |

**Template test case:**
```dart
group('Equivalence Partitioning — [methodName]', () {
  test('VP1: should [expected behavior] when input is valid value [value]', () {
    // Arrange: giá trị đại diện lớp hợp lệ
    // Act: gọi method
    // Assert: kết quả đúng
  });
  test('IP1: should [expected behavior] when input is invalid value [value]', () {
    // Arrange: giá trị đại diện lớp không hợp lệ
    // Act + Assert: throw hoặc return error
  });
});
```

---

#### Kỹ thuật 2: Boundary Value Analysis (BVA) — Phân tích giá trị biên

> **Nguyên tắc**: Lỗi thường xảy ra tại biên giới giữa các lớp tương đương.
> Test chính xác tại: biên dưới – 1, biên dưới, biên dưới + 1, biên trên – 1, biên trên, biên trên + 1.

**Cách áp dụng:**

Với mỗi EP partition, xác định biên và test 3 giá trị xung quanh mỗi biên:

```
Ví dụ: hàm validateAge(int age) — hợp lệ từ 18 đến 65

Biên dưới: 18          Biên trên: 65
  ↓                       ↓
  17 (INVALID)            64 (VALID)
  18 (VALID — biên)       65 (VALID — biên)
  19 (VALID)              66 (INVALID)
```

**Template test case:**
```dart
group('Boundary Value Analysis — [methodName]', () {
  // --- Biên dưới ---
  test('BVA: should reject when value is [lower_bound - 1]', () { ... });
  test('BVA: should accept when value is exactly [lower_bound]', () { ... });
  test('BVA: should accept when value is [lower_bound + 1]', () { ... });

  // --- Biên trên ---
  test('BVA: should accept when value is [upper_bound - 1]', () { ... });
  test('BVA: should accept when value is exactly [upper_bound]', () { ... });
  test('BVA: should reject when value is [upper_bound + 1]', () { ... });

  // --- Giá trị đặc biệt ---
  test('BVA: should handle zero correctly', () { ... });
  test('BVA: should handle negative value', () { ... });
  test('BVA: should handle max int value', () { ... });
  test('BVA: should handle empty string', () { ... });
  test('BVA: should handle null (nếu nullable)', () { ... });
});
```

**Các loại biên cần test cho từng kiểu dữ liệu:**

| Kiểu dữ liệu | Biên cần test |
|---------------|---------------|
| `int` | 0, -1, 1, min_value, max_value, biên business rule |
| `double` | 0.0, -0.1, 0.1, double.infinity, double.nan, biên rule |
| `String` | "" (rỗng), " " (space), 1 ký tự, max length, max length + 1, unicode/emoji |
| `List` | [] (rỗng), [1 phần tử], [max phần tử], null |
| `DateTime` | epoch, DateTime.now(), min date, max date, leap year, DST transition |
| `enum` | Giá trị đầu tiên, giá trị cuối, giá trị giữa |

---

#### Kỹ thuật 3: Decision Table Testing — Bảng quyết định

> **Nguyên tắc**: Khi kết quả phụ thuộc vào TỔ HỢP nhiều điều kiện,
> lập bảng quyết định để đảm bảo mọi tổ hợp đều được test.

**Cách áp dụng:**

```
Ví dụ: hàm calculateDiscount(bool isPremium, double amount, bool hasCoupon)

| # | isPremium | amount > 100 | hasCoupon | Expected Discount |
|---|-----------|-------------|-----------|-------------------|
| 1 | true      | true        | true      | 30%               |
| 2 | true      | true        | false     | 20%               |
| 3 | true      | false       | true      | 15%               |
| 4 | true      | false       | false     | 10%               |
| 5 | false     | true        | true      | 15%               |
| 6 | false     | true        | false     | 5%                |
| 7 | false     | false       | true      | 10%               |
| 8 | false     | false       | false     | 0%                |
```

**Template test case:**
```dart
group('Decision Table — [methodName]', () {
  // Mỗi dòng trong bảng = 1 test case
  test('Rule 1: isPremium=true, amount>100, hasCoupon=true → 30% discount', () {
    final result = sut.calculateDiscount(isPremium: true, amount: 150, hasCoupon: true);
    expect(result, equals(0.30));
  });
  // ... tất cả các rule còn lại
});
```

---

#### Kỹ thuật 4: State Transition Testing — Kiểm thử chuyển trạng thái

> **Nguyên tắc**: Đặc biệt quan trọng cho BLoC/Cubit.
> Mô hình hóa tất cả state + event + transition, test cả valid lẫn invalid transitions.

**Cách áp dụng cho BLoC/Cubit:**

```
┌─────────┐   LoadData   ┌─────────┐   DataReceived   ┌────────┐
│ Initial │──────────────▶│ Loading │─────────────────▶│ Loaded │
└─────────┘               └─────────┘                  └────────┘
                               │                           │
                          ErrorOccurred                RefreshData
                               │                           │
                               ▼                           ▼
                          ┌─────────┐                 ┌─────────┐
                          │  Error  │────RetryLoad───▶│ Loading │
                          └─────────┘                 └─────────┘
```

**Template test case:**
```dart
group('State Transition — [BlocName]', () {
  // --- Valid Transitions ---
  blocTest<MyBloc, MyState>(
    'ST-V1: Initial → Loading when LoadData event is added',
    build: () => MyBloc(repository: mockRepository),
    act: (bloc) => bloc.add(LoadData()),
    expect: () => [isA<Loading>()],
  );

  blocTest<MyBloc, MyState>(
    'ST-V2: Loading → Loaded when data is received successfully',
    build: () {
      when(() => mockRepository.fetchData()).thenAnswer((_) async => testData);
      return MyBloc(repository: mockRepository);
    },
    act: (bloc) => bloc.add(LoadData()),
    expect: () => [isA<Loading>(), isA<Loaded>()],
  );

  blocTest<MyBloc, MyState>(
    'ST-V3: Loading → Error when exception occurs',
    build: () {
      when(() => mockRepository.fetchData()).thenThrow(Exception('Network error'));
      return MyBloc(repository: mockRepository);
    },
    act: (bloc) => bloc.add(LoadData()),
    expect: () => [isA<Loading>(), isA<Error>()],
  );

  blocTest<MyBloc, MyState>(
    'ST-V4: Error → Loading when RetryLoad event is added',
    build: () => MyBloc(repository: mockRepository),
    seed: () => Error(message: 'Previous error'),
    act: (bloc) => bloc.add(RetryLoad()),
    expect: () => [isA<Loading>()],
  );

  // --- Invalid Transitions (PHẢI test) ---
  blocTest<MyBloc, MyState>(
    'ST-I1: Loaded state should not regress to Initial',
    build: () => MyBloc(repository: mockRepository),
    seed: () => Loaded(data: testData),
    act: (bloc) => bloc.add(LoadData()),
    expect: () => isNot(contains(isA<Initial>())),
  );
});
```

---

#### Kỹ thuật 5: Error Guessing — Đoán lỗi dựa trên kinh nghiệm

> **Nguyên tắc**: Dựa trên kinh nghiệm, dự đoán các lỗi phổ biến mà developer hay mắc.

**Danh sách Error Guessing bắt buộc cho Flutter:**

| # | Loại lỗi | Test case cần tạo |
|---|----------|-------------------|
| 1 | **Null/Empty input** | Truyền `null`, `""`, `[]`, `{}` vào mọi hàm |
| 2 | **Network timeout** | Mock repository throw `TimeoutException` |
| 3 | **Malformed JSON** | `fromJson()` nhận JSON thiếu field bắt buộc |
| 4 | **Concurrent calls** | Gọi method 2 lần liên tiếp nhanh (race condition) |
| 5 | **Đã dispose** | Gọi method trên BLoC/Cubit đã close |
| 6 | **Dữ liệu quá lớn** | List có 10000+ items, String dài 10MB |
| 7 | **Special characters** | Input có `<script>`, `'; DROP TABLE`, emoji 🔥, unicode đặc biệt |
| 8 | **Date edge cases** | 29/02 (leap year), 31/04 (invalid), timezone edge |
| 9 | **Negative/Zero amounts** | Số tiền âm, số tiền = 0, overflow |
| 10 | **Duplicate calls** | Gọi `add(event)` cùng event 2 lần |
| 11 | **Auth token expired** | Mock 401 Unauthorized response |
| 12 | **Server 500** | Mock Internal Server Error response |
| 13 | **Pagination boundary** | Page cuối cùng có ít items hơn pageSize |
| 14 | **Type mismatch từ API** | API trả `String` thay vì `int` cho field numeric |

**Template test case:**
```dart
group('Error Guessing — [className]', () {
  test('EG-01: should handle null input gracefully', () { ... });
  test('EG-02: should throw/catch TimeoutException', () { ... });
  test('EG-03: should handle malformed JSON without crash', () { ... });
  test('EG-04: should handle concurrent calls safely', () { ... });
  test('EG-05: should not emit after bloc is closed', () { ... });
  // ... các test case phù hợp với SUT
});
```

---

#### Kỹ thuật 6: Use Case Testing — Kiểm thử theo luồng nghiệp vụ

> **Nguyên tắc**: Test theo kịch bản người dùng thật — happy path + alternative path + exception path.

**Cách áp dụng:**

```
Use Case: Đăng nhập
├── Happy Path: email + password đúng → login thành công → navigate Home
├── Alternative Path 1: email đúng + password sai → hiển thị lỗi
├── Alternative Path 2: email chưa verify → yêu cầu verify
├── Exception Path 1: server down → hiển thị lỗi mạng
└── Exception Path 2: account bị khóa → hiển thị thông báo bị khóa
```

**Template test case:**
```dart
group('Use Case Testing — [useCaseName]', () {
  group('Happy Path', () {
    test('UC-HP: should complete successfully with valid inputs', () { ... });
  });
  group('Alternative Paths', () {
    test('UC-AP1: should [behavior] when [condition]', () { ... });
    test('UC-AP2: should [behavior] when [condition]', () { ... });
  });
  group('Exception Paths', () {
    test('UC-EP1: should handle [exception type] gracefully', () { ... });
    test('UC-EP2: should [behavior] when [condition]', () { ... });
  });
});
```

---

#### Kỹ thuật 7: Pairwise Testing — Kiểm thử cặp đôi

> **Nguyên tắc**: Khi hàm có nhiều input parameters, thay vì test mọi tổ hợp (bùng nổ tổ hợp),
> đảm bảo MỌI CẶP giá trị (pair) đều được test ít nhất 1 lần.

**Cách áp dụng:**

```
Ví dụ: searchProducts(category, priceRange, sortBy)
- category: ['all', 'medicine', 'cosmetic']
- priceRange: ['low', 'medium', 'high']
- sortBy: ['name', 'price', 'date']

Thay vì test 3×3×3 = 27 cases, Pairwise chỉ cần ~9-12 cases:

| # | category | priceRange | sortBy | 
|---|----------|-----------|--------|
| 1 | all      | low       | name   |
| 2 | all      | medium    | price  |
| 3 | all      | high      | date   |
| 4 | medicine | low       | price  |
| 5 | medicine | medium    | date   |
| 6 | medicine | high      | name   |
| 7 | cosmetic | low       | date   |
| 8 | cosmetic | medium    | name   |
| 9 | cosmetic | high      | price  |
```

**Template test case:**
```dart
group('Pairwise Testing — [methodName]', () {
  final pairwiseMatrix = [
    {'category': 'all', 'priceRange': 'low', 'sortBy': 'name'},
    {'category': 'all', 'priceRange': 'medium', 'sortBy': 'price'},
    // ... all pairs
  ];

  for (final combo in pairwiseMatrix) {
    test('PW: category=${combo['category']}, price=${combo['priceRange']}, sort=${combo['sortBy']}', () {
      final result = sut.search(
        category: combo['category']!,
        priceRange: combo['priceRange']!,
        sortBy: combo['sortBy']!,
      );
      expect(result, isNotNull);
      // Assert specific behavior per combo
    });
  }
});
```

---

#### Kỹ thuật 8: Classification Tree — Cây phân loại

> **Nguyên tắc**: Tổ chức tất cả input parameters thành cây phân cấp,
> rồi kết hợp các nhánh để sinh test cases có hệ thống.

**Cách áp dụng:**

```
Classification Tree cho createOrder():
├── User Type
│   ├── Customer
│   └── Manager
├── Payment Method
│   ├── Cash
│   ├── Card
│   └── Transfer
├── Order Items
│   ├── Single item
│   ├── Multiple items
│   └── Empty cart (invalid)
└── Delivery
    ├── In-store pickup
    └── Home delivery
```

**Template test case:**
```dart
group('Classification Tree — [methodName]', () {
  // Kết hợp các nhánh quan trọng nhất
  test('CT-1: Customer + Cash + Single item + In-store', () { ... });
  test('CT-2: Customer + Card + Multiple items + Delivery', () { ... });
  test('CT-3: Manager + Transfer + Single item + Delivery', () { ... });
  test('CT-4: Customer + Cash + Empty cart → should reject', () { ... });
  // ... đủ tổ hợp cover tất cả nhánh lá ít nhất 1 lần
});
```

---

## Phase 3 — Sinh Test Cases

### 3.1 Checklist bắt buộc trước khi sinh test

Với MỖI public method trong SUT, phải tạo test cases cho:

- [ ] ✅ **Happy Path** (ít nhất 1 test): Luồng thành công chuẩn
- [ ] ✅ **Sad Path** (ít nhất 2 test): Luồng thất bại/lỗi
- [ ] ✅ **Null/Empty Input** (ít nhất 1 test): Xử lý input rỗng
- [ ] ✅ **Boundary Values** (ít nhất 4 test): Biên trên + biên dưới ± 1
- [ ] ✅ **Invalid Input** (ít nhất 2 test): Dữ liệu sai kiểu/format
- [ ] ✅ **Exception Handling** (ít nhất 1 test): Throw/catch đúng exception
- [ ] ✅ **State Transition** (nếu BLoC/Cubit): Đủ valid + invalid transitions
- [ ] ✅ **Concurrency** (nếu async): Race condition, debounce, throttle

### 3.2 Quy tắc đặt tên test

```dart
// Format: 'should [expected behavior] when [condition/action]'

// ✅ Tốt:
test('should return user when id is valid')
test('should throw NotFoundException when user does not exist')
test('should emit [Loading, Loaded] when fetch data succeeds')

// ❌ Xấu:
test('test 1')
test('works')
test('fetchUser test')
```

### 3.3 Quy tắc tổ chức file test

```
test/
├── unit/                             # Unit tests
│   ├── bloc/                         # BLoC/Cubit tests
│   │   ├── auth/
│   │   │   └── auth_bloc_test.dart
│   │   └── product/
│   │       └── product_cubit_test.dart
│   ├── repository/                   # Repository tests
│   │   ├── auth_repository_test.dart
│   │   └── product_repository_test.dart
│   ├── model/                        # Model tests
│   │   ├── user_model_test.dart
│   │   └── product_model_test.dart
│   ├── service/                      # Service/UseCase tests
│   │   └── discount_service_test.dart
│   └── util/                         # Utility tests
│       └── date_formatter_test.dart
├── widget/                           # Widget tests
└── integration_test/                 # Integration tests
```

**Quy tắc:**
- Cấu trúc thư mục `test/` phải **mirror** cấu trúc `lib/`
- File test tên: `[original_name]_test.dart`
- Mỗi file test import file source tương ứng

---

## Phase 4 — Sinh File _test.dart hoàn chỉnh

### 4.1 Template đầy đủ cho BLoC/Cubit Test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Import SUT
import 'package:app_name/path/to/bloc.dart';
import 'package:app_name/path/to/repository.dart';
import 'package:app_name/path/to/model.dart';

// ===== MOCKS =====
class MockRepository extends Mock implements SomeRepository {}

// ===== FAKES (cho registerFallbackValue) =====
class FakeModel extends Fake implements SomeModel {}

void main() {
  late MockRepository mockRepository;
  late MyBloc sut;

  // Test data
  final tValidData = SomeModel(id: 1, name: 'Test');
  final tEmptyList = <SomeModel>[];
  final tException = Exception('Server error');

  setUpAll(() {
    registerFallbackValue(FakeModel());
  });

  setUp(() {
    mockRepository = MockRepository();
    sut = MyBloc(repository: mockRepository);
  });

  tearDown(() {
    sut.close();
  });

  // ═══════════════════════════════════════════════════
  // STATE TRANSITION TESTING
  // ═══════════════════════════════════════════════════
  group('State Transitions', () {
    test('initial state should be MyInitial', () {
      expect(sut.state, isA<MyInitial>());
    });

    blocTest<MyBloc, MyState>(
      'should emit [Loading, Loaded] when data fetch succeeds',
      build: () {
        when(() => mockRepository.fetchData())
            .thenAnswer((_) async => [tValidData]);
        return MyBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(LoadDataEvent()),
      expect: () => [
        isA<MyLoading>(),
        isA<MyLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.fetchData()).called(1);
      },
    );

    blocTest<MyBloc, MyState>(
      'should emit [Loading, Error] when data fetch fails',
      build: () {
        when(() => mockRepository.fetchData()).thenThrow(tException);
        return MyBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(LoadDataEvent()),
      expect: () => [
        isA<MyLoading>(),
        isA<MyError>(),
      ],
    );
  });

  // ═══════════════════════════════════════════════════
  // EQUIVALENCE PARTITIONING
  // ═══════════════════════════════════════════════════
  group('Equivalence Partitioning', () {
    // VP: Valid Partitions
    // IP: Invalid Partitions
    // [Sinh tests dựa trên phân tích EP ở Phase 2]
  });

  // ═══════════════════════════════════════════════════
  // BOUNDARY VALUE ANALYSIS
  // ═══════════════════════════════════════════════════
  group('Boundary Value Analysis', () {
    // [Sinh tests cho biên trên, biên dưới ± 1]
  });

  // ═══════════════════════════════════════════════════
  // DECISION TABLE
  // ═══════════════════════════════════════════════════
  group('Decision Table', () {
    // [Sinh tests cho mọi tổ hợp điều kiện]
  });

  // ═══════════════════════════════════════════════════
  // ERROR GUESSING
  // ═══════════════════════════════════════════════════
  group('Error Guessing', () {
    // [Sinh tests cho các lỗi phổ biến]
  });

  // ═══════════════════════════════════════════════════
  // USE CASE TESTING
  // ═══════════════════════════════════════════════════
  group('Use Case Scenarios', () {
    group('Happy Path', () { /* ... */ });
    group('Alternative Paths', () { /* ... */ });
    group('Exception Paths', () { /* ... */ });
  });
}
```

### 4.2 Template cho Repository Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late RepositoryImpl sut;

  setUp(() {
    mockApiClient = MockApiClient();
    sut = RepositoryImpl(apiClient: mockApiClient);
  });

  group('fetchData', () {
    // Happy path
    test('should return data list when API call succeeds', () async {
      // Arrange
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => Response(statusCode: 200, body: jsonEncode(testData)),
      );
      // Act
      final result = await sut.fetchData();
      // Assert
      expect(result, equals(expectedData));
      verify(() => mockApiClient.get('/api/data')).called(1);
    });

    // Error cases
    test('should throw ServerException when API returns 500', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => Response(statusCode: 500, body: 'Internal Server Error'),
      );
      expect(() => sut.fetchData(), throwsA(isA<ServerException>()));
    });

    test('should throw NetworkException when connection times out', () async {
      when(() => mockApiClient.get(any())).thenThrow(
        TimeoutException('Connection timeout'),
      );
      expect(() => sut.fetchData(), throwsA(isA<NetworkException>()));
    });

    // Malformed response
    test('should throw ParseException when JSON is malformed', () async {
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => Response(statusCode: 200, body: 'not a json'),
      );
      expect(() => sut.fetchData(), throwsA(isA<ParseException>()));
    });
  });
}
```

### 4.3 Template cho Model/Entity Test

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    // ===== fromJson =====
    group('fromJson', () {
      test('should create model from valid JSON', () {
        final json = {'id': 1, 'name': 'John', 'email': 'john@test.com'};
        final result = UserModel.fromJson(json);
        expect(result.id, equals(1));
        expect(result.name, equals('John'));
        expect(result.email, equals('john@test.com'));
      });

      test('should handle JSON with missing optional fields', () {
        final json = {'id': 1, 'name': 'John'};
        final result = UserModel.fromJson(json);
        expect(result.email, isNull);
      });

      test('should throw when required field is missing', () {
        final json = {'name': 'John'};
        expect(() => UserModel.fromJson(json), throwsA(anything));
      });

      test('should handle JSON with wrong type for field', () {
        final json = {'id': 'not_a_number', 'name': 'John'};
        expect(() => UserModel.fromJson(json), throwsA(anything));
      });

      test('should handle empty JSON', () {
        expect(() => UserModel.fromJson({}), throwsA(anything));
      });
    });

    // ===== toJson =====
    group('toJson', () {
      test('should convert model to valid JSON', () {
        final model = UserModel(id: 1, name: 'John', email: 'john@test.com');
        final json = model.toJson();
        expect(json['id'], equals(1));
        expect(json['name'], equals('John'));
        expect(json['email'], equals('john@test.com'));
      });

      test('toJson → fromJson roundtrip should produce equal object', () {
        final original = UserModel(id: 1, name: 'John', email: 'john@test.com');
        final json = original.toJson();
        final recreated = UserModel.fromJson(json);
        expect(recreated, equals(original));
      });
    });

    // ===== equality =====
    group('equality', () {
      test('should be equal when all fields match', () {
        final a = UserModel(id: 1, name: 'John');
        final b = UserModel(id: 1, name: 'John');
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when id differs', () {
        final a = UserModel(id: 1, name: 'John');
        final b = UserModel(id: 2, name: 'John');
        expect(a, isNot(equals(b)));
      });
    });

    // ===== copyWith =====
    group('copyWith', () {
      test('should create new instance with updated field', () {
        final original = UserModel(id: 1, name: 'John');
        final updated = original.copyWith(name: 'Jane');
        expect(updated.name, equals('Jane'));
        expect(updated.id, equals(original.id)); // unchanged
        expect(updated, isNot(same(original))); // new instance
      });
    });

    // ===== Boundary Values cho fields =====
    group('Boundary Values', () {
      test('should handle name with 1 character', () { ... });
      test('should handle name with max length (255 chars)', () { ... });
      test('should handle name with special characters', () { ... });
      test('should handle name with unicode/emoji', () { ... });
    });
  });
}
```

---

## Phase 5 — Coverage & Quality Gate

### 5.1 Tiêu chuẩn Coverage tối thiểu

| Metric | Ngưỡng tối thiểu | Ngưỡng khuyến nghị |
|--------|-------------------|---------------------|
| **Line Coverage** | ≥ 80% | ≥ 90% |
| **Branch Coverage** | ≥ 75% | ≥ 85% |
| **Function Coverage** | ≥ 90% | ≥ 95% |
| **BLoC/Cubit State Coverage** | 100% states phải được test | 100% transitions |

### 5.2 Lệnh chạy và kiểm tra coverage

```bash
# Chạy toàn bộ unit test
flutter test

# Chạy test với coverage report
flutter test --coverage

# Chạy test một file cụ thể
flutter test test/unit/bloc/auth_bloc_test.dart

# Sinh HTML report (cần cài lcov)
genhtml coverage/lcov.info -o coverage/html

# Xem summary nhanh
lcov --summary coverage/lcov.info
```

### 5.3 Quality Gate — Checklist trước khi PASS

```
╔═══════════════════════════════════════════════════════════╗
║              UNIT TEST QUALITY GATE CHECKLIST             ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  [ ] Tất cả test PASS (0 failures, 0 errors)             ║
║  [ ] Line Coverage ≥ 80%                                  ║
║  [ ] Branch Coverage ≥ 75%                                ║
║  [ ] Mọi public method đều có ≥ 1 test                   ║
║  [ ] Mọi BLoC/Cubit state đều được test                  ║
║  [ ] Happy Path + Sad Path + Edge Case đều có             ║
║  [ ] Boundary Values đã được test cho mọi numeric input   ║
║  [ ] Null/Empty input đã được test                        ║
║  [ ] Exception handling đã được test                      ║
║  [ ] Không có test nào phụ thuộc vào test khác             ║
║  [ ] Không có hardcoded delay (dùng fakeAsync nếu cần)    ║
║  [ ] Mock/Stub đúng — không gọi API/DB thật               ║
║  [ ] Test names mô tả rõ ràng hành vi                     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

## Output Format

### Khi tất cả test PASS

```
╔════════════════════════════════════════════════════════╗
║         UNIT TEST GENERATION: COMPLETE ✓              ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  Files analyzed: N                                     ║
║  Test files generated: M                               ║
║  Total test cases: K                                   ║
║                                                        ║
║  Coverage Summary:                                     ║
║    Line:     XX.X% [■■■■■■■■■░] (≥80% ✓)              ║
║    Branch:   XX.X% [■■■■■■■■░░] (≥75% ✓)              ║
║    Function: XX.X% [■■■■■■■■■■] (≥90% ✓)              ║
║                                                        ║
║  Test Techniques Applied:                              ║
║    ✓ Equivalence Partitioning    ✓ BVA                 ║
║    ✓ Decision Table              ✓ State Transition    ║
║    ✓ Error Guessing              ✓ Use Case Testing    ║
║    ✓ Pairwise Testing            ✓ Classification Tree ║
║                                                        ║
║  → All quality gates PASSED                            ║
╚════════════════════════════════════════════════════════╝
```

### Khi có test FAIL

```
╔════════════════════════════════════════════════════════╗
║         UNIT TEST RESULT: FAILED ✗                    ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  Total: K tests | Passed: P | Failed: F | Errors: E   ║
║                                                        ║
║  ── FAILURES ──────────────────────────────────────    ║
║                                                        ║
║  [FAIL-1] test/unit/bloc/auth_bloc_test.dart:45        ║
║    Test: 'should emit [Loading, Error] when login      ║
║           fails with wrong password'                   ║
║    Expected: [Loading, Error]                          ║
║    Actual:   [Loading]                                 ║
║    Root cause: BLoC không emit Error state khi          ║
║    exception xảy ra → CẦN SỬA trong auth_bloc.dart    ║
║                                                        ║
║  ── HƯỚNG DẪN ─────────────────────────────────────    ║
║  Coder Agent vui lòng sửa code source theo lỗi test    ║
║  ở trên, rồi chạy lại `flutter test` để verify.       ║
╚════════════════════════════════════════════════════════╝
```

---

## Lưu ý quan trọng

1. **KHÔNG BAO GIỜ bỏ qua Boundary Value Analysis** — Đây là nguồn phát hiện bug lớn nhất.
2. **KHÔNG BAO GIỜ test chỉ Happy Path** — Mỗi method phải có ít nhất 1 Sad Path test.
3. **Mock tất cả external dependencies** — Dùng `mocktail` (ưu tiên) hoặc `mockito`.
4. **Mỗi test phải ĐỘC LẬP** — Không phụ thuộc thứ tự chạy hay state từ test khác.
5. **Dùng `setUp()`/`tearDown()`** — Khởi tạo/dọn dẹp SUT + mocks mỗi test.
6. **Dùng `blocTest` cho BLoC/Cubit** — Không test BLoC bằng `test()` thường.
7. **Test `fromJson`/`toJson` roundtrip** — Đảm bảo serialization khứ hồi đúng.
8. **Không hardcode delay trong test** — Dùng `fakeAsync` + `tick()` cho time-based logic.
9. **Verify mock calls** — Đảm bảo repository/service được gọi đúng số lần.
10. **Test file phải mirror thư mục lib/** — Giữ cấu trúc test dễ tìm, dễ maintain.
