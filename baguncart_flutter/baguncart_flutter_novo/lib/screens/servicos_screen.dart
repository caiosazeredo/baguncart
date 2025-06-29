import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import 'cadastro_servico_screen.dart';

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({super.key});

  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Servico> _servicos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServicos();
  }

  Future<void> _loadServicos() async {
    setState(() => _isLoading = true);
    final servicos = await _firebaseService.getServicos();
    if (mounted) {
      setState(() {
        _servicos = servicos;
        _isLoading = false;
      });
    }
  }

  Future<void> _adicionarServico() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CadastroServicoScreen(),
      ),
    );
    
    if (resultado == true) {
      _loadServicos();
    }
  }

  Future<void> _editarServico(Servico servico) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroServicoScreen(servico: servico),
      ),
    );
    
    if (resultado == true) {
      _loadServicos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _adicionarServico,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _servicos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.build_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhum serviço encontrado', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _servicos.length,
                  itemBuilder: (context, index) {
                    final servico = _servicos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF8B2F8B),
                          child: Icon(Icons.build, color: Colors.white),
                        ),
                        title: Text(servico.nome),
                        subtitle: Text('R\$ ${servico.preco.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: servico.ativo ? Colors.green : Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                servico.ativo ? 'ATIVO' : 'INATIVO',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF8B2F8B)),
                              onPressed: () => _editarServico(servico),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF8C00),
        onPressed: _adicionarServico,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}