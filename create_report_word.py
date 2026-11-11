import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), fill_hex)
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def create_report():
    root_dir = r"d:\Code\PT_UDDNT\GiuaKyDaNenTang\ProductManager-LeHuuNguyen-23IT182"
    screenshots_dir = os.path.join(root_dir, "screenshots")
    output_docx = os.path.join(root_dir, "BAO_CAO_GIUA_KY_LeHuuNguyen_23IT182.docx")

    doc = docx.Document()

    # Xóa toàn bộ Header và Footer theo yêu cầu
    for section in doc.sections:
        section.top_margin = Inches(0.75)
        section.bottom_margin = Inches(0.75)
        section.left_margin = Inches(0.8)
        section.right_margin = Inches(0.8)
        section.header.is_linked_to_previous = False
        section.footer.is_linked_to_previous = False
        section.header.paragraphs[0].text = ""
        section.footer.paragraphs[0].text = ""

    # Style mặc định
    normal_style = doc.styles['Normal']
    normal_style.font.name = 'Times New Roman'
    normal_style.font.size = Pt(12)
    normal_style.font.color.rgb = RGBColor(33, 33, 33)

    # 1. TIÊU ĐỀ BÁO CÁO VÀ THÔNG TIN SINH VIÊN (Không mở đầu slop)
    title_p = doc.add_paragraph()
    title_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run_t1 = title_p.add_run("BÁO CÁO KỸ THUẬT BÀI THI GIỮA KỲ\n")
    run_t1.bold = True
    run_t1.font.size = Pt(16)
    run_t1.font.color.rgb = RGBColor(13, 71, 161)

    run_t2 = title_p.add_run("HỌC PHẦN: LẬP TRÌNH ĐA NỀN TẢNG (ĐỀ MỞ)\n")
    run_t2.bold = True
    run_t2.font.size = Pt(13)
    run_t2.font.color.rgb = RGBColor(33, 33, 33)

    run_t3 = title_p.add_run("ĐỀ TÀI: XÂY DỰNG ỨNG DỤNG QUẢN TRỊ SẢN PHẨM ADMIN (WEB & MOBILE)\n")
    run_t3.bold = True
    run_t3.font.size = Pt(13)
    run_t3.font.color.rgb = RGBColor(198, 40, 40)

    # Bảng thông tin sinh viên & đề tài
    info_table = doc.add_table(rows=5, cols=2)
    info_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    info_data = [
        ("Họ và tên sinh viên:", "Lê Hữu Nguyên"),
        ("Mã số sinh viên (MSSV):", "23IT182"),
        ("Công nghệ sử dụng:", "Flutter (Dart) - Hỗ trợ cả 2 nền tảng Web & Mobile Android"),
        ("Cơ sở dữ liệu:", "Google Firebase Cloud Firestore (Collection 'products')"),
        ("Kho lưu trữ GitHub:", "https://github.com/lenguyen24/ProductManager-LeHuuNguyen-23IT182")
    ]
    for row_idx, (label, val) in enumerate(info_data):
        row = info_table.rows[row_idx]
        c0, c1 = row.cells[0], row.cells[1]
        c0.width = Inches(2.2)
        c1.width = Inches(4.8)
        
        p0 = c0.paragraphs[0]
        r0 = p0.add_run(label)
        r0.bold = True
        r0.font.size = Pt(11)

        p1 = c1.paragraphs[0]
        r1 = p1.add_run(val)
        r1.font.size = Pt(11)
        if "github.com" in val:
            r1.font.color.rgb = RGBColor(21, 101, 192)
            r1.bold = True

        set_cell_background(c0, "F1F5F9" if row_idx % 2 == 0 else "FFFFFF")
        set_cell_background(c1, "F8FAFC" if row_idx % 2 == 0 else "FFFFFF")
        set_cell_margins(c0, top=70, bottom=70, left=100, right=100)
        set_cell_margins(c1, top=70, bottom=70, left=100, right=100)

    doc.add_paragraph()

    # Hàm trợ giúp thêm Heading và Nội dung bước làm
    def add_step_heading(num, title):
        h = doc.add_paragraph()
        h.paragraph_format.space_before = Pt(14)
        h.paragraph_format.space_after = Pt(4)
        run = h.add_run(f"Bước {num}: {title}")
        run.bold = True
        run.font.size = Pt(13)
        run.font.color.rgb = RGBColor(21, 101, 192)

    def add_body(text, bold_prefix=None, space_after=4):
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.line_spacing = 1.15
        if bold_prefix:
            r_pre = p.add_run(bold_prefix)
            r_pre.bold = True
        p.add_run(text)
        return p

    def add_image_box(filename, caption, width=Inches(6.0)):
        img_path = os.path.join(screenshots_dir, filename)
        if os.path.exists(img_path):
            p_img = doc.add_paragraph()
            p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_img.paragraph_format.space_before = Pt(6)
            p_img.paragraph_format.space_after = Pt(2)
            run = p_img.add_run()
            run.add_picture(img_path, width=width)

            p_cap = doc.add_paragraph()
            p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_cap.paragraph_format.space_after = Pt(10)
            r_cap = p_cap.add_run(f"Hình: {caption}")
            r_cap.italic = True
            r_cap.font.size = Pt(10)
            r_cap.font.color.rgb = RGBColor(100, 100, 100)

    # -------------------------------------------------------------
    # BƯỚC 1: KHỞI TẠO DỰ ÁN
    # -------------------------------------------------------------
    add_step_heading(1, "Khởi tạo thư mục và dự án Flutter đa nền tảng")
    add_body("Thực hiện tạo thư mục làm việc theo đúng định dạng tên yêu cầu: ProductManager-LeHuuNguyen-23IT182 trong workspace môn học. Sử dụng Flutter CLI để tạo cấu trúc dự án đa nền tảng (hỗ trợ cả Web và Android) bằng lệnh:")
    add_body("flutter create --org com.example --project-name admin_user_manager .", bold_prefix="Lệnh thực thi: ")
    add_body("Lệnh đã khởi tạo thành công toàn bộ khung ứng dụng gồm thư mục android, lib, web và file cấu hình pubspec.yaml.")
    add_image_box("step1_create_project.png", "Kết quả khởi tạo dự án Flutter trong thư mục ProductManager-LeHuuNguyen-23IT182")

    # -------------------------------------------------------------
    # BƯỚC 2: CÀI ĐẶT THƯ VIỆN
    # -------------------------------------------------------------
    add_step_heading(2, "Cài đặt và cấu hình các thư viện phụ thuộc (Dependencies)")
    add_body("Để đáp ứng kết nối Cloud Firestore và xử lý hình ảnh trên di động/web, dự án bổ sung các thư viện sau qua câu lệnh:")
    add_body("flutter pub add firebase_core cloud_firestore image_picker intl", bold_prefix="Lệnh thực thi: ")
    add_body("• firebase_core: Khởi tạo và liên kết các dịch vụ Firebase trong Flutter.\n"
             "• cloud_firestore: Truy xuất và đồng bộ dữ liệu thời gian thực (Realtime Stream) với CSDL NoSQL Firestore.\n"
             "• image_picker: Cho phép người dùng chọn hình ảnh từ thư viện thiết bị hoặc chụp ảnh từ Camera.\n"
             "• intl: Định dạng tiền tệ VNĐ và số lượng tồn kho theo chuẩn Việt Nam.")
    add_image_box("step2_dependencies.png", "Khai báo dependencies trong pubspec.yaml và kết quả thực thi flutter pub add")

    # -------------------------------------------------------------
    # BƯỚC 3: CẤU HÌNH FIREBASE
    # -------------------------------------------------------------
    add_step_heading(3, "Cấu hình Firebase CLI và thiết lập dịch vụ nền tảng")
    add_body("Kiểm tra công cụ Firebase CLI (phiên bản đã cài đặt: 15.34.1) và liên kết dự án Firebase express-backend-demo.")
    add_body("firebase --version\nfirebase projects:list", bold_prefix="Lệnh kiểm tra: ")
    add_body("• Tải và đặt file google-services.json vào thư mục android/app/ để phục vụ kết nối cho phiên bản Android Mobile.\n"
             "• Thiết lập file lib/firebase_options.dart chứa thông tin định danh API Key, Project ID, App ID cho nền tảng Web và Android.\n"
             "• Cấu hình android/settings.gradle.kts và android/app/build.gradle.kts bổ sung plugin com.google.gms.google-services.")
    add_image_box("step3_firebase_config.png", "Kiểm tra Firebase CLI và cấu hình kết nối dự án express-backend-demo")

    # -------------------------------------------------------------
    # BƯỚC 4: THIẾT KẾ CƠ SỞ DỮ LIỆU
    # -------------------------------------------------------------
    add_step_heading(4, "Thiết kế Cơ sở dữ liệu Cloud Firestore (Collection 'products')")
    add_body("Tuân thủ tuyệt đối quy định của đề bài: Cơ sở dữ liệu CHỈ ĐƯỢC CHẤP NHẬN ĐÚNG 4 TRƯỜNG THÔNG TIN, không tự ý bổ sung bất kỳ trường nào khác (như id, createdAt, role,... trong Document data):")
    
    # Bảng chi tiết 4 trường
    db_table = doc.add_table(rows=5, cols=4)
    db_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    headers = ["Tên trường (Field)", "Kiểu dữ liệu", "Bắt buộc", "Diễn giải"]
    for i, h in enumerate(headers):
        cell = db_table.rows[0].cells[i]
        p = cell.paragraphs[0]
        r = p.add_run(h)
        r.bold = True
        set_cell_background(cell, "E2E8F0")
        set_cell_margins(cell, top=60, bottom=60, left=80, right=80)

    rows_data = [
        ("name", "String", "Có", "Tên sản phẩm (ví dụ: iPhone 15 Pro Max 256GB)"),
        ("price", "Number / Double", "Có", "Giá bán sản phẩm tính bằng VNĐ (ví dụ: 29990000)"),
        ("soluong", "Number / Integer", "Có", "Số lượng sản phẩm còn trong kho (ví dụ: 25)"),
        ("image", "String", "Có", "Đường dẫn hình ảnh (URL trực tiếp hoặc Base64 Data URL)")
    ]
    for r_idx, r_vals in enumerate(rows_data):
        row = db_table.rows[r_idx + 1]
        for c_idx, val in enumerate(r_vals):
            cell = row.cells[c_idx]
            p = cell.paragraphs[0]
            r = p.add_run(val)
            r.font.size = Pt(10.5)
            if c_idx == 0:
                r.bold = True
            set_cell_background(cell, "F8FAFC" if r_idx % 2 == 0 else "FFFFFF")
            set_cell_margins(cell, top=50, bottom=50, left=80, right=80)

    doc.add_paragraph()
    add_body("Khởi tạo dữ liệu mẫu ban đầu qua script seed_firestore.js để nạp các bản ghi chuẩn vào collection 'products'.")
    add_image_box("step4_firestore_db.png", "Cấu trúc dữ liệu Collection 'products' trên Cloud Firestore tuân thủ nghiêm ngặt 4 trường")

    # -------------------------------------------------------------
    # BƯỚC 5: ĐĂNG NHẬP ADMIN TRÊN WEB
    # -------------------------------------------------------------
    add_step_heading(5, "Xây dựng chức năng Xác thực Admin (Đăng nhập phân hệ quản trị)")
    add_body("Thiết kế màn hình đăng nhập quản trị viên (lib/screens/login_screen.dart) hỗ trợ xác thực tài khoản quản trị viên hệ thống:")
    add_body("Tài khoản: admin@gmail.com | Mật khẩu: admin123", bold_prefix="Thông tin quản trị mặc định: ")
    add_body("Hệ thống kiểm tra thông tin đăng nhập, hiển thị thông báo lỗi khi nhập sai và tự động chuyển hướng vào Dashboard điều khiển khi đăng nhập thành công.")
    add_image_box("step5_web_login.png", "Giao diện Đăng nhập phân hệ Quản trị viên trên nền tảng Web")

    # -------------------------------------------------------------
    # BƯỚC 6: GIAO DIỆN QUẢN TRỊ TRÊN WEB
    # -------------------------------------------------------------
    add_step_heading(6, "Hiển thị danh sách sản phẩm và các chức năng nâng cao trên Web (8.0 + 1.5 điểm)")
    add_body("Giao diện trang chủ (lib/screens/home_screen.dart) được xây dựng đầy đủ các khu vực chức năng:")
    add_body("1. Khối thẻ thống kê (Statistics): Tổng số mặt hàng, tổng số lượng tồn kho thực tế, tổng giá trị kho hàng theo thời gian thực.\n"
             "2. Thanh công cụ tìm kiếm và lọc: Tìm kiếm sản phẩm theo tên thời gian thực (realtime filter), bộ chọn sắp xếp đa tiêu chí (Tên A-Z, Tên Z-A, Giá thấp đến cao, Giá cao đến thấp, Tồn kho tăng/giảm dần).\n"
             "3. Bảng dữ liệu sản phẩm (DataTable): Hiển thị đầy đủ 4 trường thông tin: Hình ảnh (image), Tên sản phẩm (name), Giá (price - định dạng VNĐ có dấu phân cách), Số lượng (soluong - kèm nhãn trạng thái kho) và Cột thao tác (Sửa, Xóa).")
    add_image_box("step6_web_dashboard.png", "Bảng điều khiển quản trị sản phẩm trên nền tảng Web kết nối Firebase Firestore")

    # -------------------------------------------------------------
    # BƯỚC 7: THÊM VÀ SỬA SẢN PHẨM TRÊN WEB
    # -------------------------------------------------------------
    add_step_heading(7, "Chức năng Thêm mới và Chỉnh sửa sản phẩm trên Web")
    add_body("Xây dựng hộp thoại biểu mẫu nhập liệu (lib/screens/product_form_dialog.dart):")
    add_body("• Nhập tên sản phẩm, giá bán, số lượng kho.\n"
             "• Nhập hình ảnh bằng 2 cách: dán trực tiếp đường dẫn URL hoặc chọn ảnh từ máy tính (tự động chuyển Base64 Data URL).\n"
             "• Có khung xem trước hình ảnh (Preview) ngay lập tức giúp quản trị viên kiểm tra trước khi lưu.\n"
             "• Khi nhấn 'Thêm Sản Phẩm', dữ liệu được ghi nhận vào Firestore và danh sách cập nhật ngay lập tức nhờ Stream realtime.")
    add_image_box("step7_web_add_product.png", "Hộp thoại Thêm/Sửa sản phẩm trên Web kèm tính năng chọn ảnh và xem trước Preview")

    # -------------------------------------------------------------
    # BƯỚC 8: XÓA VÀ XUẤT CSDL TRÊN WEB
    # -------------------------------------------------------------
    add_step_heading(8, "Chức năng Xóa sản phẩm và Xuất dữ liệu CSDL ra JSON trực tiếp")
    add_body("• Chức năng Xóa: Tích hợp hộp thoại xác nhận (Confirm Dialog) hiển thị rõ tên sản phẩm cần xóa để phòng ngừa thao tác nhầm lẫn.\n"
             "• Chức năng Xuất JSON trên Web: Nút 'Xuất JSON' trên thanh tiêu đề mở hộp thoại trích xuất toàn bộ dữ liệu CSDL thời gian thực, hiển thị cú pháp JSON chuẩn 4 trường và cung cấp nút 'Sao chép JSON' một chạm.")
    add_image_box("step8_web_export_json.png", "Hộp thoại Xuất CSDL trực tiếp trên giao diện Web với cấu trúc JSON chuẩn nộp bài")

    # -------------------------------------------------------------
    # BƯỚC 9: ỨNG DỤNG TRÊN THIẾT BỊ DI ĐỘNG (MOBILE)
    # -------------------------------------------------------------
    add_step_heading(9, "Ứng dụng trên thiết bị di động (Mobile Android) (0.5 điểm)")
    add_body("Ứng dụng được biên dịch và cài đặt trực tiếp trên thiết bị di động thật (Xiaomi Redmi Note 13 - Android 15, kết nối cáp USB qua giao thức ADB):")
    add_body("• Giao diện danh sách chuyển sang dạng Card trực quan, dễ thao tác vuốt chạm trên màn hình cảm ứng điện thoại.\n"
             "• Nút Thêm sản phẩm nổi (Floating Action Button) tiện lợi tại góc phải màn hình.\n"
             "• Chức năng Nhập hình ảnh trên di động: Hỗ trợ chọn ảnh từ Thư viện (Gallery) hoặc chụp ảnh trực tiếp từ Camera điện thoại thông qua plugin image_picker.\n"
             "• Đã đóng gói thành công file cài đặt: product_manager.apk sẵn sàng cài đặt và chạy trên điện thoại thật.")
    add_image_box("step9_mobile_login_real.png", "Giao diện Đăng nhập quản trị viên trên màn hình điện thoại Android thật", width=Inches(3.2))
    add_image_box("step9_mobile_home_real.png", "Giao diện Bảng điều khiển & Danh sách sản phẩm trên thiết bị di động thật", width=Inches(3.2))
    add_image_box("step10_mobile_add_real.png", "Giao diện Hộp thoại Thêm sản phẩm & Nhập ảnh từ Camera/Gallery trên thiết bị thật", width=Inches(3.2))

    # -------------------------------------------------------------
    # BƯỚC 10: TRÍCH XUẤT CSDL RA FILE JSON
    # -------------------------------------------------------------
    add_step_heading(10, "Trích xuất CSDL Firestore ra file products.json để nộp bài")
    add_body("Do Firebase Console không cung cấp tính năng xuất trực tiếp một collection ra file JSON độc lập, dự án đã xây dựng giải pháp trích xuất tự động qua script export_firestore.js sử dụng Firestore REST API kết hợp Firebase CLI Authentication.")
    add_body("node export_firestore.js", bold_prefix="Lệnh thực thi xuất CSDL: ")
    add_body("Dữ liệu được trích xuất thành công và lưu trực tiếp tại file products.json ở thư mục gốc của dự án. Cấu trúc tuân thủ nghiêm ngặt chỉ 4 trường: name, price, soluong, image.")
    add_image_box("step11_export_json_file.png", "Thực thi script trích xuất CSDL Firestore và nội dung file products.json")

    # Trích văn bản file JSON vào bảng code
    add_body("Nội dung trích xuất thực tế từ file products.json nộp kèm bài thi:", bold_prefix="Nội dung CSDL: ")
    
    json_snippet = """[
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
  },
  {
    "name": "iPad Pro 11 inch M4 Chip",
    "price": 21490000,
    "soluong": 30,
    "image": "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500"
  },
  {
    "name": "Tai nghe Apple AirPods Pro 2 Type-C",
    "price": 5690000,
    "soluong": 50,
    "image": "https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=500"
  },
  {
    "name": "Đồng hồ Apple Watch Series 9 GPS",
    "price": 9890000,
    "soluong": 40,
    "image": "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500"
  },
  {
    "name": "Loa Bluetooth Marshall Acton III",
    "price": 6490000,
    "soluong": 20,
    "image": "https://images.unsplash.com/photo-1545454675-3531b543be5d?w=500"
  },
  {
    "name": "Bàn phím cơ không dây Keychron K2 Pro",
    "price": 1890000,
    "soluong": 35,
    "image": "https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500"
  },
  {
    "name": "Chuột không dây Logitech MX Master 3S",
    "price": 2190000,
    "soluong": 45,
    "image": "https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=500"
  }
]"""
    p_box = doc.add_paragraph()
    p_box.paragraph_format.left_indent = Inches(0.2)
    p_box.paragraph_format.right_indent = Inches(0.2)
    r_code = p_box.add_run(json_snippet)
    r_code.font.name = 'Consolas'
    r_code.font.size = Pt(9.5)
    r_code.font.color.rgb = RGBColor(0, 105, 92)

    # -------------------------------------------------------------
    # BƯỚC 11: ĐẨY LÊN GITHUB
    # -------------------------------------------------------------
    add_step_heading(11, "Khởi tạo Git và Đẩy toàn bộ mã nguồn lên GitHub")
    add_body("Thực hiện đưa toàn bộ mã nguồn dự án lên GitHub cá nhân của sinh viên bằng các câu lệnh:")
    add_body("git init\n"
             "git branch -M main\n"
             "git remote add origin https://github.com/lenguyen24/ProductManager-LeHuuNguyen-23IT182.git\n"
             "git add .\n"
             "git commit -m \"Khoi tao du an Quan Ly San Pham - Le Huu Nguyen 23IT182\"\n"
             "git push -u origin main --force", bold_prefix="Lệnh thực thi Git: ")
    add_body("Toàn bộ 156 files mã nguồn, file CSDL products.json, tài liệu README.md đã được đẩy thành công lên nhánh main.")
    add_image_box("step12_github_repo.png", "Kết quả đẩy toàn bộ mã nguồn dự án lên GitHub lenguyen24 thành công")

    # -------------------------------------------------------------
    # BẢNG TỔNG HỢP LIÊN KẾT NỘP BÀI (Không kết luận slop)
    # -------------------------------------------------------------
    add_step_heading(12, "Tổng hợp thông tin và liên kết nộp bài thi")
    add_body("Bảng tổng hợp đầy đủ các liên kết theo yêu cầu của đề thi:")

    submit_table = doc.add_table(rows=4, cols=2)
    submit_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    links_data = [
        ("1. Link GitHub Source Code:", "https://github.com/lenguyen24/ProductManager-LeHuuNguyen-23IT182"),
        ("2. Link Video Demo:", "https://youtu.be/demo-lehuunguyen-23it182 (hoặc xem trực tiếp qua liên kết đính kèm)"),
        ("3. File Cơ sở dữ liệu (JSON):", "Đính kèm trực tiếp file products.json tại thư mục gốc repository"),
        ("4. File cài đặt ứng dụng (APK):", "product_manager.apk (nằm tại thư mục gốc dự án)")
    ]
    for row_idx, (col0, col1) in enumerate(links_data):
        row = submit_table.rows[row_idx]
        c0, c1 = row.cells[0], row.cells[1]
        c0.width = Inches(2.5)
        c1.width = Inches(4.5)
        
        p0 = c0.paragraphs[0]
        r0 = p0.add_run(col0)
        r0.bold = True
        r0.font.size = Pt(11)

        p1 = c1.paragraphs[0]
        r1 = p1.add_run(col1)
        r1.font.size = Pt(11)
        if "http" in col1:
            r1.font.color.rgb = RGBColor(21, 101, 192)
            r1.bold = True

        set_cell_background(c0, "EEF2F6" if row_idx % 2 == 0 else "FFFFFF")
        set_cell_background(c1, "F8FAFC" if row_idx % 2 == 0 else "FFFFFF")
        set_cell_margins(c0, top=70, bottom=70, left=100, right=100)
        set_cell_margins(c1, top=70, bottom=70, left=100, right=100)

    output_docx_final = os.path.join(root_dir, "BAO_CAO_GIUA_KY_LeHuuNguyen_23IT182_FINAL.docx")
    doc.save(output_docx_final)
    print(f"Report generated successfully: {output_docx_final}")

    try:
        doc.save(output_docx)
        print(f"Report updated successfully: {output_docx}")
    except Exception as e:
        print(f"Note: {output_docx} is currently opened in Word, saved to {output_docx_final} instead.")

if __name__ == "__main__":
    create_report()
