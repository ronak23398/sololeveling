import 'package:flutter/foundation.dart';
import 'package:solo_leveling/core/models/stats_model.dart';
import '../local/shared_prefs.dart';
import '../remote/firebase_api.dart';

class ProgressRepository {
  final SharedPrefs _sharedPrefs;
  final FirebaseApi _firebaseApi;

  ProgressRepository({
    required SharedPrefs sharedPrefs,
    required FirebaseApi firebaseApi,
  })  : _sharedPrefs = sharedPrefs,
        _firebaseApi = firebaseApi;

  // Get current user stats
  Future<StatsModel> getUserStats(String userId) async {
    try {
      // Try to get from Firebase first
      final remoteStats = await _firebaseApi.getUserStats(userId);
      if (remoteStats != null) {
        // Save to local storage for offline access
        await _saveStatsLocally(userId, remoteStats);
        return remoteStats;
      }

      // Fall back to local storage if remote fetch fails
      return await _getLocalStats(userId);
    } catch (e) {
      debugPrint('Error fetching user stats: $e');
      // Fall back to local storage in case of an error
      return await _getLocalStats(userId);
    }
  }

  // Update user stats
  Future<bool> updateUserStats(String userId, StatsModel stats) async {
    try {
      // Update locally first for immediate feedback
      await _saveStatsLocally(userId, stats);

      // Then update in Firebase
      await _firebaseApi.updateUserStats(userId, stats);
      return true;
    } catch (e) {
      debugPrint('Error updating user stats: $e');
      return false;
    }
  }

  // Increment stats based on completed exercise
  Future<bool> incrementStats({
    required String userId,
    required int strengthGain,
    required int enduranceGain,
    required int agilityGain,
    required int flexibilityGain,
    required int experienceGain,
  }) async {
    try {
      // Get current stats
      final currentStats = await getUserStats(userId);

      // Calculate new stats
      final updatedStats = currentStats.increaseStats(
        strengthGain: strengthGain,
        enduranceGain: enduranceGain,
        agilityGain: agilityGain,
        flexibilityGain: flexibilityGain,
        experienceGain: experienceGain,
      );

      // Save updated stats
      return await updateUserStats(userId, updatedStats);
    } catch (e) {
      debugPrint('Error incrementing stats: $e');
      return false;
    }
  }

  // Increment dungeon cleared count
  Future<bool> incrementDungeonCleared(String userId) async {
    try {
      final currentStats = await getUserStats(userId);
      final updatedStats = currentStats.incrementDungeonCleared();
      return await updateUserStats(userId, updatedStats);
    } catch (e) {
      debugPrint('Error incrementing dungeon cleared: $e');
      return false;
    }
  }

  // Increment quests completed count
  Future<bool> incrementQuestsCompleted(String userId) async {
    try {
      final currentStats = await getUserStats(userId);
      final updatedStats = currentStats.incrementQuestsCompleted();
      return await updateUserStats(userId, updatedStats);
    } catch (e) {
      debugPrint('Error incrementing quests completed: $e');
      return false;
    }
  }

  // Get user's current power level
  Future<int> getUserPowerLevel(String userId) async {
    final stats = await getUserStats(userId);
    return stats.calculatePowerLevel();
  }

  // Get user's stat balance (how evenly distributed their stats are)
  Future<double> getUserStatBalance(String userId) async {
    final stats = await getUserStats(userId);
    return stats.calculateStatBalance();
  }

  // Get summary of user's strongest and weakest attributes
  Future<Map<String, String>> getUserStatsSummary(String userId) async {
    final stats = await getUserStats(userId);
    return stats.getSummary();
  }

  // Private method to get stats from local storage
  Future<StatsModel> _getLocalStats(String userId) async {
    try {
      final statsJson = await _sharedPrefs.getMap('user_stats_$userId');
      if (statsJson != null) {
        return StatsModel.fromJson(statsJson);
      }
      return const StatsModel(); // Return default stats if none found
    } catch (e) {
      debugPrint('Error getting local stats: $e');
      return const StatsModel(); // Return default stats in case of an error
    }
  }

  // Private method to save stats to local storage
  Future<void> _saveStatsLocally(String userId, StatsModel stats) async {
    try {
      await _sharedPrefs.saveMap('user_stats_$userId', stats.toJson());
    } catch (e) {
      debugPrint('Error saving local stats: $e');
    }
  }

  // Sync local stats with remote (can be called when connectivity is restored)
  Future<bool> syncStats(String userId) async {
    try {
      final localStats = await _getLocalStats(userId);
      await _firebaseApi.updateUserStats(userId, localStats);
      return true;
    } catch (e) {
      debugPrint('Error syncing stats: $e');
      return false;
    }
  }
}
