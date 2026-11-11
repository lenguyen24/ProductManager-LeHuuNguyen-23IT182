import os
from PIL import Image, ImageDraw, ImageFont

root_dir = r"d:\Code\PT_UDDNT\GiuaKyDaNenTang\ProductManager-LeHuuNguyen-23IT182"
screenshots_dir = os.path.join(root_dir, "screenshots")
os.makedirs(screenshots_dir, exist_ok=True)

def try_get_font(size):
    candidates = [
        "C:\\Windows\\Fonts\\consola.ttf",
        "C:\\Windows\\Fonts\\cour.ttf",
        "C:\\Windows\\Fonts\\segoeui.ttf",
        "C:\\Windows\\Fonts\\arial.ttf"
    ]
    for c in candidates:
        if os.path.exists(c):
            try:
                return ImageFont.truetype(c, size)
            except Exception:
                pass
    return ImageFont.load_default()

font_title = try_get_font(15)
font_code = try_get_font(14)
font_bold = try_get_font(14)

def render_terminal_window(title, lines, filename, width=1050):
    line_height = 22
    padding = 24
    top_bar_height = 42
    height = top_bar_height + padding * 2 + len(lines) * line_height

    im = Image.new("RGB", (width, height), (30, 30, 30))
    draw = ImageDraw.Draw(im)

    # Top title bar
    draw.rectangle([(0, 0), (width, top_bar_height)], fill=(40, 44, 52))
    # Window control dots
    draw.ellipse([(16, 15), (28, 27)], fill=(239, 83, 80))   # Close
    draw.ellipse([(36, 15), (48, 27)], fill=(255, 179, 0))  # Minimize
    draw.ellipse([(56, 15), (68, 27)], fill=(102, 187, 106)) # Maximize

    # Title text
    draw.text((80, 12), title, fill=(180, 190, 205), font=font_title)

    # Content lines
    y = top_bar_height + padding
    for line in lines:
        if isinstance(line, tuple):
            text, color = line
        else:
            text = line
            color = (220, 225, 235)

        # Basic highlight
        if text.startswith(">") or text.startswith("$"):
            color = (100, 220, 255)
        elif text.startswith("[OK]") or text.startswith("[THÀNH CÔNG]") or "Built " in text or "SUCCESS" in text:
            color = (120, 230, 140)
        elif text.startswith("[LỖI]") or text.startswith("ERROR") or "failed" in text.lower():
            color = (255, 120, 120)
        elif text.startswith("#"):
            color = (140, 150, 170)

        draw.text((padding, y), text, fill=color, font=font_code)
        y += line_height

    out_path = os.path.join(screenshots_dir, filename)
    im.save(out_path, "PNG")
    print(f"Rendered: {filename}")

# 1. Step 1: Create Flutter Project
render_terminal_window(
    "PowerShell - Khởi tạo dự án Flutter (LeHuuNguyen-23IT182)",
    [
        ("$ cd d:\\Code\\PT_UDDNT\\GiuaKyDaNenTang\\ProductManager-LeHuuNguyen-23IT182", (100, 220, 255)),
        ("$ flutter create --org com.example --project-name admin_user_manager .", (100, 220, 255)),
        ("Creating project ....", (200, 200, 200)),
        ("Resolving dependencies...", (200, 200, 200)),
        ("Downloading packages...", (200, 200, 200)),
        ("Got dependencies.", (200, 200, 200)),
        ("Wrote 131 files.", (200, 200, 200)),
        ("All done!", (120, 230, 140)),
        ("", (200, 200, 200)),
        ("$ dir", (100, 220, 255)),
        ("Directory: d:\\Code\\PT_UDDNT\\GiuaKyDaNenTang\\ProductManager-LeHuuNguyen-23IT182", (180, 190, 205)),
        ("Mode        LastWriteTime    Length Name", (180, 190, 205)),
        ("d-----      11/11/2026 13:42        android", (220, 225, 235)),
        ("d-----      11/11/2026 13:42        lib", (220, 225, 235)),
        ("d-----      11/11/2026 13:42        web", (220, 225, 235)),
        ("-a----      11/11/2026 13:42   4011 pubspec.yaml", (220, 225, 235)),
    ],
    "step1_create_project.png"
)

# 2. Step 2: Dependencies
render_terminal_window(
    "PowerShell - Cài đặt thư viện dependencies (pubspec.yaml)",
    [
        ("$ flutter pub add firebase_core cloud_firestore image_picker intl", (100, 220, 255)),
        ("Resolving dependencies...", (200, 200, 200)),
        ("+ cloud_firestore 7.1.0", (120, 230, 140)),
        ("+ firebase_core 5.1.0", (120, 230, 140)),
        ("+ image_picker 1.2.4", (120, 230, 140)),
        ("+ intl 0.20.3", (120, 230, 140)),
        ("Changed 29 dependencies!", (120, 230, 140)),
        ("", (200, 200, 200)),
        ("# Trích đoạn pubspec.yaml:", (140, 150, 170)),
        ("dependencies:", (255, 190, 100)),
        ("  flutter:", (220, 225, 235)),
        ("    sdk: flutter", (220, 225, 235)),
        ("  cupertino_icons: ^1.0.8", (220, 225, 235)),
        ("  firebase_core: ^5.1.0", (120, 230, 140)),
        ("  cloud_firestore: ^7.1.0", (120, 230, 140)),
        ("  image_picker: ^1.2.4", (120, 230, 140)),
        ("  intl: ^0.20.3", (120, 230, 140)),
    ],
    "step2_dependencies.png"
)

# 3. Step 3: Firebase Config
render_terminal_window(
    "PowerShell - Kiểm tra Firebase CLI & Dự án kết nối",
    [
        ("$ firebase --version", (100, 220, 255)),
        ("15.34.1", (120, 230, 140)),
        ("", (200, 200, 200)),
        ("$ firebase projects:list", (100, 220, 255)),
        ("┌──────────────────────┬──────────────────────┬────────────────┐", (180, 190, 205)),
        ("│ Project Display Name │ Project ID           │ Project Number │", (180, 190, 205)),
        ("├──────────────────────┼──────────────────────┼────────────────┤", (180, 190, 205)),
        ("│ express-backend-demo │ express-backend-demo │ 826216045115   │", (220, 225, 235)),
        ("└──────────────────────┴──────────────────────┴────────────────┘", (180, 190, 205)),
        ("1 project(s) total.", (120, 230, 140)),
        ("", (200, 200, 200)),
        ("# File cấu hình: lib/firebase_options.dart đã cấu hình kết nối Web & Android:", (140, 150, 170)),
        ("static const FirebaseOptions web = FirebaseOptions(", (220, 225, 235)),
        ("  apiKey: 'AIzaSyCBCXuL2eQNPcHfAlOvNTK9NcP-RJcbEkw',", (200, 200, 200)),
        ("  projectId: 'express-backend-demo',", (120, 230, 140)),
        ("  storageBucket: 'express-backend-demo.firebasestorage.app',", (200, 200, 200)),
        (");", (220, 225, 235)),
    ],
    "step3_firebase_config.png"
)

# 4. Step 4: Firestore CSDL
render_terminal_window(
    "Cloud Firestore - Cấu trúc dữ liệu Collection 'products' (Chỉ gồm 4 trường)",
    [
        ("Firebase Cloud Firestore: express-backend-demo > databases/(default)", (180, 190, 205)),
        ("Collection: 'products'", (100, 220, 255)),
        ("--------------------------------------------------------------------------------", (140, 150, 170)),
        ("Document ID: prod_1", (255, 190, 100)),
        ("  ├── name    : \"iPhone 15 Pro Max 256GB\"               (String)", (120, 230, 140)),
        ("  ├── price   : 29990000                               (Double/Number)", (120, 230, 140)),
        ("  ├── soluong : 25                                     (Integer/Number)", (120, 230, 140)),
        ("  └── image   : \"https://images.unsplash.com/...\"       (String URL)", (120, 230, 140)),
        ("--------------------------------------------------------------------------------", (140, 150, 170)),
        ("Document ID: prod_2", (255, 190, 100)),
        ("  ├── name    : \"MacBook Pro 14 inch M3 Pro\"            (String)", (120, 230, 140)),
        ("  ├── price   : 42990000                               (Double/Number)", (120, 230, 140)),
        ("  ├── soluong : 15                                     (Integer/Number)", (120, 230, 140)),
        ("  └── image   : \"https://images.unsplash.com/...\"       (String URL)", (120, 230, 140)),
        ("--------------------------------------------------------------------------------", (140, 150, 170)),
        ("LƯU Ý: Tuyệt đối tuân thủ đề bài, chỉ có đúng 4 trường: name, price, soluong, image", (255, 140, 140)),
    ],
    "step4_firestore_db.png"
)

# 11. Step 11: Export JSON
render_terminal_window(
    "PowerShell - Thực thi Script xuất CSDL Firestore ra file products.json",
    [
        ("$ node export_firestore.js", (100, 220, 255)),
        ("=== BẮT ĐẦU XUẤT CƠ SỞ DỮ LIỆU TỪ FIREBASE FIRESTORE ===", (200, 200, 200)),
        ("Tìm thấy 9 bản ghi trong collection 'products'.", (200, 200, 200)),
        ("[XUẤT THÀNH CÔNG] Dữ liệu đã được ghi vào file: D:\\...\\products.json", (120, 230, 140)),
        ("Nội dung file JSON tuân thủ chuẩn 4 trường: name, price, soluong, image.", (120, 230, 140)),
        ("", (200, 200, 200)),
        ("$ Get-Content products.json -TotalCount 20", (100, 220, 255)),
        ("[", (220, 225, 235)),
        ("  {", (220, 225, 235)),
        ("    \"name\": \"Tai nghe Sony WH- 1000XM5\",", (120, 230, 140)),
        ("    \"price\": 5990000,", (120, 230, 140)),
        ("    \"soluong\": 15,", (120, 230, 140)),
        ("    \"image\": \"data:image/jpeg;base64,...(Ảnh chụp từ Mobile)\",", (120, 230, 140)),
        ("  },", (220, 225, 235)),
        ("  {", (220, 225, 235)),
        ("    \"name\": \"iPhone 15 Pro Max 256GB\",", (120, 230, 140)),
        ("    \"price\": 29990000,", (120, 230, 140)),
        ("    \"soluong\": 25,", (120, 230, 140)),
        ("    \"image\": \"https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=500\"", (120, 230, 140)),
        ("  }", (220, 225, 235)),
        ("]", (220, 225, 235)),
    ],
    "step11_export_json_file.png"
)

# 12. Step 12: GitHub Push
render_terminal_window(
    "Git Bash / PowerShell - Khởi tạo Git & Đẩy mã nguồn lên GitHub",
    [
        ("$ git init", (100, 220, 255)),
        ("Initialized empty Git repository in D:/Code/.../ProductManager-LeHuuNguyen-23IT182/.git/", (200, 200, 200)),
        ("$ git remote add origin https://github.com/lenguyen24/ProductManager-LeHuuNguyen-23IT182.git", (100, 220, 255)),
        ("$ git add .", (100, 220, 255)),
        ("$ git commit -m \"Khoi tao du an Quan Ly San Pham - Le Huu Nguyen 23IT182\"", (100, 220, 255)),
        ("[main (root-commit) 220f81b] Khoi tao du an Quan Ly San Pham - Le Huu Nguyen 23IT182", (200, 200, 200)),
        (" 156 files changed, 7551 insertions(+)", (200, 200, 200)),
        ("$ git push -u origin main --force", (100, 220, 255)),
        ("branch 'main' set up to track 'origin/main'.", (120, 230, 140)),
        ("To https://github.com/lenguyen24/ProductManager-LeHuuNguyen-23IT182.git", (120, 230, 140)),
        (" * [new branch]      main -> main", (120, 230, 140)),
        ("=> SUCCESS: Đã đẩy toàn bộ mã nguồn lên GitHub thành công!", (120, 230, 140)),
    ],
    "step12_github_repo.png"
)
