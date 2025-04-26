import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dailyboost/features/auth/data/services/auth_service.dart';

// Renamed from AuthProvider to UserAuthProvider to avoid name conflicts with Firebase's AuthProvider
class UserAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;

  UserAuthProvider() {
    // Listen for authentication state changes
    _authService.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Current user
  User? get user => _user;
  
  // Loading state
  bool get isLoading => _isLoading;

  // Check if user is authenticated
  bool get isAuthenticated => _user != null;

  // Login with email and password
  Future<void> login(String email, String password) async {
    try {
      await _authService.login(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email and password
  Future<void> signUp(String email, String password) async {
    try {
      await _authService.signUp(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }
}