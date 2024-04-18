import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/HomeScreen/home_screen.dart';
import 'features/HomeScreen/manager/home_screen_provider.dart';
import 'features/LoginScreen/manager/login_provider.dart';
import 'features/SignupScreen/manager/sign_up_provider.dart';
import 'features/SplashScreen/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => HomeScreenProvider()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OLX Clone App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
