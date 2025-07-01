import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import 'cadastro_promocao_screen.dart';

class PromocoesScreen extends StatefulWidget {
  const PromocoesScreen({super.key});

  @override
  State<PromocoesScreen> createState() => _PromocoesScreenState();
}

class _PromocoesScreenState extends State<PromocoesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Promocao> _promocoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPromocoes();
  }

  Future<void> _loadPromocoes() async {
    setState(() => _isLoading = true);
    final promocoes = await _firebaseService.getPromocoes();
    if (mounted) {
      setState(() {
        _promocoes = promocoes;
        _isLoading = false;
      });
    }
  }

  Future<void> _adicionarPromocao() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CadastroPromocaoScreen(),
      ),
    );
    
    if (resultado == true) {
      _loadPromocoes();
    }
  }

  Future<void> _editarPromocao(Promocao promocao) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroPromocaoScreen(promocao: promocao),
      ),
    );
    
    if (resultado == true) {
      _loadPromocoes();
    }
  }

  String _formatarDesconto(Promocao promocao) {
    if (promocao.desconto == null) return 'Sem desconto';
    
    if (promocao.tipo == 'percentual') {
      return '${promocao.desconto!.toStringAsFixed(0)}% OFF';
    } else {
      return 'R\$ ${promocao.desconto!.toStringAsFixed(2)} OFF';
    }
  }

  String _formatarValidadeText(DateTime? validoAte) {
    if (validoAte == null) return 'Sem validade';
    
    final agora = DateTime.now();
    final diferenca = validoAte.difference(agora).inDays;
    
    if (diferenca < 0) return 'EXPIRADA';
    if (diferenca == 0) return 'Expira hoje';
    if (diferenca == 1) return 'Expira amanhã';
    return 'Expira em $diferenca dias';
  }

  Color _getStatusColor(Promocao promocao) {
    if (!promocao.ativo) return Colors.grey;
    if (promocao.validoAte != null && promocao.validoAte!.isBefore(DateTime.now())) {
      return Colors.red;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promoções'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _adicionarPromocao,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _promocoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma promoção cadastrada',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _adicionarPromocao,
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Primeira Promoção'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPromocoes,
                  child: ListView.builder(
                    itemCount: _promocoes.length,
                    itemBuilder: (context, index) {
                      final promocao = _promocoes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(promocao),
                            child: const Icon(
                              Icons.local_offer,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            promocao.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promocao.descricao,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: promocao.tipo == 'percentual'
                                          ? Colors.orange.shade100
                                          : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _formatarDesconto(promocao),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: promocao.tipo == 'percentual'
                                            ? Colors.orange.shade700
                                            : Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatarValidadeText(promocao.validoAte),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: promocao.validoAte != null &&
                                              promocao.validoAte!.isBefore(DateTime.now())
                                          ? Colors.red
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color(0xFFFF8C00),
                                ),
                                onPressed: () => _editarPromocao(promocao),
                                tooltip: 'Editar promoção',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmarExclusao(promocao),
                                tooltip: 'Excluir promoção',
                              ),
                            ],
                          ),
                          onTap: () => _editarPromocao(promocao),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarPromocao,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmarExclusao(Promocao promocao) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a promoção "${promocao.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmacao == true && promocao.id != null) {
      final sucesso = await _firebaseService.deletePromocao(promocao.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sucesso 
              ? 'Promoção excluída com sucesso!'
              : 'Erro ao excluir promoção'
            ),
            backgroundColor: sucesso ? Colors.green : Colors.red,
          ),
        );
        if (sucesso) _loadPromocoes();
      }
    }
  }
}