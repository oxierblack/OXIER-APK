import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'providers/app_store.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verify_screen.dart';
import 'screens/auth/pin_screen.dart';
import 'screens/trading/trading_platform.dart';

class OxierApp extends StatelessWidget {
  const OxierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStore>(
      builder: (context, store, _) {
        return MaterialApp(
          title: 'OXIER',
          debugShowCheckedModeBanner: false,
          theme: store.isDark ? AppColors.darkTheme : AppColors.lightTheme,
          home: _buildScreen(store),
        );
      },
    );
  }

  Widget _buildScreen(AppStore store) {
    switch (store.screen) {
      case AppScreen.splash: return const SplashScreen();
      case AppScreen.login: return const LoginScreen();
      case AppScreen.register: return const RegisterScreen();
      case AppScreen.verify: return const VerifyScreen();
      case AppScreen.pin: return const PinScreen();
      case AppScreen.trading: return const TradingPlatform();
    }
  }
}
