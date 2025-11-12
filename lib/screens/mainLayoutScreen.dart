import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teladelogin/screens/homeScreen.dart';
import 'package:teladelogin/screens/productsListScreen.dart';
import 'package:teladelogin/screens/productFormScreen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    ProductsListScreen(),
    const ProductFormScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      // bottomNavigationBar removido a pedido — use o Drawer para navegação
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              accountName: Text(
                FirebaseAuth.instance.currentUser?.displayName ?? 'Usuário',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? '',
                style: const TextStyle(fontSize: 14),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  FirebaseAuth.instance.currentUser?.displayName?.substring(0, 1).toUpperCase() ??
                      FirebaseAuth.instance.currentUser?.email?.substring(0, 1).toUpperCase() ??
                      'U',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Produtos'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Novo Produto'),
              onTap: () {
                Navigator.pop(context);
                // Abrir formulário de produto em vez de trocar a aba
                Get.toNamed('/product-form');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Relatórios'),
              subtitle: const Text('Em breve'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Em Desenvolvimento',
                  'Funcionalidade em breve!',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              subtitle: const Text('Em breve'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Em Desenvolvimento',
                  'Funcionalidade em breve!',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Get.offAllNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}