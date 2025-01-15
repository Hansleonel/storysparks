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
      ];
}
