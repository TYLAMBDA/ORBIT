import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../types.dart';
import '../orbital_provider.dart';
import '../components/glass_card.dart';
import '../components/cyber_button.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExploreView extends StatefulWidget {
  final DockPosition dockPosition;

  const ExploreView({super.key, required this.dockPosition});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  @override
  void initState() {
    super.initState();
    // Fetch data when view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrbitalProvider>().fetchExploreBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrbitalProvider>();
    final books = provider.exploreBooks;
    final size = MediaQuery.of(context).size;
    
    // Responsive column count
    int crossAxisCount = 4;
    if (size.width < 600) crossAxisCount = 1;
    else if (size.width < 900) crossAxisCount = 2;
    else if (size.width < 1200) crossAxisCount = 3;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(48, 48, 48, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(LucideIcons.globe, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "GALACTIC ARCHIVES",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                                ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Discover sci-fi classics from across the cosmos",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                ],
              ),
            ),
          ),
          
          // Content
          provider.isExploreLoading
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.5),
                              blurRadius: 30,
                            )
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Establishing Uplink...",
                        style: TextStyle(
                          color: const Color(0xFF8B5CF6).withOpacity(0.8),
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.58, // Taller cards to prevent overflow
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final book = books[index];
                      return _BookCard(
                        book: book,
                        onAcquire: () {
                          provider.importBook(book);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(LucideIcons.downloadCloud, color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  Text("Importing ${book.title}..."),
                                ],
                              ),
                              backgroundColor: const Color(0xFF8B5CF6),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ).animate(delay: Duration(milliseconds: 50 * index))
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, end: 0, duration: 500.ms);
                    },
                    childCount: books.length,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _BookCard extends StatefulWidget {
  final ExploreBook book;
  final VoidCallback onAcquire;

  const _BookCard({required this.book, required this.onAcquire});

  @override
  State<_BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<_BookCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovering ? 1.02 : 1.0),
        child: GlassCard(
          animateHover: false,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E1B4B).withOpacity(0.3),
                  const Color(0xFF0A0E1A).withOpacity(0.5),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Area with Gradient
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF8B5CF6).withOpacity(0.3),
                          const Color(0xFF3B82F6).withOpacity(0.3),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Geometric pattern overlay
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _GridPatternPainter(),
                          ),
                        ),
                        // Book icon/symbol
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.bookOpen,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Content
                Expanded(
                  flex: 3, // More space for content
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Reduced padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.book.title,
                          style: const TextStyle(
                            fontSize: 16, // Slightly smaller
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        
                        // Author
                        Row(
                          children: [
                            Icon(
                              LucideIcons.user,
                              size: 14,
                              color: const Color(0xFF8B5CF6).withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.book.author,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        
                        const Spacer(),
                        
                        // Description preview
                        Text(
                          widget.book.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11, // Smaller text
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: CyberButton(
                            text: "ACQUIRE",
                            icon: LucideIcons.downloadCloud,
                            width: double.infinity,
                            height: 44,
                            onPressed: widget.onAcquire,
                          ),
                        ),
                      ],
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

// Custom painter for geometric grid pattern
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
