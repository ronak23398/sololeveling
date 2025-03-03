import 'package:flutter/foundation.dart';
import 'package:solo_leveling/data/local/shared_prefs.dart';
import 'package:solo_leveling/data/remote/firebase_api.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../../../core/models/quest_model.dart';
import '../../../core/enums/difficulty_level.dart';

class QuestRepository {
  final SharedPrefs _sharedPrefs;
  final FirebaseApi _firebaseApi;
  final _uuid = const Uuid();

  QuestRepository({
    required SharedPrefs sharedPrefs,
    required FirebaseApi firebaseApi,
  })  : _sharedPrefs = sharedPrefs,
        _firebaseApi = firebaseApi;

  // Get all quests
  Future<List<QuestModel>> getAllQuests() async {
    try {
      final userId = _firebaseApi.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Try to get from remote first
      final remoteQuests = await _firebaseApi.getDailyQuests(userId);

      if (remoteQuests.isNotEmpty) {
        // Save to local for offline access
        await _saveQuestsLocally(remoteQuests);
        return remoteQuests;
      }

      // If remote fails or is empty, get from local storage
      return await _getLocalQuests();
    } catch (e) {
      debugPrint('Error fetching quests: $e');
      // Fallback to local storage
      return await _getLocalQuests();
    }
  }

  // Get daily quests
  Future<List<QuestModel>> getDailyQuests() async {
    try {
      final userId = _firebaseApi.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Try to get from remote first
      return await _firebaseApi.getDailyQuests(userId);
    } catch (e) {
      debugPrint('Error fetching daily quests: $e');

      // If remote fails, try to filter local quests that are daily
      final allQuests = await _getLocalQuests();
      final now = DateTime.now();

      return allQuests
          .where((quest) =>
              quest.isDaily && !quest.isExpired && !quest.isCompleted)
          .toList();
    }
  }

  // Get quest by id
  Future<QuestModel?> getQuestById(String id) async {
    try {
      // For the MVP, we'll just get it from local quests
      final allQuests = await _getLocalQuests();
      return allQuests.firstWhere((quest) => quest.id == id);
    } catch (e) {
      debugPrint('Error fetching quest by id: $e');
      return null;
    }
  }

  // Complete a quest
  Future<bool> completeQuest(String questId) async {
    try {
      final userId = _firebaseApi.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Mark as completed in Firebase
      await _firebaseApi.completeQuest(userId, questId);

      // Update local storage
      final quests = await _getLocalQuests();
      final index = quests.indexWhere((q) => q.id == questId);

      if (index >= 0) {
        quests[index] = quests[index].copyWith(isCompleted: true);
        await _saveQuestsLocally(quests);
      }

      return true;
    } catch (e) {
      debugPrint('Error completing quest: $e');
      return false;
    }
  }

  // Save or update a quest (for local updates only in MVP)
  Future<bool> saveQuest(QuestModel quest) async {
    try {
      // In the MVP, we're just saving locally
      final quests = await _getLocalQuests();
      final index = quests.indexWhere((q) => q.id == quest.id);

      if (index >= 0) {
        quests[index] = quest;
      } else {
        quests.add(quest);
      }

      await _saveQuestsLocally(quests);
      return true;
    } catch (e) {
      debugPrint('Error saving quest: $e');
      return false;
    }
  }

  // Update a single task in a quest
  Future<bool> updateQuestTask(String questId, QuestTask updatedTask) async {
    try {
      final quest = await getQuestById(questId);
      if (quest == null) return false;

      final tasks = quest.tasks
          .map((task) => task.id == updatedTask.id ? updatedTask : task)
          .toList();

      // Check if all tasks are completed
      final allCompleted = tasks.every((task) => task.isCompleted);

      final updatedQuest = quest.copyWith(
        tasks: tasks,
        isCompleted: allCompleted,
      );

      // Save locally
      final success = await saveQuest(updatedQuest);

      // If all tasks are completed, mark the quest as completed in Firebase
      if (success && allCompleted) {
        await completeQuest(questId);
      }

      return success;
    } catch (e) {
      debugPrint('Error updating quest task: $e');
      return false;
    }
  }

  // Generate new daily quests
  Future<List<QuestModel>> generateDailyQuests() async {
    try {
      // For MVP, we'll generate basic quests locally
      final newQuests = _createDefaultDailyQuests();

      // Save the new quests locally
      await _saveQuestsLocally(newQuests);

      return newQuests;
    } catch (e) {
      debugPrint('Error generating daily quests: $e');
      return [];
    }
  }

  // Listen to daily quests stream
  Stream<List<QuestModel>> dailyQuestsStream() {
    return _firebaseApi.dailyQuestsStream();
  }

  // Listen to completed quests stream
  Stream<List<String>> completedQuestsStream() {
    final userId = _firebaseApi.getCurrentUserId();
    if (userId == null) {
      return Stream.value([]);
    }

    return _firebaseApi.completedQuestsStream(userId);
  }

  // Private: Get quests from local storage
  // Private: Get quests from local storage
  Future<List<QuestModel>> _getLocalQuests() async {
    try {
      final questsJson = await _sharedPrefs.getString('quests') ?? '[]';
      final List<dynamic> questsList = jsonDecode(questsJson) as List<dynamic>;
      return questsList
          .map((questData) => QuestModel.fromJson(questData))
          .toList();
    } catch (e) {
      debugPrint('Error fetching local quests: $e');
      return [];
    }
  }

  // Private: Save quests to local storage
  Future<void> _saveQuestsLocally(List<QuestModel> quests) async {
    try {
      final questsJson = jsonEncode(quests.map((q) => q.toJson()).toList());
      await _sharedPrefs.saveString('quests', questsJson);
    } catch (e) {
      debugPrint('Error saving quests locally: $e');
    }
  }

  // Private: Create default daily quests (for MVP)
  List<QuestModel> _createDefaultDailyQuests() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateStr = '${now.year}-${now.month}-${now.day}';

    return [
      QuestModel(
        id: 'daily-strength-${_uuid.v4()}',
        title: 'Daily Strength Training',
        description: 'Complete these strength exercises to power up!',
        difficulty: DifficultyLevel.beginner,
        xpReward: 100,
        statsReward: {'strength': 5, 'endurance': 2},
        tasks: [
          QuestTask(
            id: 'push-ups-${_uuid.v4()}',
            description: 'Complete 20 push-ups',
            exerciseId: 'push-up',
            targetCount: 20,
          ),
          QuestTask(
            id: 'squats-${_uuid.v4()}',
            description: 'Complete 30 squats',
            exerciseId: 'squat',
            targetCount: 30,
          ),
        ],
        expiresAt: tomorrow,
        isDaily: true,
      ),
      QuestModel(
        id: 'daily-cardio-${_uuid.v4()}',
        title: 'Cardio Challenge',
        description: 'Push your cardio to the next level!',
        difficulty: DifficultyLevel.intermediate,
        xpReward: 150,
        statsReward: {'speed': 3, 'endurance': 5},
        tasks: [
          QuestTask(
            id: 'running-${_uuid.v4()}',
            description: 'Run for 15 minutes',
            exerciseId: 'running',
            targetCount: 15,
          ),
          QuestTask(
            id: 'jumping-jacks-${_uuid.v4()}',
            description: 'Complete 50 jumping jacks',
            exerciseId: 'jumping-jack',
            targetCount: 50,
          ),
        ],
        expiresAt: tomorrow,
        isDaily: true,
      ),
      QuestModel(
        id: 'daily-flexibility-${_uuid.v4()}',
        title: 'Flexibility Training',
        description: 'Improve your flexibility to enhance your other stats!',
        difficulty: DifficultyLevel.beginner,
        xpReward: 80,
        statsReward: {'flexibility': 6, 'recovery': 4},
        tasks: [
          QuestTask(
            id: 'stretching-${_uuid.v4()}',
            description: 'Complete 10 minutes of stretching',
            exerciseId: 'stretching',
            targetCount: 10,
          ),
          QuestTask(
            id: 'yoga-${_uuid.v4()}',
            description: 'Complete 5 yoga poses',
            exerciseId: 'yoga',
            targetCount: 5,
          ),
        ],
        expiresAt: tomorrow,
        isDaily: true,
      ),
    ];
  }
}
