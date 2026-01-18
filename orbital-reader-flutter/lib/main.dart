import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'orbital_provider.dart';
import 'types.dart';
import 'components/orb.dart';
import 'components/orbit_menu.dart';
import 'views/auth_view.dart';
import 'views/library_view.dart';
import 'views/reader_view.dart';
import 'views/settings_view.dart';
import 'views/profile_view.dart';
import 'views/explore_view.dart';
import 'components/starfield.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrbitalProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Orbital Reader',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617), // slate-950
        fontFamily: 'Roboto', 
        useMaterial3: true,
      ),
      home: const OrbitalScaffold(),
    );
  }
}

class OrbitalScaffold extends StatelessWidget {
  const OrbitalScaffold({super.key});

  List<MenuItem> getMenuItems(Language lang, Map<String, String> t) {
    return [
      MenuItem(id: 'library', label: t['library']!, icon: LucideIcons.library, targetDock: DockPosition.left, color: const Color(0xFF3B82F6)),
      MenuItem(id: 'reader', label: t['reader']!, icon: LucideIcons.bookOpen, targetDock: DockPosition.top, color: const Color(0xFF10B981)),
      MenuItem(id: 'search', label: t['search']!, icon: LucideIcons.search, targetDock: DockPosition.left, color: const Color(0xFFF59E0B)),
      MenuItem(id: 'profile', label: t['profile']!, icon: LucideIcons.user, targetDock: DockPosition.top, color: const Color(0xFF8B5CF6)),
      MenuItem(id: 'settings', label: t['settings']!, icon: LucideIcons.settings, targetDock: DockPosition.left, color: const Color(0xFF64748B)),
      MenuItem(id: 'offline', label: t['offline']!, icon: LucideIcons.wifiOff, targetDock: DockPosition.center, color: const Color(0xFF94A3B8), special: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrbitalProvider>();
    final t = provider.t;
    final currentMenuItems = getMenuItems(provider.language, t);
    
    // Logic for auto-hiding the orb
    final isOrbVisible = provider.dockPosition == DockPosition.center || !provider.autoHide || provider.isInteracting;

    // Pre-calculate Blur Backdrop Layout
    double? blurLeft, blurRight, blurTop, blurBottom, blurWidth, blurHeight;
    if (provider.autoHide) {
        final isMobile = MediaQuery.of(context).size.width < 768;
        final dockSize = isMobile ? 80.0 : 120.0;
        switch (provider.dockPosition) {
           case DockPosition.left: blurLeft = 0; blurTop = 0; blurBottom = 0; blurWidth = dockSize; break;
           case DockPosition.right: blurRight = 0; blurTop = 0; blurBottom = 0; blurWidth = dockSize; break;
           case DockPosition.top: blurLeft = 0; blurRight = 0; blurTop = 0; blurHeight = dockSize; break;
           case DockPosition.bottom: blurLeft = 0; blurRight = 0; blurBottom = 0; blurHeight = dockSize; break;
           default: blurLeft = 0; blurRight = 0; blurTop = 0; blurBottom = 0; 
        }
    }

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Stack(
        fit: StackFit.expand,
        children: [
           // 1. Background Ambience
           Container(
             decoration: const BoxDecoration(
               gradient: RadialGradient(
                 center: Alignment.center,
                 radius: 1.5,
                 colors: [Color(0xFF1E293B), Color(0xFF020617)],
               ),
             ),
          ),
          /* Animated Starfield Surprise */
          const Positioned.fill(child: StarfieldBackground()),
          
          // 2. Main Content Area (Views) using Navigator for Hero Support
          Positioned.fill(
             child: Navigator(
                key: ValueKey(provider.activeItemId),
                onPopPage: (route, result) {
                  if (!route.didPop(result)) return false;
                  // Handle pop (back button)
                  
                  // If we were in Reader, popping goes back to Library
                  if (provider.activeItemId == 'reader') {
                      provider.setActiveItemId('library');
                      return true;
                  }
                  
                  // For all other main views (Library, Settings, etc.), popping means going back to Home (Orb)
                  // unless we decide otherwise. But effectively, removing the top page means
                  // reverting to whatever is below.
                  // Since our stack logic is explicit:
                  // [Home, Library] -> pop -> [Home]
                  // So we should set activeItemId to null.
                  
                  if (provider.activeItemId != null) {
                       // If we are essentially "closing" the current main view
                       provider.setActiveItemId(null);
                       provider.setDockPosition(DockPosition.center);
                  }
                  
                  return true;
                },
                pages: _buildPages(context, provider),
             ),
          ),

          // 3. Edge Detection Regions
          Positioned(top: 0, left: 0, right: 0, height: 50, child: MouseRegion(onEnter: (_) => provider.handleEdgeEnter(DockPosition.top), onExit: (_) => provider.handleEdgeExit(), child: Container(color: Colors.transparent))),
          Positioned(bottom: 0, left: 0, right: 0, height: 50, child: MouseRegion(onEnter: (_) => provider.handleEdgeEnter(DockPosition.bottom), onExit: (_) => provider.handleEdgeExit(), child: Container(color: Colors.transparent))),
          Positioned(top: 0, left: 0, bottom: 0, width: 50, child: MouseRegion(onEnter: (_) => provider.handleEdgeEnter(DockPosition.left), onExit: (_) => provider.handleEdgeExit(), child: Container(color: Colors.transparent))),
          Positioned(top: 0, right: 0, bottom: 0, width: 50, child: MouseRegion(onEnter: (_) => provider.handleEdgeEnter(DockPosition.right), onExit: (_) => provider.handleEdgeExit(), child: Container(color: Colors.transparent))),
           
           if (provider.activeItemId != 'auth') ...[
               // Blur Backdrop for Auto-Hide Overlay
               if (provider.autoHide)
                   
                   Positioned(
                       left: blurLeft, right: blurRight, top: blurTop, bottom: blurBottom,
                       width: blurWidth, height: blurHeight,
                       child: IgnorePointer(
                         ignoring: !isOrbVisible,
                         child: AnimatedOpacity(
                           duration: const Duration(milliseconds: 300),
                           opacity: isOrbVisible ? 1.0 : 0.0,
                           child: ClipRect(
                             child: ShaderMask(
                               shaderCallback: (Rect bounds) {
                                  // Gradient to fade out the blur at the edge facing the center of screen
                                  Alignment begin = Alignment.centerLeft;
                                  Alignment end = Alignment.centerRight;
                                  
                                  switch (provider.dockPosition) {
                                      case DockPosition.left: // Fade out to RIGHT
                                          begin = Alignment.centerLeft; end = Alignment.centerRight;
                                          break;
                                      case DockPosition.right: // Fade out to LEFT
                                          begin = Alignment.centerRight; end = Alignment.centerLeft;
                                          break;
                                      case DockPosition.top: // Fade out to BOTTOM
                                          begin = Alignment.topCenter; end = Alignment.bottomCenter;
                                          break;
                                      case DockPosition.bottom: // Fade out to TOP
                                          begin = Alignment.bottomCenter; end = Alignment.topCenter;
                                          break;
                                      default: break;
                                  }

                                  return LinearGradient(
                                    begin: begin,
                                    end: end,
                                    stops: const [0.0, 0.8, 1.0], // Fade out at the very edge (80%-100%)
                                    colors: const [Colors.white, Colors.white, Colors.transparent],
                                  ).createShader(bounds);
                               },
                               blendMode: BlendMode.dstIn,
                               child: BackdropFilter(
                                 filter: setupBlur(),
                                 child: Container(
                                   color: Colors.black.withOpacity(0.35),
                                 ),
                               ),
                             ),
                           ),
                         ),
                       ),
                   ),

               OrbitMenu(
                 items: currentMenuItems,
                 currentDock: provider.dockPosition,
                 activeItemId: provider.activeItemId,
                 isHidden: !isOrbVisible,
                 onItemClick: provider.handleMenuItemClick,
                 onHoverStart: () => provider.setHover('menu', true),
                 onHoverEnd: () => provider.setHover('menu', false),
               ),
               Orb(
                 position: provider.dockPosition,
                 isHidden: !isOrbVisible,
                 onClick: () {
                    provider.setDockPosition(DockPosition.center);
                    provider.setActiveItemId(null);
                 },
                 onHoverStart: () => provider.setHover('orb', true),
                 onHoverEnd: () => provider.setHover('orb', false),
               ),
           ],

          // 4. TOP RIGHT HEADER AREA (Status + User)
          Positioned(
            top: 24,
            right: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.isOfflineMode) ...[
                    GestureDetector( // Added Click to Toggle Off
                      onTap: () => provider.setIsOfflineMode(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.wifiOff, size: 14, color: Colors.redAccent),
                            const SizedBox(width: 8),
                            Text(t['status_offline']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                            const SizedBox(width: 6),
                            const Icon(Icons.close, size: 10, color: Colors.redAccent) // Status indicator
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                ],

                // User Interaction Area
                GestureDetector(
                   onTap: () {
                     if (provider.user != null) {
                        if (provider.activeItemId != 'profile') {
                           provider.setActiveItemId('profile');
                           provider.setDockPosition(provider.preferredDock);
                        }
                     } else {
                        if (provider.isOfflineMode) provider.setIsOfflineMode(false);
                        provider.setActiveItemId('auth');
                     }
                   },
                   child: AnimatedContainer(
                     duration: const Duration(milliseconds: 200),
                     height: 48, // Taller, more clickable
                     padding: const EdgeInsets.only(left: 6, right: 16),
                     decoration: BoxDecoration(
                       color: provider.user != null ? Colors.blueGrey.shade900.withOpacity(0.8) : Colors.blue.shade600,
                       borderRadius: BorderRadius.circular(24),
                       border: Border.all(
                           color: provider.user != null ? Colors.blueGrey.shade700 : Colors.blue.shade400,
                           width: 1.5
                       ),
                       boxShadow: [
                           BoxShadow(
                               color: provider.user != null ? Colors.black26 : Colors.blue.withOpacity(0.4),
                               blurRadius: 12,
                               offset: const Offset(0, 4)
                           )
                       ]
                     ),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         // Avatar / Icon
                         Container(
                           width: 36, height: 36,
                           decoration: BoxDecoration(
                               shape: BoxShape.circle,
                               color: provider.user != null ? Colors.blueAccent : Colors.white.withOpacity(0.2),
                               image: provider.user != null ? null : null, // Could add avatar image here
                           ),
                           alignment: Alignment.center,
                           child: provider.user != null 
                             ? Text(provider.user!.username.substring(0, 2).toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))
                             : const Icon(LucideIcons.logIn, size: 18, color: Colors.white),
                         ),
                         const SizedBox(width: 12),
                         // Text Label
                         Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                                 Text(
                                    provider.user != null ? provider.user!.username : t['login']!,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)
                                 ),
                                 if (provider.user != null)
                                     Text(t['status_online']!, style: const TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.w500))
                                 else 
                                     Text(t['status_guest']!, style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500))
                             ],
                         )
                       ],
                     ),
                   ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsets _calculateViewPadding(BuildContext context, OrbitalProvider provider) {
      if (provider.autoHide) {
          return const EdgeInsets.all(0); // If auto-hide, content expands fully
      }
      
      // If docked and NOT auto-hidden, we reserve space
      // Mobile always behaves like auto-hide mostly, but let's respect dock
      final isMobile = MediaQuery.of(context).size.width < 768;
      final dockSize = isMobile ? 80.0 : 120.0;

      switch (provider.dockPosition) {
          case DockPosition.left: return EdgeInsets.only(left: dockSize);
          case DockPosition.right: return EdgeInsets.only(right: dockSize);
          case DockPosition.top: return EdgeInsets.only(top: dockSize);
          case DockPosition.bottom: return EdgeInsets.only(bottom: dockSize);
          default: return EdgeInsets.zero;
      }
  }

  List<Page> _buildPages(BuildContext context, OrbitalProvider provider) {
      final padding = _calculateViewPadding(context, provider);
      
      List<Page> pages = [];
      
      // 1. Base Layer: Home (Transparent / Orb View)
      // This ensures we always have a page in the stack.
      pages.add(const MaterialPage(
        key: ValueKey('home'),
        child: Scaffold(backgroundColor: Colors.transparent), // Empty scaffolding for "Desktop" state
      ));

      // 2. Navigation Logic
      // If we have an active item, we push it onto the stack.
      // For Reader, we usually want Library underneath to support Hero transitions.
      
      if (provider.activeItemId == 'library') {
          pages.add(MaterialPage(
            key: const ValueKey('library'),
            child: Padding(
                padding: padding,
                child: LibraryView(
                   onSelectBook: provider.handleBookSelect,
                   dockPosition: provider.dockPosition,
                   language: provider.language
                )
            )
          ));
      } 
      else if (provider.activeItemId == 'reader') {
          // To support Hero from Library -> Reader, include Library in stack logic?
          // If we just add Reader, it replaces Home. Hero *might* not work if the source widget is gone.
          // Let's add Library explicitly if we are in Reader mode (assuming flow is Lib -> Reader).
          
          pages.add(MaterialPage(
            key: const ValueKey('library'),
            child: Padding(
                padding: padding,
                child: LibraryView(
                   onSelectBook: provider.handleBookSelect,
                   dockPosition: provider.dockPosition,
                   language: provider.language
                )
            )
          ));
          
          pages.add(MaterialPage(
            key: const ValueKey('reader'),
            child: Padding(padding: padding, child: ReaderView(
               dockPosition: provider.dockPosition,
               language: provider.language,
               book: provider.currentBook,
            ))
          ));
      } 
      else if (provider.activeItemId == 'profile') {
          pages.add(MaterialPage(
             key: const ValueKey('profile'),
             child: Padding(padding: padding, child: ProfileView(
                language: provider.language,
                user: provider.user,
                onUpdateUser: provider.setUser,
                onLogout: provider.handleLogout,
             ))
          ));
      } 
      else if (provider.activeItemId == 'settings') {
          pages.add(MaterialPage(
             key: const ValueKey('settings'),
             child: Padding(padding: padding, child: SettingsView(
                language: provider.language,
                preferredDock: provider.preferredDock,
                onDockChange: provider.setPreferredDock,
                currentDockPosition: provider.dockPosition,
                autoHide: provider.autoHide,
                onAutoHideChange: provider.setAutoHide,
                edgeNav: provider.edgeNav,
                onEdgeNavChange: provider.setEdgeNav,
                onLanguageChange: provider.setLanguage,
             ))
          ));
      } 
      else if (provider.activeItemId == 'search') {
          pages.add(MaterialPage(
             key: const ValueKey('search'),
             child: Padding(padding: padding, child: ExploreView(
                dockPosition: provider.dockPosition
             ))
          ));
      } 
      else if (provider.activeItemId == 'auth') {
           pages.add(MaterialPage(
             key: const ValueKey('auth'),
             child: AuthView(
               language: provider.language,
               onClose: () => provider.setActiveItemId(null)
             )
           ));
      } 
      
      return pages;
  }

  ImageFilter setupBlur() {
    return ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0);
  }
}
