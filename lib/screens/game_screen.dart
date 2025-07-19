import 'dart:async';

import 'package:catchrush/services/cache_service.dart';
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
  bool gamePaused = false;
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

    // Load cached data if available
    _loadCachedData();
  }

  void _loadCachedData() {
    // Load cached basket position
    final basketPosition = CacheService.getBasketPosition();
    if (basketPosition != null) {
      // We'll set these after screen dimensions are available in _initializeGame()
    }

    // Load cached game state if needed
    final gameState = CacheService.getGameState();
    if (gameState != null) {
      // You can restore game state here if implementing save/load functionality
    }

    // Load user preferences
    final preferences = CacheService.getUserPreferences();
    if (preferences != null) {
      // Apply user preferences here
    }
  }

  void _initializeGame() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    screenWidth = renderBox.size.width;
    screenHeight = renderBox.size.height;

    // Try to load cached basket position
    final basketPosition = CacheService.getBasketPosition();
    if (basketPosition != null) {
      basketX = basketPosition['x']!;
      basketY = basketPosition['y']!;
    } else {
      // Initialize basket position to center
      basketX = screenWidth / 2 - GameLogicService.basketWidth / 2;
      basketY = screenHeight - GameLogicService.basketHeight - 100;
    }

    // Save screen dimensions to cache
    DataService.saveCache(
      screenWidth,
      screenHeight,
      additionalData: {
        'basket_x': basketX,
        'basket_y': basketY,
        'last_session': DateTime.now().toIso8601String(),
      },
    );

    setState(() {});
  }

  void _startGame() {
    setState(() {
      score = 0;
      lives = 3;
      level = 1;
      gameActive = true;
      gameOver = false;
      gamePaused = false;
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
    if (!objectActive || gamePaused) return;

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

    // Update cache with new basket position
    CacheService.saveBasketPosition(basketX, basketY);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (gameActive && !gamePaused) {
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data'),
        content: Text(
          'Are you sure you want to clear all game data and cache? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              DataService.clearAllData();
              CacheService.clearAllCache();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('All data and cache cleared!')),
              );
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _pauseGame() {
    setState(() {
      gamePaused = true;
    });
  }

  void _resumeGame() {
    setState(() {
      gamePaused = false;
    });
  }

  void _showMenu() {
    if (gameActive && !gameOver) {
      // Show pause menu when game is active
      _showPauseMenu();
    } else {
      // Show stats when game is not active
      _showStats();
    }
  }

  void _showPauseMenu() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PauseMenuDialog(
        onResume: () {
          Navigator.pop(context);
          _resumeGame();
        },
        onShowStats: () {
          Navigator.pop(context);
          _showStats();
        },
        onRestart: () {
          Navigator.pop(context);
          _startGame();
        },
        onQuit: () {
          Navigator.pop(context);
          setState(() {
            gameActive = false;
            gamePaused = false;
          });
        },
      ),
    );
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
                    onPressed: _showMenu,
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
                          onTap: () => gamePaused ? null : _moveBasket(-30),
                          onTapDown: () => gamePaused ? null : _moveBasket(-15),
                        ),
                        ControlButton(
                          icon: Icons.arrow_right,
                          onTap: () => gamePaused ? null : _moveBasket(30),
                          onTapDown: () => gamePaused ? null : _moveBasket(15),
                        ),
                      ],
                    ),
                  ),

                // Pause Overlay
                if (gamePaused && gameActive)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
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
                            Icon(
                              Icons.pause_circle_outline,
                              size: 48,
                              color: Colors.blue.shade600,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'PAUSED',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap menu to resume',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
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
