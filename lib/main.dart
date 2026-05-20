import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_matrix_forntend/screens/Splash/splash_screen.dart';
import 'package:job_matrix_forntend/services/auth_provider.dart';
import 'package:job_matrix_forntend/providers/language_provider.dart';
import 'package:job_matrix_forntend/screens/Invite/invite_handler_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        return MaterialApp(
          title: 'Job Matrix',
          debugShowCheckedModeBanner: false,
          locale: langProvider.locale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D464C)),
            useMaterial3: true,
          ),
          // Use onGenerateRoute to handle /invite/{code} URLs
          onGenerateRoute: (settings) {
            final uri = Uri.parse(settings.name ?? '');

            // Handle /invite/{code} route
            if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'invite') {
              final inviteCode = uri.pathSegments[1];
              return MaterialPageRoute(
                builder: (_) => InviteHandlerScreen(inviteCode: inviteCode),
              );
            }

            // Default route
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
