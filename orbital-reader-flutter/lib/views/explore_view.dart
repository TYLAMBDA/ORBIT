import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../types.dart';
import '../orbital_provider.dart';
import '../components/glass_card.dart';
import '../components/cyber_button.dart';

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 32, bottom: 16),
            child: Row(
              children: [
                 Icon(LucideIcons.globe, color: Colors.cyanAccent, size: 32),
                 const SizedBox(width: 12),
                 Text(
                  "GALACTIC ARCHIVES",
                  style: TextStyle(
                    fontFamily: 'Orbitron', // Assuming we have it, or fallback
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Colors.cyanAccent,
                    shadows: [
                      Shadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10)
                    ]
                  ),
                ),
              ],
            )
          ),
          
          // Content
          Expanded(
            child: provider.isExploreLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.cyanAccent),
                      const SizedBox(height: 16),
                      Text("Establishing Uplink...", style: TextStyle(color: Colors.cyanAccent.withOpacity(0.7)))
                    ],
                  )
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(32),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Responsive logic could be added here
                    childAspectRatio: 0.8, // Tall cards
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title & Author
                            Text(
                              book.title,
                              style: const TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.white
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              book.author,
                              style: TextStyle(
                                fontSize: 14, 
                                color: Colors.white.withOpacity(0.6)
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 24),
                            
                            // Description
                            Expanded(
                              child: Text(
                                book.description,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  height: 1.4,
                                ),
                                maxLines: 6,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Action
                            Center(
                              child: CyberButton(
                                text: "ACQUIRE DATA",
                                icon: LucideIcons.downloadCloud,
                                width: double.infinity,
                                onPressed: () {
                                  provider.importBook(book);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Importing ${book.title}..."),
                                      backgroundColor: Colors.cyan.shade900,
                                    )
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
