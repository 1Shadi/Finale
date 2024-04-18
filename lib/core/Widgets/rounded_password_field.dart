import 'package:flutter/material.dart';
import 'package:tabeeby_app/core/Widgets/text_field_container.dart';

class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const RoundedPasswordField({super.key,
    required this.onChanged,
  });

  @override
  State<RoundedPasswordField> createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool obscureText = true; // Fixed the declaration of the boolean variable

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        obscureText: obscureText, // Removed the unnecessary '!' before obscureText
        onChanged: widget.onChanged,
        cursorColor: Colors.teal,
        decoration: InputDecoration(
          hintText: 'Password',
          icon: const Icon(
            Icons.lock,
            color: Colors.teal,
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                obscureText = !obscureText;
              });
            },
            child: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.black54,
            ),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
