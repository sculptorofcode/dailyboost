import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Utility class to check Google Play Services availability
/// and handle graceful fallbacks
class PlayServicesUtils {
  static const platform = MethodChannel('com.srtech.dailyboost/playservices');
  
  /// Check if Google Play Services is available and up-to-date
  static Future<bool> checkPlayServices() async {
    if (!Platform.isAndroid) {
      return true; // Not needed on platforms other than Android
    }
    
    try {
      final bool isAvailable = await platform.invokeMethod('isGooglePlayServicesAvailable');
      return isAvailable;
    } on PlatformException catch (e) {
      debugPrint('Error checking Google Play Services: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error checking Google Play Services: $e');
      return false;
    }
  }
  
  /// Check if the app should use Firebase services or fallback to local data
  static Future<bool> shouldUseFirebase() async {
    if (!Platform.isAndroid) {
      return true; // Always use Firebase on non-Android platforms
    }
    
    try {
      final bool playServicesAvailable = await checkPlayServices();
      return playServicesAvailable;
    } catch (e) {
      debugPrint('Error determining Firebase usage: $e');
      return false; // Fallback to local storage on any error
    }
  }
}
