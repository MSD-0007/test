import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/app_state_provider.dart';

class HugsSection extends StatefulWidget {
  const HugsSection({super.key});

  @override
  State<HugsSection> createState() => _HugsSectionState();
}

class _HugsSectionState extends State<HugsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section header
        Text(
          'Hidden Hugs',
          style: AppTheme.heading2.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.2, end: 0),
        
        const SizedBox(height: AppTheme.spacingM),
        
        Text(
          'For when you need a little extra love. Click below for a secret message.',
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textTertiary,
          ),
          textAlign: TextAlign.center,
        )
        .animate(delay: 200.ms)
        .fadeIn(duration: 600.ms),
        
        const SizedBox(height: AppTheme.spacingXXL),
        
        // Hug button
        _buildHugButton(),
        
        const SizedBox(height: AppTheme.spacingXXL),
      ],
    );
  }

  Widget _buildHugButton() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: GestureDetector(
                  onTapDown: (_) {
                    setState(() {
                      _isPressed = true;
                    });
                    _animationController.forward();
                  },
                  onTapUp: (_) {
                    setState(() {
                      _isPressed = false;
                    });
                    _animationController.reverse();
                  },
                  onTapCancel: () {
                    setState(() {
                      _isPressed = false;
                    });
                    _animationController.reverse();
                  },
                  onTap: () => _sendHug(context, appState),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXL,
                      vertical: AppTheme.spacingL,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B9D).withValues(alpha: 0.8),
                          const Color(0xFFFF8E9B).withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                          blurRadius: _isPressed ? 15 : 20,
                          offset: Offset(0, _isPressed ? 5 : 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Heart icon (smaller)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(width: AppTheme.spacingM),
                        
                        // Button text
                        Text(
                          '🤗 Send me a hug',
                          style: AppTheme.heading3.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    )
    .animate(delay: 400.ms)
    .fadeIn(duration: 800.ms)
    .slideY(begin: 0.3, end: 0);
  }

  void _sendHug(BuildContext context, AppStateProvider appState) {
    // Send a special hug ping
    appState.sendPing('hug', '🤗 Sending you the biggest, warmest hug! You are so loved and cherished. 💕');
    
    // Show a beautiful confirmation
    _showHugSentDialog(context);
  }

  void _showHugSentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B9D).withValues(alpha: 0.95),
                  const Color(0xFFFF8E9B).withValues(alpha: 0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated heart
                const Icon(
                  Icons.favorite,
                  size: 60,
                  color: Colors.white,
                )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.2, 1.2),
                  duration: 1000.ms,
                )
                .then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1.0, 1.0),
                  duration: 1000.ms,
                ),
                
                const SizedBox(height: AppTheme.spacingL),
                
                Text(
                  'Hug Sent! 🤗',
                  style: AppTheme.heading2.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacingM),
                
                Text(
                  'Your love is on its way! 💕',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacingL),
                
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}