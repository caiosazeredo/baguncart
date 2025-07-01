import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'home_screen.dart';

class ContratoDetalhesScreen extends StatelessWidget {
  final Contrato contrato;

  const ContratoDetalhesScreen({
    super.key,
    required this.contrato,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contrato ${contrato.numero}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF8B2F8B),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B2F8B),
              Color(0xFF6A1B6A),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card principal do contrato
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header do contrato
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B2F8B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.description,
                            color: Color(0xFF8B2F8B),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contrato ${contrato.numero}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B2F8B),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(contrato.status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getStatusText(contrato.status),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    
                    // Informações do evento
                    _buildSection(
                      'Informações do Evento',
                      Icons.event,
                      [
                        _buildInfoRow(
                          'Data do Evento',
                          contrato.dataEvento != null
                              ? DateFormat('dd/MM/yyyy').format(contrato.dataEvento!)
                              : 'Não definida',
                          Icons.calendar_today,
                        ),
                        if (contrato.localEvento != null && contrato.localEvento!.isNotEmpty)
                          _buildInfoRow(
                            'Local do Evento',
                            contrato.localEvento!,
                            Icons.location_on,
                          ),
                        _buildInfoRow(
                          'Valor Total',
                          contrato.valorTotal != null 
                              ? 'R\$ ${contrato.valorTotal!.toStringAsFixed(2)}'
                              : 'Não definido',
                          Icons.attach_money,
                        ),
                        if (contrato.formaPagamento != null)
                          _buildInfoRow(
                            'Forma de Pagamento',
                            _getFormaPagamentoText(contrato.formaPagamento!),
                            Icons.payment,
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Informações do cliente
                    _buildSection(
                      'Informações do Cliente',
                      Icons.person,
                      [
                        _buildInfoRow(
                          'Nome',
                          contrato.clienteNome ?? 'Não informado',
                          Icons.person_outline,
                        ),
                        _buildInfoRow(
                          'ID do Cliente',
                          contrato.clienteId ?? 'Não informado',
                          Icons.badge,
                        ),
                      ],
                    ),
                    
                    // Serviços inclusos
                    if (contrato.servicos != null && contrato.servicos!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildServicosSection(),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Data de criação
                    if (contrato.createdAt != null)
                      _buildInfoRow(
                        'Contrato criado em',
                        DateFormat('dd/MM/yyyy - HH:mm').format(contrato.createdAt!),
                        Icons.schedule,
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Botões de ação
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF8B2F8B), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B2F8B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.list_alt, color: Color(0xFF8B2F8B), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Serviços Inclusos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B2F8B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...contrato.servicos!.map((servico) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servico.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Removido servico.descricao pois não existe no modelo
                    Text(
                      'Serviço ${servico.ativo ? 'ativo' : 'inativo'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: servico.ativo ? Colors.green : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'R\$ ${servico.preco.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        )),
        
        // Total dos serviços
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF8B2F8B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total dos Serviços:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B2F8B),
                ),
              ),
              Text(
                'R\$ ${contrato.servicos!.fold(0.0, (sum, servico) => sum + servico.preco).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B2F8B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Botão de contato
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Entre em contato: (11) 99999-9999'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text(
              'ENTRAR EM CONTATO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Botão de voltar
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('VOLTAR'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'ativo':
        return 'ATIVO';
      case 'concluido':
        return 'CONCLUÍDO';
      case 'cancelado':
        return 'CANCELADO';
      case 'pendente':
        return 'PENDENTE';
      case 'confirmado':
        return 'CONFIRMADO';
      case 'em_andamento':
        return 'EM ANDAMENTO';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ativo':
      case 'confirmado':
        return const Color(0xFF4CAF50);
      case 'concluido':
        return const Color(0xFF2196F3);
      case 'cancelado':
        return const Color(0xFFFF5722);
      case 'pendente':
        return const Color(0xFFFF8C00);
      case 'em_andamento':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  String _getFormaPagamentoText(String formaPagamento) {
    switch (formaPagamento.toLowerCase()) {
      case 'dinheiro':
        return 'Dinheiro';
      case 'cartao_credito':
        return 'Cartão de Crédito';
      case 'cartao_debito':
        return 'Cartão de Débito';
      case 'pix':
        return 'PIX';
      case 'transferencia':
        return 'Transferência';
      case 'parcelado':
        return 'Parcelado';
      default:
        return formaPagamento;
    }
  }
}