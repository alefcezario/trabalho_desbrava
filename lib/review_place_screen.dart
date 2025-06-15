import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_desbrava/widgets/place_card.dart'; // Reutiliza a classe Place
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewPlaceScreen extends StatefulWidget {
  final Place place;

  const ReviewPlaceScreen({super.key, required this.place});

  @override
  State<ReviewPlaceScreen> createState() => _ReviewPlaceScreenState();
}

class _ReviewPlaceScreenState extends State<ReviewPlaceScreen> {
  // Variáveis para guardar as avaliações
  double _limpezaRating = 3.0;
  double _conservacaoRating = 3.0;
  double _segurancaRating = 3.0;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isAnonymous = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para avaliar.'), backgroundColor: Colors.red),
      );
      setState(() { _isLoading = false; });
      return;
    }

    try {
      // Busca os dados do perfil do utilizador no Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String userName = 'Anônimo';
      String? userPhotoUrl;

      if (userDoc.exists) {
        userName = _isAnonymous ? 'Anônimo' : userDoc.get('name') ?? 'Anônimo';
        userPhotoUrl = _isAnonymous ? null : userDoc.get('photoUrl');
      }

      // Adiciona a avaliação com os dados corretos
      await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.place.id)
          .collection('reviews')
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'userName': userName,
        'userPhotoUrl': userPhotoUrl,
        'limpeza': _limpezaRating,
        'conservacao': _conservacaoRating,
        'seguranca': _segurancaRating,
        'comment': _commentController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avaliação enviada com sucesso! Obrigado.')),
        );
        // <<< ATUALIZAÇÃO AQUI >>>
        // Retorna 'true' para a tela anterior, a avisar que a avaliação foi enviada.
        Navigator.of(context).pop(true);
      }

    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar avaliação: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE7DC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  widget.place.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.place.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: Colors.grey.shade200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text('Avaliação', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      RatingItem(
                        title: 'Limpeza',
                        onRatingUpdate: (rating) => setState(() => _limpezaRating = rating),
                      ),
                      RatingItem(
                        title: 'Conservação',
                        onRatingUpdate: (rating) => setState(() => _conservacaoRating = rating),
                      ),
                      RatingItem(
                        title: 'Segurança',
                        onRatingUpdate: (rating) => setState(() => _segurancaRating = rating),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Digite sua avaliação sobre o lugar aqui',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, escreva um comentário.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              CheckboxListTile(
                title: const Text("Publicar como anônimo"),
                value: _isAnonymous,
                onChanged: (newValue) {
                  setState(() {
                    _isAnonymous = newValue ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitReview,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Enviar'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para cada linha de estrelas
class RatingItem extends StatelessWidget {
  final String title;
  final ValueChanged<double> onRatingUpdate;

  const RatingItem({
    super.key,
    required this.title,
    required this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        RatingBar.builder(
          initialRating: 3,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: onRatingUpdate,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
