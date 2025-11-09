import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/ping_type.dart';
import '../theme/app_theme.dart';
import '../widgets/ping_button.dart';
import '../providers/app_state_provider.dart';

class PingGrid extends StatelessWidget {
  const PingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Column(
          children: [
            // Title
            Text(
              'Quick Pings',
              style: AppTheme.heading2,
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.3, end: 0),

            const SizedBox(height: AppTheme.spacingM),

            Text(
              'Send a quick message to let them know what\'s on your mind',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            )
            .animate(delay: 200.ms)
            .fadeIn(duration: 600.ms),

            const SizedBox(height: AppTheme.spacingXL),

            // Ping buttons grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppTheme.spacingM,
                mainAxisSpacing: AppTheme.spacingM,
                childAspectRatio: 1.0, // Increased from 0.85 to fix overflow
              ),
              itemCount: PingType.values.length,
              itemBuilder: (context, index) {
                final pingType = PingType.values[index];
                return PingButton(
                  pingType: pingType,
                  isLoading: appState.isLoading,
                  onTap: () => _sendPing(context, appState, pingType),
                )
                .animate(delay: (index * 100).ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
              },
            ),
          ],
        );
      },
    );
  }

  void _sendPing(BuildContext context, AppStateProvider appState, PingType pingType) async {
    final success = await appState.sendPing(pingType.value, pingType.message);
    
    if (!context.mounted) return;
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success 
            ? '💕 ${pingType.label} sent successfully!'
            : '❌ Failed to send ping. Please try again.',
        ),
        backgroundColor: success 
          ? Colors.green.withValues(alpha: 0.8)
          : Colors.red.withValues(alpha: 0.8),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
    );
  }
}