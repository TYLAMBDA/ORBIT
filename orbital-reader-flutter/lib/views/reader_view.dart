import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../types.dart';


class ReaderView extends StatelessWidget {
    final DockPosition dockPosition;
    final Language language;
    final Book? book;

    ReaderView({super.key, required this.dockPosition, required this.language, this.book});

    final Map<String, List<String>> bookExcerpts = {
        '1': [
            "The nanosuit was soft to the touch, but Wang Miao felt like he was wearing a layer of flayed skin. It monitored his heart rate, his sweat, his trembling.",
            "He stood in front of the window. The city was a sea of lights, but to him, it was a burning circuit board, calculating the countdown to humanity's end.",
            "Physics has never existed, and will never exist. The suicide note of Yang Dong replayed in his mind.",
            "The frontiers of science were not merely expanding; they were shattering. And he was standing on the precipice, looking down into the abyss where the laws of nature dissolved into chaos."
        ],
        '2': [
            "A beginning is the time for taking the most delicate care that the balances are correct. This is known by every sister of the Bene Gesserit.",
            "To begin your study of the life of Muad'Dib, then, take care that you first place him in his time: born in the 57th year of the Padishah Emperor Shaddam IV.",
            "And take the most special care that you locate him in his place: the planet Arrakis. Do not be deceived by the fact that he was born on Caladan and lived his first years there. Arrakis, the planet known as Dune, is forever his place.",
            "The mystery of life isn't a problem to solve, but a reality to experience."
        ],
        'default': [
            "This is a placeholder text for books that do not have specific mock content in this prototype.",
            "The Orbital Reader interface allows for a focused reading experience free from distractions.",
            "The text you are reading flows naturally, adapting to the screen size and your reading speed.",
            "Imagine complex worlds and vivid characters coming to life as you scroll through these pages."
        ]
    };

    @override
    Widget build(BuildContext context) {
         if (book == null) return Container();
         

         


         // TEXT RENDERING MODE (Fallback)
         final content = bookExcerpts[book!.id] ?? bookExcerpts['default']!;
         final t = language == Language.en ? {'chapter': "Chapter 1"} : {'chapter': "第一章"};
         final isMobile = MediaQuery.of(context).size.width < 768;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 48),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                             // Header
                             Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                     Expanded(
                                         child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                                 // Hero Cover
                                                 Hero(
                                                   tag: 'book-cover-${book!.id}',
                                                   child: Container(
                                                     width: 60, height: 90,
                                                     margin: const EdgeInsets.only(bottom: 16),
                                                     decoration: BoxDecoration(
                                                       color: book!.parsedColor,
                                                       borderRadius: BorderRadius.circular(8),
                                                        boxShadow: [
                                                            BoxShadow(color: book!.parsedColor.withOpacity(0.5), blurRadius: 20)
                                                        ]
                                                     ),
                                                   ),
                                                 ),
                                                 Text(t['chapter']!.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 2.0, fontSize: 12)),
                                                 const SizedBox(height: 8),
                                                 Text(book!.title, style: TextStyle(fontFamily: 'serif', fontSize: isMobile ? 32 : 48, color: Colors.white, height: 1.1)),
                                                 const SizedBox(height: 8),
                                                 Text(book!.author, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey.shade400, fontSize: 16)),
                                             ],
                                         ),
                                     ),
                                     Row(children: [
                                         IconButton(onPressed: (){}, icon: const Icon(LucideIcons.type, color: Colors.grey)),
                                         IconButton(onPressed: (){}, icon: const Icon(LucideIcons.bookmark, color: Colors.grey)),
                                         IconButton(onPressed: (){}, icon: const Icon(LucideIcons.share2, color: Colors.grey)),
                                         const SizedBox(width: 16),
                                         IconButton(
                                            onPressed: () {
                                                // Trigger back via Navigator or Provider
                                                // Since we use Navigator, pop() works and triggers onPopPage
                                                Navigator.of(context).pop();
                                            }, 
                                            icon: const Icon(LucideIcons.x, color: Colors.white)
                                         ),
                                     ])
                                 ],
                             ),
                             Divider(color: Colors.blueGrey.shade800, height: 64),
                             
                             // Content
                             Column(
                                 children: content.asMap().entries.map((entry) {
                                     return Padding(
                                         padding: const EdgeInsets.only(bottom: 24),
                                         child: Text(
                                             entry.value,
                                             style: TextStyle(fontFamily: 'serif', fontSize: isMobile ? 18 : 22, color: Colors.blueGrey.shade100, height: 1.8),
                                         ).animate(delay: Duration(milliseconds: 200 * entry.key)).fadeIn().slideY(begin: 0.1, end: 0, duration: 600.ms),
                                     );
                                 }).toList(),
                             ),
                             
                             const SizedBox(height: 64),
                             Center(child: Text("1 / 24", style: TextStyle(color: Colors.blueGrey.shade600))),
                             const SizedBox(height: 100),
                        ],
                    ),
                ),
            ),
          ),
        );
    }
}
