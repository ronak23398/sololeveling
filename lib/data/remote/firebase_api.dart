import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:solo_leveling/core/exceptions/app_exceptions.dart';
import 'package:solo_leveling/core/models/exercise_model.dart';
import 'package:solo_leveling/core/models/quest_model.dart';
import 'package:solo_leveling/core/models/stats_model.dart';
import 'package:solo_leveling/core/models/user_model.dart';

class FirebaseApi {
  final FirebaseDatabase _database;
  final FirebaseAuth _auth;

  FirebaseApi({
    FirebaseDatabase? database,
    FirebaseAuth? auth,
  })  : _database = database ?? FirebaseDatabase.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Database References
  DatabaseReference get _usersRef => _database.ref('users');
  DatabaseReference get _exercisesRef => _database.ref('exercises');
  DatabaseReference get _questsRef => _database.ref('quests');

  // User Related Methods
  Future<void> createUser(UserModel user) async {
    try {
      await _usersRef.child(user.id).set(user.toJson());
    } catch (e) {
      debugPrint('Error creating user: $e');
      throw AppException('Failed to create user profile');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final snapshot = await _usersRef.child(userId).get();
      if (snapshot.exists) {
        return UserModel.fromJson(
            Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      throw AppException('Failed to retrieve user data');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _usersRef.child(user.id).update(user.toJson());
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw AppException('Failed to update user profile');
    }
  }

  // Stats Related Methods
  Future<StatsModel?> getUserStats(String userId) async {
    try {
      final snapshot = await _usersRef.child('$userId/data/stats').get();
      if (snapshot.exists) {
        return StatsModel.fromJson(
            Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      throw AppException('Failed to retrieve user stats');
    }
  }

  Future<void> updateUserStats(String userId, StatsModel stats) async {
    try {
      await _usersRef.child('$userId/data/stats').update(stats.toJson());
    } catch (e) {
      debugPrint('Error updating user stats: $e');
      throw AppException('Failed to update user stats');
    }
  }

  // Exercise Related Methods
  Future<List<ExerciseModel>> getExercises() async {
    try {
      final snapshot = await _exercisesRef.get();
      if (!snapshot.exists) return [];

      final exercisesData = Map<String, dynamic>.from(snapshot.value as Map);
      return exercisesData.entries
          .map((entry) => ExerciseModel.fromJson(
              Map<String, dynamic>.from(entry.value as Map)))
          .toList();
    } catch (e) {
      debugPrint('Error getting exercises: $e');
      throw AppException('Failed to retrieve exercises');
    }
  }

  Future<ExerciseModel?> getExercise(String exerciseId) async {
    try {
      final snapshot = await _exercisesRef.child(exerciseId).get();
      if (snapshot.exists) {
        return ExerciseModel.fromJson(
            Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      debugPrint('Error getting exercise: $e');
      throw AppException('Failed to retrieve exercise details');
    }
  }

  // Quest Related Methods
  Future<List<QuestModel>> getDailyQuests(String userId) async {
    try {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month}-${today.day}';

      // Check if there are specific quests for this user today
      final userQuestsSnapshot = await _usersRef
          .child('$userId/quests')
          .orderByChild('date')
          .equalTo(dateStr)
          .get();

      if (userQuestsSnapshot.exists) {
        final questsData =
            Map<String, dynamic>.from(userQuestsSnapshot.value as Map);
        return questsData.entries
            .map((entry) => QuestModel.fromJson(
                Map<String, dynamic>.from(entry.value as Map)))
            .toList();
      }

      // Otherwise fetch from global quests
      final globalQuestsSnapshot =
          await _questsRef.orderByChild('date').equalTo(dateStr).get();

      if (!globalQuestsSnapshot.exists) return [];

      final questsData =
          Map<String, dynamic>.from(globalQuestsSnapshot.value as Map);
      return questsData.entries
          .where((entry) {
            final questData = Map<String, dynamic>.from(entry.value as Map);
            return questData['isGlobal'] == true;
          })
          .map((entry) => QuestModel.fromJson(
              Map<String, dynamic>.from(entry.value as Map)))
          .toList();
    } catch (e) {
      debugPrint('Error getting daily quests: $e');
      throw AppException('Failed to retrieve daily quests');
    }
  }

  Future<void> completeQuest(String userId, String questId) async {
    try {
      await _usersRef.child('$userId/completedQuests/$questId').set({
        'completedAt': ServerValue.timestamp,
        'questId': questId,
      });
    } catch (e) {
      debugPrint('Error completing quest: $e');
      throw AppException('Failed to mark quest as completed');
    }
  }

  // Exercise Log Methods
  Future<void> logExerciseCompletion(
    String userId,
    String exerciseId,
    Map<String, dynamic> completionData,
  ) async {
    try {
      final newLogRef = _usersRef.child('$userId/exerciseLogs').push();
      await newLogRef.set({
        'exerciseId': exerciseId,
        'completedAt': ServerValue.timestamp,
        ...completionData,
      });
    } catch (e) {
      debugPrint('Error logging exercise completion: $e');
      throw AppException('Failed to log exercise completion');
    }
  }

  // Dungeon Related Methods
  Future<void> logDungeonCompletion(
    String userId,
    Map<String, dynamic> dungeonData,
  ) async {
    try {
      final newLogRef = _usersRef.child('$userId/dungeonLogs').push();
      await newLogRef.set({
        'completedAt': ServerValue.timestamp,
        ...dungeonData,
      });
    } catch (e) {
      debugPrint('Error logging dungeon completion: $e');
      throw AppException('Failed to log dungeon completion');
    }
  }

  // Authentication Methods
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      throw AppException('Failed to sign out');
    }
  }

  // Listen for user stats changes
  Stream<StatsModel> userStatsStream(String userId) {
    return _usersRef.child('$userId/data/stats').onValue.map((event) {
      if (event.snapshot.value == null) {
        return const StatsModel();
      }
      return StatsModel.fromJson(
          Map<String, dynamic>.from(event.snapshot.value as Map));
    });
  }

  // Listen for completed quests
  Stream<List<String>> completedQuestsStream(String userId) {
    return _usersRef.child('$userId/completedQuests').onValue.map((event) {
      if (event.snapshot.value == null) {
        return <String>[];
      }
      final completedQuestsData =
          Map<String, dynamic>.from(event.snapshot.value as Map);
      return completedQuestsData.keys.toList();
    });
  }

  // Listen for new daily quests
  Stream<List<QuestModel>> dailyQuestsStream() {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';

    return _questsRef
        .orderByChild('date')
        .equalTo(dateStr)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) {
        return <QuestModel>[];
      }

      final questsData = Map<String, dynamic>.from(event.snapshot.value as Map);
      return questsData.entries
          .where((entry) {
            final questData = Map<String, dynamic>.from(entry.value as Map);
            return questData['isGlobal'] == true;
          })
          .map((entry) => QuestModel.fromJson(
              Map<String, dynamic>.from(entry.value as Map)))
          .toList();
    });
  }
}
