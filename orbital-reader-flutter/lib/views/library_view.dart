import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../types.dart';
import '../components/glass_card.dart';
import '../components/cyber_button.dart';

import 'package:provider/provider.dart';
import '../orbital_provider.dart';

class LibraryView extends StatefulWidget {
    final Function(Book) onSelectBook;
    final DockPosition dockPosition;
    final Language language;

    const LibraryView({super.key, required this.onSelectBook, required this.dockPosition, required this.language});

    @override
    State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {

    @override
    void initState() {
      super.initState();
      // Fetch books on load
      WidgetsBinding.instance.addPostFrameCallback((_) {
         context.read<OrbitalProvider>().fetchBooks();
      });
    }

    @override
    Widget build(BuildContext context) {
         final provider = context.watch<OrbitalProvider>();
         final books = provider.libraryBooks;

         final t = widget.language == Language.en ? {
            'title': "My Library", 'subtitle': "${books.length} Books"
        } : {
            'title': "我的书库", 'subtitle': "${books.length} 本书"
        };
        
        final isMobile = MediaQuery.of(context).size.width < 768;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 48),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(t['title']!, style: TextStyle(fontSize: isMobile ? 24 : 36, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 8),
                                Text(t['subtitle']!, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ]),
                            const Row(children: [
                                Icon(LucideIcons.clock, color: Colors.grey, size: 20),
                                SizedBox(width: 16),
                                Icon(LucideIcons.star, color: Colors.grey, size: 20),
                            ])
                        ],
                    ),
                    Divider(color: Colors.blueGrey.shade800, height: 48),
                    
                    Expanded(
                        child: books.isEmpty 
                        ? Center(child: Text("Library Empty", style: TextStyle(color: Colors.white54)))
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile ? 2 : 4,
                                childAspectRatio: 2/3,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 32
                            ),
                            itemCount: books.length,
                            itemBuilder: (context, index) {
                                final book = books[index];
                                return _BookCard(book: book, onTap: () => widget.onSelectBook(book))
                                    .animate(delay: Duration(milliseconds: 100 * index))
                                    .fadeIn(duration: 500.ms)
                                    .slideY(begin: 0.1, end: 0, duration: 500.ms);
                            }
                        ),
                    )
                ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
             backgroundColor: Colors.white,
             child: const Icon(LucideIcons.plus, color: Colors.black),
             onPressed: () => _showAddBookDialog(context),
          ),
        );
    }

    void _showAddBookDialog(BuildContext context) {
      final titleCtrl = TextEditingController();
      final authorCtrl = TextEditingController();
      final contentCtrl = TextEditingController(text: "Currently empty content...");
      
      showDialog(
        context: context, 
        builder: (ctx) => AlertDialog(
           backgroundColor: const Color(0xFF1E1E1E),
           title: const Text("Upload Book", style: TextStyle(color: Colors.white)),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                TextField(
                  controller: titleCtrl, 
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Title", labelStyle: TextStyle(color: Colors.grey))
                ),
                TextField(
                  controller: authorCtrl, 
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Author", labelStyle: TextStyle(color: Colors.grey))
                ),
                TextField(
                  controller: contentCtrl, 
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Content", labelStyle: TextStyle(color: Colors.grey))
                ),
             ],
           ),
           actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              CyberButton(
                text: "UPLOAD",
                width: 120,
                height: 40,
                onPressed: () async {
                   if(titleCtrl.text.isNotEmpty && authorCtrl.text.isNotEmpty) {
                      Navigator.pop(ctx);
                      await context.read<OrbitalProvider>().uploadBook(
                        titleCtrl.text, authorCtrl.text, contentCtrl.text
                      );
                   }
                }, 
              )
           ],
        )
      );
    }
}

class _BookCard extends StatefulWidget {
    final Book book;
    final VoidCallback onTap;
    const _BookCard({required this.book, required this.onTap});

    @override
    State<_BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<_BookCard> {
    bool _isHovering = false;

    @override
    Widget build(BuildContext context) {
        return GlassCard(
            animateHover: true,
            onTap: widget.onTap,
            color: Colors.black, // Base tint
            opacity: 0.3,
            blur: 10,
            borderRadius: BorderRadius.circular(12),
            child: Stack(
                fit: StackFit.expand,
                children: [
                    // Cover
                    Container(color: widget.book.parsedColor.withOpacity(0.8)), // Slight transparency for glass
                    
                    // Gradient Overlay
                    Container(
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black12, Colors.black87],
                                stops: [0.6, 1.0]
                            )
                        ),
                    ),
                    
                    // Content
                    Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(widget.book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(widget.book.author, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                    const SizedBox(height: 12),
                                    
                                    // Progress
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: LinearProgressIndicator(
                                        value: widget.book.progress / 100,
                                            backgroundColor: const Color(0xFF8B5CF6),
                                            valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)), // Purple
                                            minHeight: 3,
                                        ),
                                    ),
                                    const SizedBox(height: 4),
                                     Align(alignment: Alignment.centerRight, child: Text("${widget.book.progress}%", style: const TextStyle(fontSize: 10, color: Colors.white54))),
                                ],
                            ),
                        ),
                    ),
                    
                                // Hover Menu
                                Positioned(
                                    top: 4, right: 4,
                                    child: AnimatedOpacity(
                                        duration: const Duration(milliseconds: 200),
                                        opacity: _isHovering ? 1.0 : 0.0,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: PopupMenuButton<String>(
                                            icon: const CircleAvatar(
                                                radius: 14,
                                                backgroundColor: Colors.black54,
                                                child: Icon(LucideIcons.moreVertical, color: Colors.white, size: 14),
                                            ),
                                            color: Colors.blueGrey.shade900,
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'open',
                                                child: Row(children: [
                                                  Icon(LucideIcons.bookOpen, color: Color(0xFF8B5CF6), size: 18),
                                                  SizedBox(width: 12),
                                                  Text("Access Data", style: TextStyle(color: Colors.white))
                                                ]),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(children: [
                                                  Icon(LucideIcons.trash2, color: Colors.redAccent, size: 18),
                                                  SizedBox(width: 12),
                                                  Text("Purge Entry", style: TextStyle(color: Colors.redAccent))
                                                ]),
                                              ),
                                            ],
                                            onSelected: (value) {
                                               if (value == 'open') {
                                                  widget.onTap();
                                               } else if (value == 'delete') {
                                                  _showDeleteDialog(context);
                                               }
                                            },
                                          ),
                                        )
                                    ),
                                )
                ],
            ),
        );
    }
    
    // Move _showDeleteDialog inside the widget if it's not already accessible or pass context
    // Actually, _showDeleteDialog is in the State, which is fine.
    // Wait, I am replacing `build` here, so I need to verify `_showDeleteDialog` call.
    // In original code, `_showDeleteDialog(context)` was called.
    // Since `_showDeleteDialog` is a method of `_BookCardState` (or handled via mixin/parent?), 
    // actually in the previous turn I added `_showDeleteDialog` to `_LibraryViewState`? 
    // No, I added it to `_BookCardState`.
    // Wait, let's double check step 1479. Yes, `_showDeleteDialog` was added to `_LibraryViewState` ??
    // Let's re-read step 1479.
    // "The following code ... library_view.dart"
    // It was added at the end of the file? No, step 1479 added it AFTER `build` of `_LibraryViewState`?
    // Let me check `library_view.dart` again to be absolutely sure where `_showDeleteDialog` lives.
    // Because if it's in `(_LibraryViewState)`, `_BookCard` cannot call it directly unless passed as prop.
    // Step 1453: `_BookCard` is a separate Stateful Widget at the bottom.
    // In Step 1479, I added `_showDeleteDialog` to... wait, where? 
    // Step 1479 ended with `}` then added `_showDeleteDialog`. 
    // If it was added after `LibraryView` class end, and `_BookCard` is in the same file...
    // Ah, `_BookCard` is a separate class in the same file.
    // If I successfully added `_showDeleteDialog` to `_BookCardState`, then `context` works.
    // Let's assume it's in `_BookCardState` for now, but I will check.

    void _showDeleteDialog(BuildContext context) {
       showDialog(
         context: context,
         builder: (ctx) => AlertDialog(
           backgroundColor: const Color(0xFF0F172A),
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.redAccent.withOpacity(0.3))),
           title: const Row(children: [
             Icon(LucideIcons.alertTriangle, color: Colors.redAccent),
             SizedBox(width: 12),
             Text("PROTOCOL 33: PURGE?", style: TextStyle(color: Colors.white, letterSpacing: 1.5, fontSize: 16))
           ]),
           content: Text("Permanently erase '${widget.book.title}' from the memory banks?\nThis action is irreversible.", style: const TextStyle(color: Colors.grey)),
           actions: [
             TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ABORT", style: TextStyle(color: Colors.grey))),
             CyberButton(
               text: "EXECUTE",
               width: 140,
               height: 40,
               color: Colors.redAccent.shade700,
               isPrimary: false,
               onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await context.read<OrbitalProvider>().deleteBook(widget.book.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.redAccent.shade700,
                          content: const Row(children: [
                            Icon(LucideIcons.checkCircle, color: Colors.white),
                            SizedBox(width: 12),
                            Text("ARCHIVE VAPORIZED"),
                          ]),
                          behavior: SnackBarBehavior.floating,
                          width: 300,
                        )
                      );
                    }
                  } catch (e) {
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Purge Failed. System Locked.")));
                     }
                  }
               }, 
             )
           ],
         )
       );
    }
}
