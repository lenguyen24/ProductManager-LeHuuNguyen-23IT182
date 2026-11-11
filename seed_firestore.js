// Script nạp dữ liệu từ products.json lên Firebase Cloud Firestore
const fs = require('fs');
const path = require('path');

function getConfigToken() {
  const homeDir = process.env.USERPROFILE || process.env.HOME;
  const configPath = path.join(homeDir, '.config', 'configstore', 'firebase-tools.json');
  if (fs.existsSync(configPath)) {
    const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    return cfg.tokens && cfg.tokens.access_token;
  }
  return null;
}

async function seed() {
  console.log('=== BẮT ĐẦU NẠP DỮ LIỆU SẢN PHẨM LÊN FIREBASE FIRESTORE ===');
  const token = getConfigToken();
  if (!token) {
    console.error('LỖI: Không tìm thấy token Firebase CLI. Vui lòng đăng nhập bằng lệnh: firebase login');
    return;
  }

  const productsPath = path.join(__dirname, 'products.json');
  const products = JSON.parse(fs.readFileSync(productsPath, 'utf8'));

  console.log(`Đang nạp ${products.length} sản phẩm vào collection 'products'...`);

  for (let i = 0; i < products.length; i++) {
    const p = products[i];
    const docId = `prod_${i + 1}`;
    const url = `https://firestore.googleapis.com/v1/projects/express-backend-demo/databases/(default)/documents/products/${docId}`;
    
    // Đảm bảo chỉ đúng 4 trường: name, price, soluong, image
    const body = {
      fields: {
        name: { stringValue: p.name },
        price: { doubleValue: Number(p.price) },
        soluong: { integerValue: String(p.soluong) },
        image: { stringValue: p.image }
      }
    };

    try {
      const res = await fetch(url, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        },
        body: JSON.stringify(body)
      });
      const data = await res.json();
      if (res.ok && data.name) {
        console.log(`[THÀNH CÔNG] Đã lưu [${docId}]: ${p.name} - ${p.price} VNĐ (Kho: ${p.soluong})`);
      } else {
        console.error(`[THẤT BẠI] ${p.name}:`, data.error ? data.error.message : res.statusText);
      }
    } catch (err) {
      console.error(`[EXCEPTION] ${p.name}:`, err.message);
    }
  }

  console.log('=== HOÀN TẤT NẠP DỮ LIỆU CSDL SẢN PHẨM LÊN FIREBASE FIRESTORE ===');
}

seed();
