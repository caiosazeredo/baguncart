import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';

class CadastroContratoScreen extends StatefulWidget {
  final Contrato? contrato;

  const CadastroContratoScreen({super.key, this.contrato});

  @override
  State<CadastroContratoScreen> createState() => _CadastroContratoScreenState();
}

class _CadastroContratoScreenState extends State<CadastroContratoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numeroController;
  late final TextEditingController _localEventoController;
  late final TextEditingController _valorTotalController;
  
  String? _clienteSelecionadoId;
  String? _clienteSelecionadoNome;
  DateTime? _dataEvento;
  String _status = 'pendente';
  String _formaPagamento = 'dinheiro';
  List<String> _servicosSelecionados = [];
  
  final FirebaseService _firebaseService = FirebaseService();
  List<Cliente> _clientes = [];
  List<Servico> _servicos = [];
  bool _isLoading = false;
  bool _isLoadingData = true;

  bool get _isEditing => widget.contrato != null;

  final List<String> _statusOptions = [
    'pendente',
    'confirmado',
    'em_andamento',
    'concluido',
    'cancelado',
  ];

  final List<String> _pagamentoOptions = [
    'dinheiro',
    'cartao_credito',
    'cartao_debito',
    'pix',
    'transferencia',
    'parcelado',
  ];

  @override
  void initState() {
    super.initState();
    _numeroController = TextEditingController(text: widget.contrato?.numero ?? _gerarNumeroContrato());
    _localEventoController = TextEditingController(text: widget.contrato?.localEvento ?? '');
    _valorTotalController = TextEditingController(
      text: widget.contrato?.valorTotal?.toStringAsFixed(2) ?? ''
    );
    
    if (widget.contrato != null) {
      _clienteSelecionadoId = widget.contrato!.clienteId;
      _clienteSelecionadoNome = widget.contrato!.clienteNome;
      _dataEvento = widget.contrato!.dataEvento;
      _status = widget.contrato!.status;
      _formaPagamento = widget.contrato!.formaPagamento ?? 'dinheiro';
      _servicosSelecionados = widget.contrato!.servicosIds ?? [];
    }
    
    _loadData();
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _localEventoController.dispose();
    _valorTotalController.dispose();
    super.dispose();
  }

  String _gerarNumeroContrato() {
    final agora = DateTime.now();
    return 'C${agora.year}${agora.month.toString().padLeft(2, '0')}${agora.day.toString().padLeft(2, '0')}-${agora.millisecond}';
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);
    
    try {
      final clientesFuture = _firebaseService.getClientes();
      final servicosFuture = _firebaseService.getServicos();
      
      final results = await Future.wait([clientesFuture, servicosFuture]);
      
      if (mounted) {
        setState(() {
          _clientes = results[0] as List<Cliente>;
          _servicos = results[1] as List<Servico>;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _validateNumero(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Número do contrato é obrigatório';
    }
    return null;
  }

  String? _validateValorTotal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Valor total é obrigatório';
    }
    
    final valor = double.tryParse(value.replaceAll(',', '.'));
    if (valor == null || valor <= 0) {
      return 'Valor deve ser maior que zero';
    }
    
    return null;
  }

  Future<void> _selecionarDataEvento() async {
    final dataAtual = DateTime.now();
    final dataMaxima = DateTime(dataAtual.year + 2);
    
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataEvento ?? dataAtual.add(const Duration(days: 7)),
      firstDate: dataAtual,
      lastDate: dataMaxima,
      helpText: 'Selecionar data do evento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataEvento = dataSelecionada;
      });
    }
  }

  void _calcularValorTotal() {
    double total = 0.0;
    for (final servicoId in _servicosSelecionados) {
      final servico = _servicos.firstWhere(
        (s) => s.id == servicoId,
        orElse: () => const Servico(nome: '', preco: 0.0),
      );
      total += servico.preco;
    }
    _valorTotalController.text = total.toStringAsFixed(2);
  }

  Future<void> _salvarContrato() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_clienteSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um cliente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_dataEvento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a data do evento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final valorTotal = double.parse(_valorTotalController.text.replaceAll(',', '.'));
      
      final contrato = Contrato(
        id: widget.contrato?.id,
        numero: _numeroController.text.trim(),
        clienteId: _clienteSelecionadoId,
        clienteNome: _clienteSelecionadoNome,
        dataEvento: _dataEvento,
        localEvento: _localEventoController.text.trim().isNotEmpty 
          ? _localEventoController.text.trim() 
          : null,
        valorTotal: valorTotal,
        status: _status,
        formaPagamento: _formaPagamento,
        servicosIds: _servicosSelecionados.isNotEmpty ? _servicosSelecionados : null,
      );

      bool sucesso;
      if (_isEditing) {
        sucesso = await _firebaseService.updateContrato(widget.contrato!.id!, contrato);
      } else {
        final id = await _firebaseService.insertContrato(contrato);
        sucesso = id != null;
      }
      
      if (mounted) {
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing 
                ? 'Contrato atualizado com sucesso!'
                : 'Contrato criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing 
                ? 'Erro ao atualizar contrato'
                : 'Erro ao criar contrato'),
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

  String _formatarData(DateTime? data) {
    if (data == null) return 'Selecionar data';
    return DateFormat('dd/MM/yyyy').format(data);
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pendente': return 'Pendente';
      case 'confirmado': return 'Confirmado';
      case 'em_andamento': return 'Em Andamento';
      case 'concluido': return 'Concluído';
      case 'cancelado': return 'Cancelado';
      default: return status;
    }
  }

  String _getPagamentoLabel(String pagamento) {
    switch (pagamento) {
      case 'dinheiro': return 'Dinheiro';
      case 'cartao_credito': return 'Cartão de Crédito';
      case 'cartao_debito': return 'Cartão de Débito';
      case 'pix': return 'PIX';
      case 'transferencia': return 'Transferência';
      case 'parcelado': return 'Parcelado';
      default: return pagamento;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Contrato' : 'Novo Contrato'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Contrato' : 'Novo Contrato'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Número do contrato
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(
                  labelText: 'Número do Contrato *',
                  prefixIcon: Icon(Icons.tag),
                  hintText: 'C202412-001',
                ),
                validator: _validateNumero,
                enabled: !_isEditing, // Não permitir editar número
              ),
              const SizedBox(height: 16),

              // Seleção de cliente
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Cliente *'),
                  subtitle: Text(_clienteSelecionadoNome ?? 'Selecionar cliente'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final clienteSelecionado = await showDialog<Cliente>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Selecionar Cliente'),
                        content: SizedBox(
                          width: double.maxFinite,
                          height: 300,
                          child: ListView.builder(
                            itemCount: _clientes.length,
                            itemBuilder: (context, index) {
                              final cliente = _clientes[index];
                              return ListTile(
                                title: Text(cliente.nome),
                                subtitle: Text('CPF: ${cliente.cpf}'),
                                onTap: () => Navigator.pop(context, cliente),
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ],
                      ),
                    );

                    if (clienteSelecionado != null) {
                      setState(() {
                        _clienteSelecionadoId = clienteSelecionado.id;
                        _clienteSelecionadoNome = clienteSelecionado.nome;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Data do evento
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Data do Evento *'),
                  subtitle: Text(_formatarData(_dataEvento)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selecionarDataEvento,
                ),
              ),
              const SizedBox(height: 16),

              // Local do evento
              TextFormField(
                controller: _localEventoController,
                decoration: const InputDecoration(
                  labelText: 'Local do Evento',
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Ex: Salão de Festas, Casa, etc.',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Seleção de serviços
              Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.build),
                  title: const Text('Serviços'),
                  subtitle: Text(_servicosSelecionados.isEmpty 
                    ? 'Nenhum serviço selecionado'
                    : '${_servicosSelecionados.length} serviço(s) selecionado(s)'
                  ),
                  children: _servicos.map((servico) {
                    final isSelected = _servicosSelecionados.contains(servico.id);
                    return CheckboxListTile(
                      title: Text(servico.nome),
                      subtitle: Text('R\$ ${servico.preco.toStringAsFixed(2)}'),
                      value: isSelected,
                      onChanged: servico.ativo ? (value) {
                        setState(() {
                          if (value == true) {
                            _servicosSelecionados.add(servico.id!);
                          } else {
                            _servicosSelecionados.remove(servico.id);
                          }
                          _calcularValorTotal();
                        });
                      } : null,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Valor total
              TextFormField(
                controller: _valorTotalController,
                decoration: const InputDecoration(
                  labelText: 'Valor Total *',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: 'R\$ ',
                  hintText: '0,00',
                ),
                validator: _validateValorTotal,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
              ),
              const SizedBox(height: 16),

              // Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status do Contrato',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusLabel(status)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _status = value!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Forma de pagamento
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Forma de Pagamento',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _formaPagamento,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.payment),
                        ),
                        items: _pagamentoOptions.map((pagamento) {
                          return DropdownMenuItem(
                            value: pagamento,
                            child: Text(_getPagamentoLabel(pagamento)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _formaPagamento = value!);
                        },
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
                  onPressed: _isLoading ? null : _salvarContrato,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Icon(_isEditing ? Icons.update : Icons.save),
                  label: Text(_isEditing ? 'ATUALIZAR CONTRATO' : 'CRIAR CONTRATO'),
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