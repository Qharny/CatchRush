import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
import 'dart:async';
import 'main.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _gameController;
  late Timer _gameTimer;

  // Hive boxes
  late Box<GameScore> scoresBox;
  late Box<UserData> userDataBox;
  late Box<GameSettings> settingsBox;
  late Box cacheBox;

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
  final double basketWidth = 80;
  final double basketHeight = 100;

  // Falling object properties
  double objectX = 0;
  double objectY = 0;
  final double objectSize = 40;
  bool objectActive = false;

  // Game settings
  double objectSpeed = 200; // pixels per second
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _initializeHive();
    _gameController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    // Wait for the first frame to get screen dimensions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  void _initializeHive() {
    scoresBox = Hive.box<GameScore>('scores');
    userDataBox = Hive.box<UserData>('userData');
    settingsBox = Hive.box<GameSettings>('settings');
    cacheBox = Hive.box('cache');

    // Load or create user data
    if (userDataBox.isEmpty) {
      currentUser = UserData(
        playerName: 'Player 1',
        highScore: 0,
        totalGamesPlayed: 0,
        totalScore: 0,
        lastPlayDate: DateTime.now(),
        achievements: [],
      );
      userDataBox.put('current_user', currentUser!);
    } else {
      currentUser = userDataBox.get('current_user');
    }

    // Load or create settings
    if (settingsBox.isEmpty) {
      gameSettings = GameSettings(
        soundEnabled: true,
        vibrationEnabled: true,
        gameSpeed: 1.0,
        theme: 'default',
      );
      settingsBox.put('game_settings', gameSettings!);
    } else {
      gameSettings = settingsBox.get('game_settings');
    }

    // Apply settings
    objectSpeed = 200 * gameSettings!.gameSpeed;
  }

  void _initializeGame() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    screenWidth = renderBox.size.width;
    screenHeight = renderBox.size.height;

    // Initialize basket position
    basketX = screenWidth / 2 - basketWidth / 2;
    basketY = screenHeight - basketHeight - 100;

    // Cache screen dimensions
    cacheBox.put('screen_width', screenWidth);
    cacheBox.put('screen_height', screenHeight);
    cacheBox.put('last_session', DateTime.now().toIso8601String());

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
      double currentSpeed = objectSpeed * (1 + (level - 1) * 0.2);
      objectY += currentSpeed * 0.016; // 16ms frame time

      // Check if object reached bottom
      if (objectY > screenHeight) {
        _missedObject();
      }

      // Check collision with basket
      if (_checkCollision()) {
        _caughtObject();
      }
    });
  }

  bool _checkCollision() {
    // Simple rectangular collision detection
    return objectX < basketX + basketWidth &&
        objectX + objectSize > basketX &&
        objectY < basketY + basketHeight &&
        objectY + objectSize > basketY;
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
    scoresBox.add(gameScore);

    // Update user data
    if (currentUser != null) {
      currentUser!.totalGamesPlayed++;
      currentUser!.totalScore += score;
      currentUser!.lastPlayDate = DateTime.now();

      if (score > currentUser!.highScore) {
        currentUser!.highScore = score;
        _addAchievement('New High Score!');
      }

      currentUser!.save();
    }

    // Keep only last 50 scores to prevent excessive storage
    if (scoresBox.length > 50) {
      final oldestKey = scoresBox.keys.first;
      scoresBox.delete(oldestKey);
    }
  }

  void _checkAchievements() {
    List<String> newAchievements = [];

    if (level == 5 && !currentUser!.achievements.contains('Level 5 Reached')) {
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

  void _addAchievement(String achievement) {
    if (currentUser != null &&
        !currentUser!.achievements.contains(achievement)) {
      currentUser!.achievements.add(achievement);
      currentUser!.save();

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
        objectX = random.nextDouble() * (screenWidth - objectSize);
        objectY = -objectSize;
        objectActive = true;
      });
    }
  }

  void _moveBasket(double deltaX) {
    setState(() {
      basketX += deltaX;

      // Keep basket within screen bounds
      if (basketX < 0) basketX = 0;
      if (basketX > screenWidth - basketWidth) {
        basketX = screenWidth - basketWidth;
      }
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
      builder: (context) => AlertDialog(
        title: Text('Game Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Player: ${currentUser?.playerName ?? 'Unknown'}'),
            Text('High Score: ${currentUser?.highScore ?? 0}'),
            Text('Total Games: ${currentUser?.totalGamesPlayed ?? 0}'),
            Text('Total Score: ${currentUser?.totalScore ?? 0}'),
            SizedBox(height: 16),
            Text(
              'Recent Scores:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                itemCount: scoresBox.length > 5 ? 5 : scoresBox.length,
                itemBuilder: (context, index) {
                  final scores = scoresBox.values.toList().reversed.toList();
                  final gameScore = scores[index];
                  return Text(
                    '${gameScore.score} points - Level ${gameScore.level}',
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Achievements:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...currentUser?.achievements.map(
                  (achievement) => Text('🏆 $achievement'),
                ) ??
                [],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearData() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shadowColor: Colors.black,
           // transparent outer shell
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg3.jpg'), // make sure the path is correct
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Clear All Data',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Are you sure you want to clear all game data? This cannot be undone.',
                  style: TextStyle(color: Colors.white70,fontFamily: 'RobotoMono',fontWeight: FontWeight.bold,),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: Colors.white,fontFamily: 'RobotoMono',fontWeight: FontWeight.bold,)),
                    ),
                    TextButton(
                      onPressed: () {
                        scoresBox.clear();
                        currentUser?.delete();
                        cacheBox.clear();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('All data cleared!',style: TextStyle(fontFamily: 'RobotoMono'),)));
                      },
                      child: Text('Clear', style: TextStyle(color: Colors.redAccent,fontFamily: 'RobotoMono')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white, 
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text(
          'Catch Rush',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.w600,
            color: Color(0xFFF178E6),
            fontSize: 24,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _showStats,
            icon: Icon(Icons.menu), // already white due to foregroundColor
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),


      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/bg.jpg', // Replace with your actual path
            fit: BoxFit.cover,
          ),
          SafeArea(
            bottom: false,
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              child: Stack(
                children: [

                  // Falling object
                  if (objectActive)
                    Positioned(
                      left: objectX,
                      top: objectY,
                      child: Container(
                        width: objectSize,
                        height: objectSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text('🍎', style: TextStyle(fontSize: 25)),
                        ),
                      ),
                    ),

                  // Basket
                  if (screenWidth > 0)
                    Positioned(
                      left: basketX,
                      top: basketY-60,
                      // bottom: -60,
                      child: SizedBox(
                        width: basketWidth,
                        height: basketHeight,

                        child: Image(image: AssetImage("assets/newton.png"))
                      )

                    ),

                  //score-high score-lives
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        // Score Container
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.white.withAlpha(128),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withAlpha(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(25),
                                offset: const Offset(0, 7.62),
                                blurRadius: 22.85,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Score: $score',
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow,
                                ),
                              ),
                              Text(
                                'Level: $level',
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 12,
                                  color: Colors.yellowAccent,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 12),

                        // High Score Container
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.white.withAlpha(128),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withAlpha(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(25),
                                offset: const Offset(0, 7.62),
                                blurRadius: 22.85,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            'High Score: ${currentUser?.highScore ?? 0}',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'RobotoMono',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD3FF5F),
                            ),
                          ),
                        ),

                        SizedBox(width: 12),

                        // Lives Container
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.white.withAlpha(128),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withAlpha(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(25),
                                offset: const Offset(0, 7.62),
                                blurRadius: 22.85,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(

                            children: [
                              Text(
                                'Lives:',
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF61DAFF),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...List.generate(
                                    3,
                                        (index) => Icon(
                                      Icons.favorite,
                                      color: index < lives
                                          ? Colors.red
                                          : Colors.grey.shade300,
                                      size:18,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
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
                          GestureDetector(
                            onTap: () => _moveBasket(-30),
                            onTapDown: (_) => _moveBasket(-15),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2,
                                  color: Colors.white.withAlpha(128),
                                ),
                                color: Colors.white.withAlpha(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(25),
                                    offset: const Offset(0, 7.62),
                                    blurRadius: 22.85,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_left,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _moveBasket(30),
                            onTapDown: (_) => _moveBasket(15),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2,
                                  color: Colors.white.withAlpha(128),
                                ),
                                color: Colors.white.withAlpha(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(25),
                                    offset: const Offset(0, 7.62),
                                    blurRadius: 22.85,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_right,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Start/Game Over Screen
                  if (!gameActive)
                    Positioned.fill(
                      // Use Positioned.fill for full screen overlay
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(32),
                            margin: EdgeInsets.symmetric(horizontal: 32),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: Colors.white.withAlpha(128),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white.withAlpha(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(25),
                                  offset: const Offset(0, 7.62),
                                  blurRadius: 22.85,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  gameOver
                                      ? 'Game Over!'
                                      : 'Catch the Falling Object',
                                  style: TextStyle(
                                    fontFamily: 'RobotoMono',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                if (gameOver) ...[
                                  Text(
                                    'Final Score: $score',
                                    style: TextStyle(
                                      fontFamily: 'RobotoMono',
                                      fontSize: 18,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                  Text(
                                    'Level Reached: $level',
                                    style: TextStyle(
                                      fontFamily: 'RobotoMono',
                                      fontSize: 16,
                                      color: Colors.blue.shade500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'High Score: ${currentUser?.highScore ?? 0}',
                                    style: TextStyle(
                                      fontFamily: 'RobotoMono',
                                      fontSize: 16,
                                      color: Colors.amber.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 24),
                                Text(
                                  gameOver
                                      ? 'Tap to play again'
                                      : 'Swipe or use buttons to move the basket',
                                  style: TextStyle(
                                    fontFamily: 'RobotoMono',
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _startGame,
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
                                      child: Text(
                                        gameOver ? 'Play Again' : 'Start Game',
                                        style: TextStyle(fontSize: 16,fontFamily: 'RobotoMono',),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: _showStats,
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
                                      child: Text(
                                        'Stats',
                                        style: TextStyle(fontSize: 16,fontFamily: 'RobotoMono',),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                TextButton(
                                  onPressed: _clearData,
                                  child: Text(
                                    'Clear Data',
                                    style: TextStyle(color: Colors.red,fontFamily: 'RobotoMono',),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}


