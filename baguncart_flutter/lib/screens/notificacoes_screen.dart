import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import 'cadastro_notificacao_screen.dart';

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
    final notificacoes = await _firebaseService.getNotificacoes();
    if (mounted) {
      setState(() {
        _notificacoes = notificacoes;
        _isLoading = false;
      });
    }
  }

  Future<void> _adicionarNotificacao() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CadastroNotificacaoScreen(),
      ),
    );
    
    if (resultado == true) {
      _loadNotificacoes();
    }
  }

  Future<void> _editarNotificacao(Notificacao notificacao) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroNotificacaoScreen(notificacao: notificacao),
      ),
    );
    
    if (resultado == true) {
      _loadNotificacoes();
    }
  }

  IconData _getIconoTipo(String tipo) {
    switch (tipo) {
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  Color _getCorTipo(String tipo) {
    switch (tipo) {
      case 'info':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'success':
        return Colors.green;
      default:
        return const Color(0xFF8B2F8B);
    }
  }

  String _getNomeTipo(String tipo) {
    switch (tipo) {
      case 'info':
        return 'Informação';
      case 'warning':
        return 'Aviso';
      case 'error':
        return 'Erro';
      case 'success':
        return 'Sucesso';
      default:
        return 'Geral';
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Sem data';
    
    final agora = DateTime.now();
    final diferenca = agora.difference(data);
    
    if (diferenca.inDays == 0) {
      if (diferenca.inHours == 0) {
        return '${diferenca.inMinutes}min atrás';
      }
      return '${diferenca.inHours}h atrás';
    } else if (diferenca.inDays == 1) {
      return 'Ontem';
    } else if (diferenca.inDays < 7) {
      return '${diferenca.inDays}d atrás';
    } else {
      return '${data.day}/${data.month}/${data.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _adicionarNotificacao,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notificacoes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhuma notificação encontrada', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Crie notificações para comunicar com os clientes!', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notificacoes.length,
                  itemBuilder: (context, index) {
                    final notificacao = _notificacoes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: _getCorTipo(notificacao.tipo),
                          child: Icon(_getIconoTipo(notificacao.tipo), color: Colors.white),
                        ),
                        title: Text(
                          notificacao.titulo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              notificacao.mensagem,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getCorTipo(notificacao.tipo),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getNomeTipo(notificacao.tipo),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatarData(notificacao.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: notificacao.lida ? Colors.grey : Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                notificacao.lida ? 'LIDA' : 'NOVA',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF8B2F8B)),
                              onPressed: () => _editarNotificacao(notificacao),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF8C00),
        onPressed: _adicionarNotificacao,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova Notificação', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}