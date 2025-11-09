import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import '../widgets/floating_particles.dart';
import '../providers/app_state_provider.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _textController;
  late Animation<double> _heartScale;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    // Heart animation controller
    _heartController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Heart scale animation
    _heartScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticOut,
    ));

    // Text opacity animation
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _heartController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  void _initializeApp() async {
    // Wait for the first frame to complete before initializing
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize app state
      final appState = context.read<AppStateProvider>();
      await appState.initialize();

      // Wait for animations to complete
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      // Navigate based on authentication state
      if (appState.isAuthenticated) {
        _navigateToHome();
      } else {
        _navigateToAuth();
      }
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToAuth() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            // Floating particles
            const FloatingParticles(
              particleCount: 30,
              minSize: 6.0,
              maxSize: 16.0,
            ),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated infinity icon
                  AnimatedBuilder(
                    animation: _heartScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _heartScale.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF9C27B0),
                                Color(0xFF673AB7),
                              ],
                            ),
                            boxShadow: AppTheme.glowShadow,
                          ),
                          child: const Icon(
                            Icons.all_inclusive,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXL),
                  
                  // Animated title
                  AnimatedBuilder(
                    animation: _textOpacity,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: Column(
                          children: [
                            Text(
                              'Always and Forever',
                              style: AppTheme.heading1.copyWith(
                                fontSize: 38,
                                fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: AppTheme.spacingM),
                            
                            Text(
                              'Where hearts connect across any distance 💕',
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXXL),
                  
                  // Loading indicator
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  )
                  .animate(delay: 1000.ms)
                  .fadeIn(duration: 500.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}