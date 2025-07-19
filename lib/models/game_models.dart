class GameScore {
  final int score;
  final DateTime date;
  final int level;

  GameScore({required this.score, required this.date, required this.level});

  Map<String, dynamic> toJson() {
    return {'score': score, 'date': date.toIso8601String(), 'level': level};
  }

  factory GameScore.fromJson(Map<String, dynamic> json) {
    return GameScore(
      score: json['score'],
      date: DateTime.parse(json['date']),
      level: json['level'],
    );
  }
}

class UserData {
  String playerName;
  int highScore;
  int totalGamesPlayed;
  int totalScore;
  DateTime lastPlayDate;
  List<String> achievements;

  UserData({
    required this.playerName,
    required this.highScore,
    required this.totalGamesPlayed,
    required this.totalScore,
    required this.lastPlayDate,
    required this.achievements,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'highScore': highScore,
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'lastPlayDate': lastPlayDate.toIso8601String(),
      'achievements': achievements,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      playerName: json['playerName'],
      highScore: json['highScore'],
      totalGamesPlayed: json['totalGamesPlayed'],
      totalScore: json['totalScore'],
      lastPlayDate: DateTime.parse(json['lastPlayDate']),
      achievements: List<String>.from(json['achievements']),
    );
  }
}

class GameSettings {
  bool soundEnabled;
  bool vibrationEnabled;
  double gameSpeed;
  String theme;

  GameSettings({
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.gameSpeed,
    required this.theme,
  });

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'gameSpeed': gameSpeed,
      'theme': theme,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      soundEnabled: json['soundEnabled'],
      vibrationEnabled: json['vibrationEnabled'],
      gameSpeed: json['gameSpeed'],
      theme: json['theme'],
    );
  }
}
