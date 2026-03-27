import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_matrix_forntend/screens/Splash/splash_screen.dart';
import 'package:job_matrix_forntend/services/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Matrix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D464C)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
