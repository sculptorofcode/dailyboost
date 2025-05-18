import 'package:dailyboost/features/auth/data/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dailyboost/features/auth/data/services/auth_service.dart';
import 'package:dailyboost/features/auth/data/services/profile_service.dart';

// Renamed from AuthProvider to UserAuthProvider to avoid name conflicts with Firebase's AuthProvider
class UserAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  
  User? _user;
  UserProfileModel? _userProfile;
  bool _isLoading = true;
  bool _isProfileLoading = false;

  UserAuthProvider() {
    // Listen for authentication state changes
    _authService.authStateChanges.listen((user) async {
      _user = user;
      _isLoading = false;
      
      if (user != null) {
        // Load or create user profile
        await _loadUserProfile();
      } else {
        _userProfile = null;
      }
      
      notifyListeners();
    });
  }

  // Current user
  User? get user => _user;
  
  // User profile
  UserProfileModel? get userProfile => _userProfile;
  
  // Loading states
  bool get isLoading => _isLoading;
  bool get isProfileLoading => _isProfileLoading;

  // Check if user is authenticated
  bool get isAuthenticated => _user != null;

  // Load user profile from Firestore
  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    
    _isProfileLoading = true;
    notifyListeners();
    
    try {
      // Try to get existing profile
      _userProfile = await _profileService.getUserProfile(_user!.uid);
      
      // If no profile exists, create one
      if (_userProfile == null) {
        _userProfile = await _profileService.createInitialProfile(_user!);
      } else {
        // Update last active status
        await _profileService.updateLastActive(_user!.uid);
      }
    } catch (e) {
      // If there's an error, try to create a basic profile
      _userProfile = UserProfileModel(
        uid: _user!.uid,
        displayName: _user!.displayName,
        email: _user!.email,
        photoURL: _user!.photoURL,
      );
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfileModel updatedProfile) async {
    if (_user == null) return;
    
    try {
      await _profileService.saveUserProfile(updatedProfile);
      _userProfile = updatedProfile;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    try {
      await _authService.login(email: email, password: password);
      // Profile will be loaded by the auth state listener
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      // Profile will be loaded by the auth state listener
      return credential?.user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email and password
  Future<void> signUp(String email, String password) async {
    try {
      await _authService.signUp(email: email, password: password);
      // Profile will be created by the auth state listener
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _userProfile = null;
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }
  
  // Refresh user profile data
  Future<void> refreshProfile() async {
    if (_user == null) return;
    await _loadUserProfile();
  }
  
  // Update user location
  Future<void> updateLocation() async {
    if (_user == null || _userProfile == null) return;
    
    try {
      final location = await _profileService.getCurrentLocation();
      if (location != null && _userProfile != null) {
        final updatedProfile = _userProfile!.copyWith(location: location);
        await updateUserProfile(updatedProfile);
      }
    } catch (e) {
      // Silently fail
    }
  }
}
