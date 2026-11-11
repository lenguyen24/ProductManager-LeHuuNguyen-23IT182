import subprocess
import time
import sys
import os
from playwright.sync_api import sync_playwright

root_dir = r"d:\Code\PT_UDDNT\GiuaKyDaNenTang\ProductManager-LeHuuNguyen-23IT182"
web_dir = os.path.join(root_dir, "build", "web")
screenshots_dir = os.path.join(root_dir, "screenshots")
os.makedirs(screenshots_dir, exist_ok=True)

server = subprocess.Popen(
    [sys.executable, "-m", "http.server", "8089", "-d", web_dir],
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL
)
time.sleep(2)

try:
    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True,
            args=[
                '--enable-webgl',
                '--ignore-gpu-blocklist',
                '--use-gl=angle',
                '--use-angle=swiftshader'
            ]
        )

        # 1. Web Login Screen (1280x800)
        page = browser.new_page(viewport={'width': 1280, 'height': 800})
        page.goto('http://localhost:8089/')
        time.sleep(6)
        page.screenshot(path=os.path.join(screenshots_dir, "step5_web_login.png"))
        print("[1/5] Captured step5_web_login.png")

        # 2. Web Dashboard Screen (1280x800)
        page.goto('http://localhost:8089/?screen=home')
        time.sleep(7)
        page.screenshot(path=os.path.join(screenshots_dir, "step6_web_dashboard.png"))
        print("[2/5] Captured step6_web_dashboard.png")

        # 3. Web Add Product Dialog WITH FILLED DATA & PREVIEW (1280x800)
        page.goto('http://localhost:8089/?screen=add&filled=true')
        time.sleep(7)
        page.screenshot(path=os.path.join(screenshots_dir, "step7_web_add_product.png"))
        print("[3/5] Captured step7_web_add_product.png (with filled data & preview)")

        # 4. Web Export JSON Dialog (1280x800)
        page.goto('http://localhost:8089/?screen=export')
        time.sleep(7)
        page.screenshot(path=os.path.join(screenshots_dir, "step8_web_export_json.png"))
        print("[4/5] Captured step8_web_export_json.png")

        # 5. Mobile Home Screen (390x844)
        mobile_page = browser.new_page(viewport={'width': 390, 'height': 844})
        mobile_page.goto('http://localhost:8089/?screen=home')
        time.sleep(7)
        mobile_page.screenshot(path=os.path.join(screenshots_dir, "step9_mobile_home.png"))
        print("[5/6] Captured step9_mobile_home.png")

        # 6. Mobile Add Product Screen WITH FILLED DATA & PREVIEW (390x844)
        mobile_page.goto('http://localhost:8089/?screen=add&filled=true')
        time.sleep(7)
        mobile_page.screenshot(path=os.path.join(screenshots_dir, "step10_mobile_add.png"))
        print("[6/6] Captured step10_mobile_add.png (with filled data & preview)")

        browser.close()
finally:
    server.terminate()
    print("Web server closed.")
