import 'package:flutter/material.dart';

class AlreadyHaveAnAccountCheck extends StatelessWidget {

  final bool login;
  final VoidCallback press;

  const AlreadyHaveAnAccountCheck({super.key,
    this.login = true,
    required this.press,
});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          login ? "Don't have an account?" : 'Already have an account?',
          style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic,),
        ),
        GestureDetector(
          onTap: press,
          child: Text(
            login ? '  Sign up' : 'Sign in',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        )
      ],

    );
  }
}
