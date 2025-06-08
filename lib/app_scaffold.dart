import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_desbrava/main.dart'; // Importa o main.dart para a navegação de logout

// Este é um widget reutilizável que define a estrutura padrão da tela
// com uma AppBar e um Drawer (menu lateral).
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0A192F);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: darkBlue,
        iconTheme: const IconThemeData(color: Colors.white), // Define a cor do ícone do menu
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // TODO: Navegar para a tela de notificações
            },
          ),
        ],
      ),
      // Adiciona o menu lateral (gaveta)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Cabeçalho do Drawer
            const DrawerHeader(
              decoration: BoxDecoration(
                color: darkBlue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // Item de menu para Sair
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                // Faz o logout do Firebase
                await FirebaseAuth.instance.signOut();
                // Navega para a tela inicial e remove todas as outras telas
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                        (Route<dynamic> route) => false,
                  );
                }
              },
            ),
            // Adicione outros itens de menu aqui no futuro
          ],
        ),
      ),
      body: body, // O corpo da tela será o widget que passarmos
    );
  }
}
