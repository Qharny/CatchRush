import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'game_screen.dart';

// Hive data models
part 'main.g.dart';

@HiveType(typeId: 0)
class GameScore extends HiveObject {
  @HiveField(0)
  int score;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  int level;

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(GameScoreAdapter());
  Hive.registerAdapter(UserDataAdapter());
  Hive.registerAdapter(GameSettingsAdapter());

  // Open boxes
  await Hive.openBox<GameScore>('scores');
  await Hive.openBox<UserData>('userData');
  await Hive.openBox<GameSettings>('settings');
  await Hive.openBox('cache');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catch the Falling Object',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GameScreen(),
    );
  }
}

