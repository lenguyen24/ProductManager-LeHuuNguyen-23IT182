import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String _currentAdminEmail = '';
  String _currentAdminName = '';

  bool get isLoggedIn => _isLoggedIn;
  String get currentAdminEmail => _currentAdminEmail;
  String get currentAdminName => _currentAdminName;

  Future<bool> login(String email, String password) async {
    // 1. Kiểm tra tài khoản mặc định quản trị
    if ((email.trim().toLowerCase() == 'admin@gmail.com' ||
            email.trim().toLowerCase() == 'admin') &&
        password.trim() == 'admin123') {
      _isLoggedIn = true;
      _currentAdminEmail = 'admin@gmail.com';
      _currentAdminName = 'Quản Trị Viên (Admin)';
      return true;
    }

    // 2. Thử đối soát với Firestore nếu khả dụng
    try {
      final docId = email.trim().replaceAll('.', '_');
      final doc = await FirebaseFirestore.instance.collection('users').doc(docId).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        if (data['matkhau'] == password.trim()) {
          _isLoggedIn = true;
          _currentAdminEmail = email.trim();
          _currentAdminName = data['hoten'] ?? 'Quản Trị Viên';
          return true;
        }
      }
    } catch (e) {
      debugPrint('Lỗi xác thực Firestore: $e');
    }

    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _currentAdminEmail = '';
    _currentAdminName = '';
  }
}
