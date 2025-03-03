import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:solo_leveling/core/models/user_model.dart';

class UserRepository {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final String _usersPath = 'users';

  // Get user by ID
  Future<UserModel> getUserById(String userId) async {
    try {
      final snapshot = await _database.child('$_usersPath/$userId').get();

      if (snapshot.exists) {
        return UserModel.fromJson(
            {'id': userId, ...snapshot.value as Map<dynamic, dynamic>});
      } else {
        throw UserNotFoundException('User with ID $userId not found');
      }
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw DatabaseException('Failed to fetch user: ${e.toString()}');
    }
  }

  // Create new user
  Future<UserModel> createUser(
      String userId, String username, String email) async {
    try {
      final newUser = UserModel.createNew(
        id: userId,
        username: username,
        email: email,
      );

      await _database.child('$_usersPath/$userId').set(newUser.toJson());
      return newUser;
    } catch (e) {
      throw DatabaseException('Failed to create user: ${e.toString()}');
    }
  }

  // Update user
  Future<UserModel> updateUser(UserModel user) async {
    try {
      await _database.child('$_usersPath/${user.id}').update(user.toJson());
      return user;
    } catch (e) {
      throw DatabaseException('Failed to update user: ${e.toString()}');
    }
  }

  // Update specific user fields
  Future<void> updateUserFields(
      String userId, Map<String, dynamic> fields) async {
    try {
      await _database.child('$_usersPath/$userId').update(fields);
    } catch (e) {
      throw DatabaseException('Failed to update user fields: ${e.toString()}');
    }
  }

  // Add XP to user and handle level up
  Future<UserModel> addUserXp(String userId, int xpAmount) async {
    try {
      // Use a transaction to ensure data consistency
      final userRef = _database.child('$_usersPath/$userId');

      final TransactionResult result =
          await userRef.runTransaction((Object? currentData) {
        if (currentData == null) {
          return Transaction.abort();
        }

        Map<dynamic, dynamic> userData = currentData as Map<dynamic, dynamic>;
        int currentXp = userData['xp'] ?? 0;
        int newXp = currentXp + xpAmount;
        int currentLevel = userData['level'] ?? 1;
        int xpToNextLevel = userData['xpToNextLevel'] ?? 100;

        userData['xp'] = newXp;

        // Check if level up
        if (newXp >= xpToNextLevel) {
          userData['level'] = currentLevel + 1;
          userData['xp'] = newXp - xpToNextLevel;

          // Calculate new XP needed for next level (simple formula)
          int newXpToNextLevel =
              ((currentLevel + 1) * 100) + ((currentLevel) * 25);
          userData['xpToNextLevel'] = newXpToNextLevel;

          // Update rank if needed (simplified logic)
          if (currentLevel + 1 >= 50) {
            userData['rank'] = 'S';
          } else if (currentLevel + 1 >= 40) {
            userData['rank'] = 'A';
          } else if (currentLevel + 1 >= 30) {
            userData['rank'] = 'B';
          } else if (currentLevel + 1 >= 20) {
            userData['rank'] = 'C';
          } else if (currentLevel + 1 >= 10) {
            userData['rank'] = 'D';
          }
        }

        return Transaction.success(userData);
      });

      if (result.committed) {
        final updatedData = result.snapshot.value as Map<dynamic, dynamic>;
        return UserModel.fromJson({'id': userId, ...updatedData});
      } else {
        throw DatabaseException(
            'Failed to update user XP: Transaction aborted');
      }
    } catch (e) {
      throw DatabaseException('Failed to add XP to user: ${e.toString()}');
    }
  }

  // Update user stats
  Future<UserModel> updateUserStats(String userId, UserStats newStats) async {
    try {
      await _database
          .child('$_usersPath/$userId/stats')
          .update(newStats.toJson());

      // Fetch and return the updated user
      return await getUserById(userId);
    } catch (e) {
      throw DatabaseException('Failed to update user stats: ${e.toString()}');
    }
  }

  // Add completed quest to user
  Future<void> addCompletedQuest(String userId, String questId) async {
    try {
      // Get current completed quests
      final snapshot =
          await _database.child('$_usersPath/$userId/completedQuests').get();
      List<String> completedQuests = [];

      if (snapshot.exists && snapshot.value != null) {
        completedQuests = List<String>.from(
            (snapshot.value as List<dynamic>).map((e) => e.toString()));
      }

      // Add new quest if not already completed
      if (!completedQuests.contains(questId)) {
        completedQuests.add(questId);
        await _database
            .child('$_usersPath/$userId/completedQuests')
            .set(completedQuests);
      }
    } catch (e) {
      throw DatabaseException('Failed to add completed quest: ${e.toString()}');
    }
  }

  // Add achievement to user
  Future<void> addAchievement(String userId, String achievementId) async {
    try {
      // Get current achievements
      final snapshot =
          await _database.child('$_usersPath/$userId/achievements').get();
      List<String> achievements = [];

      if (snapshot.exists && snapshot.value != null) {
        achievements = List<String>.from(
            (snapshot.value as List<dynamic>).map((e) => e.toString()));
      }

      // Add new achievement if not already earned
      if (!achievements.contains(achievementId)) {
        achievements.add(achievementId);
        await _database
            .child('$_usersPath/$userId/achievements')
            .set(achievements);
      }
    } catch (e) {
      throw DatabaseException('Failed to add achievement: ${e.toString()}');
    }
  }

  // Update last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await _database
          .child('$_usersPath/$userId/lastActive')
          .set(DateTime.now().toIso8601String());
    } catch (e) {
      throw DatabaseException(
          'Failed to update last active timestamp: ${e.toString()}');
    }
  }

  // Delete user account
  Future<void> deleteUser(String userId) async {
    try {
      await _database.child('$_usersPath/$userId').remove();
    } catch (e) {
      throw DatabaseException('Failed to delete user: ${e.toString()}');
    }
  }

  // Stream user data for real-time updates
  Stream<UserModel> streamUserData(String userId) {
    return _database.child('$_usersPath/$userId').onValue.map((event) {
      if (event.snapshot.value == null) {
        throw UserNotFoundException('User with ID $userId not found');
      }

      return UserModel.fromJson(
          {'id': userId, ...(event.snapshot.value as Map<dynamic, dynamic>)});
    });
  }

  // Check if username is already taken
  Future<bool> isUsernameTaken(String username) async {
    try {
      final query = await _database
          .child(_usersPath)
          .orderByChild('username')
          .equalTo(username)
          .limitToFirst(1)
          .get();

      return query.exists;
    } catch (e) {
      throw DatabaseException('Failed to check username: ${e.toString()}');
    }
  }
}

class UserNotFoundException implements Exception {
  final String message;
  UserNotFoundException(this.message);

  @override
  String toString() => message;
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => message;
}
