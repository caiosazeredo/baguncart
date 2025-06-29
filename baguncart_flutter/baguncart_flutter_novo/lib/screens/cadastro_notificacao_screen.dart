import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class CadastroNotificacaoScreen extends StatefulWidget {
  final Notificacao? notificacao;

  const CadastroNotificacaoScreen({super.key, this.notificacao});

  @override
  State<CadastroNotificacaoScreen> createState() => _CadastroNotificacaoScreenState();
}

class _CadastroNotificacaoScreenState extends State<CadastroNotificacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _mensagemController;
  late String _tipo;
  late bool _lida;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  bool get _isEditing => widget.notificacao != null;

  final List<Map<String, dynamic>> _tiposNotificacao = [
    {
      'value': 'info',
      'label': 'Informação',
      'icon': Icons.info,
      'color': Colors.blue,
      'description': 'Informações gerais para os clientes'
    },
    {
      'value': 'success',
      'label': 'Sucesso',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'description': 'Confirmações e mensagens positivas'
    },
    {
      'value': 'warning',
      'label': 'Aviso',
      'icon': Icons.warning,
      'color': Colors.orange,
      'description': 'Alertas importantes mas não críticos'
    },
    {
      'value': 'error',
      'label': 'Urgente',
      'icon': Icons.error,
      'color': Colors.red,
      'description': 'Mensagens urgentes que requerem atenção'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.notificacao?.titulo ?? '');
    _mensagemController = TextEditingController(text: widget.notificacao?.mensagem ?? '');
    _tipo = widget.notificacao?.tipo ?? 'info';
    _lida = widget.notificacao?.lida ?? false;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _mensagemController.dispose();
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

  String? _validateMensagem(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mensagem é obrigatória';
    }
    if (value.trim().length < 10) {
      return 'Mensagem deve ter pelo menos 10 caracteres';
    }
    return null;
  }

  Future<void> _salvarNotificacao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notificacao = Notificacao(
        id: widget.notificacao?.id,
        titulo: _tituloController.text.trim(),
        mensagem: _mensagemController.text.trim(),
        tipo: _tipo,
        lida: _lida,
      );

      bool sucesso;
      if (_isEditing) {
        sucesso = await _firebaseService.updateNotificacao(widget.notificacao!.id!, notificacao);
      } else {
        final id = await _firebaseService.insertNotificacao(notificacao);
        sucesso = id != null;
      }
      
      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing 
                ? 'Notificação atualizada com sucesso!'
                : 'Notificação enviada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing 
                ? 'Erro ao atualizar notificação'
                : 'Erro ao enviar notificação'),
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
        content: Text('Deseja realmente excluir a notificação "${widget.notificacao!.titulo}"?'),
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
      await _excluirNotificacao();
    }
  }

  Future<void> _excluirNotificacao() async {
    setState(() => _isLoading = true);

    try {
      final sucesso = await _firebaseService.deleteNotificacao(widget.notificacao!.id!);
      
      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notificação excluída com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir notificação'),
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

  Widget _buildTipoSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de Notificação *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            ...(_tiposNotificacao.map((tipoInfo) {
              final isSelected = _tipo == tipoInfo['value'];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? tipoInfo['color'] : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected ? tipoInfo['color'].withOpacity(0.1) : null,
                ),
                child: ListTile(
                  leading: Icon(
                    tipoInfo['icon'],
                    color: tipoInfo['color'],
                  ),
                  title: Text(
                    tipoInfo['label'],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    tipoInfo['description'],
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Radio<String>(
                    value: tipoInfo['value'],
                    groupValue: _tipo,
                    onChanged: (value) {
                      setState(() => _tipo = value!);
                    },
                    activeColor: tipoInfo['color'],
                  ),
                  onTap: () {
                    setState(() => _tipo = tipoInfo['value']);
                  },
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Notificação' : 'Nova Notificação'),
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
                  labelText: 'Título da Notificação *',
                  prefixIcon: Icon(Icons.title),
                  hintText: 'Ex: Nova promoção disponível!',
                ),
                validator: _validateTitulo,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 50,
              ),
              const SizedBox(height: 16),

              // Mensagem
              TextFormField(
                controller: _mensagemController,
                decoration: const InputDecoration(
                  labelText: 'Mensagem *',
                  prefixIcon: Icon(Icons.message),
                  hintText: 'Digite a mensagem que será enviada aos clientes...',
                ),
                validator: _validateMensagem,
                maxLines: 4,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Tipo de notificação
              _buildTipoSelector(),
              const SizedBox(height: 16),

              // Status lida (apenas para edição)
              if (_isEditing)
                Card(
                  child: SwitchListTile(
                    title: const Text('Marcar como Lida'),
                    subtitle: Text(_lida 
                      ? 'Notificação já foi visualizada'
                      : 'Notificação ainda não foi visualizada'
                    ),
                    value: _lida,
                    activeColor: const Color(0xFF8B2F8B),
                    onChanged: (value) {
                      setState(() => _lida = value);
                    },
                  ),
                ),

              if (_isEditing) const SizedBox(height: 16),

              // Preview da notificação
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.preview, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Preview da Notificação',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _tiposNotificacao.firstWhere(
                                (t) => t['value'] == _tipo,
                                orElse: () => _tiposNotificacao.first,
                              )['icon'],
                              color: _tiposNotificacao.firstWhere(
                                (t) => t['value'] == _tipo,
                                orElse: () => _tiposNotificacao.first,
                              )['color'],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _tituloController.text.isEmpty 
                                      ? 'Título da notificação'
                                      : _tituloController.text,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _mensagemController.text.isEmpty 
                                      ? 'Mensagem da notificação aparecerá aqui'
                                      : _mensagemController.text,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
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

              // Botão salvar
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _salvarNotificacao,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Icon(_isEditing ? Icons.update : Icons.send),
                  label: Text(_isEditing ? 'ATUALIZAR NOTIFICAÇÃO' : 'ENVIAR NOTIFICAÇÃO'),
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