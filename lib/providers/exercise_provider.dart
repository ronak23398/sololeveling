import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:solo_leveling/core/enums/excercise_category.dart';
import '../core/models/exercise_model.dart';
import '../data/repositories/exercise_repository.dart';
import '../data/repositories/progress_repository.dart';

class ExerciseProvider extends ChangeNotifier {
  final ExerciseRepository _exerciseRepository;
  final ProgressRepository _progressRepository;

  ExerciseProvider({
    required ExerciseRepository exerciseRepository,
    required ProgressRepository progressRepository,
  })  : _exerciseRepository = exerciseRepository,
        _progressRepository = progressRepository {
    _loadExercises();
  }

  // State variables
  List<ExerciseModel> _exercises = [];
  List<ExerciseModel> _filteredExercises = [];
  ExerciseCategory? _selectedCategory;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<ExerciseModel> get exercises => _exercises;
  List<ExerciseModel> get filteredExercises => _filteredExercises;
  ExerciseCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  // Initialize by loading exercises
  Future<void> _loadExercises() async {
    _setLoading(true);
    try {
      _exercises = await _exerciseRepository.getAllExercises();
      _applyFilters(); // Apply any existing filters
      _setLoading(false);
    } catch (e) {
      debugPrint('Error loading exercises: $e');
      _setError('Failed to load exercises. Please try again.');
    }
  }

  // Refresh exercises list
  Future<void> refreshExercises() async {
    await _loadExercises();
  }

  // Filter exercises by category
  void filterByCategory(ExerciseCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Apply all current filters to the exercises list
  void _applyFilters() {
    _filteredExercises = _exercises;

    // Apply category filter if selected
    if (_selectedCategory != null) {
      _filteredExercises = _filteredExercises
          .where((exercise) => exercise.category == _selectedCategory)
          .toList();
    }
  }

  // Get exercise details by ID
  Future<ExerciseModel?> getExerciseById(String id) async {
    try {
      return await _exerciseRepository.getExerciseById(id);
    } catch (e) {
      debugPrint('Error getting exercise by ID: $e');
      _setError('Failed to load exercise details.');
      return null;
    }
  }

  // Log exercise completion
  Future<bool> completeExercise(
    String userId,
    String exerciseId,
    Map<String, dynamic> completionData,
  ) async {
    try {
      // Get the exercise to determine stat gains
      final exercise = await getExerciseById(exerciseId);
      if (exercise == null) return false;

      // Log the completion
      await _exerciseRepository.logExerciseCompletion(
        userId,
        exerciseId,
        completionData,
      );

      // Update user stats based on the exercise
      await _progressRepository.incrementStats(
        userId: userId,
        strengthGain: exercise.strengthGain,
        enduranceGain: exercise.enduranceGain,
        agilityGain: exercise.agilityGain,
        flexibilityGain: exercise.flexibilityGain,
        experienceGain: exercise.experienceGain,
      );

      return true;
    } catch (e) {
      debugPrint('Error completing exercise: $e');
      _setError('Failed to record exercise completion.');
      return false;
    }
  }

  // Get recommended exercises based on user stats
  Future<List<ExerciseModel>> getRecommendedExercises(String userId) async {
    try {
      final stats = await _progressRepository.getUserStats(userId);
      final summary = stats.getSummary();
      final weakestAttribute = summary['weakest'] ?? '';

      // Filter exercises that target the user's weakest attribute
      return _exercises.where((exercise) {
        switch (weakestAttribute) {
          case 'Strength':
            return exercise.strengthGain > 0;
          case 'Endurance':
            return exercise.enduranceGain > 0;
          case 'Agility':
            return exercise.agilityGain > 0;
          case 'Flexibility':
            return exercise.flexibilityGain > 0;
          default:
            return true; // If no clear weakness, don't filter
        }
      }).toList();
    } catch (e) {
      debugPrint('Error getting recommended exercises: $e');
      return [];
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = '';
    }
    notifyListeners();
  }

  // Helper method to set error state
  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  // Clear any error messages
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
