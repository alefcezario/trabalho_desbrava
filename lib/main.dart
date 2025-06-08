import 'package:flutter/material.dart';
import 'package:my_desbrava/login_screen.dart'; // Importa a nova tela de Login
import 'package:my_desbrava/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Garante que o Flutter está inicializado.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase usando as opções corretas para a plataforma atual.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

// MyApp é o widget raiz do seu aplicativo.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Esta linha remove a faixa de "Debug" no canto da tela.
      debugShowCheckedModeBanner: false,
      title: 'Desbrava App',
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      // A tela inicial do seu aplicativo.
      home: const WelcomeScreen(),
    );
  }
}

// Este é o widget que constrói a sua tela inicial (com o logo).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFF5F5F5),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: screenHeight * 0.65,
              width: screenWidth,
              decoration: const BoxDecoration(
                color: Color(0xFF0A192F),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(200),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    Image.asset(
                      'assets/logo.png',
                      height: 150,
                    ),
                    const Spacer(flex: 4),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // <<< CÓDIGO ATUALIZADO AQUI >>>
                          // Navega para a tela de Login
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE0DDCF),
                          foregroundColor: const Color(0xFF0A192F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          // Navega para a tela de cadastro.
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFE0DDCF),
                            width: 2,
                          ),
                          foregroundColor: const Color(0xFFE0DDCF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Criar Conta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
