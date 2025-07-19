import 'data_service.dart';

class CacheService {
  static const String _basketPositionKey = 'basket_position';
  static const String _gameStateKey = 'game_state';
  static const String _lastSessionKey = 'last_session';
  static const String _userPreferencesKey = 'user_preferences';

  // Save basket position
  static void saveBasketPosition(double x, double y) {
    DataService.updateCacheData({
      _basketPositionKey: {'x': x, 'y': y},
    });
  }

  // Get basket position
  static Map<String, double>? getBasketPosition() {
    final cache = DataService.getCache();
    if (cache != null && cache.additionalData.containsKey(_basketPositionKey)) {
      final position = cache.additionalData[_basketPositionKey];
      if (position is Map) {
        final x = position['x'];
        final y = position['y'];
        if (x != null && y != null) {
          return {'x': x.toDouble(), 'y': y.toDouble()};
        }
      }
    }
    return null;
  }

  // Save game state
  static void saveGameState({
    required int score,
    required int level,
    required int lives,
    required bool gameActive,
  }) {
    DataService.updateCacheData({
      _gameStateKey: {
        'score': score,
        'level': level,
        'lives': lives,
        'gameActive': gameActive,
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
  }

  // Get game state
  static Map<String, dynamic>? getGameState() {
    final cache = DataService.getCache();
    if (cache != null && cache.additionalData.containsKey(_gameStateKey)) {
      final gameState = cache.additionalData[_gameStateKey];
      if (gameState is Map) {
        return Map<String, dynamic>.from(gameState);
      }
    }
    return null;
  }

  // Save user preferences
  static void saveUserPreferences(Map<String, dynamic> preferences) {
    DataService.updateCacheData({_userPreferencesKey: preferences});
  }

  // Get user preferences
  static Map<String, dynamic>? getUserPreferences() {
    final cache = DataService.getCache();
    if (cache != null &&
        cache.additionalData.containsKey(_userPreferencesKey)) {
      final preferences = cache.additionalData[_userPreferencesKey];
      if (preferences is Map) {
        return Map<String, dynamic>.from(preferences);
      }
    }
    return null;
  }

  // Save last session info
  static void saveLastSession() {
    DataService.updateCacheData({
      _lastSessionKey: {
        'timestamp': DateTime.now().toIso8601String(),
        'sessionDuration': 0, // You can calculate this if needed
      },
    });
  }

  // Get last session info
  static Map<String, dynamic>? getLastSession() {
    final cache = DataService.getCache();
    if (cache != null && cache.additionalData.containsKey(_lastSessionKey)) {
      final session = cache.additionalData[_lastSessionKey];
      if (session is Map) {
        return Map<String, dynamic>.from(session);
      }
    }
    return null;
  }

  // Clear all cache data
  static void clearAllCache() {
    DataService.clearCache();
  }

  // Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    final cache = DataService.getCache();
    if (cache != null) {
      return {
        'lastSession': cache.lastSession,
        'screenWidth': cache.screenWidth,
        'screenHeight': cache.screenHeight,
        'dataEntries': cache.additionalData.length,
        'hasBasketPosition': cache.additionalData.containsKey(
          _basketPositionKey,
        ),
        'hasGameState': cache.additionalData.containsKey(_gameStateKey),
        'hasUserPreferences': cache.additionalData.containsKey(
          _userPreferencesKey,
        ),
      };
    }
    return {};
  }
}
