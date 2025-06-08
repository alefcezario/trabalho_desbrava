import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_desbrava/main_wrapper.dart';
import 'package:my_desbrava/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para ler o texto dos campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variável para controlar o estado de carregamento
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função para fazer o login com o Firebase
  Future<void> _login() async {
    // Verifica se os campos são válidos
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true; // Ativa o indicador de progresso
    });

    try {
      // Tenta fazer o login no Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Se o login for bem-sucedido, navega para a tela principal
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainWrapper()),
              (Route<dynamic> route) => false,
        );
      }

    } on FirebaseAuthException catch (e) {
      // Trata erros específicos de autenticação
      String errorMessage = 'E-mail ou senha incorretos.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'E-mail ou senha inválidos. Tente novamente.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Trata outros erros
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorreu um erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Garante que o indicador de progresso seja desativado
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // <<< NOVA FUNÇÃO ADICIONADA AQUI >>>
  // Função para redefinir a senha
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, digite seu e-mail para redefinir a senha.'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se o e-mail estiver registado, um link de redefinição foi enviado.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro ao enviar o e-mail: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // ---- TÍTULO ----
                const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 20),

                // ---- LINK PARA CRIAR CONTA ----
                Row(
                  children: [
                    const Text(
                      'Não tem uma conta?',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navega para a tela de cadastro, substituindo a de login
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        'Clique Aqui',
                        style: TextStyle(color: Color(0xFF6A0DAD), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // ---- CAMPO E-MAIL ----
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor, digite seu e-mail';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ---- CAMPO SENHA ----
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor, digite sua senha';
                    return null;
                  },
                ),
                // <<< NOVO WIDGET ADICIONADO AQUI >>>
                // ---- LINK ESQUECI A SENHA ----
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: const Text(
                      'Esqueci minha senha',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---- BOTÃO ENTRAR ----
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login, // Desativa o botão durante o carregamento
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A192F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: const Color(0xFF0A192F).withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Entrar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
