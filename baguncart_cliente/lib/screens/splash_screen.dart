import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final cpfSalvo = prefs.getString('cliente_cpf');
      final senhaSalva = prefs.getString('cliente_senha');
      
      if (cpfSalvo != null && senhaSalva != null) {
        final firebaseService = FirebaseService();
        final success = await firebaseService.loginSimples(cpfSalvo, senhaSalva);
        
        if (success && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          return;
        }
      }
    } catch (e) {
      print('Erro ao verificar login salvo: $e');
    }
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B2F8B), Color(0xFFFF8C00)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo com efeitos de pintura
                      Container(
                        width: 200,
                        height: 100,
                        child: Stack(
                          children: [
                            // Background com manchas de tinta
                            Positioned.fill(
                              child: CustomPaint(
                                painter: PaintSplashPainter(),
                              ),
                            ),
                            // Texto principal
                            Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Bagunç',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF1493), // Rosa
                                        fontFamily: 'Arial',
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Art',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00BFFF), // Azul
                                        fontFamily: 'Arial',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 50),
                      
                      // Loading indicator
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      const Text(
                        'Carregando...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class PaintSplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Manchas de tinta decorativas
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      15,
      paint..color = const Color(0xFFFF1493).withOpacity(0.3),
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      10,
      paint..color = const Color(0xFF00BFFF).withOpacity(0.3),
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      8,
      paint..color = const Color(0xFFFF1493).withOpacity(0.2),
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.7),
      12,
      paint..color = const Color(0xFF00BFFF).withOpacity(0.2),
    );
    
    // Estrelas pequenas
    _drawStar(canvas, Offset(size.width * 0.15, size.height * 0.15), 4);
    _drawStar(canvas, Offset(size.width * 0.85, size.height * 0.85), 3);
    _drawStar(canvas, Offset(size.width * 0.7, size.height * 0.4), 3);
  }

  void _drawStar(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path();
    const points = 5;
    const angle = 2 * 3.14159 / points;

    for (int i = 0; i < points * 2; i++) {
      final currentAngle = i * angle / 2 - 3.14159 / 2;
      final currentRadius = (i % 2 == 0) ? radius : radius * 0.5;
      final x = center.dx + currentRadius * 0.8 * math.cos(currentAngle);
      final y = center.dy + currentRadius * 0.8 * math.sin(currentAngle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}