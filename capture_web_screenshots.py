import time
import subprocess
import os
import sys
from playwright.sync_api import sync_playwright

def main():
    root_dir = r"d:\Code\PT_UDDNT\GiuaKyDaNenTang\ProductManager-LeHuuNguyen-23IT182"
    web_dir = os.path.join(root_dir, "build", "web")
    screenshots_dir = os.path.join(root_dir, "screenshots")
    os.makedirs(screenshots_dir, exist_ok=True)

    # 1. Start local web server
    print("Starting web server on port 8089...")
    server = subprocess.Popen(
        [sys.executable, "-m", "http.server", "8089", "-d", web_dir],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )
    time.sleep(2)

    try:
        with sync_playwright() as p:
            print("Launching browser...")
            browser = p.chromium.launch(headless=True)
            page = browser.new_page(viewport={"width": 1366, "height": 850})

            # Navigate to web app
            print("Navigating to http://localhost:8089...")
            page.goto("http://localhost:8089", wait_until="networkidle")
            time.sleep(4)

            # Screenshot 1: Login Screen
            login_shot = os.path.join(screenshots_dir, "05_web_login.png")
            page.screenshot(path=login_shot)
            print(f"Captured: {login_shot}")

            # Click Login button
            # In Flutter Web, we can click near center or click by text or dispatch enter
            print("Clicking login...")
            # Click the submit button
            submit_btn = page.locator("text=ĐĂNG NHẬP VÀO HỆ THỐNG").first
            if submit_btn.is_visible():
                submit_btn.click()
            else:
                # Click coordinates of button on standard 440px wide card
                page.mouse.click(683, 560)
            
            time.sleep(3)

            # Screenshot 2: Dashboard
            dash_shot = os.path.join(screenshots_dir, "06_web_dashboard.png")
            page.screenshot(path=dash_shot)
            print(f"Captured: {dash_shot}")

            # Search interaction
            print("Testing search...")
            search_input = page.locator("input").first
            if search_input.is_visible():
                search_input.fill("iPhone")
                time.sleep(1)
                search_shot = os.path.join(screenshots_dir, "07_web_search.png")
                page.screenshot(path=search_shot)
                print(f"Captured: {search_shot}")
                search_input.fill("")
                time.sleep(1)

            # Click 'Thêm Sản Phẩm Mới'
            add_btn = page.locator("text=Thêm Sản Phẩm Mới").first
            if add_btn.is_visible():
                add_btn.click()
                time.sleep(1)
                add_shot = os.path.join(screenshots_dir, "08_web_add_dialog.png")
                page.screenshot(path=add_shot)
                print(f"Captured: {add_shot}")
                # Close dialog
                close_btn = page.locator("text=Hủy bỏ").first
                if close_btn.is_visible():
                    close_btn.click()
                    time.sleep(1)

            # Click 'Xuất JSON'
            export_btn = page.locator("text=Xuất JSON").first
            if export_btn.is_visible():
                export_btn.click()
                time.sleep(1)
                export_shot = os.path.join(screenshots_dir, "09_web_export_dialog.png")
                page.screenshot(path=export_shot)
                print(f"Captured: {export_shot}")
                close_json_btn = page.locator("text=Đóng").first
                if close_json_btn.is_visible():
                    close_json_btn.click()
                    time.sleep(1)

            # Mobile viewport screenshot (to simulate mobile view on web)
            page.set_viewport_size({"width": 390, "height": 844})
            time.sleep(1)
            mobile_web_shot = os.path.join(screenshots_dir, "10_mobile_responsive_view.png")
            page.screenshot(path=mobile_web_shot)
            print(f"Captured: {mobile_web_shot}")

            browser.close()
    finally:
        server.terminate()
        print("Server terminated.")

if __name__ == "__main__":
    main()
