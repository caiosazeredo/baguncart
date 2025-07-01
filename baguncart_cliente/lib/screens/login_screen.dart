import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firebase_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _cpfController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _realizarLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sucesso = await _firebaseService.loginCliente(
        _cpfController.text.trim(),
        _senhaController.text.trim(),
      );

      if (sucesso && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validarCPF(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'CPF é obrigatório';
    }
    
    // Remove caracteres não numéricos
    final cpfLimpo = valor.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cpfLimpo.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    
    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (valor.length < 4) {
      return 'Senha deve ter pelo menos 4 caracteres';
    }
    
    return null;
  }

  String _formatarCPF(String cpf) {
    // Remove caracteres não numéricos
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limita a 11 dígitos
    if (cpf.length > 11) {
      cpf = cpf.substring(0, 11);
    }
    
    // Aplica a máscara
    if (cpf.length >= 4) {
      cpf = '${cpf.substring(0, 3)}.${cpf.substring(3)}';
    }
    if (cpf.length >= 8) {
      cpf = '${cpf.substring(0, 7)}.${cpf.substring(7)}';
    }
    if (cpf.length >= 12) {
      cpf = '${cpf.substring(0, 11)}-${cpf.substring(11)}';
    }
    
    return cpf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B2F8B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Título
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.celebration,
                        size: 60,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'BagunçArt',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Sua festa dos sonhos',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Formulário de Login
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Entrar na sua conta',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B2F8B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Campo CPF
                        TextFormField(
                          controller: _cpfController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          onChanged: (value) {
                            // Formatação em tempo real
                            final formatted = _formatarCPF(value);
                            if (formatted != value) {
                              _cpfController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: formatted.length,
                                ),
                              );
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'CPF',
                            hintText: '000.000.000-00',
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Color(0xFF8B2F8B),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF8B2F8B),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: _validarCPF,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Campo Senha
                        TextFormField(
                          controller: _senhaController,
                          obscureText: !_senhaVisivel,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            hintText: 'Digite sua senha',
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(0xFF8B2F8B),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _senhaVisivel
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF8B2F8B),
                              ),
                              onPressed: () {
                                setState(() {
                                  _senhaVisivel = !_senhaVisivel;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF8B2F8B),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: _validarSenha,
                          onFieldSubmitted: (_) => _realizarLogin(),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Botão de Login
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _realizarLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B2F8B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'ENTRAR',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Dados de teste
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'Dados para teste:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B2F8B),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'CPF: 135.875.027-06\nSenha: 1234',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Footer
                const Text(
                  'Entre em contato conosco:\n(11) 99999-9999',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}