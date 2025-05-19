import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/logic/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import 'routes.dart';

/// Main navigation coordinator for the app
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserAuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          // Show loading indicator while checking authentication status
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }        // Use a single Navigator with named routes
        return WillPopScope(
          // This is the top-level WillPopScope that works with the ExitConfirmationWrapper
          onWillPop:
              () async =>
                  false, // Force handling in the ExitConfirmationWrapper
          child: Navigator(
            key: _rootNavigatorKey,
            initialRoute:
                authProvider.isAuthenticated ? Routes.home : Routes.login,
            onGenerateRoute: (settings) {
              // Choose route generation based on authentication state (including guest mode)
              if (authProvider.isAuthenticated) {
                return Routes.generateRoute(settings);
              } else {
                if (settings.name == Routes.login ||
                    settings.name == Routes.signup ||
                    settings.name == Routes.forgotPassword) {
                  return Routes.generateRoute(settings);
                }
                // Default to login for unauthenticated users trying to access protected routes
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              }
            },
          ),
        );
      },
    );
  }
}
