import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  final String? id;
  final String nome;
  final String cpf;
  final String? telefone;
  final String? email;
  final String? endereco;
  final String? senha;
  final DateTime? createdAt;

  const Cliente({
    this.id,
    required this.nome,
    required this.cpf,
    this.telefone,
    this.email,
    this.endereco,
    this.senha,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'senha': senha,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] as String?,
      nome: map['nome'] as String? ?? '',
      cpf: map['cpf'] as String? ?? '',
      telefone: map['telefone'] as String?,
      email: map['email'] as String?,
      endereco: map['endereco'] as String?,
      senha: map['senha'] as String?,
      createdAt: map['created_at'] is Timestamp 
          ? (map['created_at'] as Timestamp).toDate()
          : map['created_at'] is String
              ? DateTime.tryParse(map['created_at'])
              : null,
    );
  }
}

class Servico {
  final String? id;
  final String nome;
  final double preco;
  final bool ativo;
  final DateTime? createdAt;

  const Servico({
    this.id,
    required this.nome,
    required this.preco,
    this.ativo = true,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'preco': preco,
      'ativo': ativo,
    };
  }

  factory Servico.fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id'] as String?,
      nome: map['nome'] as String? ?? '',
      preco: (map['preco'] as num?)?.toDouble() ?? 0.0,
      ativo: map['ativo'] as bool? ?? true,
      createdAt: map['created_at'] is Timestamp 
          ? (map['created_at'] as Timestamp).toDate()
          : map['created_at'] is String
              ? DateTime.tryParse(map['created_at'])
              : null,
    );
  }
}

class Contrato {
  final String? id;
  final String numero;
  final String? clienteId;
  final String? clienteNome;
  final DateTime? dataEvento;
  final String? localEvento;
  final double? valorTotal;
  final String status;
  final String? formaPagamento;
  final List<String>? servicosIds;
  final List<Servico>? servicos;
  final DateTime? createdAt;

  const Contrato({
    this.id,
    required this.numero,
    this.clienteId,
    this.clienteNome,
    this.dataEvento,
    this.localEvento,
    this.valorTotal,
    this.status = 'pendente',
    this.formaPagamento,
    this.servicosIds,
    this.servicos,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'cliente_id': clienteId,
      'cliente_nome': clienteNome,
      'data_evento': dataEvento?.toIso8601String(),
      'local_evento': localEvento,
      'valor_total': valorTotal,
      'status': status,
      'forma_pagamento': formaPagamento,
      'servicos_ids': servicosIds,
    };
  }

  factory Contrato.fromMap(Map<String, dynamic> map) {
    return Contrato(
      id: map['id'] as String?,
      numero: map['numero'] as String? ?? '',
      clienteId: map['cliente_id'] as String?,
      clienteNome: map['cliente_nome'] as String?,
      dataEvento: map['data_evento'] is Timestamp
          ? (map['data_evento'] as Timestamp).toDate()
          : map['data_evento'] is String
              ? DateTime.tryParse(map['data_evento'])
              : null,
      localEvento: map['local_evento'] as String?,
      valorTotal: (map['valor_total'] as num?)?.toDouble(),
      status: map['status'] as String? ?? 'pendente',
      formaPagamento: map['forma_pagamento'] as String?,
      servicosIds: map['servicos_ids'] is List 
          ? List<String>.from(map['servicos_ids'])
          : null,
      createdAt: map['created_at'] is Timestamp 
          ? (map['created_at'] as Timestamp).toDate()
          : map['created_at'] is String
              ? DateTime.tryParse(map['created_at'])
              : null,
    );
  }

  // Getter para verificar se o contrato está próximo
  bool get isProximo {
    if (dataEvento == null) return false;
    final agora = DateTime.now();
    final diferenca = dataEvento!.difference(agora).inDays;
    return diferenca >= 0 && diferenca <= 30; // Próximos 30 dias
  }

  // Getter para dias restantes
  int get diasRestantes {
    if (dataEvento == null) return -1;
    final agora = DateTime.now();
    return dataEvento!.difference(agora).inDays;
  }

  // Getter para status formatado
  String get statusFormatado {
    switch (status) {
      case 'pendente': return 'PENDENTE';
      case 'confirmado': return 'CONFIRMADO';
      case 'em_andamento': return 'EM ANDAMENTO';
      case 'concluido': return 'CONCLUÍDO';
      case 'cancelado': return 'CANCELADO';
      default: return status.toUpperCase();
    }
  }
}

class Promocao {
  final String? id;
  final String titulo;
  final String descricao;
  final double? desconto;
  final DateTime? validadeAte;
  final bool ativo;
  final DateTime? createdAt;

  const Promocao({
    this.id,
    required this.titulo,
    required this.descricao,
    this.desconto,
    this.validadeAte,
    this.ativo = true,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'desconto': desconto,
      'validade_ate': validadeAte?.toIso8601String(),
      'ativo': ativo,
    };
  }

  factory Promocao.fromMap(Map<String, dynamic> map) {
    return Promocao(
      id: map['id'] as String?,
      titulo: map['titulo'] as String? ?? '',
      descricao: map['descricao'] as String? ?? '',
      desconto: (map['desconto'] as num?)?.toDouble(),
      validadeAte: map['validade_ate'] is Timestamp
          ? (map['validade_ate'] as Timestamp).toDate()
          : map['validade_ate'] is String
              ? DateTime.tryParse(map['validade_ate'])
              : null,
      ativo: map['ativo'] as bool? ?? true,
      createdAt: map['created_at'] is Timestamp 
          ? (map['created_at'] as Timestamp).toDate()
          : map['created_at'] is String
              ? DateTime.tryParse(map['created_at'])
              : null,
    );
  }

  // Getter para verificar se a promoção ainda é válida
  bool get isValida {
    if (validadeAte == null) return ativo;
    return ativo && DateTime.now().isBefore(validadeAte!);
  }
}

class Notificacao {
  final String? id;
  final String tipo; // 'promocao', 'evento', 'geral'
  final String titulo;
  final String mensagem;
  final bool lida;
  final DateTime? createdAt;

  const Notificacao({
    this.id,
    required this.tipo,
    required this.titulo,
    required this.mensagem,
    this.lida = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'titulo': titulo,
      'mensagem': mensagem,
      'lida': lida,
    };
  }

  factory Notificacao.fromMap(Map<String, dynamic> map) {
    return Notificacao(
      id: map['id'] as String?,
      tipo: map['tipo'] as String? ?? 'geral',
      titulo: map['titulo'] as String? ?? '',
      mensagem: map['mensagem'] as String? ?? '',
      lida: map['lida'] as bool? ?? false,
      createdAt: map['created_at'] is Timestamp 
          ? (map['created_at'] as Timestamp).toDate()
          : map['created_at'] is String
              ? DateTime.tryParse(map['created_at'])
              : null,
    );
  }
}