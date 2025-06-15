import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_desbrava/edit_profile_screen.dart';
import 'package:my_desbrava/maintenance_screen.dart';
import 'package:my_desbrava/my_contributions_screen.dart';
import 'package:my_desbrava/widgets/place_card.dart';
import 'package:my_desbrava/legal_document_screen.dart';
import 'package:my_desbrava/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Future.error('Nenhum utilizador logado.');
    }
    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    const Color lightBeige = Color(0xFFEAE7DC);

    return Container(
      color: const Color(0xFFF0F0F0),
      child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('Não foi possível carregar os dados do perfil.'));
          }

          final userData = snapshot.data!.data()!;
          final String name = userData['name'] ?? 'Nome não encontrado';
          final String? photoUrl = userData['photoUrl'];

          return Stack(
            children: [
              ClipPath(
                clipper: ProfileBackgroundClipper(),
                child: Container(
                  height: 250,
                  color: lightBeige,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 30),
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade400,
                        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A192F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // <<< SEÇÃO DE MEDALHAS REVERTIDA PARA A VERSÃO ANTERIOR >>>
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceScreen()));
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Medalhas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                                  Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                                  Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // O resto dos botões continua como estava
                    OptionButton(
                      icon: Icons.rate_review_outlined,
                      text: 'Minhas Contribuições',
                      onTap: () {
                        // A tela de contribuições ainda precisa do índice para funcionar
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyContributionsScreen()));
                      },
                    ),
                    const SizedBox(height: 12),

                    OptionButton(
                      icon: Icons.settings,
                      text: 'Configurações de perfil',
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    OptionButton(
                      icon: Icons.description_outlined,
                      text: 'Termos de Uso',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        const LegalDocumentScreen(
                          title: 'Termos de Uso',
                          content: termsOfUseContent,
                        )
                        ));
                      },
                    ),
                    const SizedBox(height: 12),
                    OptionButton(
                      icon: Icons.shield_outlined,
                      text: 'Política de Privacidade',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        const LegalDocumentScreen(
                          title: 'Política de Privacidade',
                          content: privacyPolicyContent,
                        )
                        ));
                      },
                    ),
                    const SizedBox(height: 12),
                    OptionButton(
                      icon: Icons.logout,
                      text: 'Sair',
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                                (Route<dynamic> route) => false,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A192F),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16)
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}

class ProfileBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    var controlPoint = Offset(size.width / 4, size.height - 80);
    var endPoint = Offset(size.width / 1.5, size.height - 40);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    controlPoint = Offset(size.width - (size.width / 5), size.height);
    endPoint = Offset(size.width, size.height - 120);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
