import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// <<< MODELO ATUALIZADO >>>
// Agora guarda todas as informações que precisamos para exibir o cartão completo.
class UserReview {
  final String placeId;
  final String placeName;
  final String placeImageUrl;
  final String reviewId;
  final String comment;
  final double limpezaRating;
  final double conservacaoRating;
  final double segurancaRating;
  final Timestamp createdAt;

  UserReview({
    required this.placeId,
    required this.placeName,
    required this.placeImageUrl,
    required this.reviewId,
    required this.comment,
    required this.limpezaRating,
    required this.conservacaoRating,
    required this.segurancaRating,
    required this.createdAt,
  });
}

class MyContributionsScreen extends StatefulWidget {
  const MyContributionsScreen({super.key});

  @override
  State<MyContributionsScreen> createState() => _MyContributionsScreenState();
}

class _MyContributionsScreenState extends State<MyContributionsScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // <<< FUNÇÃO DE BUSCA ATUALIZADA >>>
  // Agora, para cada avaliação, ela também busca os detalhes do local.
  Future<List<UserReview>> _fetchMyReviews() async {
    if (_currentUser == null) return [];

    // 1. Busca todas as avaliações do utilizador
    final reviewsSnapshot = await FirebaseFirestore.instance
        .collectionGroup('reviews')
        .where('userId', isEqualTo: _currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .get();

    List<UserReview> userReviews = [];

    // 2. Para cada avaliação, busca os detalhes do local correspondente
    for (var reviewDoc in reviewsSnapshot.docs) {
      final reviewData = reviewDoc.data();
      final placeId = reviewDoc.reference.parent.parent!.id;

      final placeDoc = await FirebaseFirestore.instance.collection('places').doc(placeId).get();

      if (placeDoc.exists) {
        final placeData = placeDoc.data()!;
        userReviews.add(
          UserReview(
            placeId: placeId,
            reviewId: reviewDoc.id,
            comment: reviewData['comment'] ?? '',
            createdAt: reviewData['createdAt'] ?? Timestamp.now(),
            limpezaRating: (reviewData['limpeza'] as num).toDouble(),
            conservacaoRating: (reviewData['conservacao'] as num).toDouble(),
            segurancaRating: (reviewData['seguranca'] as num).toDouble(),
            placeName: placeData['name'] ?? 'Nome do local indisponível',
            placeImageUrl: placeData['imageUrl'] ?? '',
          ),
        );
      }
    }
    return userReviews;
  }

  // Função para apagar uma avaliação
  Future<void> _deleteReview(String placeId, String reviewId) async {
    final bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Avaliação?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('places')
            .doc(placeId)
            .collection('reviews')
            .doc(reviewId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avaliação excluída com sucesso.')));
          setState(() {}); // Força a reconstrução da lista
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Contribuições'),
        backgroundColor: const Color(0xFF0A192F),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<UserReview>>(
        future: _fetchMyReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar contribuições: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Você ainda não fez nenhuma avaliação.'));
          }

          final reviews = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              // Usa o novo widget de cartão de contribuição
              return ContributionCard(
                review: review,
                onDelete: () => _deleteReview(review.placeId, review.reviewId),
              );
            },
          );
        },
      ),
    );
  }
}


// <<< NOVO WIDGET DE CARTÃO, MUITO MAIS COMPLETO >>>
class ContributionCard extends StatelessWidget {
  final UserReview review;
  final VoidCallback onDelete;

  const ContributionCard({
    super.key,
    required this.review,
    required this.onDelete,
  });

  Widget _buildRatingRow(String title, double rating) {
    return Row(
      children: [
        Expanded(child: Text(title, style: TextStyle(color: Colors.grey.shade700))),
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
          itemCount: 5,
          itemSize: 18.0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          // Imagem e nome do local
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(review.placeImageUrl),
            ),
            title: Text(review.placeName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Sua avaliação em ${review.createdAt.toDate().day}/${review.createdAt.toDate().month}/${review.createdAt.toDate().year}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ),
          const Divider(height: 1),
          // Comentário e estrelas
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (review.comment.isNotEmpty) ...[
                  Text(
                    '"${review.comment}"',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildRatingRow('Limpeza', review.limpezaRating),
                _buildRatingRow('Conservação', review.conservacaoRating),
                _buildRatingRow('Segurança', review.segurancaRating),
              ],
            ),
          )
        ],
      ),
    );
  }
}
