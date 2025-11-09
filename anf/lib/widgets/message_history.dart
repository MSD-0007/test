import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/ping_message.dart';
import '../models/ping_type.dart';
import '../theme/app_theme.dart';
import '../providers/app_state_provider.dart';

class MessageHistory extends StatelessWidget {
  const MessageHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        if (appState.recentMessages.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.favorite_outline,
                  size: 48,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'No messages yet',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Send your first ping to get started! 💕',
                  style: AppTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Messages',
              style: AppTheme.heading3,
            )
            .animate()
            .fadeIn(duration: 600.ms),

            const SizedBox(height: AppTheme.spacingM),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appState.recentMessages.length > 5 
                  ? 5 
                  : appState.recentMessages.length,
              separatorBuilder: (context, index) => 
                  const SizedBox(height: AppTheme.spacingS),
              itemBuilder: (context, index) {
                final message = appState.recentMessages[index];
                return _MessageTile(message: message)
                    .animate(delay: (index * 100).ms)
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: -0.3, end: 0);
              },
            ),
          ],
        );
      },
    );
  }
}

class _MessageTile extends StatelessWidget {
  final PingMessage message;

  const _MessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    final pingType = PingType.fromString(message.type);
    final isFromCurrentUser = message.from == 
        context.read<AppStateProvider>().currentUserId;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: pingType.gradientColors.first.withValues(alpha: 0.3),
        ),
        gradient: LinearGradient(
          colors: [
            pingType.gradientColors.first.withValues(alpha: 0.1),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: pingType.gradientColors,
              ),
            ),
            child: Icon(
              pingType.icon,
              size: 20,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: AppTheme.spacingM),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${pingType.emoji} ${pingType.label}',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      isFromCurrentUser ? 'Sent' : 'Received',
                      style: AppTheme.bodySmall.copyWith(
                        color: isFromCurrentUser 
                            ? Colors.green[300] 
                            : Colors.blue[300],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingXS),
                
                Text(
                  _getTimeAgo(message.timestamp),
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}