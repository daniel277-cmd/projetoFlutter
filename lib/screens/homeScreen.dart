import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone principal
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.redAccent,
                  size: 60,
                ),
              ),
              const SizedBox(height: 30),

              // Texto de boas-vindas
              Text(
                'Bem-vindo, ${user?.email ?? "usuário"}!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Explore nossos produtos e aproveite as ofertas.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Botão principal
              ElevatedButton(
                onPressed: () => Get.toNamed('/products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'VER PRODUTOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Botão de logout
              TextButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Get.offAllNamed('/login');
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white70,
                ),
                label: const Text(
                  'Sair da conta',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomItem(
              icon: Icons.home_outlined,
              label: 'Home',
              selected: true,
              onTap: () {},
            ),
            _buildBottomItem(
              icon: Icons.storefront_outlined,
              label: 'Produtos',
              onTap: () => Get.toNamed('/products'),
            ),
            _buildBottomItem(
              icon: Icons.add_circle_outline,
              label: 'Novo',
              onTap: () => Get.toNamed('/product-form'),
            ),
            _buildBottomItem(
              icon: Icons.person_outline,
              label: 'Account',
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

  Widget _buildBottomItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? Colors.redAccent : Colors.white70,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.redAccent : Colors.white60,
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
