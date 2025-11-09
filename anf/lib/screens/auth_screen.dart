import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import '../widgets/floating_particles.dart';
import '../providers/app_state_provider.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordValid = false;
  bool _showUserSelection = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePassword() async {
    final appState = context.read<AppStateProvider>();
    final password = _passwordController.text;

    final isValid = await appState.authenticateWithPassword(password);
    
    setState(() {
      _isPasswordValid = isValid;
      if (isValid) {
        _showUserSelection = true;
        _errorMessage = null;
      } else {
        _errorMessage = 'Incorrect password. Try again.';
      }
    });
  }

  void _selectUser(String userId) async {
    final appState = context.read<AppStateProvider>();
    
    try {
      await appState.selectUser(userId);
      
      if (!mounted) return;
      
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error selecting user. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            // Floating particles
            const FloatingParticles(
              particleCount: 40,
              minSize: 4.0,
              maxSize: 12.0,
            ),
            
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      'Welcome Back',
                      style: AppTheme.heading1,
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3, end: 0),
                    
                    const SizedBox(height: AppTheme.spacingM),
                    
                    Text(
                      'Enter your secret password to continue',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 600.ms),
                    
                    const SizedBox(height: AppTheme.spacingXXL),
                    
                    // Password input or user selection
                    if (!_showUserSelection) ...[
                      _buildPasswordInput(),
                    ] else ...[
                      _buildUserSelection(),
                    ],
                    
                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppTheme.spacingL),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.red[300],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .shake(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      children: [
        // Password field
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(
              color: AppTheme.cardBorder,
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            style: AppTheme.bodyLarge,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Enter password',
              hintStyle: TextStyle(color: AppTheme.textTertiary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppTheme.spacingL),
            ),
            onSubmitted: (_) => _validatePassword(),
          ),
        )
        .animate(delay: 400.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: AppTheme.spacingL),
        
        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _validatePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.buttonBackground,
              padding: const EdgeInsets.all(AppTheme.spacingL),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
            ),
            child: const Text(
              'Continue',
              style: AppTheme.buttonText,
            ),
          ),
        )
        .animate(delay: 600.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildUserSelection() {
    return Column(
      children: [
        Text(
          'Choose Your Identity',
          style: AppTheme.heading3,
          textAlign: TextAlign.center,
        )
        .animate()
        .fadeIn(duration: 600.ms),
        
        const SizedBox(height: AppTheme.spacingXL),
        
        // User buttons
        Row(
          children: [
            // NDG button
            Expanded(
              child: _buildUserButton(
                'NDG',
                'The loving partner',
                const Color(0xFFE91E63),
                () => _selectUser('ndg'),
              ),
            ),
            
            const SizedBox(width: AppTheme.spacingL),
            
            // AK button
            Expanded(
              child: _buildUserButton(
                'AK',
                'The beloved one',
                const Color(0xFF9C27B0),
                () => _selectUser('ak'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserButton(
    String name,
    String description,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: color.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
              ),
              child: Icon(
                Icons.person,
                size: 30,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            Text(
              name,
              style: AppTheme.heading3.copyWith(fontSize: 24),
            ),
            
            const SizedBox(height: AppTheme.spacingS),
            
            Text(
              description,
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
    .animate(delay: 200.ms)
    .fadeIn(duration: 600.ms)
    .slideY(begin: 0.3, end: 0);
  }
}