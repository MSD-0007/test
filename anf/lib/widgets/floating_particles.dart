import 'dart:math';
import 'package:flutter/material.dart';

class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final double minSize;
  final double maxSize;
  final Duration animationDuration;

  const FloatingParticles({
    super.key,
    this.particleCount = 50,
    this.minSize = 4.0,
    this.maxSize = 12.0,
    this.animationDuration = const Duration(seconds: 20),
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeParticles();
  }

  void _initializeParticles() {
    _controllers = [];
    _particles = [];

    for (int i = 0; i < widget.particleCount; i++) {
      final controller = AnimationController(
        duration: Duration(
          milliseconds: widget.animationDuration.inMilliseconds +
              _random.nextInt(10000), // Add randomness
        ),
        vsync: this,
      );

      final particle = Particle(
        startX: _random.nextDouble(),
        startY: _random.nextDouble() + 0.2, // Start below screen
        endX: _random.nextDouble(),
        endY: _random.nextDouble() - 0.2, // End above screen
        size: widget.minSize +
            _random.nextDouble() * (widget.maxSize - widget.minSize),
        opacity: 0.3 + _random.nextDouble() * 0.7,
        rotationSpeed: (_random.nextDouble() - 0.5) * 4, // -2 to 2
        type: ParticleType.values[_random.nextInt(ParticleType.values.length)],
        controller: controller,
      );

      _controllers.add(controller);
      _particles.add(particle);

      // Start animation with random delay
      Future.delayed(Duration(milliseconds: _random.nextInt(5000)), () {
        if (mounted) {
          controller.repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: ParticlesPainter(_particles),
        ),
      ),
    );
  }
}

enum ParticleType {
  heart,
  star,
  sparkle,
  circle,
}

class Particle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  final double opacity;
  final double rotationSpeed;
  final ParticleType type;
  final AnimationController controller;

  Particle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.opacity,
    required this.rotationSpeed,
    required this.type,
    required this.controller,
  });

  Offset getPosition(Size canvasSize) {
    final progress = controller.value;
    final x = startX + (endX - startX) * progress;
    final y = startY + (endY - startY) * progress;
    
    // Add some wave motion
    final waveX = sin(progress * 2 * pi + startX * 10) * 0.05;
    final waveY = sin(progress * 3 * pi + startY * 15) * 0.03;
    
    return Offset(
      (x + waveX) * canvasSize.width,
      (y + waveY) * canvasSize.height,
    );
  }

  double getRotation() {
    return controller.value * 2 * pi * rotationSpeed;
  }

  double getCurrentOpacity() {
    final progress = controller.value;
    // Fade in and out
    if (progress < 0.1) {
      return opacity * (progress / 0.1);
    } else if (progress > 0.9) {
      return opacity * ((1.0 - progress) / 0.1);
    }
    return opacity;
  }
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;

  ParticlesPainter(this.particles) : super(repaint: _getListenable(particles));

  static Listenable _getListenable(List<Particle> particles) {
    return Listenable.merge(particles.map((p) => p.controller).toList());
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final position = particle.getPosition(size);
      final rotation = particle.getRotation();
      final opacity = particle.getCurrentOpacity();

      if (opacity <= 0) continue;

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      switch (particle.type) {
        case ParticleType.heart:
          _drawHeart(canvas, particle.size, paint);
          break;
        case ParticleType.star:
          _drawStar(canvas, particle.size, paint);
          break;
        case ParticleType.sparkle:
          _drawSparkle(canvas, particle.size, paint);
          break;
        case ParticleType.circle:
          _drawCircle(canvas, particle.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawHeart(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final halfSize = size / 2;
    
    // Simple heart shape
    path.moveTo(0, halfSize * 0.3);
    path.cubicTo(-halfSize * 0.7, -halfSize * 0.5, -halfSize * 1.2, halfSize * 0.2, 0, halfSize * 1.2);
    path.cubicTo(halfSize * 1.2, halfSize * 0.2, halfSize * 0.7, -halfSize * 0.5, 0, halfSize * 0.3);
    
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final radius = size / 2;
    final innerRadius = radius * 0.4;
    
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - (pi / 2);
      final innerAngle = ((i + 0.5) * 2 * pi / 5) - (pi / 2);
      
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;
      final innerX = cos(innerAngle) * innerRadius;
      final innerY = sin(innerAngle) * innerRadius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(Canvas canvas, double size, Paint paint) {
    final radius = size / 2;
    
    // Draw cross shape
    canvas.drawLine(
      Offset(-radius, 0),
      Offset(radius, 0),
      paint..strokeWidth = size * 0.2,
    );
    canvas.drawLine(
      Offset(0, -radius),
      Offset(0, radius),
      paint,
    );
    
    // Draw diagonal lines
    final diagonalRadius = radius * 0.7;
    canvas.drawLine(
      Offset(-diagonalRadius, -diagonalRadius),
      Offset(diagonalRadius, diagonalRadius),
      paint..strokeWidth = size * 0.15,
    );
    canvas.drawLine(
      Offset(-diagonalRadius, diagonalRadius),
      Offset(diagonalRadius, -diagonalRadius),
      paint,
    );
  }

  void _drawCircle(Canvas canvas, double size, Paint paint) {
    canvas.drawCircle(Offset.zero, size / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}