import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final CollectionReference _productsRef =
      FirebaseFirestore.instance.collection('products');

  bool _isFirebaseAvailable = true;
  void setFirebaseAvailable(bool available) {
    _isFirebaseAvailable = available;
  }
  bool get isFirebaseAvailable => _isFirebaseAvailable;

  // Dữ liệu mẫu ban đầu (tuân thủ nghiêm ngặt: name, price, soluong, image)
  final List<Product> _mockProducts = [
    Product(
      id: 'mock_1',
      name: 'iPhone 15 Pro Max 256GB',
      price: 29990000,
      soluong: 25,
      image: 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=500',
    ),
    Product(
      id: 'mock_2',
      name: 'MacBook Pro 14 M3 Pro',
      price: 42990000,
      soluong: 15,
      image: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500',
    ),
    Product(
      id: 'mock_3',
      name: 'iPad Pro 11 inch M4',
      price: 21490000,
      soluong: 30,
      image: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500',
    ),
    Product(
      id: 'mock_4',
      name: 'Tai nghe Apple AirPods Pro 2',
      price: 5690000,
      soluong: 50,
      image: 'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=500',
    ),
    Product(
      id: 'mock_5',
      name: 'Apple Watch Series 9 GPS',
      price: 9890000,
      soluong: 40,
      image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500',
    ),
    Product(
      id: 'mock_6',
      name: 'Loa Bluetooth Marshall Acton III',
      price: 6490000,
      soluong: 20,
      image: 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=500',
    ),
    Product(
      id: 'mock_7',
      name: 'Bàn phím cơ Keychron K2 Pro',
      price: 1890000,
      soluong: 35,
      image: 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500',
    ),
    Product(
      id: 'mock_8',
      name: 'Chuột không dây Logitech MX Master 3S',
      price: 2190000,
      soluong: 45,
      image: 'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=500',
    ),
  ];

  Stream<List<Product>>? _productsStreamCache;

  // Lấy Stream danh sách sản phẩm thời gian thực từ Firestore (sử dụng broadcast stream để không tạo kết nối mới khi rebuild)
  Stream<List<Product>> getProductsStream() {
    if (!_isFirebaseAvailable) {
      return Stream.value(List.unmodifiable(_mockProducts));
    }

    _productsStreamCache ??= _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    }).asBroadcastStream();

    return _productsStreamCache!;
  }

  // Thêm sản phẩm mới vào Firestore
  Future<void> addProduct(Product product) async {
    if (!_isFirebaseAvailable) {
      final newProd = product.copyWith(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      );
      _mockProducts.add(newProd);
      return;
    }

    // Ghi vào Firestore: Document ID tự sinh, data CHỈ CHỨA 4 trường
    await _productsRef.add(product.toFirestore());
  }

  // Cập nhật sản phẩm
  Future<void> updateProduct(Product product) async {
    if (!_isFirebaseAvailable) {
      final index = _mockProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _mockProducts[index] = product;
      }
      return;
    }

    await _productsRef.doc(product.id).update(product.toFirestore());
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String id) async {
    if (!_isFirebaseAvailable) {
      _mockProducts.removeWhere((p) => p.id == id);
      return;
    }

    await _productsRef.doc(id).delete();
  }

  // Nạp dữ liệu mẫu ban đầu vào Firestore nếu đang trống
  Future<int> seedInitialProducts() async {
    int count = 0;
    for (final prod in _mockProducts) {
      await addProduct(prod);
      count++;
    }
    return count;
  }

  // Trích xuất toàn bộ dữ liệu CSDL sang chuỗi JSON chuẩn
  Future<String> exportProductsToJson() async {
    List<Map<String, dynamic>> jsonList = [];

    if (_isFirebaseAvailable) {
      final querySnapshot = await _productsRef.get();
      for (var doc in querySnapshot.docs) {
        final prod = Product.fromFirestore(doc);
        jsonList.add(prod.toJson());
      }
    } else {
      jsonList = _mockProducts.map((p) => p.toJson()).toList();
    }

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonList);
  }
}
