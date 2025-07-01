import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/models.dart';
import 'contrato_detalhes_screen.dart';
import 'home_screen.dart';
import 'notificacoes_screen.dart';

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
    
    try {
      final contratos = await _firebaseService.getContratosCliente();
      if (mounted) {
        setState(() {
          _contratos = contratos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar contratos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        // Já estamos na tela de contratos
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NotificacoesScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus Contratos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF8B2F8B),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContratos,
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
        child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _contratos.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: _loadContratos,
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _contratos.length,
                  itemBuilder: (context, index) {
                    return _buildContratoCard(_contratos[index]);
                  },
                ),
              ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 1,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF8B2F8B),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'CONTRATO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'NOTIFICAÇÃO',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: Colors.white70,
          ),
          SizedBox(height: 16),
          Text(
            'Nenhum contrato encontrado',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Seus contratos aparecerão aqui\nquando forem criados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContratoCard(Contrato contrato) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContratoDetalhesScreen(contrato: contrato),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do contrato
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B2F8B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: Color(0xFF8B2F8B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contrato ${contrato.numero}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B2F8B),
                          ),
                        ),
                        Text(
                          _getStatusText(contrato.status),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getStatusColor(contrato.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Informações do evento
              _buildInfoRow(
                Icons.event,
                'Data do Evento',
                contrato.dataEvento != null
                  ? DateFormat('dd/MM/yyyy').format(contrato.dataEvento!)
                  : 'Não definida',
              ),
              
              const SizedBox(height: 8),
              
              _buildInfoRow(
                Icons.attach_money,
                'Valor Total',
                contrato.valorTotal != null 
                  ? 'R\$ ${contrato.valorTotal!.toStringAsFixed(2)}'
                  : 'Não definido',
              ),
              
              // Mostrar local se houver
              if (contrato.localEvento != null && contrato.localEvento!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.location_on,
                  'Local',
                  contrato.localEvento!,
                ),
              ],
              
              // Mostrar serviços se houver
              if (contrato.servicos != null && contrato.servicos!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Serviços Inclusos:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B2F8B),
                  ),
                ),
                const SizedBox(height: 8),
                ...contrato.servicos!.take(2).map((servico) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          servico.nome,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        'R\$ ${servico.preco.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )),
                if (contrato.servicos!.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+ ${contrato.servicos!.length - 2} serviço(s) adicional(is)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'ativo':
        return 'Ativo';
      case 'concluido':
        return 'Concluído';
      case 'cancelado':
        return 'Cancelado';
      case 'pendente':
        return 'Pendente';
      case 'confirmado':
        return 'Confirmado';
      case 'em_andamento':
        return 'Em Andamento';
      default:
        return status;
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
}