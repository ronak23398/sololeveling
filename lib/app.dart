import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/home/home_screen.dart';

class SoloFitnessApp extends StatelessWidget {
  const SoloFitnessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Solo Fitness',
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              ThemeMode.dark, // Always use dark theme for Solo Leveling style
          initialRoute: AppRoutes.welcome,
          routes: AppRoutes.routes,
          home: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              // Redirect to home if user is already logged in
              return userProvider.isLoggedIn
                  ? const HomeScreen()
                  : const WelcomeScreen();
            },
          ),
        );
      },
    );
  }
}
