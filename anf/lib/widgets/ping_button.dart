import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/ping_type.dart';
import '../theme/app_theme.dart';

class PingButton extends StatefulWidget {
  final PingType pingType;
  final VoidCallback onTap;
  final bool isLoading;

  const PingButton({
    super.key,
    required this.pingType,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<PingButton> createState() => _PingButtonState();
}

class _PingButtonState extends State<PingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.animationMedium,
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
      end: 0.05,
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

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.isLoading ? null : widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.pingType.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: widget.pingType.gradientColors.first.withValues(alpha: 0.3),
                      blurRadius: _isPressed ? 15 : 20,
                      offset: Offset(0, _isPressed ? 5 : 10),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      // Shimmer effect overlay
                      gradient: _isPressed
                          ? LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.1),
                                Colors.transparent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon container (responsive size)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: widget.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  widget.pingType.icon,
                                  size: 24,
                                  color: Colors.white,
                                ),
                        ),

                        const SizedBox(height: 8),

                        // Emoji and label (responsive text)
                        Flexible(
                          child: Text(
                            '${widget.pingType.emoji} ${widget.pingType.label}',
                            style: AppTheme.pingLabel.copyWith(fontSize: 12),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Description (smaller and flexible)
                        Flexible(
                          child: Text(
                            _getShortDescription(),
                            style: AppTheme.pingDescription.copyWith(fontSize: 9),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getShortDescription() {
    switch (widget.pingType) {
      case PingType.thinkingOfYou:
        return 'You crossed my mind...';
      case PingType.missYou:
        return 'Missing you so much!';
      case PingType.loveYou:
        return 'You mean everything!';
      case PingType.needYou:
        return 'Need to hear your voice';
      case PingType.freeTalk:
        return 'Are you free to talk?';
      case PingType.busy:
        return 'Busy right now';
      case PingType.goodMorning:
        return 'Have an amazing day!';
      case PingType.sweetDreams:
        return 'Sweet dreams, love';
      case PingType.hug:
        return 'Sending warm hugs!';
    }
  }
}