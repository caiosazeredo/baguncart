class Cliente {
  final int? id;
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
      id: map['id'] as int?,
      nome: map['nome'] as String? ?? '',
      cpf: map['cpf'] as String? ?? '',
      telefone: map['telefone'] as String?,
      email: map['email'] as String?,
      endereco: map['endereco'] as String?,
      createdAt: map['created_at'] = null 
          ? DateTime.tryParse(map['created_at'].toString()) 
          : null,
    );
  }
}

class Servico {
  final int? id;
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
      'ativo': ativo ? 1 : 0,
    };
  }

  factory Servico.fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id'] as int?,
      nome: map['nome'] as String? ?? '',
      preco: (map['preco'] as num?)?.toDouble() ?? 0.0,
      ativo: map['ativo'] == 1,
      createdAt: map['created_at'] = null 
          ? DateTime.tryParse(map['created_at'].toString()) 
          : null,
    );
  }
}

class Contrato {
  final int? id;
  final String numero;
  final int? clienteId;
  final String? clienteNome;
  final DateTime? dataEvento;
  final String? localEvento;
  final double? valorTotal;
  final String status;
  final String? formaPagamento;
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
    this.createdAt,
  });

  factory Contrato.fromMap(Map<String, dynamic> map) {
    return Contrato(
      id: map['id'] as int?,
      numero: map['numero'] as String? ?? '',
      clienteId: map['cliente_id'] as int?,
      clienteNome: map['cliente_nome'] as String?,
      dataEvento: map['data_evento'] = null 
          ? DateTime.tryParse(map['data_evento'].toString()) 
          : null,
      localEvento: map['local_evento'] as String?,
      valorTotal: (map['valor_total'] as num?)?.toDouble(),
      status: map['status'] as String? ?? 'pendente',
      formaPagamento: map['forma_pagamento'] as String?,
      createdAt: map['created_at'] = null 
          ? DateTime.tryParse(map['created_at'].toString()) 
          : null,
    );
  }
}
