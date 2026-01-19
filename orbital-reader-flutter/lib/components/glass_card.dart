import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool animateHover;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 15,
    this.opacity = 0.1,
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.onTap,
    this.animateHover = false,
  });

  @override
  Widget build(BuildContext context) {
    if (animateHover) {
      return _AnimatedGlassCard(
        blur: blur,
        opacity: opacity,
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border,
        boxShadow: boxShadow,
        onTap: onTap,
        child: child,
      );
    }

    return _buildCard(false);
  }

  Widget _buildCard(bool isHovered) {
    final finalBorderRadius = borderRadius ?? BorderRadius.circular(16);
    
    // Default Style
    final defaultColor = color ?? Colors.white;
    final defaultBorder = border ?? Border.all(color: Colors.white.withOpacity(0.1));
    final defaultShadow = boxShadow ?? [];

    // Hover Enhancements
    final effectiveShadow = isHovered 
        ? [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.4), blurRadius: 20, spreadRadius: 2), ...defaultShadow]
        : defaultShadow;
    
    final effectiveBorder = isHovered
        ? Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.6))
        : defaultBorder;

    Widget card = ClipRRect(
      borderRadius: finalBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: defaultColor.withOpacity(opacity),
            borderRadius: finalBorderRadius,
            border: effectiveBorder,
            boxShadow: effectiveShadow,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

class _AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const _AnimatedGlassCard({
    required this.child,
    required this.blur,
    required this.opacity,
    this.color,
    required this.borderRadius,
    this.border,
    this.boxShadow,
    this.onTap,
  });

  @override
  State<_AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<_AnimatedGlassCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Reconstruct style logic here or extract to helper
    final defaultColor = widget.color ?? Colors.white;
    final defaultBorder = widget.border ?? Border.all(color: Colors.white.withOpacity(0.1));
    final defaultShadow = widget.boxShadow ?? [];

    final effectiveShadow = _isHovering 
        ? [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.4), blurRadius: 20, spreadRadius: 2), ...defaultShadow]
        : defaultShadow;
    
    final effectiveBorder = _isHovering
        ? Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.6))
        : defaultBorder;
        
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovering ? 1.02 : 1.0),
           decoration: BoxDecoration(
              // We can't animate BackdropFilter easily, so we animate the wrapper container properties
              // Actually, standard Glassmorphism uses a stack or simple container.
              // For performance, we'll keep it simple: just animate scale and border/shadow on the container
               borderRadius: widget.borderRadius,
               boxShadow: effectiveShadow,
           ),
           child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                 child: AnimatedContainer(
                   duration: const Duration(milliseconds: 200),
                   decoration: BoxDecoration(
                     color: defaultColor.withOpacity(widget.opacity + (_isHovering ? 0.05 : 0)),
                     borderRadius: widget.borderRadius,
                     border: effectiveBorder,
                   ),
                   child: widget.child,
                 ),
              ),
           ),
        ),
      ),
    );
  }
}
