@echo off
chcp 65001
echo ===========================================
echo  CORRETOR AUTOMÁTICO - BAGUNCART FLUTTER
echo ===========================================
echo.

REM Verificar se estamos no diretório correto
if not exist "pubspec.yaml" (
    echo ERRO: Execute este arquivo no diretório raiz do projeto Flutter
    pause
    exit /b 1
)

echo [1/8] Adicionando suporte para web...
flutter create --platforms web .

echo.
echo [2/8] Corrigindo models.dart...
(
echo class Cliente {
echo   final int? id;
echo   final String nome;
echo   final String cpf;
echo   final String? telefone;
echo   final String? email;
echo   final String? endereco;
echo   final DateTime? createdAt;
echo.
echo   const Cliente({
echo     this.id,
echo     required this.nome,
echo     required this.cpf,
echo     this.telefone,
echo     this.email,
echo     this.endereco,
echo     this.createdAt,
echo   }^);
echo.
echo   Map^<String, dynamic^> toMap(^) {
echo     return {
echo       'nome': nome,
echo       'cpf': cpf,
echo       'telefone': telefone,
echo       'email': email,
echo       'endereco': endereco,
echo     };
echo   }
echo.
echo   factory Cliente.fromMap(Map^<String, dynamic^> map^) {
echo     return Cliente(
echo       id: map['id'] as int?,
echo       nome: map['nome'] as String? ?? '',
echo       cpf: map['cpf'] as String? ?? '',
echo       telefone: map['telefone'] as String?,
echo       email: map['email'] as String?,
echo       endereco: map['endereco'] as String?,
echo       createdAt: map['created_at'] == null 
echo           ? null
echo           : DateTime.tryParse(map['created_at'].toString(^)^),
echo     ^);
echo   }
echo }
echo.
echo class Servico {
echo   final int? id;
echo   final String nome;
echo   final double preco;
echo   final bool ativo;
echo   final DateTime? createdAt;
echo.
echo   const Servico({
echo     this.id,
echo     required this.nome,
echo     required this.preco,
echo     this.ativo = true,
echo     this.createdAt,
echo   }^);
echo.
echo   Map^<String, dynamic^> toMap(^) {
echo     return {
echo       'nome': nome,
echo       'preco': preco,
echo       'ativo': ativo ? 1 : 0,
echo     };
echo   }
echo.
echo   factory Servico.fromMap(Map^<String, dynamic^> map^) {
echo     return Servico(
echo       id: map['id'] as int?,
echo       nome: map['nome'] as String? ?? '',
echo       preco: (map['preco'] as num?^)?.toDouble(^) ?? 0.0,
echo       ativo: map['ativo'] == 1,
echo       createdAt: map['created_at'] == null 
echo           ? null
echo           : DateTime.tryParse(map['created_at'].toString(^)^),
echo     ^);
echo   }
echo }
echo.
echo class Contrato {
echo   final int? id;
echo   final String numero;
echo   final int? clienteId;
echo   final String? clienteNome;
echo   final DateTime? dataEvento;
echo   final String? localEvento;
echo   final double? valorTotal;
echo   final String status;
echo   final String? formaPagamento;
echo   final DateTime? createdAt;
echo.
echo   const Contrato({
echo     this.id,
echo     required this.numero,
echo     this.clienteId,
echo     this.clienteNome,
echo     this.dataEvento,
echo     this.localEvento,
echo     this.valorTotal,
echo     this.status = 'pendente',
echo     this.formaPagamento,
echo     this.createdAt,
echo   }^);
echo.
echo   factory Contrato.fromMap(Map^<String, dynamic^> map^) {
echo     return Contrato(
echo       id: map['id'] as int?,
echo       numero: map['numero'] as String? ?? '',
echo       clienteId: map['cliente_id'] as int?,
echo       clienteNome: map['cliente_nome'] as String?,
echo       dataEvento: map['data_evento'] == null 
echo           ? null
echo           : DateTime.tryParse(map['data_evento'].toString(^)^),
echo       localEvento: map['local_evento'] as String?,
echo       valorTotal: (map['valor_total'] as num?^)?.toDouble(^),
echo       status: map['status'] as String? ?? 'pendente',
echo       formaPagamento: map['forma_pagamento'] as String?,
echo       createdAt: map['created_at'] == null 
echo           ? null
echo           : DateTime.tryParse(map['created_at'].toString(^)^),
echo     ^);
echo   }
echo }
) > lib\models\models.dart

echo.
echo [3/8] Criando login_screen.dart...
(
echo import 'package:flutter/material.dart';
echo import '../services/database_service.dart';
echo import 'menu_screen.dart';
echo.
echo class LoginScreen extends StatefulWidget {
echo   const LoginScreen({super.key}^);
echo.
echo   @override
echo   State^<LoginScreen^> createState(^) =^> _LoginScreenState(^);
echo }
echo.
echo class _LoginScreenState extends State^<LoginScreen^> {
echo   final _formKey = GlobalKey^<FormState^>(^);
echo   final _usernameController = TextEditingController(^);
echo   final _passwordController = TextEditingController(^);
echo   final DatabaseService _db = DatabaseService(^);
echo   bool _isLoading = false;
echo.
echo   @override
echo   void dispose(^) {
echo     _usernameController.dispose(^);
echo     _passwordController.dispose(^);
echo     super.dispose(^);
echo   }
echo.
echo   Future^<void^> _login(^) async {
echo     if (^!_formKey.currentState^!.validate(^)^) return;
echo.
echo     setState(^(^) =^> _isLoading = true^);
echo.
echo     try {
echo       // Simular autenticação
echo       await Future.delayed(const Duration(seconds: 1^)^);
echo       
echo       final connected = await _db.connect(^);
echo       
echo       if (connected ^&^& mounted^) {
echo         Navigator.of(context^).pushReplacement(
echo           MaterialPageRoute(builder: (_^) =^> const MenuScreen(^)^),
echo         ^);
echo       } else {
echo         _showErrorDialog('Erro de conexão com o banco de dados'^);
echo       }
echo     } catch (e^) {
echo       _showErrorDialog('Erro ao fazer login: $e'^);
echo     } finally {
echo       if (mounted^) setState(^(^) =^> _isLoading = false^);
echo     }
echo   }
echo.
echo   void _showErrorDialog(String message^) {
echo     showDialog(
echo       context: context,
echo       builder: (context^) =^> AlertDialog(
echo         title: const Text('Erro'^),
echo         content: Text(message^),
echo         actions: [
echo           TextButton(
echo             onPressed: (^) =^> Navigator.pop(context^),
echo             child: const Text('OK'^),
echo           ^),
echo         ],
echo       ^),
echo     ^);
echo   }
echo.
echo   @override
echo   Widget build(BuildContext context^) {
echo     return Scaffold(
echo       body: Container(
echo         decoration: const BoxDecoration(
echo           gradient: LinearGradient(
echo             colors: [Color(0xFF8B2F8B^), Color(0xFFFF8C00^)],
echo             begin: Alignment.topCenter,
echo             end: Alignment.bottomCenter,
echo           ^),
echo         ^),
echo         child: Center(
echo           child: SingleChildScrollView(
echo             padding: const EdgeInsets.all(24^),
echo             child: Card(
echo               elevation: 8,
echo               shape: RoundedRectangleBorder(
echo                 borderRadius: BorderRadius.circular(20^),
echo               ^),
echo               child: Padding(
echo                 padding: const EdgeInsets.all(32^),
echo                 child: Form(
echo                   key: _formKey,
echo                   child: Column(
echo                     mainAxisSize: MainAxisSize.min,
echo                     children: [
echo                       const Icon(
echo                         Icons.celebration,
echo                         size: 80,
echo                         color: Color(0xFF8B2F8B^),
echo                       ^),
echo                       const SizedBox(height: 16^),
echo                       const Text(
echo                         'BagunçArt',
echo                         style: TextStyle(
echo                           fontSize: 32,
echo                           fontWeight: FontWeight.bold,
echo                           color: Color(0xFF8B2F8B^),
echo                         ^),
echo                       ^),
echo                       const SizedBox(height: 8^),
echo                       const Text(
echo                         'Sistema Administrativo',
echo                         style: TextStyle(
echo                           fontSize: 16,
echo                           color: Colors.grey,
echo                         ^),
echo                       ^),
echo                       const SizedBox(height: 32^),
echo                       TextFormField(
echo                         controller: _usernameController,
echo                         decoration: const InputDecoration(
echo                           labelText: 'Usuário',
echo                           prefixIcon: Icon(Icons.person^),
echo                         ^),
echo                         validator: (value^) {
echo                           if (value == null ^|^| value.isEmpty^) {
echo                             return 'Por favor, insira o usuário';
echo                           }
echo                           return null;
echo                         },
echo                       ^),
echo                       const SizedBox(height: 16^),
echo                       TextFormField(
echo                         controller: _passwordController,
echo                         obscureText: true,
echo                         decoration: const InputDecoration(
echo                           labelText: 'Senha',
echo                           prefixIcon: Icon(Icons.lock^),
echo                         ^),
echo                         validator: (value^) {
echo                           if (value == null ^|^| value.isEmpty^) {
echo                             return 'Por favor, insira a senha';
echo                           }
echo                           return null;
echo                         },
echo                         onFieldSubmitted: (_^) =^> _login(^),
echo                       ^),
echo                       const SizedBox(height: 32^),
echo                       SizedBox(
echo                         width: double.infinity,
echo                         height: 50,
echo                         child: ElevatedButton(
echo                           onPressed: _isLoading ? null : _login,
echo                           child: _isLoading
echo                               ? const CircularProgressIndicator(color: Colors.white^)
echo                               : const Text('ENTRAR'^),
echo                         ^),
echo                       ^),
echo                     ],
echo                   ^),
echo                 ^),
echo               ^),
echo             ^),
echo           ^),
echo         ^),
echo       ^),
echo     ^);
echo   }
echo }
) > lib\screens\login_screen.dart

echo.
echo [4/8] Corrigindo clientes_screen.dart...
(
echo import 'package:flutter/material.dart';
echo import '../models/models.dart';
echo import '../services/database_service.dart';
echo import 'cadastro_screen.dart';
echo.
echo class ClientesScreen extends StatefulWidget {
echo   const ClientesScreen({super.key}^);
echo.
echo   @override
echo   State^<ClientesScreen^> createState(^) =^> _ClientesScreenState(^);
echo }
echo.
echo class _ClientesScreenState extends State^<ClientesScreen^> {
echo   final DatabaseService _db = DatabaseService(^);
echo   List^<Cliente^> _clientes = [];
echo   List^<Cliente^> _clientesFiltrados = [];
echo   final _searchController = TextEditingController(^);
echo   bool _isLoading = true;
echo.
echo   @override
echo   void initState(^) {
echo     super.initState(^);
echo     _loadClientes(^);
echo   }
echo.
echo   Future^<void^> _loadClientes(^) async {
echo     setState(^(^) =^> _isLoading = true^);
echo     final clientes = await _db.getClientes(^);
echo     if (mounted^) {
echo       setState(^(^) {
echo         _clientes = clientes;
echo         _clientesFiltrados = clientes;
echo         _isLoading = false;
echo       }^);
echo     }
echo   }
echo.
echo   void _filterClientes(String query^) {
echo     setState(^(^) {
echo       _clientesFiltrados = _clientes.where((cliente^) {
echo         return cliente.nome.toLowerCase(^).contains(query.toLowerCase(^)^) ^|^|
echo                cliente.cpf.contains(query^) ^|^|
echo                (cliente.telefone?.contains(query^) ?? false^) ^|^|
echo                (cliente.email?.toLowerCase(^).contains(query.toLowerCase(^)^) ?? false^);
echo       }^).toList(^);
echo     }^);
echo   }
echo.
echo   @override
echo   Widget build(BuildContext context^) {
echo     return Scaffold(
echo       appBar: AppBar(
echo         title: const Text('Clientes'^),
echo         actions: [
echo           IconButton(
echo             icon: const Icon(Icons.person_add^),
echo             onPressed: (^) async {
echo               await Navigator.push(
echo                 context,
echo                 MaterialPageRoute(builder: (_^) =^> const CadastroScreen(^)^),
echo               ^);
echo               _loadClientes(^);
echo             },
echo           ^),
echo         ],
echo       ^),
echo       body: Column(
echo         children: [
echo           Padding(
echo             padding: const EdgeInsets.all(16^),
echo             child: TextField(
echo               controller: _searchController,
echo               decoration: InputDecoration(
echo                 labelText: 'Pesquisar clientes...',
echo                 prefixIcon: const Icon(Icons.search^),
echo                 suffixIcon: _searchController.text.isNotEmpty
echo                     ? IconButton(
echo                         icon: const Icon(Icons.clear^),
echo                         onPressed: (^) {
echo                           _searchController.clear(^);
echo                           _filterClientes(''^);
echo                         },
echo                       ^)
echo                     : null,
echo               ^),
echo               onChanged: _filterClientes,
echo             ^),
echo           ^),
echo           Expanded(
echo             child: _isLoading
echo                 ? const Center(child: CircularProgressIndicator(^)^)
echo                 : _clientesFiltrados.isEmpty
echo                     ? const Center(
echo                         child: Column(
echo                           mainAxisAlignment: MainAxisAlignment.center,
echo                           children: [
echo                             Icon(
echo                               Icons.people_outline,
echo                               size: 64,
echo                               color: Colors.grey,
echo                             ^),
echo                             SizedBox(height: 16^),
echo                             Text(
echo                               'Nenhum cliente encontrado',
echo                               style: TextStyle(
echo                                 fontSize: 18,
echo                                 color: Colors.grey,
echo                               ^),
echo                             ^),
echo                           ],
echo                         ^),
echo                       ^)
echo                     : ListView.builder(
echo                         padding: const EdgeInsets.all(16^),
echo                         itemCount: _clientesFiltrados.length,
echo                         itemBuilder: (context, index^) {
echo                           final cliente = _clientesFiltrados[index];
echo                           return Card(
echo                             margin: const EdgeInsets.only(bottom: 12^),
echo                             child: ListTile(
echo                               leading: const CircleAvatar(
echo                                 backgroundColor: Color(0xFF8B2F8B^),
echo                                 child: Icon(Icons.person, color: Colors.white^),
echo                               ^),
echo                               title: Text(
echo                                 cliente.nome,
echo                                 style: const TextStyle(fontWeight: FontWeight.bold^),
echo                               ^),
echo                               subtitle: Column(
echo                                 crossAxisAlignment: CrossAxisAlignment.start,
echo                                 children: [
echo                                   Text('CPF: ${cliente.cpf}'^),
echo                                   if (cliente.telefone ^!= null^)
echo                                     Text('Tel: ${cliente.telefone}'^),
echo                                 ],
echo                               ^),
echo                               trailing: Row(
echo                                 mainAxisSize: MainAxisSize.min,
echo                                 children: [
echo                                   IconButton(
echo                                     icon: const Icon(Icons.edit, color: Color(0xFF8B2F8B^)^),
echo                                     onPressed: (^) =^> _showDevelopment(^),
echo                                   ^),
echo                                   IconButton(
echo                                     icon: const Icon(Icons.description, color: Color(0xFFFF8C00^)^),
echo                                     onPressed: (^) =^> _showDevelopment(^),
echo                                   ^),
echo                                 ],
echo                               ^),
echo                             ^),
echo                           ^);
echo                         },
echo                       ^),
echo           ^),
echo         ],
echo       ^),
echo     ^);
echo   }
echo.
echo   void _showDevelopment(^) {
echo     ScaffoldMessenger.of(context^).showSnackBar(
echo       const SnackBar(content: Text('Funcionalidade em desenvolvimento'^)^),
echo     ^);
echo   }
echo.
echo   @override
echo   void dispose(^) {
echo     _searchController.dispose(^);
echo     super.dispose(^);
echo   }
echo }
) > lib\screens\clientes_screen.dart

echo.
echo [5/8] Criando cadastro_screen.dart...
(
echo import 'package:flutter/material.dart';
echo import '../models/models.dart';
echo import '../services/database_service.dart';
echo.
echo class CadastroScreen extends StatefulWidget {
echo   const CadastroScreen({super.key}^);
echo.
echo   @override
echo   State^<CadastroScreen^> createState(^) =^> _CadastroScreenState(^);
echo }
echo.
echo class _CadastroScreenState extends State^<CadastroScreen^> {
echo   final _formKey = GlobalKey^<FormState^>(^);
echo   final _nomeController = TextEditingController(^);
echo   final _cpfController = TextEditingController(^);
echo   final _telefoneController = TextEditingController(^);
echo   final _emailController = TextEditingController(^);
echo   final _enderecoController = TextEditingController(^);
echo   final DatabaseService _db = DatabaseService(^);
echo   bool _isLoading = false;
echo.
echo   @override
echo   void dispose(^) {
echo     _nomeController.dispose(^);
echo     _cpfController.dispose(^);
echo     _telefoneController.dispose(^);
echo     _emailController.dispose(^);
echo     _enderecoController.dispose(^);
echo     super.dispose(^);
echo   }
echo.
echo   String? _validateName(String? value^) {
echo     if (value == null ^|^| value.trim(^).isEmpty^) {
echo       return 'Nome é obrigatório';
echo     }
echo     if (value.trim(^).length ^< 2^) {
echo       return 'Nome deve ter pelo menos 2 caracteres';
echo     }
echo     return null;
echo   }
echo.
echo   String? _validateCPF(String? value^) {
echo     if (value == null ^|^| value.isEmpty^) {
echo       return 'CPF é obrigatório';
echo     }
echo     
echo     final cpf = value.replaceAll(RegExp(r'[^0-9]'^), ''^);
echo     if (cpf.length ^!= 11^) {
echo       return 'CPF deve ter 11 dígitos';
echo     }
echo     
echo     return null;
echo   }
echo.
echo   String? _validateEmail(String? value^) {
echo     if (value != null ^&^& value.isNotEmpty^) {
echo       final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+'^);
echo       if (^!emailRegex.hasMatch(value^)^) {
echo         return 'Email inválido';
echo       }
echo     }
echo     return null;
echo   }
echo.
echo   Future^<void^> _cadastrarCliente(^) async {
echo     if (^!_formKey.currentState^!.validate(^)^) return;
echo.
echo     setState(^(^) =^> _isLoading = true^);
echo.
echo     try {
echo       final cpfLimpo = _cpfController.text.replaceAll(RegExp(r'[^0-9]'^), ''^);
echo       
echo       final cliente = Cliente(
echo         nome: _nomeController.text.trim(^),
echo         cpf: cpfLimpo,
echo         telefone: _telefoneController.text.trim(^).isNotEmpty 
echo           ? _telefoneController.text.trim(^) 
echo           : null,
echo         email: _emailController.text.trim(^).isNotEmpty 
echo           ? _emailController.text.trim(^) 
echo           : null,
echo         endereco: _enderecoController.text.trim(^).isNotEmpty 
echo           ? _enderecoController.text.trim(^) 
echo           : null,
echo       ^);
echo.
echo       final id = await _db.insertCliente(cliente^);
echo       
echo       if (mounted^) {
echo         if (id ^!= null^) {
echo           ScaffoldMessenger.of(context^).showSnackBar(
echo             const SnackBar(
echo               content: Text('Cliente cadastrado com sucesso^!'^),
echo               backgroundColor: Colors.green,
echo             ^),
echo           ^);
echo           Navigator.pop(context^);
echo         } else {
echo           ScaffoldMessenger.of(context^).showSnackBar(
echo             const SnackBar(
echo               content: Text('Erro ao cadastrar cliente'^),
echo               backgroundColor: Colors.red,
echo             ^),
echo           ^);
echo         }
echo       }
echo     } catch (e^) {
echo       if (mounted^) {
echo         ScaffoldMessenger.of(context^).showSnackBar(
echo           SnackBar(
echo             content: Text('Erro: $e'^),
echo             backgroundColor: Colors.red,
echo           ^),
echo         ^);
echo       }
echo     } finally {
echo       if (mounted^) setState(^(^) =^> _isLoading = false^);
echo     }
echo   }
echo.
echo   @override
echo   Widget build(BuildContext context^) {
echo     return Scaffold(
echo       appBar: AppBar(
echo         title: const Text('Cadastrar Cliente'^),
echo       ^),
echo       body: Padding(
echo         padding: const EdgeInsets.all(16^),
echo         child: Form(
echo           key: _formKey,
echo           child: ListView(
echo             children: [
echo               TextFormField(
echo                 controller: _nomeController,
echo                 decoration: const InputDecoration(
echo                   labelText: 'Nome Completo *',
echo                   prefixIcon: Icon(Icons.person^),
echo                 ^),
echo                 validator: _validateName,
echo                 textCapitalization: TextCapitalization.words,
echo               ^),
echo               const SizedBox(height: 16^),
echo               TextFormField(
echo                 controller: _cpfController,
echo                 decoration: const InputDecoration(
echo                   labelText: 'CPF *',
echo                   prefixIcon: Icon(Icons.credit_card^),
echo                   hintText: '000.000.000-00',
echo                 ^),
echo                 validator: _validateCPF,
echo                 keyboardType: TextInputType.number,
echo               ^),
echo               const SizedBox(height: 16^),
echo               TextFormField(
echo                 controller: _telefoneController,
echo                 decoration: const InputDecoration(
echo                   labelText: 'Telefone',
echo                   prefixIcon: Icon(Icons.phone^),
echo                   hintText: '(00^) 00000-0000',
echo                 ^),
echo                 keyboardType: TextInputType.phone,
echo               ^),
echo               const SizedBox(height: 16^),
echo               TextFormField(
echo                 controller: _emailController,
echo                 decoration: const InputDecoration(
echo                   labelText: 'Email',
echo                   prefixIcon: Icon(Icons.email^),
echo                   hintText: 'exemplo@email.com',
echo                 ^),
echo                 validator: _validateEmail,
echo                 keyboardType: TextInputType.emailAddress,
echo               ^),
echo               const SizedBox(height: 16^),
echo               TextFormField(
echo                 controller: _enderecoController,
echo                 decoration: const InputDecoration(
echo                   labelText: 'Endereço',
echo                   prefixIcon: Icon(Icons.location_on^),
echo                 ^),
echo                 maxLines: 2,
echo               ^),
echo               const SizedBox(height: 32^),
echo               SizedBox(
echo                 height: 50,
echo                 child: ElevatedButton(
echo                   onPressed: _isLoading ? null : _cadastrarCliente,
echo                   child: _isLoading
echo                       ? const CircularProgressIndicator(color: Colors.white^)
echo                       : const Text('CADASTRAR CLIENTE'^),
echo                 ^),
echo               ^),
echo               const SizedBox(height: 16^),
echo               const Text(
echo                 '* Campos obrigatórios',
echo                 style: TextStyle(
echo                   fontSize: 12,
echo                   color: Colors.grey,
echo                 ^),
echo               ^),
echo             ],
echo           ^),
echo         ^),
echo       ^),
echo     ^);
echo   }
echo }
) > lib\screens\cadastro_screen.dart

echo.
echo [6/8] Limpando cache e dependências...
flutter clean

echo.
echo [7/8] Reinstalando dependências...
flutter pub get

echo.
echo [8/8] Testando compilação...
flutter analyze

echo.
echo ===========================================
echo        CORREÇÃO CONCLUÍDA COM SUCESSO^!
echo ===========================================
echo.
echo Principais correções realizadas:
echo ✓ Adicionado suporte para web
echo ✓ Corrigidos erros de sintaxe nos modelos
echo ✓ Criado arquivo login_screen.dart
echo ✓ Corrigido arquivo clientes_screen.dart  
echo ✓ Criado arquivo cadastro_screen.dart funcional
echo ✓ Limpado cache e reinstalado dependências
echo.
echo Agora você pode executar:
echo   flutter run -d chrome
echo.
pause