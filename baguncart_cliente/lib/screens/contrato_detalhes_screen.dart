import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import 'home_screen.dart';
import 'contratos_screen.dart';
import 'notificacoes_screen.dart';

class ContratoDetalhesScreen extends StatefulWidget {
  final Contrato contrato;

  const ContratoDetalhesScreen({super.key, required this.contrato});

  @override
  State<ContratoDetalhesScreen> createState() => _ContratoDetalhesScreenState();
}

class _ContratoDetalhesScreenState extends State<ContratoDetalhesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Contrato? _contratoCompleto;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContratoDetalhes();
  }

  Future<void> _loadContratoDetalhes() async {
    setState(() => _isLoading = true);
    
    try {
      if (widget.contrato.id != null) {
        final contrato = await _firebaseService.getContratoById(widget.contrato.id!);
        if (mounted) {
          setState(() {
            _contratoCompleto = contrato ?? widget.contrato;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _contratoCompleto = widget.contrato;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _contratoCompleto = widget.contrato;
          _isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ContratosScreen()),
          (route) => false,
        );
        break;
      case 2:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const NotificacoesScreen()),
          (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final contrato = _contratoCompleto ?? widget.contrato;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Header com logo e botão voltar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF8B2F8B),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Logo BagunçArt
                    Container(
                      width: 120,
                      height: 50,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: PaintSplashPainter(),
                            ),
                          ),
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Bagunç',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF1493),
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Art',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00BFFF),
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Título
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'CONTRATO',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8C00),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Conteúdo do contrato
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B2F8B), Color(0xFF6A1B6A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B2F8B).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Informações básicas
                              _buildInfoRow('Contrato:', contrato.numero),
                              _buildInfoRow('Contratante:', contrato.clienteNome ?? 'N/A'),
                              
                              const SizedBox(height: 16),
                              
                              _buildInfoRow(
                                'Data do Evento:', 
                                contrato.dataEvento != null 
                                    ? DateFormat('dd/MM/yy').format(contrato.dataEvento!)
                                    : 'N/A'
                              ),
                              _buildInfoRow(
                                'Local do Evento:', 
                                contrato.localEvento ?? 'Não informado'
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Serviços contratados
                              const Text(
                                'Serviços contratados:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              if (contrato.servicos != null && contrato.servicos!.isNotEmpty) ...[
                                ...contrato.servicos!.map((servico) => _buildServicoItem(servico)),
                              ] else ...[
                                // Serviços mock baseados no protótipo
                                _buildServicoItem(const Servico(nome: 'Pula pula', preco: 20.00)),
                                _buildServicoItem(const Servico(nome: 'Garçom', preco: 20.00)),
                                _buildServicoItem(const Servico(nome: 'Barman', preco: 20.00)),
                                _buildServicoItem(const Servico(nome: 'Palhaço', preco: 20.00)),
                                _buildServicoItem(const Servico(nome: 'Recepção', preco: 20.00)),
                              ],
                              
                              const SizedBox(height: 24),
                              
                              // Valor total
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Valor Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(contrato.valorTotal ?? 100.00)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      
      // Bottom Navigation
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicoItem(Servico servico) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              servico.nome,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Text(
            NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(servico.preco),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class PaintSplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Manchas de tinta decorativas pequenas
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      4,
      paint..color = const Color(0xFFFF1493).withOpacity(0.3),
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      3,
      paint..color = const Color(0xFF00BFFF).withOpacity(0.3),
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      2,
      paint..color = const Color(0xFFFF1493).withOpacity(0.2),
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.7),
      3,
      paint..color = const Color(0xFF00BFFF).withOpacity(0.2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}