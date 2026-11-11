# HỆ THỐNG QUẢN LÝ SẢN PHẨM - ADMIN (FLUTTER & FIREBASE FIRESTORE)
### BÀI THI GIỮA KỲ: MÔN LẬP TRÌNH ĐA NỀN TẢNG (ĐỀ MỞ)

---

### THÔNG TIN SINH VIÊN
* **Họ và tên:** Lê Hữu Nguyên
* **Mã số sinh viên (MSSV):** 23IT182
* **Khoa:** Công Nghệ Thông Tin
* **Học phần:** Lập trình đa nền tảng
* **Công nghệ phát triển:** **Flutter (Dart)** + **Google Firebase Cloud Firestore**

---

### TỔNG QUAN TÍNH NĂNG THEO YÊU CẦU ĐỀ THI

1. **Cơ sở dữ liệu Firebase Cloud Firestore:**
   - Collection: `products`
   - Tuân thủ quy định đề bài: Chỉ chấp nhận đúng 4 trường thông tin:
     - `name`: Tên sản phẩm (`String`)
     - `price`: Giá sản phẩm (`Double` / `Number`)
     - `soluong`: Số lượng sản phẩm tồn kho (`Integer` / `Number`)
     - `image`: Đường dẫn hình ảnh sản phẩm URL hoặc Base64 Data URL (`String`)
   - Tuyệt đối không tự ý bổ sung thêm trường thừa.

2. **Chạy hoàn chỉnh trên nền tảng Web:**
   - Đăng nhập phân hệ quản trị viên (Admin authentication).
   - Hiển thị danh sách sản phẩm dạng bảng (DataTable) trực quan và thẻ thống kê (Tổng sản phẩm, Tổng tồn kho, Tổng giá trị kho).
   - Chức năng Thêm sản phẩm mới với hỗ trợ nhập URL hoặc tải ảnh trực tiếp từ máy tính.
   - Chức năng Sửa thông tin sản phẩm và Xóa sản phẩm kèm hộp thoại xác nhận an toàn.
   - Tính năng nâng cao: Tìm kiếm sản phẩm theo tên theo thời gian thực (realtime search), sắp xếp đa tiêu chí (theo tên, theo giá, theo số lượng).
   - Nút Xuất CSDL trực tiếp ra định dạng JSON chuẩn nộp bài.

3. **Chạy hoàn chỉnh trên nền tảng Di động (Mobile Android):**
   - Giao diện tự động co giãn Responsive chuẩn mobile UX/UI.
   - Nhập hình ảnh từ thư viện thiết bị (Gallery) hoặc chụp ảnh trực tiếp từ Camera (`image_picker`).
   - Hiển thị danh sách sản phẩm dạng Card có thumbnail, tên, giá bán và số lượng tồn kho.

---

### CẤU TRÚC DỮ LIỆU JSON NỘP BÀI (`products.json`)
```json
[
  {
    "name": "iPhone 15 Pro Max 256GB",
    "price": 29990000,
    "soluong": 25,
    "image": "https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=500"
  },
  {
    "name": "MacBook Pro 14 inch M3 Pro",
    "price": 42990000,
    "soluong": 15,
    "image": "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500"
  }
]
```

---

### HƯỚNG DẪN CÀI ĐẶT & CHẠY ỨNG DỤNG

#### 1. Cài đặt thư viện phụ thuộc
```bash
flutter pub get
```

#### 2. Nạp dữ liệu mẫu ban đầu lên Firestore (nếu cần)
```bash
node seed_firestore.js
```

#### 3. Chạy trên nền tảng Web
```bash
flutter run -d chrome
```

#### 4. Chạy trên thiết bị di động (Android)
```bash
flutter run
```

#### 5. Trích xuất CSDL từ Firestore ra file JSON
```bash
node export_firestore.js
```

---

### LIÊN KẾT BÀI THI
* **GitHub Repository:** [https://github.com/lenguyen24/ProductManager-LeHuuNguyen-23IT182](https://github.com/lenguyen24/ProductManager-LeHuuNguyen-23IT182)
* **File CSDL JSON:** Nằm trực tiếp tại thư mục gốc dự án (`products.json`).
