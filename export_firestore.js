// Script trích xuất (export) toàn bộ cơ sở dữ liệu sản phẩm từ Firestore ra file products.json
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

async function exportFirestore() {
  console.log('=== BẮT ĐẦU XUẤT CƠ SỞ DỮ LIỆU TỪ FIREBASE FIRESTORE ===');
  const token = getConfigToken();
  if (!token) {
    console.error('LỖI: Không tìm thấy token Firebase CLI. Vui lòng chạy lệnh: firebase login');
    return;
  }

  const url = 'https://firestore.googleapis.com/v1/projects/express-backend-demo/databases/(default)/documents/products?pageSize=100';

  try {
    const res = await fetch(url, {
      method: 'GET',
      headers: {
        'Authorization': 'Bearer ' + token
      }
    });

    const data = await res.json();
    if (!res.ok) {
      console.error('Lỗi truy vấn Firestore:', data.error ? data.error.message : res.statusText);
      return;
    }

    const documents = data.documents || [];
    console.log(`Tìm thấy ${documents.length} bản ghi trong collection 'products'.`);

    const products = [];

    for (const doc of documents) {
      const fields = doc.fields || {};
      const product = {
        name: fields.name?.stringValue || '',
        price: fields.price?.doubleValue ? Number(fields.price.doubleValue) : (fields.price?.integerValue ? Number(fields.price.integerValue) : 0),
        soluong: fields.soluong?.integerValue ? Number(fields.soluong.integerValue) : 0,
        image: fields.image?.stringValue || ''
      };
      products.push(product);
    }

    const outputPath = path.join(__dirname, 'products.json');
    fs.writeFileSync(outputPath, JSON.stringify(products, null, 2), 'utf8');
    console.log(`[XUẤT THÀNH CÔNG] Dữ liệu đã được ghi vào file: ${outputPath}`);
    console.log('Nội dung file JSON tuân thủ chuẩn 4 trường: name, price, soluong, image.');
  } catch (err) {
    console.error('Lỗi khi xuất CSDL:', err.message);
  }
}

exportFirestore();
