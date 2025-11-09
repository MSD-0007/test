import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'theme/app_theme.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/haptic_service.dart';
import 'providers/app_state_provider.dart';
import 'providers/moments_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize services
  await _initializeServices();

  runApp(const SpecialLoveApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize Firebase
    await FirebaseService().initialize();
    
    // Initialize Notifications
    await NotificationService().initialize();
    await NotificationService().requestPermissions();
    
    // Initialize Haptics
    await HapticService().initialize();
    
    print('✅ All services initialized successfully');
  } catch (e) {
    print('❌ Error initializing services: $e');
  }
}

class SpecialLoveApp extends StatelessWidget {
  const SpecialLoveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProxyProvider<AppStateProvider, MomentsProvider>(
          create: (_) => MomentsProvider(),
          update: (_, appStateProvider, momentsProvider) {
            momentsProvider ??= MomentsProvider();
            appStateProvider.setMomentsProvider(momentsProvider);
            // Set current user if already authenticated
            if (appStateProvider.currentUserId != null) {
              momentsProvider.setCurrentUser(appStateProvider.currentUserId!);
            }
            // Initialize moments provider
            momentsProvider.initialize();
            return momentsProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Special Love',
        theme: AppTheme.materialTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}