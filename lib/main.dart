import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

// Screens
import 'package:teladelogin/screens/eventosScreen.dart';
import 'package:teladelogin/screens/loginScreen.dart';
import 'package:teladelogin/screens/homeScreen.dart';
import 'package:teladelogin/screens/productsListScreen.dart';
import 'package:teladelogin/screens/productFormScreen.dart';
import 'package:teladelogin/screens/mainLayoutScreen.dart';
import 'package:teladelogin/screens/profileScreen.dart';

// Controller
import 'package:teladelogin/products/productController.dart';

// SQLite Web
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('pt_BR', null);

  // ---------------------------------------------
  // 🔥 SQLite para Web
  // ---------------------------------------------
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
    print("✅ SQLite Web ativado com sqflite_common_ffi_web");
  }

  // ---------------------------------------------
  // 🔥 Firebase Inicialização
  // ---------------------------------------------
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB1vI8yyPR-d9MYvrliuYHqVpucU9PB0mo",
        authDomain: "appmobile-2bbcb.firebaseapp.com",
        projectId: "appmobile-2bbcb",
        storageBucket: "appmobile-2bbcb.firebasestorage.app",
        messagingSenderId: "851102593535",
        appId: "1:851102593535:web:0b345ef43bf95ac37ca7ca",
        measurementId: "G-9S2R9WYWTX",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // ---------------------------------------------
  // 🔥 Firestore Offline Cache
  // ---------------------------------------------
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
    print("📦 Firestore com cache offline ativado");
  } catch (e) {
    print("⚠️ Erro ao ativar Firestore offline: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    // 🔥 Registrar o Controller global (uma única vez)
    Get.put(ProductController(), permanent: true);

    // ---------------------------------------------
    // 🔥 Aplicação principal (GetX Navigation)
    // ---------------------------------------------
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App de Produtos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      initialRoute: '/main',

      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/main', page: () => MainLayoutScreen()),
        GetPage(name: '/products', page: () => ProductsListScreen()),
        GetPage(name: '/product-form', page: () => ProductFormScreen()),
        GetPage(name: '/eventos', page: () => const EventosScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
      ],
    );
  }
}
