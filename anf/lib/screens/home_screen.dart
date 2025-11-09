import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import '../widgets/floating_particles.dart';
import '../widgets/ping_grid.dart';
import '../widgets/moments_section.dart';

import '../providers/app_state_provider.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            // Floating particles
            const FloatingParticles(),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header with user info
                  _buildHeader(),
                  
                  // Main content area with pull-to-refresh
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        print('🔄 App-wide refresh triggered');
                        final appState = context.read<AppStateProvider>();
                        await appState.initialize();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppTheme.spacingL),
                        child: Column(
                          children: [
                            // Hero section
                            _buildHeroSection(),
                            
                            const SizedBox(height: AppTheme.spacingXXL),
                            
                            // Ping buttons grid
                            _buildPingGrid(),
                            
                            const SizedBox(height: AppTheme.spacingXXL),
                            
                            // Moments Together section
                            const MomentsSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Row(
            children: [
              // User identity display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Logged in as:',
                      style: AppTheme.bodySmall,
                    ),
                    Text(
                      appState.displayName,
                      style: AppTheme.heading3.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Logout button
              IconButton(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(
                  Icons.logout,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Text(
          'Our Secret Love Space',
          style: AppTheme.heading1.copyWith(fontSize: 36),
          textAlign: TextAlign.center,
        )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: -0.3, end: 0),
        
        const SizedBox(height: AppTheme.spacingM),
        
        Text(
          'A place where our hearts connect, no matter the distance 💕',
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textTertiary,
          ),
          textAlign: TextAlign.center,
        )
        .animate(delay: 300.ms)
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildPingGrid() {
    return const PingGrid();
  }



  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            side: const BorderSide(color: AppTheme.cardBorder),
          ),
          title: const Text(
            'Logout',
            style: AppTheme.heading3,
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: AppTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final appState = context.read<AppStateProvider>();
                await appState.logout();
                
                if (!context.mounted) return;
                
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.3),
              ),
              child: const Text(
                'Logout',
                style: AppTheme.buttonText,
              ),
            ),
          ],
        );
      },
    );
  }
}