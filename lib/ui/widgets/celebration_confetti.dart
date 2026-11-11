import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  double rotationSpeed;
  double size;
  Color color;
  double opacity;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    this.opacity = 1.0,
  });
}

class CelebrationConfettiOverlay extends StatefulWidget {
  final Widget child;

  const CelebrationConfettiOverlay({super.key, required this.child});

  static CelebrationConfettiOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<CelebrationConfettiOverlayState>();
  }

  @override
  State<CelebrationConfettiOverlay> createState() => CelebrationConfettiOverlayState();
}

class CelebrationConfettiOverlayState extends State<CelebrationConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();
  bool _isPlaying = false;

  final List<Color> _colors = const [
    Color(0xFF6366F1), // Indigo
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Rose
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFFFFD700), // Gold
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addListener(_updatePhysics)
     ..addStatusListener((status) {
       if (status == AnimationStatus.completed) {
         setState(() {
           _isPlaying = false;
           _particles.clear();
         });
       }
     });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void trigger() {
    // Play celebratory sound feedback
    try {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.mediumImpact();
    } catch (_) {}

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    _particles.clear();
    // Spawn 70 celebratory particles from top and center
    for (int i = 0; i < 70; i++) {
      final startX = width * 0.2 + _random.nextDouble() * (width * 0.6);
      final startY = height * 0.35 + (_random.nextDouble() - 0.5) * 80;
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 3.0 + _random.nextDouble() * 9.0;

      _particles.add(ConfettiParticle(
        x: startX,
        y: startY,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 4.0, // slight upward pop
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.25,
        size: 7.0 + _random.nextDouble() * 6.0,
        color: _colors[_random.nextInt(_colors.length)],
      ));
    }

    setState(() {
      _isPlaying = true;
    });

    _animController.forward(from: 0.0);
  }

  void _updatePhysics() {
    final progress = _animController.value;
    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.28; // gravity
      p.vx *= 0.98; // air resistance
      p.rotation += p.rotationSpeed;
      if (progress > 0.6) {
        p.opacity = ((1.0 - progress) / 0.4).clamp(0.0, 1.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isPlaying)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(particles: _particles),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      // Draw confetti ribbon/rectangle
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: p.size,
        height: p.size * 0.6,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
