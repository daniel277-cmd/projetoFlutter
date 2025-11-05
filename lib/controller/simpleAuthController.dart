// ignore: file_names
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleAuthController extends GetxController {
  // Estado UI
  final isLoading = false.obs;
  final errorMessage = RxnString();
  
  // Usuário atual
  final isLoggedIn = false.obs;
  final currentUser = Rxn<Map<String, String>>();

  @override
  void onInit() {
    super.onInit();
    _checkSavedLogin();
  }

  // Verificar se há login salvo
  Future<void> _checkSavedLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('user_email');
      final savedName = prefs.getString('user_name');
      
      if (savedEmail != null && savedName != null) {
        currentUser.value = {
          'email': savedEmail,
          'name': savedName,
        };
        isLoggedIn.value = true;
        
        // Auto-navegar para home se já logado
        Future.delayed(Duration(milliseconds: 500), () {
          Get.offAllNamed('/home');
        });
      }
    } catch (e) {
      print('❌ Erro ao verificar login salvo: $e');
    }
  }

  // LOGIN por email/senha (simulado localmente)
  Future<void> loginEmail(String email, String password) async {
    await _run(() async {
      // Simulação de delay de rede
      await Future.delayed(Duration(seconds: 1));
      
      // Verificar credenciais básicas
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email e senha são obrigatórios');
      }
      
      if (!email.contains('@')) {
        throw Exception('Email inválido');
      }
      
      if (password.length < 6) {
        throw Exception('Senha deve ter pelo menos 6 caracteres');
      }
      
      // Verificar se usuário existe localmente
      final prefs = await SharedPreferences.getInstance();
      final savedUsers = prefs.getStringList('registered_users') ?? [];
      
      bool userExists = false;
      String userName = 'Usuário';
      
      for (String userData in savedUsers) {
        final parts = userData.split('|');
        if (parts.length >= 3 && parts[1] == email && parts[2] == password) {
          userExists = true;
          userName = parts[0];
          break;
        }
      }
      
      if (!userExists) {
        throw Exception('Email ou senha incorretos');
      }
      
      // Salvar login
      await _saveUserLogin(email, userName);
      
      // Navegar para home
      Get.offAllNamed('/home');
    });
  }

  // REGISTRO de novo usuário (local)
  Future<void> registerEmail(String email, String password, {String name = 'Usuário'}) async {
    await _run(() async {
      // Simulação de delay
      await Future.delayed(Duration(seconds: 1));
      
      // Validações
      if (name.trim().isEmpty) {
        throw Exception('Nome é obrigatório');
      }
      
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Email inválido');
      }
      
      if (password.length < 6) {
        throw Exception('Senha deve ter pelo menos 6 caracteres');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final savedUsers = prefs.getStringList('registered_users') ?? [];
      
      // Verificar se email já existe
      for (String userData in savedUsers) {
        final parts = userData.split('|');
        if (parts.length >= 2 && parts[1] == email) {
          throw Exception('Este email já está cadastrado');
        }
      }
      
      // Adicionar novo usuário
      savedUsers.add('$name|$email|$password');
      await prefs.setStringList('registered_users', savedUsers);
      
      // Fazer login automaticamente
      await _saveUserLogin(email, name);
      
      // Navegar para home
      Get.offAllNamed('/home');
    });
  }

  // Salvar dados do usuário logado
  Future<void> _saveUserLogin(String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_name', name);
    
    currentUser.value = {
      'email': email,
      'name': name,
    };
    isLoggedIn.value = true;
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      
      currentUser.value = null;
      isLoggedIn.value = false;
      
      Get.offAllNamed('/login');
    } catch (e) {
      print('❌ Erro no logout: $e');
    }
  }

  // Método auxiliar para executar operações com loading
  Future<void> _run(Future<void> Function() body) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await body();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('❌ Erro na operação: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Método de conveniência para login Google (desabilitado)
  Future<void> loginGoogle() async {
    errorMessage.value = 'Login com Google indisponível. Configure o Client ID.';
  }
}