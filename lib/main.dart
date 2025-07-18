import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catch the Falling Object',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

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

  // Screen dimensions
  double screenWidth = 0;
  double screenHeight = 0;

  // Basket properties
  double basketX = 0;
  double basketY = 0;
  final double basketWidth = 80;
  final double basketHeight = 60;

  // Falling object properties
  double objectX = 0;
  double objectY = 0;
  final double objectSize = 30;
  bool objectActive = false;

  // Game settings
  final double objectSpeed = 200; // pixels per second
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    // Wait for the first frame to get screen dimensions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  void _initializeGame() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    screenWidth = renderBox.size.width;
    screenHeight = renderBox.size.height;

    // Initialize basket position
    basketX = screenWidth / 2 - basketWidth / 2;
    basketY = screenHeight - basketHeight - 100;

    setState(() {});
  }

  void _startGame() {
    setState(() {
      score = 0;
      lives = 3;
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
      // Move object down
      objectY += objectSpeed * 0.016; // 16ms frame time

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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Score: $score',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Lives: ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            ...List.generate(
                              3,
                                  (index) => Icon(
                                Icons.favorite,
                                color: index < lives ? Colors.red : Colors.grey.shade300,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

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
                        color: Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '🍎',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),

                // Basket
                if (screenWidth > 0)
                  Positioned(
                    left: basketX,
                    top: basketY,
                    child: Container(
                      width: basketWidth,
                      height: basketHeight,
                      decoration: BoxDecoration(
                        color: Colors.brown.shade600,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '🧺',
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
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
                              color: Colors.blue.shade600,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
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
                              color: Colors.blue.shade600,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
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
                  Container(
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
                              gameOver ? 'Game Over!' : 'Catch the Falling Object',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            if (gameOver)
                              Text(
                                'Final Score: $score',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            SizedBox(height: 24),
                            Text(
                              gameOver ? 'Tap to play again' : 'Swipe or use buttons to move the basket',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                gameOver ? 'Play Again' : 'Start Game',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}