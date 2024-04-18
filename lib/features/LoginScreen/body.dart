import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabeeby_app/ForgetPassword/forget_password.dart';
import '../../core/Widgets/already_have_an_account_check.dart';
import '../../core/Widgets/rounded_button.dart';
import '../../core/Widgets/rounded_input_field.dart';
import '../../core/Widgets/rounded_password_field.dart';
import '../SignupScreen/signup_screen.dart';
import 'background.dart';
import 'manager/login_provider.dart';
class LoginBody extends StatelessWidget {
  const LoginBody({Key? key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LoginBackground(
      child: ChangeNotifierProvider(
        create: (context) => LoginProvider(), // Initialize LoginProvider
        child: Consumer<LoginProvider>(
          builder: (context, provider, _) => SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.04),
                Image.asset(
                  'assets/icons/login.png',
                  height: size.height * 0.32,
                ),
                SizedBox(height: size.height * 0.03),
                RoundedInputField(
                  hintText: 'Email',
                  icon: Icons.person,
                  onChanged: (value) =>
                      provider.setEmail(value), // Update email in provider
                ),
                const SizedBox(height: 3),
                RoundedPasswordField(
                  onChanged: (value) =>
                      provider.setPassword(value), // Update password in provider
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgetPassword()),
                    ),
                    child: const Text(
                      'Forgot your Password? ',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                provider.isLoading
                    ? CircularProgressIndicator() // Show loading indicator if loading
                    : RoundedButton(
                  text: 'LOGIN',
                  press: () => provider.login(context),
                ),
                SizedBox(height: size.height * 0.03),
                AlreadyHaveAnAccountCheck(
                  login: true,
                  press: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
