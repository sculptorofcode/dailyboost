import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/logic/providers/auth_provider.dart';
import 'routes.dart';

/// Main navigation coordinator for the app
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  @override
  Widget build(BuildContext context) {
    return Consumer<UserAuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          // Show loading indicator while checking authentication status
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (authProvider.isAuthenticated) {
          // User is authenticated, show the app content
          return Navigator(
            key: _rootNavigatorKey,
            initialRoute: Routes.home,
            onGenerateRoute: (settings) {
              return Routes.generateRoute(settings);
            },
          );
        } else {
          // User is not authenticated, show auth screens
          return Navigator(
            key: _rootNavigatorKey,
            initialRoute: Routes.login,
            onGenerateRoute: (settings) {
              return Routes.generateAuthRoute(settings);
            },
          );
        }
      },
    );
  }
}