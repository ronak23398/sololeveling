import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ui/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and app name
                  Image.asset(
                    'assets/images/ui/logo.png',
                    height: 120,
                  ).animate().fadeIn(duration: 600.ms).slideY(
                        begin: -0.2,
                        end: 0,
                        duration: 600.ms,
                      ),
                  const SizedBox(height: 24),
                  Text(
                    'SOLO FITNESS',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.glowBlue,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          color: AppTheme.glowBlue.withOpacity(0.7),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(
                        delay: 300.ms,
                        duration: 600.ms,
                      ),
                  const SizedBox(height: 8),
                  Text(
                    'RISE IN RANKS. BECOME STRONGER.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          letterSpacing: 1.2,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(
                        delay: 600.ms,
                        duration: 600.ms,
                      ),
                  const SizedBox(height: 64),

                  // Call to Action buttons
                  PrimaryButton(
                    text: 'REGISTER',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    gradient: AppTheme.blueGradient,
                  ).animate().fadeIn(
                        delay: 900.ms,
                        duration: 600.ms,
                      ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    text: 'LOGIN',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                  ).animate().fadeIn(
                        delay: 1200.ms,
                        duration: 600.ms,
                      ),
                  const SizedBox(height: 48),

                  // Version info
                  Text(
                    'Version 0.1.0 | BETA',
                    style: Theme.of(context).textTheme.bodySmall,
                  ).animate().fadeIn(
                        delay: 1500.ms,
                        duration: 600.ms,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
