import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teladelogin/controller/authController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSignUp = false;
  bool _obscure = true;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final AuthController _auth = Get.put(AuthController());

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Informe o e-mail';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value);
    if (!ok) return 'E-mail inválido';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  String? _validateName(String? v) {
    if (!isSignUp) return null;
    final value = v?.trim() ?? '';
    if (value.length < 2) return 'Informe seu nome';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (isSignUp) {
      await _auth.registerEmail(_emailCtrl.text.trim(), _passCtrl.text.trim());
    } else {
      await _auth.loginEmail(_emailCtrl.text.trim(), _passCtrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE50914), 
        secondary: Color(0xFFFF3D3D),
        surface: Color(0xFF1B1B1B),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B1B1B),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        prefixIconColor: const Color(0xFFFF3D3D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF3D3D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE50914), width: 2),
        ),
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  elevation: 8,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                    child: Obx(() => Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.music_note,
                                  color: Color(0xFFE50914), size: 64),
                              const SizedBox(height: 20),
                              Text(
                                isSignUp ? 'Criar Conta' : 'Bem-vindo de volta',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),

                              if (_auth.errorMessage.value != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.redAccent),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: Colors.redAccent),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _auth.errorMessage.value!,
                                          style: const TextStyle(color: Colors.redAccent),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              if (isSignUp) ...[
                                TextFormField(
                                  controller: _nameCtrl,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Nome completo',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: _validateName,
                                ),
                                const SizedBox(height: 14),
                              ],

                              TextFormField(
                                controller: _emailCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'E-mail',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                controller: _passCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: const Color(0xFFFF3D3D),
                                    ),
                                  ),
                                ),
                                obscureText: _obscure,
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE50914),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: _auth.isLoading.value ? null : _submit,
                                  child: _auth.isLoading.value
                                      ? const CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white)
                                      : Text(
                                          isSignUp ? 'CRIAR CONTA' : 'ENTRAR',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              TextButton(
                                onPressed: _auth.isLoading.value
                                    ? null
                                    : () => setState(() => isSignUp = !isSignUp),
                                child: Text(
                                  isSignUp
                                      ? 'Já tem conta? Entrar'
                                      : 'Não tem conta? Criar conta',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),

                              const SizedBox(height: 18),
                              Row(
                                children: const [
                                  Expanded(child: Divider(color: Colors.white24)),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Text("ou",
                                        style:
                                            TextStyle(color: Colors.white70)),
                                  ),
                                  Expanded(child: Divider(color: Colors.white24)),
                                ],
                              ),
                              const SizedBox(height: 18),

                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white24),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed:
                                    _auth.isLoading.value ? null : _auth.loginGoogle,
                                icon: Image.asset(
                                  'assets/icons/google.png',
                                  height: 22,
                                  width: 22,
                                ),
                                label: const Text('Entrar com Google'),
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
