import 'package:dailyboost/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:dailyboost/features/auth/presentation/screens/login_screen.dart';
import 'package:dailyboost/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter/material.dart';

import 'bottom_nav_scaffold.dart';

class Routes {
  // Route names
  static const String home = '/';
  static const String favorites = '/favorites';
  static const String quotes = '/quotes';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String createQuote = '/create-quote';
  static const String editQuote = '/edit-quote';
  static const String myQuotes = '/my-quotes';

  // Tab indices
  static const int homeIndex = 0;
  static const int favoritesIndex = 1;
  static const int myQuotesIndex = 2;
  static const int profileIndex = 3;
  static const int settingsIndex = 4;

  // Generate routes for authenticated users
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: homeIndex),
        );
      case favorites:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: favoritesIndex),
        );
      case quotes:
      case myQuotes:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: myQuotesIndex),
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: profileIndex),
        );
      case Routes.settings:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: settingsIndex),
        );
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(initialIndex: homeIndex),
        );
    }
  }
}