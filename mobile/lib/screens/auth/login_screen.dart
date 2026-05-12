import 'package:flutter/material.dart';
import 'package:planejamento_urbano/contexts/authProvider.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
          // title: const Text('Login'),
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'InovaUrbano',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Cor azul
                ),
                textAlign: TextAlign.center, // Centralizar texto
              ),
              const SizedBox(height: 32),
              // Campo de Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Insira um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de Senha
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botão de Login
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 80, 144, 227), // Cor de fundo mais chamativa
                  foregroundColor: Colors.white, // Cor do texto
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, // Mantendo o espaçamento
                    vertical: 12.0, // Mantendo o espaçamento
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Bordas arredondadas
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    try {
                      await authProvider.signIn(
                        _emailController.text,
                        _passwordController.text,
                      );
                      FocusScope.of(context).unfocus();
                      // Navegue para a tela inicial após o login
                      Navigator.pushReplacementNamed(context, '/home');
                    } catch (error) {
                      // Trate o erro (exibindo um snackbar ou alert)
                      print('Erro durante o login: $error');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro: $error')),
                      );
                    }
                  }
                },
                child: const Text('Fazer Login'),
              ),
              const SizedBox(height: 57),
              const Text(
                'Não tem uma conta?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/createAccount');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, // Cor do texto
                ),
                child: const Text("Criar conta"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
