import 'package:flutter/material.dart';

import 'routes.dart';

/// Navigation utility class to replace go_router context.go() methods
class NavigationUtils {
  /// Navigate to a named route
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  /// Navigate to the home screen
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.home,
      (route) => false,
    );
  }

  /// Navigate to the login screen
  static void navigateToLogin(BuildContext context) {
    navigateTo(context, Routes.login);
  }

  /// Navigate to the signup screen
  static void navigateToSignup(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.signup);
  }

  /// Navigate to forgot password screen
  static void navigateToForgotPassword(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.forgotPassword);
  }

  /// Navigate to favorites screen
  static void navigateToFavorites(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.favorites);
  }

  /// Navigate to profile screen
  static void navigateToProfile(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.profile);
  }

  /// Navigate to settings screen
  static void navigateToSettings(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.settings);
  }
}