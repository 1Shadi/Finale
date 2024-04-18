import 'package:flutter/material.dart';

import '../../core/Widgets/rounded_button.dart';
import '../LoginScreen/login_screen.dart';
import '../SignupScreen/signup_screen.dart';
import 'background.dart';

class WelcomeBody extends StatelessWidget {
  const WelcomeBody({super.key});


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return  WelcomeBackground(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tabeeby',
              style: TextStyle(
                fontSize: 60.0,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                fontFamily: 'Signatra,'

              ),
            ),
            SizedBox(height: size.height * 0.05,),
            Image.asset('assets/icons/chat.png',
            height: size.height * 0.40,
            ), //Image.ASSETS
            RoundedButton(
              text: 'LOGIN',
              press: ()
              {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()));

              },
            ),
            RoundedButton(
              text: 'SIGN UP',
              color: Colors.black54,
              textColor: Colors.white,
              press: ()
              {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()));

              },
            ),

          ],
        ),
      ),
    );
  }
}
