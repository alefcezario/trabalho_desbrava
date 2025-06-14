import 'package:flutter/material.dart';
import 'package:my_desbrava/category_places_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color lightBeige = Color(0xFFEAE7DC);

    return Scaffold( // Adicionamos um Scaffold para ter controlo sobre o fundo
      backgroundColor: lightBeige,
      body: Stack( // Usamos um Stack para sobrepor o logo à lista
        children: [
          // A lista de conteúdo principal
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              const SizedBox(height: 20),
              const Text(
                'Bem-Vindo!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Descubra novos lugares para visitar.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // Categorias com navegação
              CategoryCard(
                icon: Icons.waterfall_chart,
                title: 'Cachoeiras',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryPlacesScreen(categoryName: 'Cachoeiras')));
                },
              ),
              const SizedBox(height: 16),
              CategoryCard(
                icon: Icons.museum_outlined,
                title: 'Museus',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryPlacesScreen(categoryName: 'Museus')));
                },
              ),
              const SizedBox(height: 16),
              CategoryCard(
                icon: Icons.park_outlined,
                title: 'Parques',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryPlacesScreen(categoryName: 'Parques')));
                },
              ),
              const SizedBox(height: 16),
              CategoryCard(
                icon: Icons.terrain,
                title: 'Trilhas',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryPlacesScreen(categoryName: 'Trilhas')));
                },
              ),
              // Espaço extra no final para não ficar colado ao logo
              const SizedBox(height: 120),
            ],
          ),

          // <<< WIDGET DO LOGO ATUALIZADO >>>
          // O valor de 'left' foi alterado para alinhar melhor o logo
          Positioned(
            bottom: 10,
            left: 16, // Alterado de -20 para 16
            child: Image.asset(
              'assets/melodog.png', // Certifique-se que o nome do ficheiro está correto
              height: 140, // Ajuste o tamanho conforme necessário
            ),
          ),
        ],
      ),
    );
  }
}

// Widget reutilizável para os cartões de categoria
class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF0A192F), size: 30),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}
