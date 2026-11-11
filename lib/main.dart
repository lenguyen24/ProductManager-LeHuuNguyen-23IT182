import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/product_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully!');
    ProductService().setFirebaseAvailable(true);
  } catch (e) {
    debugPrint('Cảnh báo kết nối Firebase: $e');
    ProductService().setFirebaseAvailable(false);
  }

  runApp(const ProductManagerApp());
}

class ProductManagerApp extends StatelessWidget {
  const ProductManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget homeScreen;
    if (kIsWeb && Uri.base.queryParameters['screen'] == 'home') {
      homeScreen = HomeScreen();
    } else if (kIsWeb && Uri.base.queryParameters['screen'] == 'add') {
      homeScreen = HomeScreen(autoOpenAdd: true);
    } else if (kIsWeb && Uri.base.queryParameters['screen'] == 'export') {
      homeScreen = HomeScreen(autoOpenExport: true);
    } else {
      homeScreen = const LoginScreen();
    }

    return MaterialApp(
      title: 'Quản Lý Sản Phẩm - Lê Hữu Nguyên (23IT182)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5), // Material Blue
          brightness: Brightness.light,
        ),
        fontFamily: 'Segoe UI',
        cardTheme: const CardThemeData(
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.8),
          ),
        ),
      ),
      home: homeScreen,
    );
  }
}
