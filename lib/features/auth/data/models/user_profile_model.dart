import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final String? deviceId;
  final GeoPoint? location;
  final String? deviceModel;
  final String? deviceOS;
  final Timestamp? lastActive;
  final Timestamp? createdAt;
  final Map<String, dynamic>? settings;

  UserProfileModel({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.deviceId,
    this.location,
    this.deviceModel,
    this.deviceOS,
    this.lastActive,
    this.createdAt,
    this.settings,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'deviceId': deviceId,
      'location': location,
      'deviceModel': deviceModel,
      'deviceOS': deviceOS,
      'lastActive': lastActive ?? Timestamp.now(),
      'createdAt': createdAt ?? Timestamp.now(),
      'settings': settings ?? {},
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'],
      email: map['email'],
      photoURL: map['photoURL'],
      deviceId: map['deviceId'],
      location: map['location'],
      deviceModel: map['deviceModel'],
      deviceOS: map['deviceOS'],
      lastActive: map['lastActive'],
      createdAt: map['createdAt'],
      settings: map['settings'],
    );
  }

  UserProfileModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
    String? deviceId,
    GeoPoint? location,
    String? deviceModel,
    String? deviceOS,
    Timestamp? lastActive,
    Timestamp? createdAt,
    Map<String, dynamic>? settings,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      deviceId: deviceId ?? this.deviceId,
      location: location ?? this.location,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceOS: deviceOS ?? this.deviceOS,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
    );
  }
}