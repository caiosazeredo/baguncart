import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class CadastroServicoScreen extends StatefulWidget {
  final Servico? servico;

  const CadastroServicoScreen({super.key, this.servico});

  @override
  State<CadastroServicoScreen> createState() => _CadastroServicoScreenState();
}

class _CadastroServicoScreenState extends State<CadastroServicoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _precoController;
  late bool _ativo;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  bool get _isEditing => widget.servico != null;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.servico?.nome ?? '');
    _precoController = TextEditingController(
      text: widget.servico?.preco.toStringAsFixed(2) ?? ''
    );
    _ativo = widget.servico?.ativo ?? true;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  String? _validateNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome do serviço é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validatePreco(String? value) {
    if (value == null || value.isEmpty) {
      return 'Preço é obrigatório';
    }
    
    final preco = double.tryParse(value.replaceAll(',', '.'));
    if (preco == null || preco < 0) {
      return 'Preço deve ser um número válido';
    }
    
    return null;
  }

  Future<void> _salvarServico() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final preco = double.parse(_precoController.text.replaceAll(',', '.'));
      
      final servico = Servico(
        id: widget.servico?.id,
        nome: _nomeController.text.trim(),
        preco: preco,
        ativo: _ativo,
      );

      bool sucesso;
      if (_isEditing) {
        sucesso = await _firebaseService.updateServico(widget.servico!.id!, servico);
      } else {
        final id = await _firebaseService.insertServico(servico);
        sucesso = id != null;
      }
      
      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing 
                ? 'Serviço atualizado com sucesso!'
                : 'Serviço cadastrado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing 
                ? 'Erro ao atualizar serviço'
                : 'Erro ao cadastrar serviço'),
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
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o serviço ${widget.servico!.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (resultado == true) {
      await _excluirServico();
    }
  }

  Future<void> _excluirServico() async {
    setState(() => _isLoading = true);

    try {
      final sucesso = await _firebaseService.deleteServico(widget.servico!.id!);
      
      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Serviço excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir serviço'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Serviço' : 'Cadastrar Serviço'),
        actions: _isEditing ? [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isLoading ? null : _confirmarExclusao,
          ),
        ] : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Serviço *',
                  prefixIcon: Icon(Icons.build),
                  hintText: 'Ex: DJ, Decoração, Pula pula...',
                ),
                validator: _validateNome,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(
                  labelText: 'Preço *',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '0,00',
                  prefixText: 'R\$ ',
                ),
                validator: _validatePreco,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: SwitchListTile(
                  title: const Text('Serviço Ativo'),
                  subtitle: Text(_ativo 
                    ? 'Disponível para contratação'
                    : 'Indisponível para contratação'
                  ),
                  value: _ativo,
                  activeColor: const Color(0xFF8B2F8B),
                  onChanged: (value) {
                    setState(() => _ativo = value);
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarServico,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isEditing ? 'ATUALIZAR SERVIÇO' : 'CADASTRAR SERVIÇO'),
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