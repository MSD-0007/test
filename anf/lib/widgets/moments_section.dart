import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import '../providers/supabase_moments_provider.dart';
import '../providers/app_state_provider.dart';

class MomentsSection extends StatelessWidget {
  const MomentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SupabaseMomentsProvider>(
      builder: (context, momentsProvider, child) {
        return Column(
          children: [
            // Section header
            Text(
              'Our Moments Together',
              style: AppTheme.heading2.copyWith(fontSize: 28),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.2, end: 0),
            
            const SizedBox(height: AppTheme.spacingM),
            
            Text(
              'Every photo tells our story of love 💕',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            )
            .animate(delay: 200.ms)
            .fadeIn(duration: 600.ms),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Add new moment button
            _buildAddMomentButton(context, momentsProvider),
            
            const SizedBox(height: AppTheme.spacingM),
            
            // Refresh button
            _buildRefreshButton(context, momentsProvider),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Moments grid or empty state with pull-to-refresh
            RefreshIndicator(
              onRefresh: () async {
                print('🔄 Pull-to-refresh triggered');
                await momentsProvider.refresh();
              },
              child: momentsProvider.moments.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 300,
                        child: _buildEmptyState(),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: _buildMomentsGrid(momentsProvider.moments),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddMomentButton(BuildContext context, SupabaseMomentsProvider provider) {
    return Column(
      children: [
        // Simple header
        Text(
          'Add a New Moment 📸',
          style: AppTheme.heading3.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: 300.ms),
        
        const SizedBox(height: AppTheme.spacingL),
        
        // Centered button
        Center(
          child: SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                print('🎯 Add photo button pressed!');
                _showImagePicker(context, provider);
              },
              icon: const Icon(Icons.add_photo_alternate, color: Colors.white, size: 20),
              label: const Text(
                'Choose Photo',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 16, 
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: 500.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
      ],
    );
  }

  Widget _buildRefreshButton(BuildContext context, SupabaseMomentsProvider provider) {
    return Center(
      child: SizedBox(
        width: 160,
        height: 40,
        child: ElevatedButton.icon(
          onPressed: () async {
            print('🔄 Manual refresh triggered');
            await provider.refresh();
          },
          icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
          label: const Text(
            'Refresh Photos',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            elevation: 4,
            shadowColor: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: AppTheme.textTertiary.withValues(alpha: 0.5),
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          Text(
            'No moments yet. Start adding your beautiful memories together! 💕',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 800.ms, delay: 600.ms);
  }

  Widget _buildMomentsGrid(List<Map<String, dynamic>> moments) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacingM,
        mainAxisSpacing: AppTheme.spacingM,
        childAspectRatio: 1.0,
      ),
      itemCount: moments.length,
      itemBuilder: (context, index) {
        return _buildMomentCard(moments[index], index);
      },
    );
  }

  Widget _buildMomentCard(Map<String, dynamic> moment, int index) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final isOwner = moment['uploaded_by'] == appState.currentUserId;
        
        return GestureDetector(
          onTap: () => _showPhotoViewer(context, moment),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Stack(
            children: [
              // Background image (slightly blurred for glass effect)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  child: Image.network(
                    moment['image_url'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
              ),
              
              // Strong glassmorphism overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.1),
                          ],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Image content with reduced opacity to show glass effect
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL - 2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL - 2),
                    ),
                    child: Opacity(
                      opacity: 0.85,
                      child: Image.network(
                        moment['image_url'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error, color: Colors.red),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              // Additional glass reflection effect
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 60,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusL),
                    topRight: Radius.circular(AppTheme.radiusL),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.6),
                          Colors.white.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Delete button (only for owner) with enhanced glassmorphism
              if (isOwner)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => _deleteMoment(context, moment['id']),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.withValues(alpha: 0.9),
                                Colors.red.withValues(alpha: 0.7),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Uploader indicator with enhanced glassmorphism
              Positioned(
                bottom: 10,
                left: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        moment['uploaded_by'].toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
      },
    );
  }

  void _showImagePicker(BuildContext context, SupabaseMomentsProvider provider) {
    print('📱 Showing image picker modal...');
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add a New Moment',
                style: AppTheme.heading3,
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print('📷 Camera button pressed!');
                        Navigator.pop(context);
                        _pickImage(context, ImageSource.camera, provider);
                      },
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text('Camera', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: AppTheme.spacingM),
                  
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print('🖼️ Gallery button pressed!');
                        Navigator.pop(context);
                        _pickImage(context, ImageSource.gallery, provider);
                      },
                      icon: const Icon(Icons.photo_library, color: Colors.white),
                      label: const Text('Gallery', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source, SupabaseMomentsProvider provider) async {
    print('📸 Starting image picker...');
    print('📋 Source: $source');
    
    // Store the navigator and scaffold messenger before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Check authentication first
    final appState = context.read<AppStateProvider>();
    print('📋 Current user ID: ${appState.currentUserId}');
    print('📋 Is authenticated: ${appState.isAuthenticated}');
    
    if (!appState.isAuthenticated || appState.currentUserId == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Please authenticate first! Go to settings and select your user.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      
      print('📋 Picked file: ${pickedFile?.path}');
      
      if (pickedFile != null) {
        print('📋 File selected, starting upload process...');
        
        // Show loading dialog using stored navigator
        showDialog(
          context: navigator.context,
          barrierDismissible: false,
          builder: (dialogContext) => const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Uploading photo...'),
              ],
            ),
          ),
        );
        
        try {
          print('📋 Calling provider.addMoment...');
          await provider.addMoment(pickedFile.path);
          print('✅ Photo upload successful!');
          
          // Close loading dialog
          navigator.pop();
          
          // Show success message
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Photo uploaded successfully! 📸'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          print('❌ Photo upload failed: $e');
          print('❌ Error details: ${e.toString()}');
          
          // Close loading dialog
          navigator.pop();
          
          // Show error message
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Failed to upload photo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('📋 No file selected');
      }
    } catch (e) {
      print('❌ Image picker failed: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPhotoViewer(BuildContext context, Map<String, dynamic> moment) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Photo viewer
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  child: Image.network(
                    moment['image_url'],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(
                          child: Icon(Icons.error, color: Colors.white, size: 50),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            
            // Photo info
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Uploaded by ${moment['uploaded_by'].toString().toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (moment['created_at'] != null)
                      Text(
                        'Shared with love 💕',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMoment(BuildContext context, String momentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Delete Moment', style: AppTheme.heading3),
        content: const Text('Are you sure you want to delete this moment?', style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<SupabaseMomentsProvider>();
              await provider.deleteMoment(momentId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}