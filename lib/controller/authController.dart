
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teladelogin/models/userModel.dart';
import 'package:teladelogin/repositories/authRepository.dart';
import 'package:teladelogin/screens/loginScreen.dart';
import 'package:teladelogin/screens/homeScreen.dart';
import 'package:teladelogin/services/authService.dart';
import 'package:teladelogin/services/sessionService.dart';

class AuthController extends GetxController {
  final AuthService _auth = AuthService();
  final UserRepository _repo = UserRepository();
  final SessionService _session = SessionService();

  // Estado UI
  final isLoading = false.obs;
  final errorMessage = RxnString();

  // Caso queira usar no formulário dessa tela:
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  UserModel? current;

  @override
  void onInit() {
    super.onInit();
    // Opcional: monitorar mudanças do Firebase
    _auth.userChanges.listen((u) async {
      // evita navegação agressiva; usaremos métodos explícitos
    });
  }

  // ---------- LOGIN / CADASTRO ----------
  Future<void> loginEmail(String email, String password) async {
    await _run(() async {
      final u = await _auth.signInWithEmail(email, password);
      await _afterFirebaseLogin(u, loginProviderIsGoogle: false);
    });
  }

  Future<void> registerEmail(String email, String password) async {
    await _run(() async {
      final u = await _auth.registerWithEmail(email, password);
      await _afterFirebaseLogin(u, loginProviderIsGoogle: false, newUserDefaultRole: UserRole.student);
    });
  }

  Future<void> loginGoogle() async {
    await _run(() async {
      final u = await _auth.signInWithGoogle();
      await _afterFirebaseLogin(u, loginProviderIsGoogle: true);
    });
  }

  Future<void> logout() async {
    await _run(() async {
      await _auth.signOut();
      await _session.clear();
      current = null;
      Get.offAll(() => const LoginScreen());
    }, showErrors: false);
  }

  // ---------- SESSÃO ----------
  Future<bool> tryRestoreSession() async {
    final s = await _session.load();
    if (s == null) return false;
    current = s;
    return true;
  }

  // ---------- PERMISSÕES ----------
  bool get canAccessTeacherArea =>
      current?.role == UserRole.teacher || current?.role == UserRole.admin;
  bool get isStudent => current?.role == UserRole.student;

  // ---------- PRIVATE ----------
  Future<void> _afterFirebaseLogin(
    User? fbUser, {
    required bool loginProviderIsGoogle,
    UserRole newUserDefaultRole = UserRole.student,
  }) async {
    if (fbUser == null) {
      throw Exception('Falha ao autenticar. Tente novamente.');
    }

    // 1) Cria ou atualiza o usuário local primeiro (funciona offline)
    var userModel = UserModel(
      firebaseUid: fbUser.uid,
      name: fbUser.displayName ?? (fbUser.email ?? 'Usuário'),
      email: fbUser.email ?? 'sem-email@local',
      avatarUrl: fbUser.photoURL,
      isGoogleUser: loginProviderIsGoogle,
      role: newUserDefaultRole,
      classId: null,
    );

    // 2) Tenta buscar dados remotos (não bloqueia se offline)
    try {
      var remote = await _repo.getFromFirestore(fbUser.uid);
      if (remote != null) {
        userModel = userModel.copyWith(
          name: remote.name,
          role: remote.role,
          classId: remote.classId,
        );
        print('✅ Dados do Firestore carregados');
      }
    } catch (e) {
      print('⚠️ Usando dados padrão (offline): $e');
    }

    // 3) Salva/atualiza localmente (ou apenas usa os dados no Web)
    UserModel local;
    try {
      local = await _repo.upsertLocal(userModel);
      print('✅ Dados processados localmente');
    } catch (e) {
      print('⚠️ Usando dados sem persistência local (Web): $e');
      local = userModel;
    }
    
    // 4) Tenta sincronizar com Firestore (não bloqueia)
    _repo.upsertFirestore(local).catchError((e) {
      print('⚠️ Sincronização com Firestore falhará mais tarde: $e');
    });

    // 5) Salva na sessão
    try {
      await _session.save(local);
      print('✅ Sessão salva');
    } catch (e) {
      print('⚠️ Erro ao salvar sessão: $e');
    }
    
    current = local;

    // 6) Redireciona para home
    print('🚀 Redirecionando para home: ${local.name} (${local.email})');
    
    try {
      Get.offAllNamed('/home');
      print('✅ Navegação executada');
    } catch (e) {
      print('❌ Erro na navegação: $e');
      // Fallback: navegação direta
      Get.offAll(() => HomeScreen());
    }
  }

  Future<void> _run(Future<void> Function() body, {bool showErrors = true}) async {
    try {
      errorMessage.value = null;
      isLoading.value = true;
      await body();
    } on FirebaseAuthException catch (e) {
      if (showErrors) errorMessage.value = _mapFirebaseError(e);
    } on Exception catch (e) {
      if (showErrors) errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'Usuário não encontrado.';
      case 'wrong-password': return 'Senha incorreta.';
      case 'invalid-credential': return 'Credenciais inválidas.';
      case 'email-already-in-use': return 'E-mail já em uso.';
      case 'weak-password': return 'Senha muito fraca.';
      case 'invalid-email': return 'E-mail inválido.';
      default: return 'Erro de autenticação: ${e.message ?? e.code}';
    }
  }
}
