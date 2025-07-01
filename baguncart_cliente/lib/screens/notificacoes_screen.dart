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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificacoes();
  }

  Future<void> _loadNotificacoes() async {
    setState(() => _isLoading = true);
    
    try {
      final notificacoes = await _firebaseService.getNotificacoesCliente();
      if (mounted) {
        setState(() {
          _notificacoes = notificacoes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ DEBUG: Erro ao carregar notificações: $e');
      if (mounted) {
        setState(() => _isLoading = false);
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
      
      // Atualizar localmente
      setState(() {
        final index = _notificacoes.indexWhere((n) => n.id == notificacao.id);
        if (index != -1) {
          _notificacoes[index] = Notificacao(
            id: notificacao.id,
            tipo: notificacao.tipo,
            titulo: notificacao.titulo,
            mensagem: notificacao.mensagem,
            lida: true,
            createdAt: notificacao.createdAt,
          );
        }
      });
    }
  }

  Future<void> _marcarTodasComoLidas() async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
      ),
    );

    try {
      // Marcar todas as não lidas como lidas
      for (final notif in _notificacoes.where((n) => !n.lida)) {
        if (notif.id != null) {
          await _firebaseService.marcarNotificacaoLida(notif.id!);
        }
      }
      
      // Fechar loading
      if (mounted) Navigator.of(context).pop();
      
      // Recarregar notificações
      await _loadNotificacoes();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas as notificações foram marcadas como lidas'),
            backgroundColor: Color(0xFFFF8C00),
          ),
        );
      }
    } catch (e) {
      // Fechar loading
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao marcar notificações como lidas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificacoesNaoLidas = _notificacoes.where((n) => !n.lida).length;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notificações',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (notificacoesNaoLidas > 0)
              Text(
                '$notificacoesNaoLidas não lida${notificacoesNaoLidas > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
        backgroundColor: const Color(0xFFFF8C00),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
        actions: [
          if (notificacoesNaoLidas > 0)
            TextButton.icon(
              onPressed: _marcarTodasComoLidas,
              icon: const Icon(
                Icons.done_all,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Marcar todas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotificacoes,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF8C00),
              Color(0xFFE65100),
            ],
          ),
        ),
        child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _notificacoes.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: _loadNotificacoes,
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _notificacoes.length,
                  itemBuilder: (context, index) {
                    return _buildNotificacaoCard(_notificacoes[index]);
                  },
                ),
              ),
      ),
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
          selectedItemColor: const Color(0xFFFF8C00),
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.white70,
          ),
          SizedBox(height: 16),
          Text(
            'Nenhuma notificação',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Você está em dia!\nQuando houver novidades,\nelas aparecerão aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificacaoCard(Notificacao notificacao) {
    return GestureDetector(
      onTap: () => _marcarComoLida(notificacao),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: notificacao.lida 
            ? Colors.white.withOpacity(0.85)
            : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: notificacao.lida 
            ? null 
            : Border.all(
                color: const Color(0xFFFF8C00).withOpacity(0.3),
                width: 2,
              ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Ícone da notificação
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getNotificacaoColor(notificacao.tipo),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: _getNotificacaoColor(notificacao.tipo).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getNotificacaoIcon(notificacao.tipo),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Conteúdo da notificação
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notificacao.titulo,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: notificacao.lida ? Colors.grey[600] : Colors.black87,
                                ),
                              ),
                            ),
                            if (!notificacao.lida)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF8C00),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notificacao.mensagem,
                          style: TextStyle(
                            fontSize: 14,
                            color: notificacao.lida ? Colors.grey[500] : Colors.black54,
                            height: 1.4,
                          ),
                        ),
                        if (notificacao.createdAt != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: notificacao.lida ? Colors.grey[400] : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatarDataHora(notificacao.createdAt!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: notificacao.lida ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Indicador de tipo no canto superior direito
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getNotificacaoColor(notificacao.tipo).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getTipoLabel(notificacao.tipo),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getNotificacaoColor(notificacao.tipo),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarDataHora(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);
    
    if (diferenca.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (diferenca.inMinutes < 60) {
      return '${diferenca.inMinutes}min atrás';
    } else if (diferenca.inHours < 24) {
      return '${diferenca.inHours}h atrás';
    } else if (diferenca.inDays == 1) {
      return 'Ontem';
    } else if (diferenca.inDays < 7) {
      return '${diferenca.inDays} dias atrás';
    } else {
      return DateFormat('dd/MM/yyyy - HH:mm').format(data);
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'evento':
        return 'EVENTO';
      case 'pagamento':
        return 'PAGAMENTO';
      case 'info':
        return 'INFO';
      case 'alerta':
        return 'ALERTA';
      default:
        return 'GERAL';
    }
  }

  Color _getNotificacaoColor(String tipo) {
    switch (tipo) {
      case 'evento':
        return const Color(0xFF8B2F8B);
      case 'pagamento':
        return const Color(0xFF4CAF50);
      case 'info':
        return const Color(0xFF2196F3);
      case 'alerta':
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFF607D8B);
    }
  }

  IconData _getNotificacaoIcon(String tipo) {
    switch (tipo) {
      case 'evento':
        return Icons.event;
      case 'pagamento':
        return Icons.payment;
      case 'info':
        return Icons.info;
      case 'alerta':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }
}