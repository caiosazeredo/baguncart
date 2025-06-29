import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  final String? id;
  final String nome;
  final String cpf;
  final String? telefone;
  final String? email;
  final String? endereco;
  final DateTime? createdAt;

  const Cliente({
    this.id,
    required this.nome,
    required this.cpf,
    this.telefone,
    this.email,
    this.endereco,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
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
      servicosIds: map['servicos_ids'] != null 
          ? List<String>.from(map['servicos_ids'])
          : null,
      createdAt: map['created_at'] is Timestamp 
          ? (map['created_at'] as Timestamp).toDate()
          : map['created_at'] is String
              ? DateTime.tryParse(map['created_at'])
              : null,
    );
  }
}

class Promocao {
  final String? id;
  final String titulo;
  final String descricao;
  final double desconto;
  final String tipo; // 'percentual' ou 'valor'
  final DateTime? validoAte;
  final bool ativo;
  final DateTime? createdAt;

  const Promocao({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.desconto,
    this.tipo = 'percentual',
    this.validoAte,
    this.ativo = true,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'desconto': desconto,
      'tipo': tipo,
      'valido_ate': validoAte?.toIso8601String(),
      'ativo': ativo,
    };
  }

  factory Promocao.fromMap(Map<String, dynamic> map) {
    return Promocao(
      id: map['id'] as String?,
      titulo: map['titulo'] as String? ?? '',
      descricao: map['descricao'] as String? ?? '',
      desconto: (map['desconto'] as num?)?.toDouble() ?? 0.0,
      tipo: map['tipo'] as String? ?? 'percentual',
      validoAte: map['valido_ate'] is Timestamp 
          ? (map['valido_ate'] as Timestamp).toDate()
          : map['valido_ate'] is String
              ? DateTime.tryParse(map['valido_ate'])
              : null,
      ativo: map['ativo'] as bool? ?? true,
      createdAt: map['created_at'] is Timestamp 
          ? (map['created_at'] as Timestamp).toDate()
          : map['created_at'] is String
              ? DateTime.tryParse(map['created_at'])
              : null,
    );
  }
}

class Notificacao {
  final String? id;
  final String titulo;
  final String mensagem;
  final String tipo; // 'info', 'warning', 'error', 'success'
  final bool lida;
  final DateTime? createdAt;

  const Notificacao({
    this.id,
    required this.titulo,
    required this.mensagem,
    this.tipo = 'info',
    this.lida = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'mensagem': mensagem,
      'tipo': tipo,
      'lida': lida,
    };
  }

  factory Notificacao.fromMap(Map<String, dynamic> map) {
    return Notificacao(
      id: map['id'] as String?,
      titulo: map['titulo'] as String? ?? '',
      mensagem: map['mensagem'] as String? ?? '',
      tipo: map['tipo'] as String? ?? 'info',
      lida: map['lida'] as bool? ?? false,
      createdAt: map['created_at'] is Timestamp 
          ? (map['created_at'] as Timestamp).toDate()
          : map['created_at'] is String
              ? DateTime.tryParse(map['created_at'])
              : null,
    );
  }
}