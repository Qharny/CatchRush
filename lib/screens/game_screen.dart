import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../services/data_service.dart';
import '../services/game_logic_service.dart';
import '../widgets/dialog_widgets.dart';
import '../widgets/game_ui_widgets.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _gameController;
  late Timer _gameTimer;

  // Game state
  int score = 0;
  int lives = 3;
  bool gameActive = false;
  bool gameOver = false;
  int level = 1;

  // User data
  UserData? currentUser;
  GameSettings? gameSettings;

  // Screen dimensions
  double screenWidth = 0;
  double screenHeight = 0;

  // Basket properties
  double basketX = 0;
  double basketY = 0;

  // Falling object properties
  double objectX = 0;
  double objectY = 0;
  bool objectActive = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _gameController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    // Wait for the first frame to get screen dimensions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  void _initializeData() {
    currentUser = DataService.getOrCreateUserData();
    gameSettings = DataService.getOrCreateGameSettings();
  }

  void _initializeGame() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    screenWidth = renderBox.size.width;
    screenHeight = renderBox.size.height;

    // Initialize basket position
    basketX = screenWidth / 2 - GameLogicService.basketWidth / 2;
    basketY = screenHeight - GameLogicService.basketHeight - 100;

    // Cache screen dimensions
    DataService.cacheBox.put('screen_width', screenWidth);
    DataService.cacheBox.put('screen_height', screenHeight);
    DataService.cacheBox.put('last_session', DateTime.now().toIso8601String());

    setState(() {});
  }

  void _startGame() {
    setState(() {
      score = 0;
      lives = 3;
      level = 1;
      gameActive = true;
      gameOver = false;
      objectActive = false;
    });

    _spawnNewObject();
    _startGameLoop();
  }

  void _startGameLoop() {
    _gameTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (gameActive && !gameOver) {
        _updateGame();
      }
    });
  }

  void _updateGame() {
    if (!objectActive) return;

    setState(() {
      // Move object down (speed increases with level)
      double currentSpeed = GameLogicService.calculateObjectSpeed(level);
      objectY += currentSpeed * 0.016; // 16ms frame time

      // Check if object reached bottom
      if (objectY > screenHeight) {
        _missedObject();
      }

      // Check collision with basket
      if (GameLogicService.checkCollision(
        objectX: objectX,
        objectY: objectY,
        basketX: basketX,
        basketY: basketY,
      )) {
        _caughtObject();
      }
    });
  }

  void _caughtObject() {
    setState(() {
      score++;
      objectActive = false;

      // Level up every 10 points
      if (score % 10 == 0) {
        level++;
        _checkAchievements();
      }
    });

    // Spawn new object after short delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (gameActive) {
        _spawnNewObject();
      }
    });
  }

  void _missedObject() {
    setState(() {
      lives--;
      objectActive = false;

      if (lives <= 0) {
        gameOver = true;
        gameActive = false;
        _gameTimer.cancel();
        _saveGameData();
      }
    });

    // Spawn new object if game still active
    if (gameActive) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (gameActive) {
          _spawnNewObject();
        }
      });
    }
  }

  void _saveGameData() {
    // Save current game score
    final gameScore = GameScore(
      score: score,
      date: DateTime.now(),
      level: level,
    );
    DataService.saveGameScore(gameScore);

    // Update user data
    if (currentUser != null) {
      currentUser!.totalGamesPlayed++;
      currentUser!.totalScore += score;
      currentUser!.lastPlayDate = DateTime.now();

      if (score > currentUser!.highScore) {
        currentUser!.highScore = score;
        _addAchievement('New High Score!');
      }

      DataService.updateUserData(currentUser!);
    }
  }

  void _checkAchievements() {
    if (currentUser != null) {
      GameLogicService.checkAchievements(currentUser!, score, level);

      List<String> newAchievements = [];
      if (level == 5 &&
          !currentUser!.achievements.contains('Level 5 Reached')) {
        newAchievements.add('Level 5 Reached');
      }
      if (score >= 25 && !currentUser!.achievements.contains('Score Master')) {
        newAchievements.add('Score Master');
      }
      if (currentUser!.totalGamesPlayed >= 10 &&
          !currentUser!.achievements.contains('Persistent Player')) {
        newAchievements.add('Persistent Player');
      }

      for (String achievement in newAchievements) {
        _addAchievement(achievement);
      }
    }
  }

  void _addAchievement(String achievement) {
    if (currentUser != null &&
        !currentUser!.achievements.contains(achievement)) {
      currentUser!.achievements.add(achievement);
      DataService.updateUserData(currentUser!);

      // Show achievement notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🏆 Achievement Unlocked: $achievement'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _spawnNewObject() {
    if (screenWidth > 0) {
      setState(() {
        objectX = GameLogicService.generateRandomObjectX(screenWidth);
        objectY = -GameLogicService.objectSize;
        objectActive = true;
      });
    }
  }

  void _moveBasket(double deltaX) {
    setState(() {
      basketX = GameLogicService.constrainBasketPosition(
        basketX + deltaX,
        screenWidth,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (gameActive) {
      _moveBasket(details.delta.dx);
    }
  }

  void _showStats() {
    showDialog(
      context: context,
      builder: (context) => StatsDialog(userData: currentUser!),
    );
  }

  void _clearData() {
    showDialog(context: context, builder: (context) => ClearDataDialog());
  }

  @override
  void dispose() {
    _gameController.dispose();
    if (_gameTimer.isActive) {
      _gameTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue.shade300, Colors.lightBlue.shade100],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: Stack(
              children: [
                // Game UI
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ScoreDisplay(score: score, level: level),
                      LivesDisplay(lives: lives),
                    ],
                  ),
                ),

                // High Score Display
                Positioned(
                  top: 80,
                  left: 20,
                  child: HighScoreDisplay(
                    highScore: currentUser?.highScore ?? 0,
                  ),
                ),

                // Menu Button
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    onPressed: _showStats,
                    icon: Icon(Icons.menu, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: CircleBorder(),
                    ),
                  ),
                ),

                // Falling object
                if (objectActive)
                  FallingObject(
                    x: objectX,
                    y: objectY,
                    size: GameLogicService.objectSize,
                  ),

                // Basket
                if (screenWidth > 0)
                  Basket(
                    x: basketX,
                    y: basketY,
                    width: GameLogicService.basketWidth,
                    height: GameLogicService.basketHeight,
                  ),

                // Control buttons
                if (gameActive)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ControlButton(
                          icon: Icons.arrow_left,
                          onTap: () => _moveBasket(-30),
                          onTapDown: () => _moveBasket(-15),
                        ),
                        ControlButton(
                          icon: Icons.arrow_right,
                          onTap: () => _moveBasket(30),
                          onTapDown: () => _moveBasket(15),
                        ),
                      ],
                    ),
                  ),

                // Start/Game Over Screen
                if (!gameActive)
                  gameOver
                      ? GameOverDialog(
                          score: score,
                          level: level,
                          highScore: currentUser?.highScore ?? 0,
                          onPlayAgain: _startGame,
                        )
                      : StartGameDialog(
                          onStartGame: _startGame,
                          onShowStats: _showStats,
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
