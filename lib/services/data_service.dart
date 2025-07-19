import 'package:hive_flutter/hive_flutter.dart';

import '../models/game_models.dart';

class DataService {
  static late Box scoresBox;
  static late Box userDataBox;
  static late Box settingsBox;
  static late Box cacheBox;

  static Future<void> initialize() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Open boxes
    scoresBox = await Hive.openBox('scores');
    userDataBox = await Hive.openBox('userData');
    settingsBox = await Hive.openBox('settings');
    cacheBox = await Hive.openBox('cache');
  }

  static UserData getOrCreateUserData() {
    if (userDataBox.isEmpty) {
      final userData = UserData(
        playerName: 'Player 1',
        highScore: 0,
        totalGamesPlayed: 0,
        totalScore: 0,
        lastPlayDate: DateTime.now(),
        achievements: [],
      );
      userDataBox.put('current_user', userData.toJson());
      return userData;
    } else {
      final data = userDataBox.get('current_user');
      return UserData.fromJson(data);
    }
  }

  static GameSettings getOrCreateGameSettings() {
    if (settingsBox.isEmpty) {
      final settings = GameSettings(
        soundEnabled: true,
        vibrationEnabled: true,
        gameSpeed: 1.0,
        theme: 'default',
      );
      settingsBox.put('game_settings', settings.toJson());
      return settings;
    } else {
      final data = settingsBox.get('game_settings');
      return GameSettings.fromJson(data);
    }
  }

  static void saveGameScore(GameScore score) {
    scoresBox.add(score.toJson());

    // Keep only last 50 scores to prevent excessive storage
    if (scoresBox.length > 50) {
      final oldestKey = scoresBox.keys.first;
      scoresBox.delete(oldestKey);
    }
  }

  static void updateUserData(UserData userData) {
    userDataBox.put('current_user', userData.toJson());
  }

  static void updateGameSettings(GameSettings settings) {
    settingsBox.put('game_settings', settings.toJson());
  }

  static List<GameScore> getRecentScores({int limit = 5}) {
    final scores = scoresBox.values.toList().reversed.toList();
    return scores.take(limit).map((data) => GameScore.fromJson(data)).toList();
  }

  static void clearAllData() {
    scoresBox.clear();
    userDataBox.clear();
    cacheBox.clear();
  }
}
