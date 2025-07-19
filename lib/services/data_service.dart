import 'package:hive_flutter/hive_flutter.dart';

import '../models/game_models.dart';

class DataService {
  static late Box<GameScore> scoresBox;
  static late Box<UserData> userDataBox;
  static late Box<GameSettings> settingsBox;
  static late Box<GameCache> cacheBox;

  static Future<void> initialize() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(GameScoreAdapter());
    Hive.registerAdapter(UserDataAdapter());
    Hive.registerAdapter(GameSettingsAdapter());
    Hive.registerAdapter(GameCacheAdapter());

    // Open boxes
    scoresBox = await Hive.openBox<GameScore>('scores');
    userDataBox = await Hive.openBox<UserData>('userData');
    settingsBox = await Hive.openBox<GameSettings>('settings');
    cacheBox = await Hive.openBox<GameCache>('cache');
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
      userDataBox.put('current_user', userData);
      return userData;
    } else {
      return userDataBox.get('current_user')!;
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
      settingsBox.put('game_settings', settings);
      return settings;
    } else {
      return settingsBox.get('game_settings')!;
    }
  }

  static void saveGameScore(GameScore score) {
    scoresBox.add(score);

    // Keep only last 50 scores to prevent excessive storage
    if (scoresBox.length > 50) {
      final oldestKey = scoresBox.keys.first;
      scoresBox.delete(oldestKey);
    }
  }

  static void updateUserData(UserData userData) {
    userDataBox.put('current_user', userData);
  }

  static void updateGameSettings(GameSettings settings) {
    settingsBox.put('game_settings', settings);
  }

  static List<GameScore> getRecentScores({int limit = 5}) {
    final scores = scoresBox.values.toList().reversed.toList();
    return scores.take(limit).toList();
  }

  static void clearAllData() {
    scoresBox.clear();
    userDataBox.clear();
    cacheBox.clear();
  }

  // Cache management methods
  static void saveCache(
    double screenWidth,
    double screenHeight, {
    Map<String, dynamic>? additionalData,
  }) {
    final cache = GameCache(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      lastSession: DateTime.now(),
      additionalData: additionalData ?? {},
    );
    cacheBox.put('game_cache', cache);
  }

  static GameCache? getCache() {
    return cacheBox.get('game_cache');
  }

  static void clearCache() {
    cacheBox.clear();
  }

  static void updateCacheData(Map<String, dynamic> data) {
    final cache = getCache();
    if (cache != null) {
      cache.additionalData.addAll(data);
      cache.save();
    }
  }
}
