import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:get/get.dart'; // GetX para navegação
import 'package:teladelogin/screens/loginScreen.dart';
import 'package:teladelogin/screens/homeScreen.dart';
import 'package:teladelogin/screens/productsListScreen.dart';
import 'package:teladelogin/screens/productFormScreen.dart';
import 'package:teladelogin/screens/mainLayoutScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Web precisa de config extra
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
    // inicializa Firebase
  }
  
  // Configurar Firestore para funcionar offline
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
    print('✅ Firestore configurado para modo offline');
  } catch (e) {
    print('⚠️ Erro ao configurar Firestore: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Mudança para GetMaterialApp
      title: 'App de Produtos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/main', page: () => MainLayoutScreen()),
        GetPage(name: '/products', page: () => ProductsListScreen()),
        GetPage(name: '/product-form', page: () => ProductFormScreen()),
      ],
    );
}
}

// ignore: camel_case_types
