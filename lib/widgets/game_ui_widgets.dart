import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final int level;

  const ScoreDisplay({super.key, required this.score, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Score: $score',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Text(
            'Level: $level',
            style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
          ),
        ],
      ),
    );
  }
}

class LivesDisplay extends StatelessWidget {
  final int lives;

  const LivesDisplay({super.key, required this.lives});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Lives: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          ...List.generate(
            3,
            (index) => Icon(
              Icons.favorite,
              color: index < lives ? Colors.red : Colors.grey.shade300,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class HighScoreDisplay extends StatelessWidget {
  final int highScore;

  const HighScoreDisplay({super.key, required this.highScore});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Text(
        'High Score: $highScore',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.amber.shade800,
        ),
      ),
    );
  }
}

class FallingObject extends StatelessWidget {
  final double x;
  final double y;
  final double size;

  const FallingObject({
    super.key,
    required this.x,
    required this.y,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: size,
        height: size,
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
        child: Center(child: Text('🍎', style: TextStyle(fontSize: 20))),
      ),
    );
  }
}

class Basket extends StatelessWidget {
  final double x;
  final double y;
  final double width;
  final double height;

  const Basket({
    super.key,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: width,
        height: height,
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
        child: Center(child: Text('🧺', style: TextStyle(fontSize: 30))),
      ),
    );
  }
}

class ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onTapDown;

  const ControlButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.onTapDown,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: onTapDown != null ? (_) => onTapDown!() : null,
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
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}
