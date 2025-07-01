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

  Future<void> _editarCliente(Cliente cliente) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarClienteScreen(cliente: cliente),
      ),
    );
    
    if (resultado == true) {
      _loadClientes(); // Recarregar lista após edição
    }
  }

  Future<void> _verDetalhesCliente(Cliente cliente) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cliente.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('CPF:', cliente.cpf),
            if (cliente.telefone != null)
              _buildDetailRow('Telefone:', cliente.telefone!),
            if (cliente.email != null)
              _buildDetailRow('Email:', cliente.email!),
            if (cliente.endereco != null)
              _buildDetailRow('Endereço:', cliente.endereco!),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.lock, size: 16, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Senha para app:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      cliente.senha ?? 'Senha não definida',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      _editarCliente(cliente);
                    },
                    tooltip: 'Editar senha',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use CPF e senha acima para login no app cliente',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editarCliente(cliente);
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _confirmarExclusao(Cliente cliente) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o cliente ${cliente.nome}?'),
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

    if (confirmacao == true && cliente.id != null) {
      final sucesso = await _firebaseService.deleteCliente(cliente.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sucesso 
              ? 'Cliente excluído com sucesso!'
              : 'Erro ao excluir cliente'
            ),
            backgroundColor: sucesso ? Colors.green : Colors.red,
          ),
        );
        if (sucesso) _loadClientes();
      }
    }
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
          // Campo de pesquisa
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
          
          // Lista de clientes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _clientesFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _clientes.isEmpty
                                  ? 'Nenhum cliente cadastrado'
                                  : 'Nenhum cliente encontrado',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_clientes.isEmpty)
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CadastroScreen(),
                                    ),
                                  );
                                  _loadClientes();
                                },
                                icon: const Icon(Icons.person_add),
                                label: const Text('Cadastrar Primeiro Cliente'),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadClientes,
                        child: ListView.builder(
                          itemCount: _clientesFiltrados.length,
                          itemBuilder: (context, index) {
                            final cliente = _clientesFiltrados[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF8B2F8B),
                                  child: Text(
                                    cliente.nome.isNotEmpty 
                                        ? cliente.nome[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  cliente.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('CPF: ${cliente.cpf}'),
                                    if (cliente.telefone != null)
                                      Text('Tel: ${cliente.telefone}'),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (cliente.senha != null)
                                            ? Colors.green.shade100
                                            : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        (cliente.senha != null)
                                            ? '🔑 Senha: ${cliente.senha}'
                                            : '⚠️ Sem senha',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: (cliente.senha != null)
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Botão Ver Detalhes
                                    IconButton(
                                      icon: const Icon(
                                        Icons.visibility,
                                        color: Color(0xFF8B2F8B),
                                      ),
                                      onPressed: () => _verDetalhesCliente(cliente),
                                      tooltip: 'Ver detalhes',
                                    ),
                                    // Botão Editar
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Color(0xFFFF8C00),
                                      ),
                                      onPressed: () => _editarCliente(cliente),
                                      tooltip: 'Editar cliente',
                                    ),
                                    // Botão Excluir
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _confirmarExclusao(cliente),
                                      tooltip: 'Excluir cliente',
                                    ),
                                  ],
                                ),
                                onTap: () => _verDetalhesCliente(cliente),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CadastroScreen()),
          );
          _loadClientes();
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}