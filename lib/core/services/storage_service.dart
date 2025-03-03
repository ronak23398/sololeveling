import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stats_model.dart';
import '../models/exercise_model.dart';
import '../models/quest_model.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _userPrefix = 'user_';
  static const String _statsPrefix = 'stats_';
  static const String _lastLoginPrefix = 'last_login_';
  static const String _exercisePrefix = 'exercise_';
  static const String _questPrefix = 'quest_';
  static const String _settingsKey = 'app_settings';

  /// Save user data to local storage
  Future<bool> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      return await prefs.setString('$_userPrefix${user.id}', userJson);
    } catch (e) {
      debugPrint('Error saving user to local storage: $e');
      return false;
    }
  }

  /// Get user data from local storage
  Future<UserModel?> getUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('$_userPrefix$userId');

      if (userJson == null) {
        return null;
      }

      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      debugPrint('Error getting user from local storage: $e');
      return null;
    }
  }

  /// Save user stats to local storage
  Future<bool> saveStats(String userId, StatsModel stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = jsonEncode(stats.toJson());
      return await prefs.setString('$_statsPrefix$userId', statsJson);
    } catch (e) {
      debugPrint('Error saving stats to local storage: $e');
      return false;
    }
  }

  /// Get user stats from local storage
  Future<StatsModel?> getStats(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('$_statsPrefix$userId');

      if (statsJson == null) {
        return null;
      }

      return StatsModel.fromJson(jsonDecode(statsJson));
    } catch (e) {
      debugPrint('Error getting stats from local storage: $e');
      return null;
    }
  }

  /// Save exercise to local storage
  Future<bool> saveExercise(ExerciseModel exercise) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exerciseJson = jsonEncode(exercise.toJson());
      return await prefs.setString(
          '$_exercisePrefix${exercise.id}', exerciseJson);
    } catch (e) {
      debugPrint('Error saving exercise to local storage: $e');
      return false;
    }
  }

  /// Get exercise from local storage
  Future<ExerciseModel?> getExercise(String exerciseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exerciseJson = prefs.getString('$_exercisePrefix$exerciseId');

      if (exerciseJson == null) {
        return null;
      }

      return ExerciseModel.fromJson(jsonDecode(exerciseJson));
    } catch (e) {
      debugPrint('Error getting exercise from local storage: $e');
      return null;
    }
  }

  /// Save all exercises to local storage
  Future<bool> saveAllExercises(List<ExerciseModel> exercises) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exercisesJsonList = exercises.map((e) => e.toJson()).toList();
      final exercisesJson = jsonEncode(exercisesJsonList);
      return await prefs.setString('exercises', exercisesJson);
    } catch (e) {
      debugPrint('Error saving all exercises to local storage: $e');
      return false;
    }
  }

  /// Get all exercises from local storage
  Future<List<ExerciseModel>> getAllExercises() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exercisesJson = prefs.getString('exercises');

      if (exercisesJson == null) {
        return [];
      }

      final exercisesJsonList = jsonDecode(exercisesJson) as List;
      return exercisesJsonList
          .map((exerciseJson) => ExerciseModel.fromJson(exerciseJson))
          .toList();
    } catch (e) {
      debugPrint('Error getting all exercises from local storage: $e');
      return [];
    }
  }

  /// Save quest to local storage
  Future<bool> saveQuest(QuestModel quest) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final questJson = jsonEncode(quest.toJson());
      return await prefs.setString('$_questPrefix${quest.id}', questJson);
    } catch (e) {
      debugPrint('Error saving quest to local storage: $e');
      return false;
    }
  }

  /// Get quest from local storage
  Future<QuestModel?> getQuest(String questId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final questJson = prefs.getString('$_questPrefix$questId');

      if (questJson == null) {
        return null;
      }

      return QuestModel.fromJson(jsonDecode(questJson));
    } catch (e) {
      debugPrint('Error getting quest from local storage: $e');
      return null;
    }
  }

  /// Save daily quests to local storage
  Future<bool> saveDailyQuests(String userId, List<QuestModel> quests) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final questsJsonList = quests.map((quest) => quest.toJson()).toList();
      final questsJson = jsonEncode(questsJsonList);
      return await prefs.setString('${_questPrefix}daily_$userId', questsJson);
    } catch (e) {
      debugPrint('Error saving daily quests to local storage: $e');
      return false;
    }
  }

  /// Get daily quests from local storage
  Future<List<QuestModel>> getDailyQuests(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final questsJson = prefs.getString('${_questPrefix}daily_$userId');

      if (questsJson == null) {
        return [];
      }

      final questsJsonList = jsonDecode(questsJson) as List;
      return questsJsonList
          .map((questJson) => QuestModel.fromJson(questJson))
          .toList();
    } catch (e) {
      debugPrint('Error getting daily quests from local storage: $e');
      return [];
    }
  }

  /// Save last login date
  Future<bool> saveLastLoginDate(String userId, DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
          '$_lastLoginPrefix$userId', date.toIso8601String());
    } catch (e) {
      debugPrint('Error saving last login date: $e');
      return false;
    }
  }

  /// Get last login date
  Future<DateTime?> getLastLoginDate(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateString = prefs.getString('$_lastLoginPrefix$userId');

      if (dateString == null) {
        return null;
      }

      return DateTime.parse(dateString);
    } catch (e) {
      debugPrint('Error getting last login date: $e');
      return null;
    }
  }

  /// Save app settings
  Future<bool> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings);
      return await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      debugPrint('Error saving app settings: $e');
      return false;
    }
  }

  /// Get app settings
  Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson == null) {
        return {};
      }

      return jsonDecode(settingsJson);
    } catch (e) {
      debugPrint('Error getting app settings: $e');
      return {};
    }
  }

  /// Save completed exercises for a user
  Future<bool> saveCompletedExercises(
      String userId, List<Map<String, dynamic>> exercises) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exercisesJson = jsonEncode(exercises);
      return await prefs.setString(
          'completed_exercises_$userId', exercisesJson);
    } catch (e) {
      debugPrint('Error saving completed exercises: $e');
      return false;
    }
  }

  /// Get completed exercises for a user
  Future<List<Map<String, dynamic>>> getCompletedExercises(
      String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exercisesJson = prefs.getString('completed_exercises_$userId');

      if (exercisesJson == null) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(exercisesJson);
      return decodedList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error getting completed exercises: $e');
      return [];
    }
  }

  /// Add a single completed exercise to the history
  Future<bool> addCompletedExercise(
      String userId, Map<String, dynamic> exerciseRecord) async {
    try {
      final exercises = await getCompletedExercises(userId);
      exercises.add(exerciseRecord);
      return await saveCompletedExercises(userId, exercises);
    } catch (e) {
      debugPrint('Error adding completed exercise: $e');
      return false;
    }
  }

  /// Clear all data for a specific user
  Future<bool> clearUserData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_userPrefix$userId');
      await prefs.remove('$_statsPrefix$userId');
      await prefs.remove('${_questPrefix}daily_$userId');
      await prefs.remove('$_lastLoginPrefix$userId');
      await prefs.remove('completed_exercises_$userId');
      return true;
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      return false;
    }
  }
}
