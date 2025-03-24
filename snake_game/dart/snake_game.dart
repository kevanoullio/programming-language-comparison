import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(SnakeGameApp());

class SnakeGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final int _rows = 20;
  final int _columns = 30;
  final int _squareSize = 10;

  List<Offset> _snake = [Offset(5, 5)];
  Offset _food = Offset(10, 10);
  String _direction = "right";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        _moveSnake();
        if (_snake.first == _food) {
          _growSnake();
          _spawnFood();
        }
        if (_isGameOver()) {
          _timer?.cancel();
          _showGameOver();
        }
      });
    });
  }

  void _moveSnake() {
    Offset newHead;
    switch (_direction) {
      case "right":
        newHead = Offset(_snake.first.dx + 1, _snake.first.dy);
        break;
      case "left":
        newHead = Offset(_snake.first.dx - 1, _snake.first.dy);
        break;
      case "up":
        newHead = Offset(_snake.first.dx, _snake.first.dy - 1);
        break;
      case "down":
      default:
        newHead = Offset(_snake.first.dx, _snake.first.dy + 1);
    }
    _snake.insert(0, newHead);
    _snake.removeLast();
  }

  void _growSnake() {
    _snake.add(_snake.last);
  }

  void _spawnFood() {
    final random = Random();
    _food = Offset(
      random.nextInt(_columns).toDouble(),
      random.nextInt(_rows).toDouble(),
    );
  }

  bool _isGameOver() {
    // Check boundaries
    if (_snake.first.dx < 0 ||
        _snake.first.dx >= _columns ||
        _snake.first.dy < 0 ||
        _snake.first.dy >= _rows) {
      return true;
    }
    // Check self-collision
    for (int i = 1; i < _snake.length; i++) {
      if (_snake[i] == _snake.first) {
        return true;
      }
    }
    return false;
  }

  void _showGameOver() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Game Over"),
        content: Text("You lost! Want to try again?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _snake = [Offset(5, 5)];
                _direction = "right";
                _startGame();
              });
            },
            child: Text("Play Again"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Quit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0 && _direction != "left") {
          _direction = "right";
        } else if (details.delta.dx < 0 && _direction != "right") {
          _direction = "left";
        }
      },
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 0 && _direction != "up") {
          _direction = "down";
        } else if (details.delta.dy < 0 && _direction != "down") {
          _direction = "up";
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Snake Game"),
        ),
        body: Center(
          child: Container(
            width: _columns * _squareSize.toDouble(),
            height: _rows * _squareSize.toDouble(),
            color: Colors.black,
            child: CustomPaint(
              painter: SnakePainter(_snake, _food, _squareSize),
            ),
          ),
        ),
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final int squareSize;

  SnakePainter(this.snake, this.food, this.squareSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green;
    for (final part in snake) {
      canvas.drawRect(
        Rect.fromLTWH(
          part.dx * squareSize,
          part.dy * squareSize,
          squareSize.toDouble(),
          squareSize.toDouble(),
        ),
        paint,
      );
    }

    paint.color = Colors.red;
    canvas.drawRect(
      Rect.fromLTWH(
        food.dx * squareSize,
        food.dy * squareSize,
        squareSize.toDouble(),
        squareSize.toDouble(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
