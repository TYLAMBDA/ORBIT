import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../types.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsView extends StatelessWidget {
    final DockPosition preferredDock;
    final Function(DockPosition) onDockChange;
    final DockPosition currentDockPosition;
    final bool autoHide;
    final Function(bool) onAutoHideChange;
    final bool edgeNav;
    final Function(bool) onEdgeNavChange;
    final Language language;
    final Function(Language) onLanguageChange;

    const SettingsView({
        super.key,
        required this.preferredDock, 
        required this.onDockChange,
        required this.currentDockPosition,
        required this.autoHide,
        required this.onAutoHideChange,
        required this.edgeNav,
        required this.onEdgeNavChange,
        required this.language,
        required this.onLanguageChange
    });

    @override
    Widget build(BuildContext context) {
        final t = language == Language.en ? {
            'title': "Settings",
            'interface': "Interface",
            'dockPos': "Dock Anchor",
            'dockDesc': "Choose the primary anchor point.",
            'dockDescOmni': "Omni-Wake active: Dock is accessible from all sides.",
            'behavior': "Behavior",
            'autoHide': "Auto-hide Dock",
            'autoHideDesc': "Automatically hide the orb when not in use. Hover edge to reveal.",
            'edgeNav': "Omni-Directional Wake",
            'edgeNavDesc': "Allow the dock to be summoned from any screen edge.",
            'general': "General",
            'language': "Language",
            'privacy': "Privacy & Data",
            'top': "Top", 'bottom': "Bottom", 'left': "Left", 'right': "Right"
        } : {
            'title': "设置",
            'interface': "界面布局",
            'dockPos': "导航停靠锚点",
            'dockDesc': "选择导航球的主要停靠位置。",
            'dockDescOmni': "全向灵动唤醒已激活：导航球可从屏幕任意边缘唤出。",
            'behavior': "交互行为",
            'autoHide': "自动隐藏导航球",
            'autoHideDesc': "不使用时自动隐藏，鼠标靠近边缘时显示。",
            'edgeNav': "全向灵动唤醒",
            'edgeNavDesc': "允许从屏幕的上下左右任意边缘呼出导航球。",
            'general': "常规",
            'language': "语言",
            'privacy': "隐私与数据",
            'top': "顶部", 'bottom': "底部", 'left': "左侧", 'right': "右侧"
        };
        
        final isMobile = MediaQuery.of(context).size.width < 768;

        return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 48),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1152),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(t['title']!, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 32),
                        
                        // GRID
                        LayoutBuilder(builder: (context, constraints) {
                           return Wrap(
                               spacing: 32,
                               runSpacing: 32,
                               children: [
                                   // LEFT COLUMN: Interface
                                   SizedBox(
                                       width: constraints.maxWidth > 800 ? (constraints.maxWidth - 32) / 2 : constraints.maxWidth,
                                       child: Container(
                                           padding: const EdgeInsets.all(32),
                                           decoration: BoxDecoration(
                                               color: Colors.blueGrey.shade900.withOpacity(0.5),
                                               borderRadius: BorderRadius.circular(24),
                                               border: Border.all(color: Colors.blueGrey.shade800)
                                           ),
                                           child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                   Row(children: [
                                                       const Icon(LucideIcons.monitor, color: Colors.blueAccent),
                                                       const SizedBox(width: 12),
                                                       Text(t['interface']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white70))
                                                   ]),
                                                   const SizedBox(height: 24),
                                                   
                                                   // Dock Pos Label
                                                   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                       Text(t['dockPos']!.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                                                       if (edgeNav)
                                                           Animate(effects: const [FadeEffect(), ScaleEffect()], child: const Row(children: [
                                                               Icon(Icons.radio_button_checked, size: 12, color: Colors.blueAccent),
                                                               SizedBox(width: 4),
                                                               Text("Active Everywhere", style: TextStyle(color: Colors.blueAccent, fontSize: 10))
                                                           ]))
                                                   ]),
                                                   const SizedBox(height: 16),
                                                   
                                                   // Grid Buttons
                                                   GridView.count(
                                                       shrinkWrap: true,
                                                       crossAxisCount: 2,
                                                       childAspectRatio: 2.5,
                                                       mainAxisSpacing: 12,
                                                       crossAxisSpacing: 12,
                                                       physics: const NeverScrollableScrollPhysics(),
                                                       children: [
                                                           _DockButton(DockPosition.top, t['top']!, LucideIcons.arrowUp, preferredDock, edgeNav, onDockChange),
                                                           _DockButton(DockPosition.bottom, t['bottom']!, LucideIcons.arrowDown, preferredDock, edgeNav, onDockChange),
                                                           _DockButton(DockPosition.left, t['left']!, LucideIcons.arrowLeft, preferredDock, edgeNav, onDockChange),
                                                           _DockButton(DockPosition.right, t['right']!, LucideIcons.arrowRight, preferredDock, edgeNav, onDockChange),
                                                       ],
                                                   ),
                                                   const SizedBox(height: 16),
                                                   Text(edgeNav ? t['dockDescOmni']! : t['dockDesc']!, style: TextStyle(fontSize: 12, color: edgeNav ? Colors.blue.shade200 : Colors.grey)),

                                                   const SizedBox(height: 32),
                                                   
                                                   // Language
                                                   Row(children: [
                                                       const Icon(LucideIcons.languages, color: Colors.pinkAccent),
                                                       const SizedBox(width: 12),
                                                       Text(t['language']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white70))
                                                   ]),
                                                   const SizedBox(height: 16),
                                                   Row(children: [
                                                       Expanded(child: _LangButton(Language.en, "English", language, onLanguageChange)),
                                                       const SizedBox(width: 12),
                                                       Expanded(child: _LangButton(Language.zh, "中文 (Chinese)", language, onLanguageChange)),
                                                   ])
                                               ],
                                           ),
                                       ),
                                   ),

                                   // RIGHT COLUMN: Behavior
                                   SizedBox(
                                       width: constraints.maxWidth > 800 ? (constraints.maxWidth - 32) / 2 : constraints.maxWidth,
                                       child: Column(
                                           children: [
                                               Container(
                                                   padding: const EdgeInsets.all(32),
                                                   decoration: BoxDecoration(
                                                       color: Colors.blueGrey.shade900.withOpacity(0.5),
                                                       borderRadius: BorderRadius.circular(24),
                                                       border: Border.all(color: Colors.blueGrey.shade800)
                                                   ),
                                                   child: Column(
                                                       children: [
                                                           Row(children: [
                                                               const Icon(LucideIcons.mousePointerClick, color: Colors.purpleAccent),
                                                               const SizedBox(width: 12),
                                                               Text(t['behavior']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white70))
                                                           ]),
                                                           const SizedBox(height: 32),
                                                           // Switch 1
                                                           _SwitchTile(t['autoHide']!, t['autoHideDesc']!, LucideIcons.eyeOff, autoHide, onAutoHideChange),
                                                           const SizedBox(height: 24),
                                                           // Switch 2
                                                           Opacity(
                                                               opacity: autoHide ? 1.0 : 0.5,
                                                               child: IgnorePointer(
                                                                   ignoring: !autoHide,
                                                                   child: _SwitchTile(t['edgeNav']!, t['edgeNavDesc']!, LucideIcons.radio, edgeNav, onEdgeNavChange, activeColor: Colors.purple),
                                                               )
                                                           )
                                                       ],
                                                   ),
                                               ),
                                               const SizedBox(height: 32),
                                               
                                               // Privacy (Dummy)
                                               Opacity(
                                                   opacity: 0.5,
                                                   child: Container(
                                                       padding: const EdgeInsets.all(32),
                                                       decoration: BoxDecoration(
                                                           color: Colors.blueGrey.shade900.withOpacity(0.3),
                                                           borderRadius: BorderRadius.circular(24),
                                                           border: Border.all(color: Colors.blueGrey.shade800)
                                                       ),
                                                       child: Column(
                                                           crossAxisAlignment: CrossAxisAlignment.start,
                                                           children: [
                                                               Row(children: [
                                                                   const Icon(LucideIcons.shield, color: Colors.green),
                                                                   const SizedBox(width: 12),
                                                                   Text(t['privacy']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white70))
                                                               ]),
                                                               const SizedBox(height: 24),
                                                               Container(height: 8, width: 200, color: Colors.white10),
                                                               const SizedBox(height: 12),
                                                               Container(height: 8, width: 140, color: Colors.white10),
                                                           ],
                                                       ),
                                                   ),
                                               )
                                           ],
                                       ),
                                   )
                               ],
                           );
                        })
                    ],
                )
            ),
        );
    }
}

class _DockButton extends StatelessWidget {
    final DockPosition pos;
    final String label;
    final IconData icon;
    final DockPosition current;
    final bool disabled;
    final Function(DockPosition) onTap;

    const _DockButton(this.pos, this.label, this.icon, this.current, this.disabled, this.onTap);

    @override
    Widget build(BuildContext context) {
        final isSelected = current == pos;
        
        Color bg = Colors.blueGrey.shade800;
        Color border = Colors.blueGrey.shade700;
        Color text = Colors.grey;

        if (disabled) {
            bg = Colors.blue.shade900.withOpacity(0.8);
            border = Colors.blue.shade500;
            text = Colors.blue.shade100;
        } else if (isSelected) {
            bg = Colors.blue.shade600.withOpacity(0.2);
            border = Colors.blue.shade500;
            text = Colors.white;
        }

        return GestureDetector(
            onTap: () => !disabled ? onTap(pos) : null,
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                    boxShadow: (isSelected || disabled) ? [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 10)] : null
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(icon, size: 18, color: text),
                        const SizedBox(width: 8),
                        Text(label, style: TextStyle(color: text, fontWeight: FontWeight.w500))
                    ],
                ),
            ),
        );
    }
}

class _LangButton extends StatelessWidget {
    final Language lang;
    final String label;
    final Language current;
    final Function(Language) onTap;

    const _LangButton(this.lang, this.label, this.current, this.onTap);

    @override
    Widget build(BuildContext context) {
        final isSelected = current == lang;
        return GestureDetector(
            onTap: () => onTap(lang),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: isSelected ? Colors.blueGrey.shade700 : Colors.blueGrey.shade800,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? Colors.blueGrey.shade500 : Colors.blueGrey.shade700)
                ),
                child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.w500)),
            ),
        );
    }
}

class _SwitchTile extends StatelessWidget {
    final String title;
    final String subtitle;
    final IconData icon;
    final bool value;
    final Function(bool) onChanged;
    final Color activeColor;

    const _SwitchTile(this.title, this.subtitle, this.icon, this.value, this.onChanged, {this.activeColor = Colors.blue});

    @override
    Widget build(BuildContext context) {
        return Row(
            children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Row(children: [
                                Icon(icon, size: 16, color: Colors.white70),
                                const SizedBox(width: 8),
                                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white70))
                            ]),
                            const SizedBox(height: 4),
                            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey))
                        ],
                    ),
                ),
                GestureDetector(
                    onTap: () => onChanged(!value),
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44, height: 24,
                        decoration: BoxDecoration(
                            color: value ? activeColor : Colors.blueGrey.shade700,
                            borderRadius: BorderRadius.circular(12)
                        ),
                        child: AnimatedAlign(
                            duration: const Duration(milliseconds: 200),
                            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                width: 20, height: 20,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            ),
                        ),
                    ),
                )
            ],
        );
    }
}
