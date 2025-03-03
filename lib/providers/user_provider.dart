import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../core/models/stats_model.dart';
import '../core/enums/user_rank.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/progress_repository.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  final UserRepository _userRepository;
  final ProgressRepository _progressRepository;

  UserProvider({
    required UserRepository userRepository,
    required ProgressRepository progressRepository,
  })  : _userRepository = userRepository,
        _progressRepository = progressRepository;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load existing user data
  Future<void> loadUserData(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await _userRepository.getUserById(userId);
      _user = userData;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize a new user with default values
  Future<void> initializeNewUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create default stats for new user
      final defaultStats = StatsModel(
        strength: 10,
        endurance: 10,
        agility: 10,
        flexibility: 10,
        totalWorkouts: 0,
        totalExercises: 0,
        workoutMinutes: 0,
      );

      // Create new user model with default values
      final newUser = UserModel(
        id: userId,
        level: 1,
        xp: 0,
        xpToNextLevel: 100,
        rank: UserRank.E,
        stats: defaultStats,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Save new user to database
      await _userRepository.createUser(newUser);

      // Initialize progress tracking
      await _progressRepository.initializeUserProgress(userId);

      _user = newUser;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user XP and handle level up
  Future<bool> addXP(int amount) async {
    if (_user == null) return false;

    bool didLevelUp = false;
    int newXP = _user!.xp + amount;
    int newLevel = _user!.level;

    // Check if user leveled up
    if (newXP >= _user!.xpToNextLevel) {
      newXP = newXP - _user!.xpToNextLevel;
      newLevel++;
      didLevelUp = true;
    }

    // Calculate new XP required for next level (increases with each level)
    int newXpToNextLevel = _user!.xpToNextLevel;
    if (didLevelUp) {
      newXpToNextLevel =
          100 + (newLevel * 50); // Simple formula: base 100 + 50 per level
    }

    // Update user rank if applicable
    UserRank newRank = _user!.rank;
    if (newLevel >= 50) {
      newRank = UserRank.S;
    } else if (newLevel >= 40) {
      newRank = UserRank.A;
    } else if (newLevel >= 30) {
      newRank = UserRank.B;
    } else if (newLevel >= 20) {
      newRank = UserRank.C;
    } else if (newLevel >= 10) {
      newRank = UserRank.D;
    }

    // Create updated user model
    final updatedUser = _user!.copyWith(
      level: newLevel,
      xp: newXP,
      xpToNextLevel: newXpToNextLevel,
      rank: newRank,
    );

    try {
      await _userRepository.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
      return didLevelUp;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update user stats
  Future<void> updateStats(StatsModel newStats) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(stats: newStats);

    try {
      await _userRepository.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
