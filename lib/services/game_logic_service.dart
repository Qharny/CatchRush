import 'dart:math';

import '../models/game_models.dart';

class GameLogicService {
  static const double objectSpeed = 200; // pixels per second
  static const double basketWidth = 80;
  static const double basketHeight = 60;
  static const double objectSize = 30;

  static final Random random = Random();

  static double calculateObjectSpeed(int level) {
    return objectSpeed * (1 + (level - 1) * 0.2);
  }

  static bool checkCollision({
    required double objectX,
    required double objectY,
    required double basketX,
    required double basketY,
  }) {
    return objectX < basketX + basketWidth &&
        objectX + objectSize > basketX &&
        objectY < basketY + basketHeight &&
        objectY + objectSize > basketY;
  }

  static double generateRandomObjectX(double screenWidth) {
    return random.nextDouble() * (screenWidth - objectSize);
  }

  static double constrainBasketPosition(double basketX, double screenWidth) {
    if (basketX < 0) return 0;
    if (basketX > screenWidth - basketWidth) {
      return screenWidth - basketWidth;
    }
    return basketX;
  }

  static void checkAchievements(UserData userData, int score, int level) {
    List<String> newAchievements = [];

    if (level == 5 && !userData.achievements.contains('Level 5 Reached')) {
      newAchievements.add('Level 5 Reached');
    }

    if (score >= 25 && !userData.achievements.contains('Score Master')) {
      newAchievements.add('Score Master');
    }

    if (userData.totalGamesPlayed >= 10 &&
        !userData.achievements.contains('Persistent Player')) {
      newAchievements.add('Persistent Player');
    }

    for (String achievement in newAchievements) {
      if (!userData.achievements.contains(achievement)) {
        userData.achievements.add(achievement);
      }
    }
  }
}
