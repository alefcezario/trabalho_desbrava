import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color lightBeige = Color(0xFFEAE7DC);

    // O Scaffold e a AppBar foram removidos, pois agora são controlados pelo AppScaffold.
    return Container(
      color: lightBeige, // A cor de fundo principal
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            // ---- TÍTULO E SUBTÍTULO ----
            const Text(
              'Bem-Vindo!',
              style: TextStyle(
                color: Colors.black, // Cor alterada para ser legível no fundo claro
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Descubra novos lugares para visitar.',
              style: TextStyle(
                color: Colors.black54, // Cor alterada
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),

            // ---- CATEGORIAS ----
            CategoryCard(
              icon: Icons.waterfall_chart,
              title: 'Cachoeiras',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            CategoryCard(
              icon: Icons.museum_outlined,
              title: 'Museus',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            CategoryCard(
              icon: Icons.park_outlined,
              title: 'Parques',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            CategoryCard(
              icon: Icons.terrain, // Ícone trocado para melhor representar trilhas
              title: 'Trilhas',
              onTap: () {},
            ),
          ],
        ),
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
      elevation: 4, // Aumentei um pouco a sombra
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
