import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final int soluong;
  final String image;

  Product({
    this.id = '',
    required this.name,
    required this.price,
    required this.soluong,
    required this.image,
  });

  // Chuyển đổi sang Map để lưu trữ trên Firestore.
  // Tuân thủ nghiêm ngặt đề bài: CHỈ GỒM 4 TRƯỜNG: name, price, soluong, image
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'soluong': soluong,
      'image': image,
    };
  }

  // Khởi tạo từ Firestore DocumentSnapshot
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Product(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      price: (data['price'] is num)
          ? (data['price'] as num).toDouble()
          : (double.tryParse(data['price']?.toString() ?? '0') ?? 0.0),
      soluong: (data['soluong'] is num)
          ? (data['soluong'] as num).toInt()
          : (int.tryParse(data['soluong']?.toString() ?? '0') ?? 0),
      image: data['image']?.toString() ?? '',
    );
  }

  // Khởi tạo từ Map (dùng khi đọc từ JSON)
  factory Product.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return Product(
      id: id,
      name: map['name']?.toString() ?? '',
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : (double.tryParse(map['price']?.toString() ?? '0') ?? 0.0),
      soluong: (map['soluong'] is num)
          ? (map['soluong'] as num).toInt()
          : (int.tryParse(map['soluong']?.toString() ?? '0') ?? 0),
      image: map['image']?.toString() ?? '',
    );
  }

  // Chuyển sang JSON chuẩn nộp bài
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'soluong': soluong,
      'image': image,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? soluong,
    String? image,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      soluong: soluong ?? this.soluong,
      image: image ?? this.image,
    );
  }
}
