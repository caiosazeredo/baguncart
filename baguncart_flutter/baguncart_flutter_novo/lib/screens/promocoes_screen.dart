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
    if (promocao.tipo == 'percentual') {
      return '${promocao.desconto.toStringAsFixed(0)}% OFF';
    } else {
      return 'R\$ ${promocao.desconto.toStringAsFixed(2)} OFF';
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
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhuma promoção encontrada', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Crie promoções para atrair mais clientes!', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _promocoes.length,
                  itemBuilder: (context, index) {
                    final promocao = _promocoes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(promocao),
                          child: const Icon(Icons.local_offer, color: Colors.white),
                        ),
                        title: Text(
                          promocao.titulo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              promocao.descricao,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF8C00),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _formatarDesconto(promocao),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatarValidadeText(promocao.validoAte),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getStatusColor(promocao),
                                    fontWeight: FontWeight.w500,
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
                                color: _getStatusColor(promocao),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                promocao.ativo ? 'ATIVA' : 'INATIVA',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF8B2F8B)),
                              onPressed: () => _editarPromocao(promocao),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF8C00),
        onPressed: _adicionarPromocao,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova Promoção', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}