import 'package:flutter/material.dart';

class CyberButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final Color? color;
  final IconData? icon;
  final double width;
  final double height;

  const CyberButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.color,
    this.icon,
    this.width = 200,
    this.height = 50,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton> with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colors
    final baseColor = widget.color ?? (widget.isPrimary ? Colors.cyanAccent : Colors.pinkAccent);
    final glowColor = baseColor.withOpacity(0.5);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          transform: Matrix4.identity()..scale(_isHovering ? 1.05 : 1.0),
          child: CustomPaint(
            painter: _CyberPainter(
              color: baseColor,
              isHovering: _isHovering,
              isPrimary: widget.isPrimary,
              glowAnimation: _controller.value,
            ),
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   if (widget.icon != null) ...[
                      Icon(widget.icon, color: _isHovering ? Colors.black : baseColor, size: 18),
                      const SizedBox(width: 8),
                   ],
                   Text(
                     widget.text.toUpperCase(),
                     style: TextStyle(
                       color: _isHovering ? Colors.black : baseColor,
                       fontWeight: FontWeight.bold,
                       letterSpacing: 2.0,
                       fontFamily: 'Roboto', // Ideally a mono font
                       fontSize: 14,
                     ),
                   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CyberPainter extends CustomPainter {
  final Color color;
  final bool isHovering;
  final bool isPrimary;
  final double glowAnimation;

  _CyberPainter({
    required this.color,
    required this.isHovering,
    required this.isPrimary,
    required this.glowAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isHovering ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final cut = 15.0; // Cut corner size

    // Shape: Angled corners (Top Left & Bottom Right)
    path.moveTo(cut, 0);
    path.lineTo(w, 0);
    path.lineTo(w, h - cut);
    path.lineTo(w - cut, h);
    path.lineTo(0, h);
    path.lineTo(0, cut);
    path.close();

    // Draw Shadow/Glow
    if (isHovering || isPrimary) {
      final shadowPaint = Paint()
        ..color = color.withOpacity(isHovering ? 0.6 : (0.2 + 0.2 * glowAnimation))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isHovering ? 15 : 10);
      canvas.drawPath(path, shadowPaint);
    }

    canvas.drawPath(path, paint);

    // Tech Details (Decorations)
    if (!isHovering) {
       final detailPaint = Paint()..color = color.withOpacity(0.5)..strokeWidth = 1;
       // Little line at bottom right
       canvas.drawLine(Offset(w - cut - 5, h - 4), Offset(w - 10, h - 4), detailPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberPainter oldDelegate) {
    return oldDelegate.isHovering != isHovering || oldDelegate.glowAnimation != glowAnimation;
  }
}
