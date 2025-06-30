import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/models.dart';
import 'contratos_screen.dart';
import 'notificacoes_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  int _selectedIndex = 0;
  Contrato? _proximoEvento;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProximoEvento();
  }

  Future<void> _loadProximoEvento() async {
    setState(() => _isLoading = true);
    
    try {
      final evento = await _firebaseService.getProximoEvento();
      if (mounted) {
        setState(() {
          _proximoEvento = evento;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firebaseService.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0:
        // Já estamos na Home
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ContratosScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificacoesScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cliente = _firebaseService.clienteLogado;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Header com logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Logo BagunçArt
                      Container(
                        width: 150,
                        height: 60,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: PaintSplashPainter(),
                              ),
                            ),
                            Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Bagunç',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF1493),
                                        fontFamily: 'Arial',
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Art',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00BFFF),
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
                      
                      const Spacer(),
                      
                      // Botão de logout
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(
                          Icons.logout,
                          color: Color(0xFF8B2F8B),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Nome do usuário
                Text(
                  cliente?.nome ?? 'Usuário',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Card principal com informações do evento
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B2F8B), Color(0xFF6A1B6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B2F8B).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Seja Bem Vindo a',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      const Text(
                        'BAGUNÇART EVENTOS',
                        style: TextStyle(
                          color: Color(0xFFFF8C00),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      if (_isLoading)
                        const CircularProgressIndicator(color: Colors.white)
                      else if (_proximoEvento != null) ...[
                        Text(
                          '${_proximoEvento!.diasRestantes}',
                          style: const TextStyle(
                            color: Color(0xFFFF8C00),
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        
                        const Text(
                          'DIAS',
                          style: TextStyle(
                            color: Color(0xFFFF8C00),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        const Text(
                          'Para o melhor dia de todos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'DIA ESPECIAL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd/MM/yy').format(_proximoEvento!.dataEvento!),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.celebration_outlined,
                          color: Color(0xFFFF8C00),
                          size: 64,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        const Text(
                          'Nenhum evento próximo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        const Text(
                          'Entre em contato para agendar seu próximo evento!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Ações rápidas
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Meus Contratos',
                          Icons.description,
                          const Color(0xFF8B2F8B),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ContratosScreen()),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: _buildActionCard(
                          'Notificações',
                          Icons.notifications,
                          const Color(0xFFFF8C00),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificacoesScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Informações de contato
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Precisa de ajuda?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B2F8B),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      const Text(
                        'Entre em contato conosco',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildContactButton(
                            Icons.phone,
                            'Telefone',
                            Colors.green,
                          ),
                          _buildContactButton(
                            Icons.message,
                            'WhatsApp',
                            const Color(0xFF25D366),
                          ),
                          _buildContactButton(
                            Icons.mail,
                            'E-mail',
                            Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 100), // Espaço para bottom navigation
              ],
            ),
          ),
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0, // Sempre 0 para Home
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF8B2F8B),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'CONTRATO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'NOTIFICAÇÃO',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class PaintSplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Manchas de tinta decorativas pequenas
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      6,
      paint..color = const Color(0xFFFF1493).withOpacity(0.3),
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      4,
      paint..color = const Color(0xFF00BFFF).withOpacity(0.3),
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      3,
      paint..color = const Color(0xFFFF1493).withOpacity(0.2),
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.7),
      5,
      paint..color = const Color(0xFF00BFFF).withOpacity(0.2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}