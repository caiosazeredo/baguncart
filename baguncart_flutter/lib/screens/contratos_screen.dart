import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import 'cadastro_contrato_screen.dart';

class ContratosScreen extends StatefulWidget {
  const ContratosScreen({super.key});

  @override
  State<ContratosScreen> createState() => _ContratosScreenState();
}

class _ContratosScreenState extends State<ContratosScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Contrato> _contratos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContratos();
  }

  Future<void> _loadContratos() async {
    setState(() => _isLoading = true);
    final contratos = await _firebaseService.getContratos();
    if (mounted) {
      setState(() {
        _contratos = contratos;
        _isLoading = false;
      });
    }
  }

  Future<void> _adicionarContrato() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CadastroContratoScreen(),
      ),
    );
    
    if (resultado == true) {
      _loadContratos();
    }
  }

  Future<void> _editarContrato(Contrato contrato) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroContratoScreen(contrato: contrato),
      ),
    );
    
    if (resultado == true) {
      _loadContratos();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmado':
        return Colors.green;
      case 'em_andamento':
        return Colors.blue;
      case 'concluido':
        return Colors.purple;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pendente': return 'PENDENTE';
      case 'confirmado': return 'CONFIRMADO';
      case 'em_andamento': return 'EM ANDAMENTO';
      case 'concluido': return 'CONCLUÍDO';
      case 'cancelado': return 'CANCELADO';
      default: return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contratos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _adicionarContrato,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contratos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhum contrato encontrado', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Crie contratos para gerenciar seus eventos!', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _contratos.length,
                  itemBuilder: (context, index) {
                    final contrato = _contratos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF8B2F8B),
                          child: Icon(Icons.description, color: Colors.white),
                        ),
                        title: Text(
                          'Contrato #${contrato.numero}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(contrato.clienteNome ?? 'Cliente não informado'),
                            const SizedBox(height: 4),
                            if (contrato.valorTotal != null)
                              Text(
                                'Valor: R\$ ${contrato.valorTotal!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                            if (contrato.dataEvento != null)
                              Text(
                                'Evento: ${contrato.dataEvento!.day}/${contrato.dataEvento!.month}/${contrato.dataEvento!.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(contrato.status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStatusLabel(contrato.status),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF8B2F8B)),
                              onPressed: () => _editarContrato(contrato),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF8C00),
        onPressed: _adicionarContrato,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo Contrato', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}