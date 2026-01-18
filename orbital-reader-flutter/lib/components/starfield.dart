import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class StarfieldBackground extends StatefulWidget {
  const StarfieldBackground({super.key});

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<Star> _stars = [];
  final Random _random = Random();
  double _time = 0.0;

  // Configuration
  static const int starCount = 150;
  static const double speed = 0.05;

  @override
  void initState() {
    super.initState();
    // Initialize stars
    for (int i = 0; i < starCount; i++) {
      _stars.add(_generateStar());
    }

    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
        _updateStars();
      });
    });
    _ticker.start();
  }

  Star _generateStar() {
    return Star(
      x: _random.nextDouble() * 2 - 1, // -1 to 1
      y: _random.nextDouble() * 2 - 1, // -1 to 1
      z: _random.nextDouble() * 1.5 + 0.1, // Depth: 0.1 to 1.6
      size: _random.nextDouble() * 1.5 + 0.5,
      brightness: _random.nextDouble(),
    );
  }

  void _updateStars() {
    for (var star in _stars) {
      // Move star towards camera (decrease z)
      star.z -= 0.005; // Base speed

      // Reset if too close or behind camera
      if (star.z <= 0.01) {
        star.z = 1.6;
        star.x = _random.nextDouble() * 2 - 1;
        star.y = _random.nextDouble() * 2 - 1;
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StarPainter(_stars, _time),
      child: Container(),
    );
  }
}

class Star {
  double x;
  double y;
  double z;
  double size;
  double brightness;

  Star({
    required this.x,
    required this.y,
    required this.z,
    required this.size,
    required this.brightness,
  });
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double time;

  StarPainter(this.stars, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (var star in stars) {
      // Perspective projection
      final factor = 1.0 / star.z;
      final x = (star.x * centerX) * factor + centerX;
      final y = (star.y * centerY) * factor + centerY;

      // Don't draw if outside screen
      if (x < 0 || x > size.width || y < 0 || y > size.height) continue;

      // Calculate size and opacity based on depth (z)
      // Closer stars (smaller z) are bigger and brighter
      double radius = star.size * (1.5 - star.z * 0.5);
      if (radius < 0.5) radius = 0.5;

      // Twinkle effect
      final twinkle = sin(time * 2 + star.x * 10) * 0.2 + 0.8;
      
      final opacity = ((1.0 - (star.z / 1.6)) * star.brightness * twinkle).clamp(0.0, 1.0);
      
      // Color: Slight blue tint for distant stars, white for close ones
      final colorBoost = (1.0 - star.z).clamp(0.0, 1.0);
      paint.color = Color.lerp(
        Colors.blueGrey.shade800, 
        Colors.white, 
        colorBoost
      )!.withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), radius, paint);
      
      // Glow for very close stars
      if (star.z < 0.3) {
         paint.color = Colors.blueAccent.withOpacity(opacity * 0.3);
         canvas.drawCircle(Offset(x, y), radius * 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) {
    return true; // Always repaint for animation
  }
}
