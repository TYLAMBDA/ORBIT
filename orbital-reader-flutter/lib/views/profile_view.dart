import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../types.dart';

class ProfileView extends StatelessWidget {
    final User? user;
    final Language language;
    final Function(User) onUpdateUser;
    final VoidCallback onLogout;

    const ProfileView({super.key, required this.user, required this.language, required this.onUpdateUser, required this.onLogout});

    @override
    Widget build(BuildContext context) {
         if (user == null) return Container();
         
         final t = language == Language.en ? {
            'changePass': "Change Password",
            'logout': "Disconnect",
            'stats_time': "Hours Read", 'stats_read': "Books Read", 'stats_pub': "Published",
            'history': "Reading History", 'works': "Published Works"
        } : {
            'changePass': "修改密码",
            'logout': "退出登录",
            'stats_time': "阅读时长", 'stats_read': "已读数量", 'stats_pub': "发布数量",
             'history': "阅读足迹", 'works': "我的作品"
        };
        
        final isMobile = MediaQuery.of(context).size.width < 768;
        
        return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 48),
            child: Column(
                children: [
                    // Identity Card
                    Container(
                        padding: EdgeInsets.all(isMobile ? 24 : 40),
                        decoration: BoxDecoration(
                            color: Colors.blueGrey.shade900.withOpacity(0.4),
                            border: Border.all(color: Colors.blueGrey.shade800),
                            borderRadius: BorderRadius.circular(24)
                        ),
                        child: Flex(
                            direction: isMobile ? Axis.vertical : Axis.horizontal,
                            crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                            children: [
                                // Avatar
                                Container(
                                    width: 140, height: 140,
                                    decoration: BoxDecoration(
                                        color: user!.parsedAvatarColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.blueGrey.shade900, width: 4),
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)]
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(user!.username.substring(0, 2).toUpperCase(), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                                SizedBox(width: isMobile ? 0 : 48, height: isMobile ? 24 : 0),
                                
                                // Info
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                                        children: [
                                            Text(user!.username, style: TextStyle(fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0)),
                                            const SizedBox(height: 12),
                                            Row(
                                                mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                                                children: [
                                                    const Icon(LucideIcons.mail, size: 14, color: Colors.grey),
                                                    const SizedBox(width: 8),
                                                    Text(user!.email, style: const TextStyle(color: Colors.grey, fontFamily: 'RobotoMono'))
                                                ],
                                            ),
                                            const SizedBox(height: 32),
                                            Wrap(
                                                spacing: 12,
                                                alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
                                                children: [
                                                    OutlinedButton.icon(
                                                        onPressed: (){}, 
                                                        icon: const Icon(LucideIcons.key, size: 16), 
                                                        label: Text(t['changePass']!),
                                                        style: OutlinedButton.styleFrom(foregroundColor: Colors.grey, side: BorderSide(color: Colors.blueGrey.shade700), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16))
                                                    ),
                                                    OutlinedButton.icon(
                                                        onPressed: onLogout, 
                                                        icon: const Icon(LucideIcons.logOut, size: 16), 
                                                        label: Text(t['logout']!),
                                                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade300, side: BorderSide(color: Colors.red.shade900.withOpacity(0.4)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), backgroundColor: Colors.red.shade900.withOpacity(0.1))
                                                    ),
                                                ],
                                            )
                                        ],
                                    ),
                                )
                            ],
                        ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Stats
                    Row(
                        children: [
                            _StatCard(t['stats_time']!, "${user!.stats.totalReadingHours}h", LucideIcons.clock, Colors.blue),
                            const SizedBox(width: 16),
                            _StatCard(t['stats_read']!, "${user!.stats.booksRead.length}", LucideIcons.bookOpen, Colors.green),
                            const SizedBox(width: 16),
                            _StatCard(t['stats_pub']!, "${user!.stats.booksPublished.length}", LucideIcons.penTool, Colors.purple),
                        ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Lists
                    LayoutBuilder(builder: (context, constraints) {
                        return Flex(
                            direction: constraints.maxWidth < 800 ? Axis.vertical : Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                SizedBox(
                                    width: constraints.maxWidth < 800 ? double.infinity : (constraints.maxWidth - 32) / 2,
                                    child: _ListSection(t['history']!, user!.stats.booksRead, Colors.green)
                                ),
                                SizedBox(width: 32, height: constraints.maxWidth < 800 ? 32 : 0),
                                SizedBox(
                                    width: constraints.maxWidth < 800 ? double.infinity : (constraints.maxWidth - 32) / 2,
                                    child: _ListSection(t['works']!, user!.stats.booksPublished, Colors.purple)
                                ),
                            ],
                        );
                    })
                ],
            ),
        );
    }
}

class _StatCard extends StatelessWidget {
    final String label;
    final String value;
    final IconData icon;
    final Color color;
    
    const _StatCard(this.label, this.value, this.icon, this.color);
    
    @override
    Widget build(BuildContext context) {
        return Expanded(
            child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900.withOpacity(0.4),
                    border: Border.all(color: Colors.blueGrey.shade800),
                    borderRadius: BorderRadius.circular(16)
                ),
                child: Row(
                    children: [
                        Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Icon(icon, color: color, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                                    Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade400, letterSpacing: 1.0), overflow: TextOverflow.ellipsis),
                                ],
                            ),
                        )
                    ],
                ),
            ),
        );
    }
}

class _ListSection extends StatelessWidget {
    final String title;
    final List<String> items;
    final Color dotColor;
    
    const _ListSection(this.title, this.items, this.dotColor);
    
    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade200)),
                const SizedBox(height: 16),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.blueGrey.shade900.withOpacity(0.3),
                        border: Border.all(color: Colors.blueGrey.shade800),
                        borderRadius: BorderRadius.circular(16)
                    ),
                    child: items.isEmpty 
                        ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text("Nothing here yet", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))))
                        : Column(
                             children: items.map((item) => Container(
                                 padding: const EdgeInsets.all(16),
                                 decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.blueGrey.shade800.withOpacity(0.5)))),
                                 child: Row(children: [
                                     Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                                     const SizedBox(width: 12),
                                     Expanded(child: Text(item, style: TextStyle(color: Colors.blueGrey.shade100)))
                                 ]),
                             )).toList(),
                        ),
                )
            ],
        );
    }
}
