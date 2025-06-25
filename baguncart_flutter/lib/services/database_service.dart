// Database service simulado - substitua por implementação real
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Dados mock para demonstração
  final List<Cliente> _clientes = [
    Cliente(id: 1, nome: 'João Silva', cpf: '12345678901', telefone: '(11) 99999-9999'),
    Cliente(id: 2, nome: 'Maria Santos', cpf: '98765432109', telefone: '(11) 88888-8888'),
    Cliente(id: 3, nome: 'Pedro Oliveira', cpf: '45678912345', telefone: '(11) 77777-7777'),
  ];

  final List<Servico> _servicos = [
    Servico(id: 1, nome: 'Pula pula', preco: 20.00),
    Servico(id: 2, nome: 'Garçom', preco: 20.00),
    Servico(id: 3, nome: 'DJ', preco: 50.00),
    Servico(id: 4, nome: 'Decoração', preco: 100.00),
  ];

  final List<Contrato> _contratos = [
    Contrato(id: 1, numero: 'C001', clienteNome: 'João Silva', status: 'confirmado'),
    Contrato(id: 2, numero: 'C002', clienteNome: 'Maria Santos', status: 'pendente'),
  ];

  Future<bool> connect() async {
    // Simular conexão
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<List<Cliente>> getClientes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_clientes);
  }

  Future<int?> insertCliente(Cliente cliente) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final novoId = _clientes.length + 1;
    _clientes.add(Cliente(
      id: novoId,
      nome: cliente.nome,
      cpf: cliente.cpf,
      telefone: cliente.telefone,
      email: cliente.email,
      endereco: cliente.endereco,
      createdAt: DateTime.now(),
    ));
    return novoId;
  }

  Future<List<Servico>> getServicos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_servicos);
  }

  Future<List<Contrato>> getContratos() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_contratos);
  }
}
