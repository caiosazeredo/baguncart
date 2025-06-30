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
      print('🔍 DEBUG: Iniciando login com CPF: $cpf');
      
      // Buscar cliente por CPF
      final clienteQuery = await _firestore
          .collection(_clientesCollection)
          .where('cpf', isEqualTo: cpf)
          .limit(1)
          .get();

      print('🔍 DEBUG: Query executada. Documentos encontrados: ${clienteQuery.docs.length}');

      if (clienteQuery.docs.isEmpty) {
        print('❌ DEBUG: Nenhum cliente encontrado com CPF: $cpf');
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
        throw e;
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
          print('   Serviços encontrados: ${servicos.length}');
          
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
          print('ℹ️ DEBUG: Contrato sem serviços vinculados');
          contratos.add(contrato);
        }
      }

      print('\n✅ DEBUG: Busca finalizada!');
      print('   Contratos válidos encontrados: ${contratos.length}');
      print('===== FIM DA BUSCA DE CONTRATOS =====\n');
      
      return contratos;
      
    } catch (e) {
      print('❌ DEBUG: Erro durante a busca: $e');
      return [];
    }
  }

  // Buscar contrato específico por ID
  Future<Contrato?> getContratoById(String contratoId) async {
    print('\n🔍 DEBUG: Buscando contrato específico: $contratoId');
    
    if (_clienteLogado?.id == null) {
      print('❌ DEBUG: Cliente não logado');
      return null;
    }

    try {
      final doc = await _firestore
          .collection(_contratosCollection)
          .doc(contratoId)
          .get();

      if (!doc.exists) {
        print('❌ DEBUG: Contrato $contratoId não existe');
        return null;
      }

      final contratoData = doc.data()!;
      contratoData['id'] = doc.id;
      
      print('✅ DEBUG: Contrato encontrado:');
      
      final contrato = Contrato.fromMap(contratoData);

      // Verificação de segurança
      if (contrato.clienteId != _clienteLogado!.id) {
        print('🚨 DEBUG: Tentativa de acesso a contrato de outro cliente!');
        print('   Cliente logado: ${_clienteLogado!.id}');
        print('   Dono do contrato: ${contrato.clienteId}');
        throw 'Acesso negado a este contrato';
      }

      print('✅ DEBUG: Contrato validado');
      return contrato;
    } catch (e) {
      print('❌ DEBUG: Erro ao buscar contrato: $e');
      return null;
    }
  }

  // Buscar próximo evento
  Future<Contrato?> getProximoEvento() async {
    try {
      final contratos = await getContratosCliente();
      final agora = DateTime.now();
      
      final eventosFuturos = contratos
          .where((c) => c.dataEvento != null && c.dataEvento!.isAfter(agora))
          .toList();
      
      if (eventosFuturos.isEmpty) {
        print('ℹ️ DEBUG: Nenhum evento futuro encontrado');
        return null;
      }
      
      eventosFuturos.sort((a, b) => a.dataEvento!.compareTo(b.dataEvento!));
      print('✅ DEBUG: Próximo evento: ${eventosFuturos.first.numero}');
      return eventosFuturos.first;
    } catch (e) {
      print('❌ DEBUG: Erro ao buscar próximo evento: $e');
      return null;
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
          print('   ❌ Serviço $servicoId não encontrado');
        }
      }
      
      print('✅ DEBUG: ${servicos.length} serviços carregados');
      return servicos;
    } catch (e) {
      print('❌ DEBUG: Erro ao buscar serviços: $e');
      return [];
    }
  }

  // PROMOÇÕES - QUERY SIMPLIFICADA (SEM ÍNDICES)
  Future<List<Promocao>> getPromocoesAtivas() async {
    try {
      print('🔍 DEBUG: Buscando promoções ativas...');
      
      // Query simplificada - apenas promoções ativas (sem orderBy)
      final query = await _firestore
          .collection(_promocoesCollection)
          .where('ativo', isEqualTo: true)
          .limit(10)
          .get();

      print('✅ DEBUG: Query de promoções executada - ${query.docs.length} encontradas');

      final promocoes = <Promocao>[];
      final agora = DateTime.now();

      for (final doc in query.docs) {
        final promocaoData = doc.data();
        promocaoData['id'] = doc.id;
        
        final promocao = Promocao.fromMap(promocaoData);
        
        // Filtrar apenas promoções válidas (em memória)
        if (promocao.validoAte == null || promocao.validoAte!.isAfter(agora)) {
          promocoes.add(promocao);
        }
      }

      // Ordenar em memória por data de validade
      promocoes.sort((a, b) {
        if (a.validoAte == null && b.validoAte == null) return 0;
        if (a.validoAte == null) return 1;
        if (b.validoAte == null) return -1;
        return a.validoAte!.compareTo(b.validoAte!);
      });

      print('✅ DEBUG: ${promocoes.length} promoções válidas encontradas');
      return promocoes;
    } catch (e) {
      print('❌ DEBUG: Erro ao buscar promoções: $e');
      return [];
    }
  }

  // NOTIFICAÇÕES - QUERY SIMPLIFICADA (SEM ÍNDICES)
  Future<List<Notificacao>> getNotificacoesCliente() async {
    if (_clienteLogado?.id == null) {
      print('❌ DEBUG: Cliente não logado para buscar notificações');
      return [];
    }

    try {
      print('🔍 DEBUG: Buscando notificações para cliente: ${_clienteLogado!.id}');
      
      // Query simplificada - apenas por cliente_id (sem orderBy)
      final query = await _firestore
          .collection(_notificacoesCollection)
          .where('cliente_id', isEqualTo: _clienteLogado!.id)
          .limit(20)
          .get();

      print('✅ DEBUG: Query de notificações executada - ${query.docs.length} encontradas');

      final notificacoes = <Notificacao>[];
      for (final doc in query.docs) {
        final notificacaoData = doc.data();
        notificacaoData['id'] = doc.id;
        notificacoes.add(Notificacao.fromMap(notificacaoData));
      }

      // Ordenar em memória por data de criação (mais recentes primeiro)
      notificacoes.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      print('✅ DEBUG: ${notificacoes.length} notificações encontradas');
      return notificacoes;
    } catch (e) {
      print('❌ DEBUG: Erro ao buscar notificações: $e');
      return [];
    }
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
      print('❌ DEBUG: Erro ao buscar cliente: $e');
      return null;
    }
  }
}