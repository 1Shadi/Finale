import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/DialogBox/error_dialog.dart';
import '../../HomeScreen/home_screen.dart';
import '../../navbar/navbar.dart';

class LoginProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Setter methods for email and password
  void setEmail(String email) {
    emailController.text = email;
  }

  void setPassword(String password) {
    passwordController.text = password;
  }

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const ErrorAlertDialog(
          message: 'Please write your email and password for login',
        ),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      UserCredential auth = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      User? currentUser = auth.user;

      if (currentUser != null) {
        // Navigate to NavBar and pass the current user ID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NavBar(currentUserId: currentUser.uid),
          ),
        );
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      showDialog(
        context: context,
        builder: (context) => ErrorAlertDialog(message: error.toString()),
      );
    }
  }
}
