import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class CadastroPromocaoScreen extends StatefulWidget {
  final Promocao? promocao;

  const CadastroPromocaoScreen({super.key, this.promocao});

  @override
  State<CadastroPromocaoScreen> createState() => _CadastroPromocaoScreenState();
}

class _CadastroPromocaoScreenState extends State<CadastroPromocaoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _descontoController;
  late String _tipoDesconto;
  late bool _ativo;
  DateTime? _validoAte;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  bool get _isEditing => widget.promocao != null;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.promocao?.titulo ?? '');
    _descricaoController = TextEditingController(text: widget.promocao?.descricao ?? '');
    _descontoController = TextEditingController(
      text: widget.promocao?.desconto?.toString() ?? ''
    );
    _tipoDesconto = widget.promocao?.tipo ?? 'percentual';
    _ativo = widget.promocao?.ativo ?? true;
    _validoAte = widget.promocao?.validoAte;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _descontoController.dispose();
    super.dispose();
  }

  String? _validateTitulo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Título é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'Título deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  String? _validateDescricao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Descrição é obrigatória';
    }
    if (value.trim().length < 10) {
      return 'Descrição deve ter pelo menos 10 caracteres';
    }
    return null;
  }

  String? _validateDesconto(String? value) {
    if (value == null || value.isEmpty) {
      return 'Desconto é obrigatório';
    }
    
    final desconto = double.tryParse(value.replaceAll(',', '.'));
    if (desconto == null || desconto <= 0) {
      return 'Desconto deve ser um número maior que zero';
    }

    if (_tipoDesconto == 'percentual' && desconto > 100) {
      return 'Desconto percentual não pode ser maior que 100%';
    }
    
    return null;
  }

  Future<void> _selecionarDataValidade() async {
    final dataAtual = DateTime.now();
    final dataMaxima = DateTime(dataAtual.year + 2);
    
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _validoAte ?? dataAtual.add(const Duration(days: 30)),
      firstDate: dataAtual,
      lastDate: dataMaxima,
      locale: const Locale('pt', 'BR'),
    );
    
    if (dataSelecionada != null) {
      setState(() => _validoAte = dataSelecionada);
    }
  }

  String _formatarDataValidade() {
    if (_validoAte == null) return 'Selecionar data (opcional)';
    return 'Válida até: ${DateFormat('dd/MM/yyyy').format(_validoAte!)}';
  }

  Future<void> _salvarPromocao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final desconto = double.parse(_descontoController.text.replaceAll(',', '.'));
      
      final promocao = Promocao(
        id: widget.promocao?.id,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        tipo: _tipoDesconto,
        desconto: desconto,
        validoAte: _validoAte,
        ativo: _ativo,
        createdAt: widget.promocao?.createdAt,
      );

      bool sucesso = false;
      if (_isEditing && widget.promocao?.id != null) {
        sucesso = await _firebaseService.updatePromocao(widget.promocao!.id!, promocao);
      } else {
        final id = await _firebaseService.insertPromocao(promocao);
        sucesso = id != null;
      }
      
      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing 
                ? 'Promoção atualizada com sucesso!'
                : 'Promoção criada com sucesso!'
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing 
                ? 'Erro ao atualizar promoção'
                : 'Erro ao criar promoção'
              ),
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
        content: Text('Tem certeza que deseja excluir a promoção "${widget.promocao?.titulo}"?'),
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

    if (confirmacao == true && widget.promocao?.id != null) {
      setState(() => _isLoading = true);
      final sucesso = await _firebaseService.deletePromocao(widget.promocao!.id!);
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
        title: Text(_isEditing ? 'Editar Promoção' : 'Nova Promoção'),
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
              // Título
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título da Promoção *',
                  prefixIcon: Icon(Icons.local_offer),
                  hintText: 'Ex: Super Desconto de Verão!',
                ),
                validator: _validateTitulo,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
              ),
              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição *',
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Descreva os detalhes da promoção...',
                ),
                validator: _validateDescricao,
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: 16),

              // Tipo de desconto
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de Desconto *',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Percentual (%)'),
                              value: 'percentual',
                              groupValue: _tipoDesconto,
                              onChanged: (value) {
                                setState(() => _tipoDesconto = value!);
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Valor (R\$)'),
                              value: 'valor',
                              groupValue: _tipoDesconto,
                              onChanged: (value) {
                                setState(() => _tipoDesconto = value!);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Desconto
              TextFormField(
                controller: _descontoController,
                decoration: InputDecoration(
                  labelText: 'Valor do Desconto *',
                  prefixIcon: const Icon(Icons.money_off),
                  hintText: _tipoDesconto == 'percentual' ? '10' : '50.00',
                  prefixText: _tipoDesconto == 'percentual' ? '' : 'R\$ ',
                  suffixText: _tipoDesconto == 'percentual' ? '%' : '',
                ),
                validator: _validateDesconto,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
              ),
              const SizedBox(height: 16),

              // Data de validade
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Data de Validade'),
                  subtitle: Text(_formatarDataValidade()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_validoAte != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _validoAte = null),
                        ),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  onTap: _selecionarDataValidade,
                ),
              ),
              const SizedBox(height: 16),

              // Status ativo/inativo
              Card(
                child: SwitchListTile(
                  title: const Text('Promoção Ativa'),
                  subtitle: Text(_ativo 
                    ? 'Visível para os clientes'
                    : 'Oculta dos clientes'
                  ),
                  value: _ativo,
                  activeColor: const Color(0xFF8B2F8B),
                  onChanged: (value) {
                    setState(() => _ativo = value);
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Botão salvar
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarPromocao,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isEditing ? 'ATUALIZAR PROMOÇÃO' : 'CRIAR PROMOÇÃO'),
                ),
              ),
              const SizedBox(height: 16),

              // Campos obrigatórios
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