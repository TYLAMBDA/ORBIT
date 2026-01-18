import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../types.dart';
import '../components/cyber_button.dart';

import 'package:provider/provider.dart';
import '../orbital_provider.dart';

class AuthView extends StatefulWidget {
  final Language language;
  final VoidCallback onClose;

  const AuthView({
    super.key,
    required this.language,
    required this.onClose,
  });

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  String _viewMode = 'login'; // login | register
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  String? _error;
  bool _isLoading = false;

  Map<String, dynamic> get t {
    if (widget.language == Language.en) {
      return {
        'loginTitle': "NEURAL LINK",
        'registerTitle': "NEW CONSCIOUSNESS",
        'email': "Neural ID (Email)",
        'password': "Access Sequence",
        'username': "Callsign",
        'loginBtn': "INITIATE LINK",
        'registerBtn': "IMPRINT IDENTITY",
        'switchRegister': "No Signal? Establish Node",
        'switchLogin': "Signal Found? Reconnect",
        'errorCredentials': "Handshake Failed. Sequence Invalid.",
        'errorFields': "Incomplete Data Packet."
      };
    } else {
      return {
        'loginTitle': "神经链接接入",
        'registerTitle': "意识上传协议",
        'email': "神经ID (邮箱)",
        'password': "访问序列 (密码)",
        'username': "代号",
        'loginBtn': "启动同步",
        'registerBtn': "刻录身份",
        'switchRegister': "无信号？建立新节点",
        'switchLogin': "信号已存在？重连",
        'errorCredentials': "握手失败。序列无效。",
        'errorFields': "数据包丢失。请补全。"
      };
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
       _error = null;
       _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;
    final provider = context.read<OrbitalProvider>();

    try {
      if (_viewMode == 'register') {
        if (email.isEmpty || password.isEmpty || username.isEmpty) {
          throw Exception(t['errorFields']);
        }
        await provider.register(username, email, password);
      } else {
        if (email.isEmpty || password.isEmpty) {
           throw Exception(t['errorFields']);
        }
        await provider.login(email, password);
      }
      // Success is handled by provider updating state, which closes this view or updates UI
    } catch (e) {
      setState(() => _error = e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {}, // Prevent close on inner click
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.95, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 450,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900.withOpacity(0.8),
                    border: Border.all(color: Colors.blueGrey.shade700.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 20))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Decoration
                      Container(
                        height: 4,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.blue, Colors.purple, Colors.blue]),
                        ),
                      ),
                      
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
                            child: Column(
                              children: [
                                // Icon
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade800,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.blueGrey.shade700)
                                  ),
                                  child: Icon(
                                    _viewMode == 'login' ? LucideIcons.logIn : LucideIcons.userPlus,
                                    size: 32,
                                    color: _viewMode == 'login' ? Colors.blue.shade400 : Colors.purple.shade400,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Title
                                Text(
                                  _viewMode == 'login' ? t['loginTitle']! : t['registerTitle']!,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0),
                                ),
                                const SizedBox(height: 24),

                                // Form
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_viewMode == 'register') ...[
                                       _buildLabel(t['username']),
                                       const SizedBox(height: 8),
                                       _buildInput(_usernameController, LucideIcons.user, "John Doe"),
                                       const SizedBox(height: 20),
                                    ].animate(interval: 100.ms).fadeIn().slideY(begin: -0.1, end: 0),

                                    _buildLabel(t['email']),
                                    const SizedBox(height: 8),
                                    _buildInput(_emailController, LucideIcons.mail, "name@example.com"),
                                    const SizedBox(height: 20),

                                    _buildLabel(t['password']),
                                    const SizedBox(height: 8),
                                    _buildInput(_passwordController, LucideIcons.lock, "••••••••", obscureText: true),
                                    const SizedBox(height: 20),
                                  ],
                                ),

                                // Error
                                if (_error != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.red.withOpacity(0.2))
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(LucideIcons.alertCircle, color: Colors.redAccent, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
                                      ],
                                    ),
                                  ).animate().fadeIn().slideY(begin: -0.2, end: 0),

                                if (_error != null) const SizedBox(height: 20),

                                // Submit Button
                                CyberButton(
                                   text: _viewMode == 'login' ? t['loginBtn']! : t['registerBtn']!,
                                   onPressed: _handleSubmit,
                                   isPrimary: true,
                                   width: double.infinity,
                                   icon: LucideIcons.arrowRight,
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                          
                          // Close Button (Absolute relative to Stack)
                          Positioned(
                            top: 16, right: 16,
                            child: IconButton(
                              icon: const Icon(LucideIcons.x, size: 20, color: Colors.grey),
                              onPressed: widget.onClose,
                              hoverColor: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),

                      // Footer Switcher (Now part of the main Column Flow)
                      GestureDetector(
                         onTap: () {
                           setState(() {
                             _viewMode = _viewMode == 'login' ? 'register' : 'login';
                             _error = null;
                           });
                         },
                         child: Container(
                           width: double.infinity,
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: Colors.black.withOpacity(0.2),
                             border: Border(top: BorderSide(color: Colors.blueGrey.shade800)),
                           ),
                           alignment: Alignment.center,
                           child: Text(
                             _viewMode == 'login' ? t['switchRegister']! : t['switchLogin']!,
                             style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, IconData icon, String hint, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
         filled: true,
         fillColor: Colors.blueGrey.shade900.withOpacity(0.5),
         prefixIcon: Icon(icon, color: Colors.grey, size: 18),
         hintText: hint,
         hintStyle: TextStyle(color: Colors.blueGrey.shade700),
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blueGrey.shade800)),
         enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blueGrey.shade700)),
         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.withOpacity(0.5))),
         contentPadding: const EdgeInsets.symmetric(vertical: 16)
      ),
    );
  }
}
