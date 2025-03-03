import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/models/quest_model.dart';
import '../data/repositories/quest_repository.dart';

class QuestProvider with ChangeNotifier {
  final QuestRepository _questRepository;

  // State variables
  List<QuestModel> _quests = [];
  List<QuestModel> _dailyQuests = [];
  Set<String> _completedQuestIds = {};
  QuestModel? _selectedQuest;
  bool _isLoading = false;
  String? _error;

  // Stream subscriptions
  StreamSubscription? _dailyQuestsSubscription;
  StreamSubscription? _completedQuestsSubscription;

  // Constructor
  QuestProvider({required QuestRepository questRepository})
      : _questRepository = questRepository {
    _initStreams();
  }

  // Initialize streams
  void _initStreams() {
    // Listen to daily quests stream
    _dailyQuestsSubscription =
        _questRepository.dailyQuestsStream().listen((quests) {
      _dailyQuests = quests;
      notifyListeners();
    }, onError: (error) {
      _setError('Stream error: $error');
    });

    // Listen to completed quests stream
    _completedQuestsSubscription =
        _questRepository.completedQuestsStream().listen((completedIds) {
      _completedQuestIds = Set<String>.from(completedIds);
      _updateQuestsCompletionStatus();
      notifyListeners();
    }, onError: (error) {
      _setError('Stream error: $error');
    });
  }

  // Update completion status of quests based on completed IDs
  void _updateQuestsCompletionStatus() {
    _dailyQuests = _dailyQuests.map((quest) {
      if (_completedQuestIds.contains(quest.id) && !quest.isCompleted) {
        return quest.copyWith(isCompleted: true);
      }
      return quest;
    }).toList();

    _quests = _quests.map((quest) {
      if (_completedQuestIds.contains(quest.id) && !quest.isCompleted) {
        return quest.copyWith(isCompleted: true);
      }
      return quest;
    }).toList();

    if (_selectedQuest != null &&
        _completedQuestIds.contains(_selectedQuest!.id)) {
      _selectedQuest = _selectedQuest!.copyWith(isCompleted: true);
    }
  }

  // Dispose
  @override
  void dispose() {
    _dailyQuestsSubscription?.cancel();
    _completedQuestsSubscription?.cancel();
    super.dispose();
  }

  // Getters
  List<QuestModel> get quests => _quests;
  List<QuestModel> get dailyQuests => _dailyQuests;
  QuestModel? get selectedQuest => _selectedQuest;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get daily quest completion percentage
  double get dailyQuestCompletionPercentage {
    if (_dailyQuests.isEmpty) return 0.0;

    int completedCount =
        _dailyQuests.where((quest) => quest.isCompleted).length;
    return completedCount / _dailyQuests.length;
  }

  // Load all quests
  Future<void> loadQuests() async {
    _setLoading(true);
    try {
      _quests = await _questRepository.getAllQuests();
      _updateQuestsCompletionStatus();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load quests: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load daily quests
  Future<void> loadDailyQuests() async {
    _setLoading(true);
    try {
      _dailyQuests = await _questRepository.getDailyQuests();

      // If no daily quests, generate new ones
      if (_dailyQuests.isEmpty) {
        await refreshDailyQuests();
      }

      _updateQuestsCompletionStatus();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load daily quests: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh daily quests
  Future<void> refreshDailyQuests() async {
    _setLoading(true);
    try {
      _dailyQuests = await _questRepository.generateDailyQuests();
      _updateQuestsCompletionStatus();
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh daily quests: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get quest by ID
  Future<void> getQuestById(String id) async {
    _setLoading(true);
    try {
      _selectedQuest = await _questRepository.getQuestById(id);
      // Update completion status if needed
      if (_selectedQuest != null && _completedQuestIds.contains(id)) {
        _selectedQuest = _selectedQuest!.copyWith(isCompleted: true);
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to get quest: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update a quest
  Future<bool> updateQuest(QuestModel quest) async {
    _setLoading(true);
    try {
      final success = await _questRepository.saveQuest(quest);

      if (success) {
        // Update local lists
        _updateLocalQuests(quest);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError('Failed to update quest: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update a quest task
  Future<bool> updateQuestTask(String questId, QuestTask updatedTask) async {
    _setLoading(true);
    try {
      final success =
          await _questRepository.updateQuestTask(questId, updatedTask);

      if (success) {
        // Refresh the selected quest if it's the one being updated
        if (_selectedQuest?.id == questId) {
          await getQuestById(questId);
        }

        // Refresh quest lists to reflect changes
        await loadQuests();
        await loadDailyQuests();
      }

      return success;
    } catch (e) {
      _setError('Failed to update quest task: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Complete a quest
  Future<bool> completeQuest(String questId) async {
    try {
      if (_completedQuestIds.contains(questId))
        return true; // Already completed

      final success = await _questRepository.completeQuest(questId);

      if (success) {
        // Local update will happen via the stream listener
        // but we can update immediately for UI responsiveness
        _completedQuestIds.add(questId);
        _updateQuestsCompletionStatus();
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError('Failed to complete quest: $e');
      return false;
    }
  }

  // Increment progress for a quest task
  Future<bool> incrementTaskProgress(String questId, String taskId,
      [int amount = 1]) async {
    try {
      // Find the quest
      QuestModel? quest;

      if (_selectedQuest?.id == questId) {
        quest = _selectedQuest;
      } else {
        final questIndex = _quests.indexWhere((q) => q.id == questId);
        if (questIndex >= 0) {
          quest = _quests[questIndex];
        } else {
          final dailyQuestIndex =
              _dailyQuests.indexWhere((q) => q.id == questId);
          if (dailyQuestIndex >= 0) {
            quest = _dailyQuests[dailyQuestIndex];
          }
        }
      }

      if (quest == null) return false;

      // Find and update the task
      final taskIndex = quest.tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex < 0) return false;

      final task = quest.tasks[taskIndex];
      final updatedTask = task.incrementProgress(amount);

      // Save the updated task
      return await updateQuestTask(questId, updatedTask);
    } catch (e) {
      _setError('Failed to increment task progress: $e');
      return false;
    }
  }

  // Helper: Update local quest lists
  void _updateLocalQuests(QuestModel updatedQuest) {
    // Update in all quests list
    final allIndex = _quests.indexWhere((q) => q.id == updatedQuest.id);
    if (allIndex >= 0) {
      _quests[allIndex] = updatedQuest;
    } else {
      _quests.add(updatedQuest);
    }

    // Update in daily quests list if applicable
    if (updatedQuest.isDaily) {
      final dailyIndex =
          _dailyQuests.indexWhere((q) => q.id == updatedQuest.id);
      if (dailyIndex >= 0) {
        _dailyQuests[dailyIndex] = updatedQuest;
      } else if (!updatedQuest.isExpired) {
        _dailyQuests.add(updatedQuest);
      }
    }

    // Update selected quest if applicable
    if (_selectedQuest?.id == updatedQuest.id) {
      _selectedQuest = updatedQuest;
    }
  }

  // Helper: Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper: Set error state
  void _setError(String errorMessage) {
    _error = errorMessage;
    debugPrint(errorMessage);
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
