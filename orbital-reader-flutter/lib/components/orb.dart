import 'package:flutter/material.dart';
import '../types.dart';

class Orb extends StatelessWidget {
  final DockPosition position;
  final bool isHidden;
  final VoidCallback onClick;
  final VoidCallback onHoverStart;
  final VoidCallback onHoverEnd;

  const Orb({
    super.key,
    required this.position,
    required this.isHidden,
    required this.onClick,
    required this.onHoverStart,
    required this.onHoverEnd,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    // Dimensions
    final double centerSize = isMobile ? 288 : 448; // 18rem : 28rem
    final double dockedSize = isMobile ? 192 : 288; // 12rem : 18rem
    
    // Offsets
    final double visibleOffset = isMobile ? 168 : 256; // 10.5rem : 16rem
    final double hiddenOffset = isMobile ? 208 : 320; // 13rem : 20rem

    double? top, left, right, bottom;
    double width = (position == DockPosition.center) ? centerSize : dockedSize;
    double height = width;
    double opacity = 1.0;
    
    // Position Logic
    if (position == DockPosition.center) {
       top = (size.height - centerSize) / 2;
       left = (size.width - centerSize) / 2;
    } else {
        // Docked Logic
        if (position == DockPosition.left) {
            top = (size.height - dockedSize) / 2;
            left = isHidden ? -hiddenOffset : -visibleOffset;
            if (isHidden) opacity = 0.0;
        } else if (position == DockPosition.right) {
            top = (size.height - dockedSize) / 2;
            right = isHidden ? -hiddenOffset : -visibleOffset;
            if (isHidden) opacity = 0.0;
        } else if (position == DockPosition.top) {
            left = (size.width - dockedSize) / 2;
            top = isHidden ? -hiddenOffset : -visibleOffset;
            if (isHidden) opacity = 0.0;
        } else if (position == DockPosition.bottom) {
             left = (size.width - dockedSize) / 2;
             bottom = isHidden ? -hiddenOffset : -visibleOffset;
             if (isHidden) opacity = 0.0;
        }
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic, // Changed from elasticOut to prevent "shaking" on hover edge
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => onHoverStart(),
        onExit: (_) => onHoverEnd(),
        child: GestureDetector(
          onTap: onClick,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: position == DockPosition.center 
                    ? const Alignment(-0.4, -0.4) // 30% 30%
                    : (position == DockPosition.left ? const Alignment(0.6, 0.0)
                        : (position == DockPosition.right ? const Alignment(-0.6, 0.0)
                            : (position == DockPosition.top ? const Alignment(0.0, 0.6)
                                : const Alignment(0.0, -0.6)))),
                colors: const [
                  Color(0xFF60A5FA), // blue-400
                  Color(0xFF2563EB), // blue-600
                  Color(0xFF1E3A8A), // blue-900
                ],
              ),
              boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(
                       isHidden ? 0.0 : (position == DockPosition.center ? 0.5 : 0.3)
                    ),
                    blurRadius: position == DockPosition.center ? 80 : 30,
                    spreadRadius: 0,
                  ),
                if (position == DockPosition.center)
                   BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                    blurStyle: BlurStyle.inner
                  )
              ],
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: position == DockPosition.center ? 1.0 : 0.0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ORBIT',
                      style: TextStyle(
                        fontFamily: 'Roboto', // Fallback
                        fontSize: isMobile ? 36 : 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -2,
                        shadows: const [
                           Shadow(
                            blurRadius: 10.0,
                            color: Colors.black26,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'READER OS',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueAccent.shade100.withOpacity(0.8),
                        letterSpacing: 4,
                        fontWeight: FontWeight.w500,
                      )
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
