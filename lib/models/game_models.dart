import 'package:hive_flutter/hive_flutter.dart';

part 'game_models.g.dart';

@HiveType(typeId: 0)
class GameScore extends HiveObject {
  @HiveField(0)
  final int score;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int level;

  GameScore({required this.score, required this.date, required this.level});
}

@HiveType(typeId: 1)
class UserData extends HiveObject {
  @HiveField(0)
  String playerName;

  @HiveField(1)
  int highScore;

  @HiveField(2)
  int totalGamesPlayed;

  @HiveField(3)
  int totalScore;

  @HiveField(4)
  DateTime lastPlayDate;

  @HiveField(5)
  List<String> achievements;

  UserData({
    required this.playerName,
    required this.highScore,
    required this.totalGamesPlayed,
    required this.totalScore,
    required this.lastPlayDate,
    required this.achievements,
  });
}

@HiveType(typeId: 2)
class GameSettings extends HiveObject {
  @HiveField(0)
  bool soundEnabled;

  @HiveField(1)
  bool vibrationEnabled;

  @HiveField(2)
  double gameSpeed;

  @HiveField(3)
  String theme;

  GameSettings({
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.gameSpeed,
    required this.theme,
  });
}

@HiveType(typeId: 3)
class GameCache extends HiveObject {
  @HiveField(0)
  double screenWidth;

  @HiveField(1)
  double screenHeight;

  @HiveField(2)
  DateTime lastSession;

  @HiveField(3)
  Map<String, dynamic> additionalData;

  GameCache({
    required this.screenWidth,
    required this.screenHeight,
    required this.lastSession,
    required this.additionalData,
  });
}
