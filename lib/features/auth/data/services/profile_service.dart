import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

import '../models/user_profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  
  // Reference to users collection
  CollectionReference get _usersCollection => _firestore.collection('users');
  
  // Get user profile
  Future<UserProfileModel?> getUserProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfileModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
  
  // Create or update user profile
  Future<void> saveUserProfile(UserProfileModel profile) async {
    try {
      await _usersCollection.doc(profile.uid).set(
        profile.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }
  
  // Get device info
  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.id; // Android device ID
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor ?? ''; // iOS device ID
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
  
  // Get device model
  Future<String> getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return '${iosInfo.name} ${iosInfo.model}';
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
  
  // Get device OS
  Future<String> getDeviceOS() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return 'iOS ${iosInfo.systemVersion}';
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
  
  // Get user's location (requires permission)
  Future<GeoPoint?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get the current position
      final position = await Geolocator.getCurrentPosition();
      return GeoPoint(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }
  
  // Create initial profile for a new user
  Future<UserProfileModel> createInitialProfile(User user) async {
    try {
      // Get device info
      final deviceId = await getDeviceId();
      final deviceModel = await getDeviceModel();
      final deviceOS = await getDeviceOS();
      
      // Try to get location
      final location = await getCurrentLocation();
      
      // Create profile
      final profile = UserProfileModel(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoURL: user.photoURL,
        deviceId: deviceId,
        location: location,
        deviceModel: deviceModel,
        deviceOS: deviceOS,
        lastActive: Timestamp.now(),
        createdAt: Timestamp.now(),
      );
      
      // Save to Firestore
      await saveUserProfile(profile);
      
      return profile;
    } catch (e) {
      throw Exception('Failed to create initial profile: $e');
    }
  }
  
  // Update user's last active timestamp
  Future<void> updateLastActive(String uid) async {
    try {
      await _usersCollection.doc(uid).update({
        'lastActive': Timestamp.now(),
      });
    } catch (e) {
      // Silently fail, not critical
    }
  }
}