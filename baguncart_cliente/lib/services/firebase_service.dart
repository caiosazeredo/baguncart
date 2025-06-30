import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  final String _clientesCollection = 'clientes';
  final String _servicosCollection = 'servicos';
  final String _contratosCollection = 'contratos';
  final String _promocoesCollection = 'promocoes';
  final String _notificacoesCollection = 'notificacoes';

  // Cliente logado
  Cliente? _clienteLogado;
  Cliente? get clienteLogado => _clienteLogado;

  // Login simplificado (sem Firebase Auth)
  Future<bool> loginCliente(String cpf, String senha) async {
    try {
      // Buscar cliente por CPF
      final clienteQuery = await _firestore
          .collection(_clientesCollection)
          .where('cpf', isEqualTo: cpf)
          .limit(1)
          .get();

      if (clienteQuery.docs.isEmpty) {
        throw 'Cliente não encontrado. Verifique o CPF.';
      }

      final clienteDoc = clienteQuery.docs.first;
      final clienteData = clienteDoc.data();
      clienteData['id'] = clienteDoc.id;

      // Verificar senha (em produção, use hash)
      if (clienteData['senha'] != senha) {
        throw 'Senha incorreta.';
      }

      _clienteLogado = Cliente.fromMap(clienteData);
      return true;
    } catch (e) {
      if (e is String) {
        throw e;
      }
      throw 'Erro ao fazer login: $e';
    }
  }

  // Logout
  Future<void> logout() async {
    _clienteLogado = null;
  }

  // Buscar contratos do cliente logado
  Future<List<Contrato>> getContratosCliente() async {
    if (_clienteLogado?.id == null) {
      // Retornar dados mock se não estiver logado ou se não conseguir conectar
      return _getContratosMock();
    }

    try {
      final query = await _firestore
          .collection(_contratosCollection)
          .where('cliente_id', isEqualTo: _clienteLogado!.id)
          .orderBy('created_at', descending: true)
          .get();

      final contratos = <Contrato>[];

      for (final doc in query.docs) {
        final contratoData = doc.data();
        contratoData['id'] = doc.id;

        final contrato = Contrato.fromMap(contratoData);
        
        if (contrato.servicosIds != null && contrato.servicosIds!.isNotEmpty) {
          final servicos = await _getServicosByIds(contrato.servicosIds!);
          contratos.add(Contrato(
            id: contrato.id,
            numero: contrato.numero,
            clienteId: contrato.clienteId,
            clienteNome: contrato.clienteNome,
            dataEvento: contrato.dataEvento,
            localEvento: contrato.localEvento,
            valorTotal: contrato.valorTotal,
            status: contrato.status,
            formaPagamento: contrato.formaPagamento,
            servicosIds: contrato.servicosIds,
            servicos: servicos,
            createdAt: contrato.createdAt,
          ));
        } else {
          contratos.add(contrato);
        }
      }

      return contratos.isNotEmpty ? contratos : _getContratosMock();
    } catch (e) {
      print('Erro ao buscar contratos, usando dados mock: $e');
      return _getContratosMock();
    }
  }

  // Dados mock para demonstração
  List<Contrato> _getContratosMock() {
    return [
      Contrato(
        id: 'mock_1',
        numero: '7.589',
        clienteId: 'cliente_demo',
        clienteNome: 'Gabriel Oliveira',
        dataEvento: DateTime(2025, 5, 25),
        localEvento: 'Rua das Laranjeiras, 325 - Casa 02',
        valorTotal: 100.00,
        status: 'confirmado',
        formaPagamento: 'dinheiro',
        servicosIds: ['serv1', 'serv2', 'serv3', 'serv4', 'serv5'],
        servicos: [
          const Servico(id: 'serv1', nome: 'Pula pula', preco: 20.00),
          const Servico(id: 'serv2', nome: 'Garçom', preco: 20.00),
          const Servico(id: 'serv3', nome: 'Barman', preco: 20.00),
          const Servico(id: 'serv4', nome: 'Palhaço', preco: 20.00),
          const Servico(id: 'serv5', nome: 'Recepção', preco: 20.00),
        ],
        createdAt: DateTime(2025, 1, 1),
      ),
      Contrato(
        id: 'mock_2',
        numero: '7.709',
        clienteId: 'cliente_demo',
        clienteNome: 'Gabriel Oliveira',
        dataEvento: DateTime(2025, 6, 30),
        localEvento: 'Salão de Festas Central',
        valorTotal: 150.00,
        status: 'pendente',
        formaPagamento: 'cartao_credito',
        servicosIds: ['serv1', 'serv3', 'serv5'],
        servicos: [
          const Servico(id: 'serv1', nome: 'Pula pula', preco: 20.00),
          const Servico(id: 'serv3', nome: 'Barman', preco: 20.00),
          const Servico(id: 'serv5', nome: 'Recepção', preco: 20.00),
        ],
        createdAt: DateTime(2025, 1, 15),
      ),
      Contrato(
        id: 'mock_3',
        numero: '7.852',
        clienteId: 'cliente_demo',
        clienteNome: 'Gabriel Oliveira',
        dataEvento: DateTime(2025, 9, 30),
        localEvento: 'Chácara dos Sonhos',
        valorTotal: 200.00,
        status: 'em_andamento',
        formaPagamento: 'pix',
        servicosIds: ['serv1', 'serv2', 'serv3', 'serv4'],
        servicos: [
          const Servico(id: 'serv1', nome: 'Pula pula', preco: 20.00),
          const Servico(id: 'serv2', nome: 'Garçom', preco: 20.00),
          const Servico(id: 'serv3', nome: 'Barman', preco: 20.00),
          const Servico(id: 'serv4', nome: 'Palhaço', preco: 20.00),
        ],
        createdAt: DateTime(2025, 1, 20),
      ),
    ];
  }

  // Buscar contrato por ID
  Future<Contrato?> getContratoById(String contratoId) async {
    // Primeiro tentar dos dados mock
    final contratosMock = _getContratosMock();
    final contratoMock = contratosMock.where((c) => c.id == contratoId).firstOrNull;
    
    if (contratoMock != null) {
      return contratoMock;
    }

    if (_clienteLogado?.id == null) {
      return null;
    }

    try {
      final doc = await _firestore
          .collection(_contratosCollection)
          .doc(contratoId)
          .get();

      if (!doc.exists) return null;

      final contratoData = doc.data()!;
      contratoData['id'] = doc.id;
      
      final contrato = Contrato.fromMap(contratoData);

      // Verificar se o contrato pertence ao cliente
      if (contrato.clienteId != _clienteLogado!.id) {
        throw 'Acesso negado a este contrato';
      }

      // Buscar serviços
      if (contrato.servicosIds != null && contrato.servicosIds!.isNotEmpty) {
        final servicos = await _getServicosByIds(contrato.servicosIds!);
        return Contrato(
          id: contrato.id,
          numero: contrato.numero,
          clienteId: contrato.clienteId,
          clienteNome: contrato.clienteNome,
          dataEvento: contrato.dataEvento,
          localEvento: contrato.localEvento,
          valorTotal: contrato.valorTotal,
          status: contrato.status,
          formaPagamento: contrato.formaPagamento,
          servicosIds: contrato.servicosIds,
          servicos: servicos,
          createdAt: contrato.createdAt,
        );
      }

      return contrato;
    } catch (e) {
      print('Erro ao buscar contrato: $e');
      return null;
    }
  }

  // Buscar próximo evento do cliente
  Future<Contrato?> getProximoEvento() async {
    try {
      final contratos = await getContratosCliente();
      final agora = DateTime.now();
      
      // Filtrar eventos futuros e pegar o mais próximo
      final eventosFuturos = contratos
          .where((c) => c.dataEvento != null && c.dataEvento!.isAfter(agora))
          .toList();
      
      if (eventosFuturos.isEmpty) return null;
      
      // Ordenar por data e pegar o primeiro
      eventosFuturos.sort((a, b) => a.dataEvento!.compareTo(b.dataEvento!));
      return eventosFuturos.first;
    } catch (e) {
      print('Erro ao buscar próximo evento: $e');
      // Retornar o primeiro contrato mock como próximo evento
      final contratosMock = _getContratosMock();
      return contratosMock.isNotEmpty ? contratosMock.first : null;
    }
  }

  // Buscar serviços por IDs
  Future<List<Servico>> _getServicosByIds(List<String> servicosIds) async {
    try {
      final servicos = <Servico>[];
      
      for (final servicoId in servicosIds) {
        final doc = await _firestore
            .collection(_servicosCollection)
            .doc(servicoId)
            .get();
        
        if (doc.exists) {
          final servicoData = doc.data()!;
          servicoData['id'] = doc.id;
          servicos.add(Servico.fromMap(servicoData));
        }
      }
      
      return servicos.isNotEmpty ? servicos : _getServicosMock();
    } catch (e) {
      print('Erro ao buscar serviços: $e');
      return _getServicosMock();
    }
  }

  List<Servico> _getServicosMock() {
    return [
      const Servico(id: 'serv1', nome: 'Pula pula', preco: 20.00),
      const Servico(id: 'serv2', nome: 'Garçom', preco: 20.00),
      const Servico(id: 'serv3', nome: 'Barman', preco: 20.00),
      const Servico(id: 'serv4', nome: 'Palhaço', preco: 20.00),
      const Servico(id: 'serv5', nome: 'Recepção', preco: 20.00),
    ];
  }

  // Buscar promoções ativas
  Future<List<Promocao>> getPromocoesAtivas() async {
    try {
      final agora = DateTime.now();
      final query = await _firestore
          .collection(_promocoesCollection)
          .where('ativo', isEqualTo: true)
          .where('validade_ate', isGreaterThan: Timestamp.fromDate(agora))
          .orderBy('validade_ate', descending: false)
          .get();

      final promocoes = <Promocao>[];
      for (final doc in query.docs) {
        final promocaoData = doc.data();
        promocaoData['id'] = doc.id;
        promocoes.add(Promocao.fromMap(promocaoData));
      }

      return promocoes.isNotEmpty ? promocoes : _getPromocoesMock();
    } catch (e) {
      print('Erro ao buscar promoções: $e');
      return _getPromocoesMock();
    }
  }

  List<Promocao> _getPromocoesMock() {
    return [
      Promocao(
        id: 'promo_1',
        titulo: 'PROMOÇÃO RELÂMPAGO',
        descricao: 'Kit pula pula + pipoca: R\$20,00',
        desconto: 20.00,
        validadeAte: DateTime(2025, 5, 5),
        ativo: true,
        createdAt: DateTime(2025, 1, 1),
      ),
    ];
  }

  // Buscar notificações do cliente
  Future<List<Notificacao>> getNotificacoesCliente() async {
    try {
      if (_clienteLogado?.id == null) {
        return _getNotificacoesMock();
      }

      final query = await _firestore
          .collection(_notificacoesCollection)
          .where('cliente_id', isEqualTo: _clienteLogado!.id)
          .orderBy('created_at', descending: true)
          .limit(20)
          .get();

      final notificacoes = <Notificacao>[];
      for (final doc in query.docs) {
        final notificacaoData = doc.data();
        notificacaoData['id'] = doc.id;
        notificacoes.add(Notificacao.fromMap(notificacaoData));
      }

      return notificacoes.isNotEmpty ? notificacoes : _getNotificacoesMock();
    } catch (e) {
      print('Erro ao buscar notificações: $e');
      return _getNotificacoesMock();
    }
  }

  List<Notificacao> _getNotificacoesMock() {
    return [
      Notificacao(
        id: 'notif_1',
        tipo: 'evento',
        titulo: 'FALTAM SÓ 15 DIAS',
        mensagem: 'Seu evento está prestes a acontecer!\nQualquer ajuda que precisar, entre em contato conosco.',
        lida: false,
        createdAt: DateTime(2025, 1, 1),
      ),
    ];
  }

  // Marcar notificação como lida
  Future<void> marcarNotificacaoLida(String notificacaoId) async {
    try {
      await _firestore
          .collection(_notificacoesCollection)
          .doc(notificacaoId)
          .update({'lida': true});
    } catch (e) {
      print('Erro ao marcar notificação como lida: $e');
    }
  }

  // Buscar dados do cliente por CPF (para verificar se existe)
  Future<Cliente?> getClienteByCpf(String cpf) async {
    try {
      final query = await _firestore
          .collection(_clientesCollection)
          .where('cpf', isEqualTo: cpf)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      final clienteData = doc.data();
      clienteData['id'] = doc.id;
      
      return Cliente.fromMap(clienteData);
    } catch (e) {
      print('Erro ao buscar cliente: $e');
      return null;
    }
  }

  // Login simples para desenvolvimento
  Future<bool> loginSimples(String cpf, String senha) async {
    // Para desenvolvimento - login mock
    if (cpf == '12345678901' && senha == '123456') {
      _clienteLogado = const Cliente(
        id: 'cliente_demo',
        nome: 'Gabriel Oliveira',
        cpf: '12345678901',
        telefone: '(11) 99999-9999',
        email: 'gabriel@email.com',
      );
      return true;
    }
    
    // Tentar login real se estiver configurado
    try {
      return await loginCliente(cpf, senha);
    } catch (e) {
      print('Login real falhou, usando mock: $e');
      return false;
    }
  }
}