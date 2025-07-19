import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../services/data_service.dart';

class StatsDialog extends StatelessWidget {
  final UserData userData;

  const StatsDialog({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Game Statistics'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Player: ${userData.playerName}'),
          Text('High Score: ${userData.highScore}'),
          Text('Total Games: ${userData.totalGamesPlayed}'),
          Text('Total Score: ${userData.totalScore}'),
          SizedBox(height: 16),
          Text('Recent Scores:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: DataService.getRecentScores().length,
              itemBuilder: (context, index) {
                final scores = DataService.getRecentScores();
                final gameScore = scores[index];
                return Text(
                  '${gameScore.score} points - Level ${gameScore.level}',
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Text('Achievements:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...userData.achievements.map(
            (achievement) => Text('🏆 $achievement'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }
}

class ClearDataDialog extends StatelessWidget {
  const ClearDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Clear All Data'),
      content: Text(
        'Are you sure you want to clear all game data? This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            DataService.clearAllData();
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('All data cleared!')));
          },
          child: Text('Clear', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

class GameOverDialog extends StatelessWidget {
  final int score;
  final int level;
  final int highScore;
  final VoidCallback onPlayAgain;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.level,
    required this.highScore,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          margin: EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Game Over!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Final Score: $score',
                style: TextStyle(fontSize: 18, color: Colors.blue.shade600),
              ),
              Text(
                'Level Reached: $level',
                style: TextStyle(fontSize: 16, color: Colors.blue.shade500),
              ),
              SizedBox(height: 8),
              Text(
                'High Score: $highScore',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Tap to play again',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onPlayAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Play Again', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StartGameDialog extends StatelessWidget {
  final VoidCallback onStartGame;
  final VoidCallback onShowStats;

  const StartGameDialog({
    super.key,
    required this.onStartGame,
    required this.onShowStats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          margin: EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Catch the Falling Object',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Swipe or use buttons to move the basket',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onStartGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Start Game', style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: onShowStats,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Stats', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
