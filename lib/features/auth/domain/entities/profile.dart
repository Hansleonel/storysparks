import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? email;
  final String? bio;
  final String provider;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSignIn;
  final int storiesGenerated;
  final int storiesShared;
  final int followersCount;
  final int followingCount;
  final bool isPrivate;
  final bool isVerified;
  final bool isPremium;

  const Profile({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.email,
    this.bio,
    required this.provider,
    required this.createdAt,
    required this.updatedAt,
    this.lastSignIn,
    this.storiesGenerated = 0,
    this.storiesShared = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isPrivate = false,
    this.isVerified = false,
    this.isPremium = false,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        fullName,
        avatarUrl,
        email,
        bio,
        provider,
        createdAt,
        updatedAt,
        lastSignIn,
        storiesGenerated,
        storiesShared,
        followersCount,
        followingCount,
        isPrivate,
        isVerified,
        isPremium,
      ];

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      fullName: map['full_name'],
      avatarUrl: map['avatar_url'],
      email: map['email'],
      bio: map['bio'],
      provider: map['provider'] ?? 'email',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      lastSignIn: map['last_sign_in'] != null
          ? DateTime.tryParse(map['last_sign_in'])
          : null,
      storiesGenerated: map['stories_generated'] ?? 0,
      storiesShared: map['stories_shared'] ?? 0,
      followersCount: map['followers_count'] ?? 0,
      followingCount: map['following_count'] ?? 0,
      isPrivate: map['is_private'] ?? false,
      isVerified: map['is_verified'] ?? false,
      isPremium: map['is_premium'] ?? false,
    );
  }
}
