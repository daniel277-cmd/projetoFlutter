
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teladelogin/models/userModel.dart';
import 'package:teladelogin/repositories/authRepository.dart';
import 'package:teladelogin/screens/loginScreen.dart';
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

    // 1) Tentamos obter do Firestore
    var remote = await _repo.getFromFirestore(fbUser.uid);

    // 2) Se não existir no Firestore, criamos um registro com defaults
    if (remote == null) {
      remote = UserModel(
        firebaseUid: fbUser.uid,
        name: fbUser.displayName ?? (fbUser.email ?? 'Usuário'),
        email: fbUser.email ?? 'sem-email@local',
        avatarUrl: fbUser.photoURL,
        isGoogleUser: loginProviderIsGoogle,
        role: newUserDefaultRole,   // por padrão aluno; professor/admin você pode ajustar manualmente no Firestore
        classId: null,
      );
      await _repo.upsertFirestore(remote);
    }

    // 3) Consolida (Firestore → Local) e garante persistência bidirecional
    final local = await _repo.syncUser(remote);

    // 4) Salva na sessão
    await _session.save(local);
    current = local;

    // 5) Redireciona pela permissão (se quiser telas distintas por perfil, ajuste aqui)
    Get.offAllNamed('/home');
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
