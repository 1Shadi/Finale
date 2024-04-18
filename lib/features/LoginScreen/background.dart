import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;

  LoginBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.teal],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              'assets/images/main_bottom.png',
              color: Colors.deepPurple.shade300,
              width: MediaQuery.of(context).size.width * 0.2,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
