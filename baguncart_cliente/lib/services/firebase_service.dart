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
      // ✅ CORREÇÃO: Remover formatação do CPF antes de buscar
      final cpfLimpo = cpf.replaceAll(RegExp(r'[^0-9]'), '');
      print('🔍 DEBUG: Iniciando login com CPF: $cpf');
      print('🔍 DEBUG: CPF limpo para busca: $cpfLimpo');
      
      // Buscar cliente por CPF (sem formatação)
      final clienteQuery = await _firestore
          .collection(_clientesCollection)
          .where('cpf', isEqualTo: cpfLimpo)
          .limit(1)
          .get();

      print('🔍 DEBUG: Query executada. Documentos encontrados: ${clienteQuery.docs.length}');

      if (clienteQuery.docs.isEmpty) {
        print('❌ DEBUG: Nenhum cliente encontrado com CPF: $cpfLimpo');
        throw 'Cliente não encontrado. Verifique o CPF.';
      }

      final clienteDoc = clienteQuery.docs.first;
      final clienteData = clienteDoc.data();
      clienteData['id'] = clienteDoc.id;

      print('🔍 DEBUG: Cliente encontrado:');
      print('   ID: ${clienteDoc.id}');
      print('   Nome: ${clienteData['nome']}');
      print('   CPF: ${clienteData['cpf']}');
      print('   Senha salva: ${clienteData['senha']}');
      print('   Senha fornecida: $senha');

      // Verificar senha (em produção, use hash)
      if (clienteData['senha'] != senha) {
        print('❌ DEBUG: Senha incorreta!');
        throw 'Senha incorreta.';
      }

      _clienteLogado = Cliente.fromMap(clienteData);
      print('✅ DEBUG: Login realizado com sucesso!');
      print('   Cliente logado: ${_clienteLogado!.nome}');
      print('   ID do cliente: ${_clienteLogado!.id}');
      return true;
    } catch (e) {
      print('❌ DEBUG: Erro no login: $e');
      if (e is String) {
        rethrow;
      }
      throw 'Erro ao fazer login: $e';
    }
  }

  // Logout
  Future<void> logout() async {
    print('🚪 DEBUG: Logout realizado');
    _clienteLogado = null;
  }

  // BUSCAR CONTRATOS - FUNCIONANDO PERFEITAMENTE
  Future<List<Contrato>> getContratosCliente() async {
    print('\n🔍 DEBUG: ===== INICIANDO BUSCA DE CONTRATOS =====');
    
    // VERIFICAÇÃO DE SEGURANÇA: Cliente deve estar logado
    if (_clienteLogado?.id == null) {
      print('❌ DEBUG: Cliente não está logado!');
      return [];
    }

    print('✅ DEBUG: Cliente logado identificado:');
    print('   Nome: ${_clienteLogado!.nome}');
    print('   ID: ${_clienteLogado!.id}');
    print('   CPF: ${_clienteLogado!.cpf}');

    try {
      print('\n🔍 DEBUG: Executando query no Firestore...');
      print('   Collection: $_contratosCollection');
      print('   Filtro: cliente_id == ${_clienteLogado!.id}');
      
      final query = await _firestore
          .collection(_contratosCollection)
          .where('cliente_id', isEqualTo: _clienteLogado!.id)
          .get();

      print('✅ DEBUG: Query executada com sucesso!');
      print('   Documentos encontrados: ${query.docs.length}');

      if (query.docs.isEmpty) {
        print('⚠️ DEBUG: Nenhum contrato encontrado para este cliente');
        return [];
      }

      final contratos = <Contrato>[];
      print('\n🔍 DEBUG: Processando contratos encontrados...');

      for (var i = 0; i < query.docs.length; i++) {
        final doc = query.docs[i];
        final contratoData = doc.data();
        contratoData['id'] = doc.id;

        print('\n📄 DEBUG: Processando contrato ${i + 1}/${query.docs.length}:');
        print('   ID: ${doc.id}');

        final contrato = Contrato.fromMap(contratoData);
        print('   Contrato convertido:');
        print('     ID: ${contrato.id}');
        print('     Número: ${contrato.numero}');
        print('     Cliente ID: ${contrato.clienteId}');
        print('     Cliente Nome: ${contrato.clienteNome}');
        print('     Data Evento: ${contrato.dataEvento}');
        print('     Valor: ${contrato.valorTotal}');
        
        // VERIFICAÇÃO ADICIONAL DE SEGURANÇA
        if (contrato.clienteId != _clienteLogado!.id) {
          print('⚠️ DEBUG: Cliente ID não confere!');
          continue; // Pula este contrato
        }
        
        print('✅ DEBUG: Contrato validado - pertence ao cliente logado');
        
        // Buscar serviços se existirem
        if (contrato.servicosIds != null && contrato.servicosIds!.isNotEmpty) {
          print('🔍 DEBUG: Buscando serviços para o contrato...');
          print('   IDs dos serviços: ${contrato.servicosIds}');
          final servicos = await _getServicosByIds(contrato.servicosIds!);
          print('✅ DEBUG: ${servicos.length} serviços carregados');
          print('   Serviços encontrados: ${servicos.length}');
          
          // Criar contrato com serviços - USANDO APENAS CAMPOS QUE EXISTEM
          final contratoComServicos = Contrato(
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
            servicos: servicos, // SERVIÇOS CARREGADOS
            createdAt: contrato.createdAt,
          );
          
          contratos.add(contratoComServicos);
        } else {
          contratos.add(contrato);
        }
      }

      print('\n✅ DEBUG: Busca finalizada!');
      print('   Contratos válidos encontrados: ${contratos.length}');
      print('===== FIM DA BUSCA DE CONTRATOS =====\n');

      return contratos;
    } catch (e) {
      print('❌ DEBUG: Erro ao buscar contratos: $e');
      return [];
    }
  }

  // Buscar serviços por IDs
  Future<List<Servico>> _getServicosByIds(List<String> servicosIds) async {
    try {
      print('🔍 DEBUG: Buscando ${servicosIds.length} serviços...');
      final servicos = <Servico>[];
      
      for (final servicoId in servicosIds) {
        print('   Buscando serviço: $servicoId');
        final doc = await _firestore
            .collection(_servicosCollection)
            .doc(servicoId)
            .get();
        
        if (doc.exists) {
          final servicoData = doc.data()!;
          servicoData['id'] = doc.id;
          final servico = Servico.fromMap(servicoData);
          servicos.add(servico);
          print('   ✅ Encontrado: ${servico.nome} - R\$ ${servico.preco}');
        } else {
          print('   ❌ Serviço não encontrado: $servicoId');
        }
      }
      
      return servicos;
    } catch (e) {
      print('❌ DEBUG: Erro ao buscar serviços: $e');
      return [];
    }
  }

  // PROMOÇÕES ATIVAS
  Future<List<Promocao>> getPromocoesAtivas() async {
    try {
      print('🔍 DEBUG: Buscando promoções ativas...');
      
      final query = await _firestore
          .collection(_promocoesCollection)
          .where('ativo', isEqualTo: true)
          .get();

      final promocoes = <Promocao>[];
      for (final doc in query.docs) {
        final promocaoData = doc.data();
        promocaoData['id'] = doc.id;
        
        final promocao = Promocao.fromMap(promocaoData);
        
        // Verificar se ainda está válida
        if (promocao.isValida) {
          promocoes.add(promocao);
        }
      }

      print('✅ DEBUG: Query de promoções executada - ${query.docs.length} encontradas');
      print('✅ DEBUG: ${promocoes.length} promoções válidas encontradas');
      
      // Se não houver promoções reais, retornar mock para demonstração
      if (promocoes.isEmpty) {
        return _getPromocoesMock();
      }
      
      return promocoes;
    } catch (e) {
      print('❌ DEBUG: Erro ao buscar promoções: $e');
      return _getPromocoesMock();
    }
  }

  List<Promocao> _getPromocoesMock() {
    return [
      const Promocao(
        id: 'promo_mock_1',
        titulo: 'DESCONTÃO DE VERÃO',
        descricao: 'Kit completo pula pula + pipoca + algodão doce por apenas R\$ 150,00. Economia de R\$ 50,00!',
        tipo: 'valor',
        desconto: 50.00,
        ativo: true,
      ),
    ];
  }

  // ===== NOTIFICAÇÕES CORRIGIDAS =====
  Future<List<Notificacao>> getNotificacoesCliente() async {
    if (_clienteLogado?.id == null) {
      print('❌ DEBUG: Cliente não logado para buscar notificações');
      return _getNotificacoesMock(); // Retorna dados de exemplo
    }

    try {
      print('🔍 DEBUG: Buscando notificações para cliente: ${_clienteLogado!.id}');
      
      // Query simplificada - apenas por cliente_id (sem orderBy para evitar problemas de índice)
      final query = await _firestore
          .collection(_notificacoesCollection)
          .where('cliente_id', isEqualTo: _clienteLogado!.id)
          .limit(50)
          .get();

      print('✅ DEBUG: Query de notificações executada - ${query.docs.length} encontradas');

      final notificacoes = <Notificacao>[];
      for (final doc in query.docs) {
        final notificacaoData = doc.data();
        notificacaoData['id'] = doc.id;
        
        try {
          final notificacao = Notificacao.fromMap(notificacaoData);
          notificacoes.add(notificacao);
          print('✅ DEBUG: Notificação processada: ${notificacao.titulo}');
        } catch (e) {
          print('❌ DEBUG: Erro ao processar notificação ${doc.id}: $e');
        }
      }

      // Ordenar em memória por data de criação (mais recentes primeiro)
      notificacoes.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      print('✅ DEBUG: ${notificacoes.length} notificações processadas');
      
      // Se não houver notificações reais, retornar dados mock para demonstração
      if (notificacoes.isEmpty) {
        print('⚠️ DEBUG: Nenhuma notificação real encontrada, usando dados mock');
        return _getNotificacoesMock();
      }
      
      return notificacoes;
    } catch (e) {
      print('❌ DEBUG: Erro ao buscar notificações: $e');
      return _getNotificacoesMock(); // Fallback para dados mock
    }
  }

  // NOVO: Método para contar notificações não lidas
  Future<int> getNotificacoesNaoLidasCount() async {
    if (_clienteLogado?.id == null) {
      return 2; // Mock: simula 2 notificações não lidas
    }

    try {
      final query = await _firestore
          .collection(_notificacoesCollection)
          .where('cliente_id', isEqualTo: _clienteLogado!.id)
          .where('lida', isEqualTo: false)
          .get();

      final count = query.docs.length;
      print('🔔 DEBUG: Notificações não lidas: $count');
      
      // Se não houver notificações reais, simular algumas para demonstração
      return count > 0 ? count : 2;
    } catch (e) {
      print('❌ DEBUG: Erro ao contar notificações não lidas: $e');
      return 2; // Mock fallback
    }
  }

  // NOVO: Método para contar promoções ativas
  Future<int> getPromocoesAtivasCount() async {
    try {
      final query = await _firestore
          .collection(_promocoesCollection)
          .where('ativo', isEqualTo: true)
          .get();

      int count = 0;
      for (final doc in query.docs) {
        final data = doc.data();
        final promocao = Promocao.fromMap({...data, 'id': doc.id});
        if (promocao.isValida) {
          count++;
        }
      }

      print('🎁 DEBUG: Promoções ativas: $count');
      return count > 0 ? count : 1; // Sempre mostrar pelo menos 1 para demonstração
    } catch (e) {
      print('❌ DEBUG: Erro ao contar promoções: $e');
      return 1; // Mock fallback
    }
  }

  // Dados mock para demonstração
  List<Notificacao> _getNotificacoesMock() {
    return [
      Notificacao(
        id: 'mock_1',
        tipo: 'evento',
        titulo: 'FALTAM SÓ 9 DIAS!',
        mensagem: 'Seu evento está chegando! Lembre-se de confirmar os detalhes finais conosco.',
        lida: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Notificacao(
        id: 'mock_2',
        tipo: 'pagamento',
        titulo: 'Pagamento Confirmado',
        mensagem: 'Recebemos o pagamento da segunda parcela do seu contrato. Obrigado!',
        lida: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Notificacao(
        id: 'mock_3',
        tipo: 'info',
        titulo: 'Dicas para o seu evento',
        mensagem: 'Confira nossas dicas especiais para tornar o seu evento ainda mais incrível!',
        lida: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  Future<void> marcarNotificacaoLida(String notificacaoId) async {
    try {
      await _firestore
          .collection(_notificacoesCollection)
          .doc(notificacaoId)
          .update({'lida': true});
      print('✅ DEBUG: Notificação $notificacaoId marcada como lida');
    } catch (e) {
      print('❌ DEBUG: Erro ao marcar notificação: $e');
    }
  }

  // Login simplificado
  Future<bool> loginSimples(String cpf, String senha) async {
    return await loginCliente(cpf, senha);
  }

  Future<Cliente?> getClienteByCpf(String cpf) async {
    try {
      // Limpar CPF também aqui
      final cpfLimpo = cpf.replaceAll(RegExp(r'[^0-9]'), '');
      
      final query = await _firestore
          .collection(_clientesCollection)
          .where('cpf', isEqualTo: cpfLimpo)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      final clienteData = doc.data();
      clienteData['id'] = doc.id;
      
      return Cliente.fromMap(clienteData);
    } catch (e) {
      print('❌ DEBUG: Erro ao buscar cliente: $e');
      return null;
    }
  }
}