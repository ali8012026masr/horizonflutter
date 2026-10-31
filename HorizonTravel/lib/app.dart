import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class HorizonTravelApp extends StatelessWidget {
  const HorizonTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp(
      title: 'Horizon Travel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      home: const SplashScreen(),
    );
  }
}
