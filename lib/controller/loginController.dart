import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teladelogin/repositories/authRepository.dart';


class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final showPassword = false.obs;
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isFacebookLoading = false.obs;

  Future<void> login() async {

    try {
      isLoading.value = true;
      if (loginFormKey.currentState!.validate()) {
        isLoading.value = false;
        return;
      }
      final auth = AuthRepository.instance;
      String? error = await auth.loginWithEmailAndPassword(email.text.trim(),password.text.trim());

      auth.setInitScreen(auth.firebaseUser);

      // ignore: unnecessary_null_comparison
      if (error != null) {
        Get.showSnackbar(GetSnackBar(message: error.toString(),));
        
 }
  } catch (e) {
    Get.showSnackbar(GetSnackBar(
      message: e.toString(),
      duration: const Duration(seconds: 3),
    ));


      
  }
  }
}

      
          