// lib/core/services/firebase_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:solo_leveling/core/enums/user_rank.dart';
import '../../core/models/user_model.dart';
import '../../core/exceptions/app_exceptions.dart';

class FirebaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Database references
  DatabaseReference get _usersRef => _database.ref('users');
  DatabaseReference get _exercisesRef => _database.ref('exercises');
  DatabaseReference get _questsRef => _database.ref('quests');

  // Get user reference for current user
  DatabaseReference getUserRef(String userId) => _usersRef.child(userId);

  // User methods
  Future<UserModel> getUserData(String userId) async {
    try {
      final snapshot = await getUserRef(userId).get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final convertedData = Map<String, dynamic>.from(data);
        return UserModel.fromJson(convertedData);
      } else {
        throw AppException('User not found');
      }
    } catch (e) {
      throw AppException('Failed to get user data: ${e.toString()}');
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await getUserRef(user.id).set(user.toJson());
    } catch (e) {
      throw AppException('Failed to create user: ${e.toString()}');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await getUserRef(user.id).update(user.toJson());
    } catch (e) {
      throw AppException('Failed to update user: ${e.toString()}');
    }
  }

  // Update specific user fields
  Future<void> updateUserStats(String userId, UserStats stats) async {
    try {
      await getUserRef(userId).child('stats').update(stats.toJson());
    } catch (e) {
      throw AppException('Failed to update user stats: ${e.toString()}');
    }
  }

  Future<void> updateUserXP(String userId, int xp, int xpToNextLevel) async {
    try {
      await getUserRef(userId).update({
        'xp': xp,
        'xpToNextLevel': xpToNextLevel,
      });
    } catch (e) {
      throw AppException('Failed to update user XP: ${e.toString()}');
    }
  }

  Future<void> levelUpUser(
      String userId, int newLevel, UserRank newRank) async {
    try {
      await getUserRef(userId).update({
        'level': newLevel,
        'rank': newRank.name,
        'xp': 0, // Reset XP after level up
      });
    } catch (e) {
      throw AppException('Failed to level up user: ${e.toString()}');
    }
  }

  Future<void> addCompletedQuest(String userId, String questId) async {
    try {
      final userRef = getUserRef(userId);
      final snapshot = await userRef.child('completedQuests').get();

      List<String> completedQuests = [];
      if (snapshot.exists) {
        completedQuests = List<String>.from(snapshot.value as List);
      }

      if (!completedQuests.contains(questId)) {
        completedQuests.add(questId);
        await userRef.child('completedQuests').set(completedQuests);
      }
    } catch (e) {
      throw AppException('Failed to add completed quest: ${e.toString()}');
    }
  }

  Future<void> addAchievement(String userId, String achievementId) async {
    try {
      final userRef = getUserRef(userId);
      final snapshot = await userRef.child('achievements').get();

      List<String> achievements = [];
      if (snapshot.exists) {
        achievements = List<String>.from(snapshot.value as List);
      }

      if (!achievements.contains(achievementId)) {
        achievements.add(achievementId);
        await userRef.child('achievements').set(achievements);
      }
    } catch (e) {
      throw AppException('Failed to add achievement: ${e.toString()}');
    }
  }

  // Update user's last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await getUserRef(userId).update({
        'lastActive': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AppException('Failed to update last active: ${e.toString()}');
    }
  }

  // Exercise methods
  Future<Map<String, dynamic>> getExercises() async {
    try {
      final snapshot = await _exercisesRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return Map<String, dynamic>.from(data);
      } else {
        return {};
      }
    } catch (e) {
      throw AppException('Failed to get exercises: ${e.toString()}');
    }
  }

  // Quest methods
  Future<Map<String, dynamic>> getDailyQuests() async {
    try {
      final snapshot =
          await _questsRef.orderByChild('isDaily').equalTo(true).get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return Map<String, dynamic>.from(data);
      } else {
        return {};
      }
    } catch (e) {
      throw AppException('Failed to get daily quests: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getQuestById(String questId) async {
    try {
      final snapshot = await _questsRef.child(questId).get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return Map<String, dynamic>.from(data);
      } else {
        throw AppException('Quest not found');
      }
    } catch (e) {
      throw AppException('Failed to get quest: ${e.toString()}');
    }
  }

  // Authentication methods that integrate with user data
  Future<UserModel> signInUser(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;
      final userData = await getUserData(userId);
      await updateLastActive(userId);

      return userData;
    } catch (e) {
      throw AppException('Failed to sign in: ${e.toString()}');
    }
  }

  Future<UserModel> registerUser(
      String username, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;
      final newUser = UserModel.createNew(
        id: userId,
        username: username,
        email: email,
      );

      await createUser(newUser);
      return newUser;
    } catch (e) {
      throw AppException('Failed to register: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      final userId = currentUserId;
      if (userId != null) {
        await updateLastActive(userId);
      }
      await _auth.signOut();
    } catch (e) {
      throw AppException('Failed to sign out: ${e.toString()}');
    }
  }
}
