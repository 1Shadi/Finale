import 'package:flutter/material.dart';
import 'package:tabeeby_app/features/SignupScreen/signup_body.dart';
import 'package:provider/provider.dart';
import 'manager/sign_up_provider.dart'; // Import your signup provider

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignupBody(),
    );
  }
}
