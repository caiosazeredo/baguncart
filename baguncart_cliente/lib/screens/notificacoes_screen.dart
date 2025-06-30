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
            validoAte: null, // CORRIGIDO: validoAte em vez de validadeAte
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
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8B2F8B),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título
                            const Text(
                              'NOTIFICAÇÕES',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B2F8B),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Notificações
                            if (_notificacoes.isNotEmpty) ...[
                              const Text(
                                'Recentes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              ...(_notificacoes.map((notificacao) => 
                                _buildNotificacaoCard(notificacao)
                              )),
                              
                              const SizedBox(height: 20),
                            ],
                            
                            // Promoções
                            if (_promocoes.isNotEmpty) ...[
                              const Text(
                                'Promoções Ativas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              ...(_promocoes.map((promocao) => 
                                _buildPromocaoCard(promocao)
                              )),
                            ],
                            
                            // Caso não haja notificações
                            if (_notificacoes.isEmpty && _promocoes.isEmpty)
                              _buildEmptyState(),
                            
                            const SizedBox(height: 100), // Espaço para o bottom nav
                          ],
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

  Widget _buildNotificacaoCard(Notificacao notificacao) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _marcarComoLida(notificacao),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getNotificacaoColor(notificacao.tipo),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _getNotificacaoIcon(notificacao.tipo),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Conteúdo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notificacao.titulo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: notificacao.lida ? Colors.grey : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notificacao.mensagem,
                        style: TextStyle(
                          fontSize: 14,
                          color: notificacao.lida ? Colors.grey : Colors.black54,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Indicador não lida
                if (!notificacao.lida)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF8C00),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromocaoCard(Promocao promocao) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8C00), Color(0xFFFF6B35)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_offer,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      promocao.titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  promocao.descricao,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                
                if (promocao.validoAte != null) ...[  // CORRIGIDO: validoAte em vez de validadeAte
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'VÁLIDO ATÉ ${DateFormat('dd/MM/yy').format(promocao.validoAte!)}',  // CORRIGIDO: validoAte em vez de validadeAte
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma notificação',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quando houver novidades, você será notificado aqui',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getNotificacaoColor(String tipo) {
    switch (tipo) {
      case 'evento':
        return const Color(0xFF8B2F8B);
      case 'promocao':
        return const Color(0xFFFF8C00);
      case 'lembrete':
        return const Color(0xFF4CAF50);
      case 'urgente':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getNotificacaoIcon(String tipo) {
    switch (tipo) {
      case 'evento':
        return Icons.event;
      case 'promocao':
        return Icons.local_offer;
      case 'lembrete':
        return Icons.alarm;
      case 'urgente':
        return Icons.priority_high;
      default:
        return Icons.info;
    }
  }
}

// Painter personalizado para o logo
class PaintSplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Splash rosa
    paint.color = const Color(0xFFFF1493).withOpacity(0.1);
    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.width * 0.6, size.height * 0.8),
      paint,
    );

    // Splash azul
    paint.color = const Color(0xFF00BFFF).withOpacity(0.1);
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.4, size.height * 0.2, size.width * 0.6, size.height * 0.8),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}