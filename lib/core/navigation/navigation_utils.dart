import 'package:flutter/material.dart';

import '../../features/quotes/data/models/custom_quote_model.dart';
import '../../features/quotes/presentation/screens/custom_quotes/create_quote_screen.dart';
import 'routes.dart';

/// Navigation utility class to replace go_router context.go() methods
class NavigationUtils {
  /// Navigate to a named route
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navigate to the home screen
  static void navigateToHome(BuildContext context) {
    navigateTo(context, Routes.home);
  }

  /// Navigate to the login screen
  static void navigateToLogin(BuildContext context) {
    navigateTo(context, Routes.login);
  }

  /// Navigate to the signup screen
  static void navigateToSignup(BuildContext context) {
    navigateTo(context, Routes.signup);
  }

  /// Navigate to forgot password screen
  static void navigateToForgotPassword(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.forgotPassword);
  }

  /// Navigate to create quote screen
  static void navigateToCreateQuote(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const CreateQuoteScreen(isEditing: false),
        fullscreenDialog: true,
      ),
    );
  }

  /// Navigate to edit quote screen
  static void navigateToEditQuote(BuildContext context, CustomQuoteModel quote) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => CreateQuoteScreen(isEditing: true, quote: quote),
        fullscreenDialog: true,
      ),
    );
  }

  /// Navigate to favorites screen
  static void navigateToFavorites(BuildContext context) {
    navigateTo(context, Routes.favorites);
  }

  /// Navigate to custom quotes screen
  static void navigateToCustomQuotes(BuildContext context) {
    navigateTo(context, Routes.quotes);
  }

  /// Navigate to profile screen
  static void navigateToProfile(BuildContext context) {
    navigateTo(context, Routes.profile);
  }

  /// Navigate to settings screen
  static void navigateToSettings(BuildContext context) {
    navigateTo(context, Routes.settings);
  }
}