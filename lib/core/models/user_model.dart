import 'package:flutter/foundation.dart';
import '../enums/user_rank.dart';

class UserStats {
  final int strength;
  final int endurance;
  final int agility;
  final int flexibility;

  const UserStats({
    this.strength = 1,
    this.endurance = 1,
    this.agility = 1,
    this.flexibility = 1,
  });

  UserStats copyWith({
    int? strength,
    int? endurance,
    int? agility,
    int? flexibility,
  }) {
    return UserStats(
      strength: strength ?? this.strength,
      endurance: endurance ?? this.endurance,
      agility: agility ?? this.agility,
      flexibility: flexibility ?? this.flexibility,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strength': strength,
      'endurance': endurance,
      'agility': agility,
      'flexibility': flexibility,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      strength: json['strength'] ?? 1,
      endurance: json['endurance'] ?? 1,
      agility: json['agility'] ?? 1,
      flexibility: json['flexibility'] ?? 1,
    );
  }
}

class UserModel {
  final String id;
  final String username;
  final String email;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final UserRank rank;
  final UserStats stats;
  final List<String> completedQuests;
  final List<String> achievements;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.level = 1,
    this.xp = 0,
    this.xpToNextLevel = 100,
    this.rank = UserRank.E,
    this.stats = const UserStats(),
    this.completedQuests = const [],
    this.achievements = const [],
    DateTime? createdAt,
    DateTime? lastActive,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.lastActive = lastActive ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    int? level,
    int? xp,
    int? xpToNextLevel,
    UserRank? rank,
    UserStats? stats,
    List<String>? completedQuests,
    List<String>? achievements,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      rank: rank ?? this.rank,
      stats: stats ?? this.stats,
      completedQuests: completedQuests ?? this.completedQuests,
      achievements: achievements ?? this.achievements,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  // Calculate progress percentage to next level
  double get levelProgress => xp / xpToNextLevel;

  // Check if player has enough XP to level up
  bool get canLevelUp => xp >= xpToNextLevel;

  // Get total stats value (used for rank calculation)
  int get totalStatsValue =>
      stats.strength + stats.endurance + stats.agility + stats.flexibility;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'level': level,
      'xp': xp,
      'xpToNextLevel': xpToNextLevel,
      'rank': rank.name,
      'stats': stats.toJson(),
      'completedQuests': completedQuests,
      'achievements': achievements,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      xpToNextLevel: json['xpToNextLevel'] ?? 100,
      rank: UserRank.values.firstWhere(
        (r) => r.name == json['rank'],
        orElse: () => UserRank.E,
      ),
      stats: UserStats.fromJson(json['stats'] ?? {}),
      completedQuests: List<String>.from(json['completedQuests'] ?? []),
      achievements: List<String>.from(json['achievements'] ?? []),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastActive: DateTime.parse(
          json['lastActive'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Create a new empty user
  factory UserModel.createNew({
    required String id,
    required String username,
    required String email,
  }) {
    return UserModel(
      id: id,
      username: username,
      email: email,
    );
  }
}
