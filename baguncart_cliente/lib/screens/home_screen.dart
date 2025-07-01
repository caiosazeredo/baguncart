import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/models.dart';
import 'contratos_screen.dart';
import 'notificacoes_screen.dart';
import 'promocoes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  
  // Contadores para badges
  int _notificacoesCount = 0;
  int _promocoesCount = 0;
  
  // Dados para exibição
  String? _proximoEvento;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() => _isLoading = true);
    
    try {
      // Carregar contadores para badges
      final notifCountFuture = _firebaseService.getNotificacoesNaoLidasCount();
      final promoCountFuture = _firebaseService.getPromocoesAtivasCount();
      
      // Carregar dados para exibição
      final contratosFuture = _firebaseService.getContratosCliente();
      
      final results = await Future.wait([
        notifCountFuture,
        promoCountFuture,
        contratosFuture,
      ]);
      
      if (mounted) {
        setState(() {
          _notificacoesCount = results[0] as int;
          _promocoesCount = results[1] as int;
          
          final contratos = results[2] as List<Contrato>;
          if (contratos.isNotEmpty) {
            final proximoContrato = contratos.first;
            _proximoEvento = proximoContrato.numero;
          }
          
          _isLoading = false;
        });
        
        print('🔍 DEBUG: Dados carregados na tela:');
        print('   Notificações: $_notificacoesCount');
        print('   Promoções: $_promocoesCount');
        if (_proximoEvento != null) {
          print('   Próximo evento: $_proximoEvento');
        }
      }
    } catch (e) {
      print('❌ DEBUG: Erro ao carregar dados da home: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Valores mock para demonstração
          _notificacoesCount = 2;
          _promocoesCount = 1;
          _proximoEvento = "C20250630-855";
        });
      }
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        // Já estamos na Home
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ContratosScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NotificacoesScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B2F8B),
              Color(0xFF6A1B6A),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Olá, ${_firebaseService.clienteLogado?.nome ?? "Cliente"}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bem-vindo ao BagunçArt',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        
                        // Próximo evento
                        if (_proximoEvento != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'PRÓXIMO EVENTO',
                                  style: TextStyle(
                                    color: Color(0xFFFF8C00),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _proximoEvento!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Cards de ação com badges
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Row(
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
                              child: _buildActionCardWithBadge(
                                'Notificações',
                                Icons.notifications,
                                const Color(0xFFFF8C00),
                                _notificacoesCount,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const NotificacoesScreen()),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Nova linha com promoções
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCardWithBadge(
                                'Promoções',
                                Icons.local_offer,
                                const Color(0xFF4CAF50),
                                _promocoesCount,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PromocoesScreen()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionCard(
                                'Suporte',
                                Icons.help_outline,
                                const Color(0xFF2196F3),
                                () {
                                  // Implementar suporte
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Entre em contato: (11) 99999-9999'),
                                      backgroundColor: Color(0xFF2196F3),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B2F8B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Entre em contato conosco!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildContactButton(
                              Icons.phone,
                              '(11) 99999-9999',
                              const Color(0xFF4CAF50),
                            ),
                            _buildContactButton(
                              Icons.email,
                              'contato@baguncart.com',
                              const Color(0xFF2196F3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
        ),
      ),
      
      // Bottom Navigation com badge
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
          currentIndex: 0,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF8B2F8B),
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'HOME',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'CONTRATO',
            ),
            BottomNavigationBarItem(
              icon: _buildIconWithBadge(Icons.notifications, _notificacoesCount),
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
            Icon(icon, color: color, size: 32),
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

  Widget _buildActionCardWithBadge(String title, IconData icon, Color color, int count, VoidCallback onTap) {
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 32),
                if (count > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
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

  Widget _buildIconWithBadge(IconData icon, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 9 ? '9+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContactButton(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}