import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  final String? id;
  final String nome;
  final String cpf;
  final String? telefone;
  final String? email;
  final String? endereco;
  final String? senha; // CAMPO SENHA ADICIONADO!
  final DateTime? createdAt;

  const Cliente({
    this.id,
    required this.nome,
    required this.cpf,
    this.telefone,
    this.email,
    this.endereco,
    this.senha, // CAMPO SENHA ADICIONADO!
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'senha': senha, // CAMPO SENHA ADICIONADO!
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
      senha: map['senha'] as String?, // CAMPO SENHA ADICIONADO!
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
}

class Promocao {
  final String? id;
  final String titulo; // Mudado de 'nome' para 'titulo'
  final String descricao;
  final String tipo; // Campo adicionado!
  final double? desconto;
  final DateTime? validoAte; // Mudado de 'validadeAte' para 'validoAte'
  final bool ativo;
  final DateTime? createdAt;

  const Promocao({
    this.id,
    required this.titulo, // Mudado de 'nome' para 'titulo'
    required this.descricao,
    this.tipo = 'percentual', // Campo adicionado com valor padrão!
    this.desconto,
    this.validoAte, // Mudado de 'validadeAte' para 'validoAte'
    this.ativo = true,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo, // Mudado de 'nome' para 'titulo'
      'descricao': descricao,
      'tipo': tipo, // Campo adicionado!
      'desconto': desconto,
      'valido_ate': validoAte != null  // Mudado de 'validade_ate' para 'valido_ate'
          ? Timestamp.fromDate(validoAte!)
          : null,
      'ativo': ativo,
    };
  }

  factory Promocao.fromMap(Map<String, dynamic> map) {
    return Promocao(
      id: map['id'] as String?,
      titulo: map['titulo'] as String? ?? '', // Mudado de 'nome' para 'titulo'
      descricao: map['descricao'] as String? ?? '',
      tipo: map['tipo'] as String? ?? 'percentual', // Campo adicionado!
      desconto: (map['desconto'] as num?)?.toDouble(),
      validoAte: map['valido_ate'] is Timestamp // Mudado de 'validade_ate' para 'valido_ate'
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

  bool get isValida {
    if (validoAte == null) return ativo;
    return ativo && DateTime.now().isBefore(validoAte!);
  }
}

class Notificacao {
  final String? id;
  final String tipo;
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