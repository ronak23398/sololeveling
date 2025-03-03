import 'package:flutter/material.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/welcome/login_screen.dart';
import '../screens/welcome/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/exercise/exercise_library_screen.dart';
import '../screens/exercise/exercise_detail_screen.dart';
import '../screens/quests/quest_board_screen.dart';
import '../screens/quests/quest_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/dungeon/dungeon_screen.dart';

class AppRoutes {
  // Route names
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String exerciseLibrary = '/exercises';
  static const String exerciseDetail = '/exercise-detail';
  static const String questBoard = '/quests';
  static const String questDetail = '/quest-detail';
  static const String profile = '/profile';
  static const String dungeon = '/dungeon';

  // Route map
  static Map<String, WidgetBuilder> get routes => {
        welcome: (context) => const WelcomeScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        home: (context) => const HomeScreen(),
        exerciseLibrary: (context) => const ExerciseLibraryScreen(),
        exerciseDetail: (context) => const ExerciseDetailScreen(),
        questBoard: (context) => const QuestBoardScreen(),
        questDetail: (context) => const QuestDetailScreen(),
        profile: (context) => const ProfileScreen(),
        dungeon: (context) => const DungeonScreen(),
      };
}
