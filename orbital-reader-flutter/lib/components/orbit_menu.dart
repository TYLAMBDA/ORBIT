import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../types.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OrbitMenu extends StatefulWidget {
  final List<MenuItem> items;
  final DockPosition currentDock;
  final String? activeItemId;
  final bool isHidden;
  final Function(MenuItem) onItemClick;
  final VoidCallback onHoverStart;
  final VoidCallback onHoverEnd;

  const OrbitMenu({
    super.key,
    required this.items,
    required this.currentDock,
    required this.activeItemId,
    required this.isHidden,
    required this.onItemClick,
    required this.onHoverStart,
    required this.onHoverEnd,
  });

  @override
  State<OrbitMenu> createState() => _OrbitMenuState();
}

class _OrbitMenuState extends State<OrbitMenu> {
  String? _hoveredItemId;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    // Geometry Constants
    final double radius = widget.currentDock == DockPosition.center
        ? (isMobile ? 150 : 280)
        : (isMobile ? 110 : 200);
        
    final double centerOffset = isMobile ? -72 : -112; 
    final double hideShift = isMobile ? 40 : 64;

    // Logic: Calculate Origin based on Dock
    double originX = size.width / 2;
    double originY = size.height / 2;
    
    if (widget.currentDock == DockPosition.left) {
        originX = 0 + centerOffset;
    } else if (widget.currentDock == DockPosition.right) {
        originX = size.width + centerOffset.abs();
    } else if (widget.currentDock == DockPosition.top) {
        originY = 0 + centerOffset;
    } else if (widget.currentDock == DockPosition.bottom) {
        originY = size.height + centerOffset.abs();
    }

    // Gap Filler Background
    // A large invisible circle that covers the area between the Orb and the Menu Items
    // ensuring we don't lose hover state when moving between them.
    final double fillerSize = (radius + 40) * 2;
    
    Widget gapFiller = Positioned(
       left: originX - fillerSize / 2,
       top: originY - fillerSize / 2,
       width: fillerSize,
       height: fillerSize,
       child: Visibility(
         visible: !widget.isHidden, // Only active when menu is showing
         child: MouseRegion(
           hitTestBehavior: HitTestBehavior.translucent, // Capture clicks even if transparent
           onEnter: (_) => widget.onHoverStart(),
           onExit: (_) => widget.onHoverEnd(),
           child: Container(
             decoration: const BoxDecoration(
               shape: BoxShape.circle,
               color: Colors.transparent, // Must have color to hit-test (even transparent)
             ),
           ),
         ),
       ),
    );

    // SORT ITEMS: Hovered item must be last (on top) for Z-Index
    List<MenuItem> sortedItems = List.from(widget.items);
    if (_hoveredItemId != null) {
      final hoveredItem = sortedItems.firstWhere((i) => i.id == _hoveredItemId, orElse: () => sortedItems.last);
      sortedItems.remove(hoveredItem);
      sortedItems.add(hoveredItem);
    }

    List<Widget> children = [gapFiller];

    children.addAll(sortedItems.map((item) {
        final index = widget.items.indexOf(item);
        final total = widget.items.length;
        
        // Calculate Position
        double angle = 0;
        
        // Use generic origin, but calculate angle
        if (widget.currentDock == DockPosition.center) {
           double angleStep = 360 / total;
           angle = (index * angleStep - 90) * (math.pi / 180);
        } else if (widget.currentDock == DockPosition.left) {
            double start = -40; double end = 40; double step = (end - start) / (total - 1);
            angle = (start + index * step) * (math.pi / 180);
        } else if (widget.currentDock == DockPosition.right) {
            double start = 140; double end = 220; double step = (end - start) / (total - 1);
            angle = (start + index * step) * (math.pi / 180);
        } else if (widget.currentDock == DockPosition.top) {
            double start = 50; double end = 130; double step = (end - start) / (total - 1);
            angle = (start + index * step) * (math.pi / 180);
        } else if (widget.currentDock == DockPosition.bottom) {
            double start = 230; double end = 310; double step = (end - start) / (total - 1);
            angle = (start + index * step) * (math.pi / 180);
        }

        // Final target position (visible)
        double targetX = originX + math.cos(angle) * radius;
        double targetY = originY + math.sin(angle) * radius;

        // Hidden Offsets
        double hiddenX = targetX;
        double hiddenY = targetY;
        
        if (widget.currentDock == DockPosition.left) hiddenX = targetX - hideShift;
        if (widget.currentDock == DockPosition.right) hiddenX = targetX + hideShift;
        if (widget.currentDock == DockPosition.top) hiddenY = targetY - hideShift;
        if (widget.currentDock == DockPosition.bottom) hiddenY = targetY + hideShift;
        
        final isActive = widget.activeItemId == item.id;
        final isSpecial = item.special;
        final activeColor = item.color;
        final isHovered = _hoveredItemId == item.id;
        
        // REVERT: Back to standard AnimatedPositioned without Animate wrapper
        // This ensures reliable visibility and position updates, fixing the disappearance issue.
        // Fix: AnimatedPositioned must be direct child of Stack. Animate wraps the *content*.
        return Positioned(
          key: ValueKey('${item.id}_${widget.currentDock}'),
          left: targetX - 20, 
          top: targetY - 20,
          child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: widget.isHidden ? 0.0 : 1.0,
              child: AnimatedScale(
                scale: widget.isHidden ? 0.0 : (widget.isHidden && widget.currentDock != DockPosition.center ? 0.85 : 1.0),
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: widget.isHidden,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) {
                        widget.onHoverStart();
                        setState(() => _hoveredItemId = item.id);
                    },
                    onExit: (_) {
                        widget.onHoverEnd();
                        setState(() => _hoveredItemId = null);
                    },
                    child: GestureDetector(
                      onTap: () => widget.onItemClick(item),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           Container(
                             width: isMobile ? 32 : 40,
                             height: isMobile ? 32 : 40,
                             decoration: BoxDecoration(
                               shape: BoxShape.circle,
                               color: isActive ? Colors.white.withOpacity(0.2) : (isSpecial ? Colors.blueGrey.shade800.withOpacity(0.8) : Colors.blueGrey.shade900.withOpacity(0.6)),
                               border: Border.all(
                                 color: isActive ? activeColor : (isSpecial ? Colors.blueGrey.shade700 : Colors.white.withOpacity(0.1)),
                                 width: 1
                               ),
                               boxShadow: isActive ? [BoxShadow(color: activeColor.withOpacity(0.5), blurRadius: 15)] : [
                                 BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
                               ]
                             ),
                             child: Icon(item.icon, size: isMobile ? 16 : 18, color: isActive ? activeColor : (isSpecial ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
                           ),
                           AnimatedSize(
                             duration: const Duration(milliseconds: 200),
                             child: SizedBox(
                               height: isHovered ? null : 0, 
                               child: AnimatedOpacity(
                                 duration: const Duration(milliseconds: 200),
                                 opacity: isHovered ? 1.0 : 0.0,
                                 child: Padding(
                                   padding: const EdgeInsets.only(top: 4),
                                   child: Text(
                                     item.label,
                                     style: TextStyle(
                                       fontSize: 9,
                                       fontWeight: FontWeight.bold,
                                       letterSpacing: 1.5,
                                       color: isActive ? activeColor : const Color(0xFF475569),
                                       fontFamily: 'Roboto',
                                       shadows: [BoxShadow(color: Colors.black, blurRadius: 4)]
                                     )
                                   ),
                                 ),
                               ),
                             ),
                           )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        );
      }).toList());

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: children,
    );
  }
}
