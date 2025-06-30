import 'package:flutter/material.dart';
import 'dart:math';
import '../models/models.dart';
import '../services/firebase_service.dart';

class EditarClienteScreen extends StatefulWidget {
  final Cliente cliente;

  const EditarClienteScreen({super.key, required this.cliente});

  @override
  State<EditarClienteScreen> createState() => _EditarClienteScreenState();
}

class _EditarClienteScreenState extends State<EditarClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _cpfController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _enderecoController;
  late final TextEditingController _senhaController;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _obscureSenha = true;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.cliente.nome);
    _cpfController = TextEditingController(text: widget.cliente.cpf);
    _telefoneController = TextEditingController(text: widget.cliente.telefone ?? '');
    _emailController = TextEditingController(text: widget.cliente.email ?? '');
    _enderecoController = TextEditingController(text: widget.cliente.endereco ?? '');
    _senhaController = TextEditingController(text: widget.cliente.senha ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    
    final cpf = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(value)) {
        return 'Email inválido';
      }
    }
    return null;
  }

  String? _validateSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória para acesso ao app cliente';
    }
    if (value.length < 4) {
      return 'Senha deve ter pelo menos 4 caracteres';
    }
    return null;
  }

  void _gerarSenhaAleatoria() {
    const chars = '0123456789';
    final random = Random();
    final senha = String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
    setState(() {
      _senhaController.text = senha;
    });
  }

  Future<void> _atualizarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cpfLimpo = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
      
      final clienteAtualizado = Cliente(
        id: widget.cliente.id,
        nome: _nomeController.text.trim(),
        cpf: cpfLimpo,
        telefone: _telefoneController.text.trim().isNotEmpty 
          ? _telefoneController.text.trim() 
          : null,
        email: _emailController.text.trim().isNotEmpty 
          ? _emailController.text.trim() 
          : null,
        endereco: _enderecoController.text.trim().isNotEmpty 
          ? _enderecoController.text.trim() 
          : null,
        senha: _senhaController.text.trim(), // Incluir senha
        createdAt: widget.cliente.createdAt,
      );

      bool sucesso = false;
      if (widget.cliente.id != null) {
        sucesso = await _firebaseService.updateCliente(
          widget.cliente.id!, 
          clienteAtualizado
        );
      }
      
      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Retorna true para indicar sucesso
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao atualizar cliente'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmarExclusao() async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o cliente ${widget.cliente.nome}?'),
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

    if (confirmacao == true && widget.cliente.id != null) {
      setState(() => _isLoading = true);
      final sucesso = await _firebaseService.deleteCliente(widget.cliente.id!);
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
        if (sucesso) {
          Navigator.pop(context, true);
        } else {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isLoading ? null : _confirmarExclusao,
            tooltip: 'Excluir cliente',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Informações pessoais
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: Color(0xFF8B2F8B)),
                          const SizedBox(width: 8),
                          Text(
                            'Informações Pessoais',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF8B2F8B),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: _validateName,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _cpfController,
                        decoration: const InputDecoration(
                          labelText: 'CPF *',
                          prefixIcon: Icon(Icons.credit_card),
                          hintText: '000.000.000-00',
                        ),
                        validator: _validateCPF,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _telefoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          prefixIcon: Icon(Icons.phone),
                          hintText: '(00) 00000-0000',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          hintText: 'exemplo@email.com',
                        ),
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _enderecoController,
                        decoration: const InputDecoration(
                          labelText: 'Endereço',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Acesso ao app cliente
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.smartphone, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Acesso ao App Cliente',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.orange.shade700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📱 Credenciais para o App Cliente:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('👤 CPF: ${_cpfController.text}'),
                            Text('🔑 Senha: ${_senhaController.text}'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _senhaController,
                              obscureText: _obscureSenha,
                              decoration: InputDecoration(
                                labelText: 'Senha para App Cliente *',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _obscureSenha 
                                          ? Icons.visibility 
                                          : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureSenha = !_obscureSenha;
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.casino, color: Colors.green),
                                      onPressed: _gerarSenhaAleatoria,
                                      tooltip: 'Gerar senha aleatória',
                                    ),
                                  ],
                                ),
                              ),
                              validator: _validateSenha,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, 
                              size: 16, 
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Esta senha será usada pelo cliente para fazer login no app móvel',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Botão de atualizar
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _atualizarCliente,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ATUALIZAR CLIENTE'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                '* Campos obrigatórios',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}