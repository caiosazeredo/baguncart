import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/models.dart';
import 'home_screen.dart';
import 'contratos_screen.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Notificacao> _notificacoes = [];
  List<Promocao> _promocoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final notificacoesFuture = _firebaseService.getNotificacoesCliente();
      final promocoesFuture = _firebaseService.getPromocoesAtivas();
      
      final results = await Future.wait([notificacoesFuture, promocoesFuture]);
      
      if (mounted) {
        setState(() {
          _notificacoes = results[0] as List<Notificacao>;
          _promocoes = results[1] as List<Promocao>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Para demonstração, adicionar dados mock
        _promocoes = [
          const Promocao(
            id: 'mock1',
            titulo: 'PROMOÇÃO RELÂMPAGO',
            descricao: 'Kit pula pula + pipoca: R\$20,00',
            desconto: 20.00,
            validadeAte: null,
          ),
        ];
        
        _notificacoes = [
          const Notificacao(
            id: 'mock1',
            tipo: 'evento',
            titulo: 'FALTAM SÓ 15 DIAS',
            mensagem: 'Seu evento está prestes a acontecer!\nQualquer ajuda que precisar, entre em contato conosco.',
          ),
        ];
      }
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ContratosScreen()),
        );
        break;
      case 2:
        // Já estamos na tela de notificações
        break;
    }
  }

  Future<void> _marcarComoLida(Notificacao notificacao) async {
    if (notificacao.id != null && !notificacao.lida) {
      await _firebaseService.marcarNotificacaoLida(notificacao.id!);
      _loadData(); // Recarregar para atualizar o status
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Header com logo e botão voltar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF8B2F8B),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Logo BagunçArt
                    Container(
                      width: 120,
                      height: 50,
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF1493),
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Art',
                                    style: TextStyle(
                                      fontSize: 16,
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
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Conteúdo
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          child: Column(
                            children: [
                              // Promoções
                              if (_promocoes.isNotEmpty) ...[
                                ..._promocoes.map((promocao) => _buildPromocaoCard(promocao)),
                                const SizedBox(height: 20),
                              ],
                              
                              // Notificações
                              if (_notificacoes.isNotEmpty) ...[
                                ..._notificacoes.map((notificacao) => _buildNotificacaoCard(notificacao)),
                              ],
                              
                              // Caso não tenha nenhuma notificação
                              if (_promocoes.isEmpty && _notificacoes.isEmpty) ...[
                                const SizedBox(height: 100),
                                const Icon(
                                  Icons.notifications_none,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Nenhuma notificação',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Você está em dia com tudo!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
              ),
            ],
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
          currentIndex: 2,
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

  Widget _buildPromocaoCard(Promocao promocao) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C00),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ATENÇÃO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'PROMOÇÃO RELÂMPAGO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            promocao.descricao,
            style: const TextStyle(
              color: Color(0xFFFF8C00),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (promocao.validadeAte != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'VÁLIDO ATÉ ${DateFormat('dd/MM/yy').format(promocao.validadeAte!)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'VÁLIDO ATÉ 05/05/25',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificacaoCard(Notificacao notificacao) {
    return GestureDetector(
      onTap: () => _marcarComoLida(notificacao),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notificacao.titulo,
              style: const TextStyle(
                color: Color(0xFFFF8C00),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              notificacao.mensagem,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
            
            if (notificacao.createdAt != null) ...[
              const SizedBox(height: 16),
              Text(
                DateFormat('dd/MM/yyyy - HH:mm').format(notificacao.createdAt!),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
            
            if (!notificacao.lida) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C00).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'NOVA',
                  style: TextStyle(
                    color: Color(0xFFFF8C00),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
      4,
      paint..color = const Color(0xFFFF1493).withOpacity(0.3),
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      3,
      paint..color = const Color(0xFF00BFFF).withOpacity(0.3),
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      2,
      paint..color = const Color(0xFFFF1493).withOpacity(0.2),
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.7),
      3,
      paint..color = const Color(0xFF00BFFF).withOpacity(0.2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}