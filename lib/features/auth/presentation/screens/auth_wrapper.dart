import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dailyboost/features/auth/logic/providers/auth_provider.dart';
import 'package:dailyboost/features/auth/presentation/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;
  
  const AuthWrapper({
    super.key,
    required this.child,
  });

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
          return child;
        } else {
          // User is not authenticated, redirect to login
          return const LoginScreen();
        }
      },
    );
  }
}