import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import 'cadastro_screen.dart';
import 'editar_cliente_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Cliente> _clientes = [];
  List<Cliente> _clientesFiltrados = [];
  final _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    setState(() => _isLoading = true);
    final clientes = await _firebaseService.getClientes();
    if (mounted) {
      setState(() {
        _clientes = clientes;
        _clientesFiltrados = clientes;
        _isLoading = false;
      });
    }
  }

  void _filterClientes(String query) {
    setState(() {
      _clientesFiltrados = _clientes.where((cliente) {
        return cliente.nome.toLowerCase().contains(query.toLowerCase()) ||
               cliente.cpf.contains(query) ||
               (cliente.telefone?.contains(query) ?? false) ||
               (cliente.email?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CadastroScreen()),
              );
              _loadClientes();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar clientes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterClientes('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterClientes,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _clientesFiltrados.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum cliente encontrado',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _clientesFiltrados.length,
                        itemBuilder: (context, index) {
                          final cliente = _clientesFiltrados[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFF8B2F8B),
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(
                                cliente.nome,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CPF: ${cliente.cpf}'),
                                  if (cliente.telefone != null)
                                    Text('Tel: ${cliente.telefone}'),
                                ],
                              ),
                                                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF8B2F8B)),
                                    onPressed: () => _editarCliente(cliente),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.description, color: Color(0xFFFF8C00)),
                                    onPressed: () => _showDevelopment(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _editarCliente(Cliente cliente) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarClienteScreen(cliente: cliente),
      ),
    );
    
    if (resultado == true) {
      _loadClientes();
    }
  }

  void _showDevelopment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}