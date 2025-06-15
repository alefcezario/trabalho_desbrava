import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_desbrava/report_problem_screen.dart';
import 'package:my_desbrava/review_place_screen.dart';
import 'package:my_desbrava/widgets/place_card.dart';
import 'package:my_desbrava/route_suggestion_screen.dart';

class PlaceReview {
  final String userId;
  final String comment;
  final double limpezaRating;
  final double conservacaoRating;
  final double segurancaRating;
  final Timestamp createdAt;

  PlaceReview({
    required this.userId,
    required this.comment,
    required this.limpezaRating,
    required this.conservacaoRating,
    required this.segurancaRating,
    required this.createdAt,
  });
}


class PlaceDetailScreen extends StatefulWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  String _placeDescription = 'Carregando descrição...';
  bool _isFavorited = false;
  bool _isLoadingFavorite = true;
  late Future<List<PlaceReview>> _reviewsFuture;
  bool _showAllReviews = false;


  @override
  void initState() {
    super.initState();
    _fetchPlaceDetails();
    _reviewsFuture = _fetchReviews();
  }

  void _refreshReviews() {
    setState(() {
      _reviewsFuture = _fetchReviews();
    });
  }

  Future<List<PlaceReview>> _fetchReviews() async {
    final reviewsSnapshot = await FirebaseFirestore.instance
        .collection('places')
        .doc(widget.place.id)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();

    return reviewsSnapshot.docs.map((doc) {
      final data = doc.data();
      return PlaceReview(
        userId: data['userId'] ?? '',
        comment: data['comment'] ?? '',
        limpezaRating: (data['limpeza'] as num).toDouble(),
        conservacaoRating: (data['conservacao'] as num).toDouble(),
        segurancaRating: (data['seguranca'] as num).toDouble(),
        createdAt: data['createdAt'] ?? Timestamp.now(),
      );
    }).toList();
  }


  Future<void> _fetchPlaceDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() { _isLoadingFavorite = false; });
      return;
    }

    final placeDoc = await FirebaseFirestore.instance.collection('places').doc(widget.place.id).get();
    if (placeDoc.exists && placeDoc.data()!.containsKey('description')) {
      if (mounted) {
        setState(() { _placeDescription = placeDoc.data()!['description']; });
      }
    } else {
      if (mounted) {
        setState(() { _placeDescription = 'Nenhuma descrição disponível.'; });
      }
    }

    final favoriteDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('favorites').doc(widget.place.id).get();
    if (mounted) {
      setState(() {
        _isFavorited = favoriteDoc.exists;
        _isLoadingFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() { _isLoadingFavorite = true; });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final favoriteRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('favorites').doc(widget.place.id);
    if (_isFavorited) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({'favoritedAt': Timestamp.now()});
    }
    if (mounted) {
      setState(() {
        _isFavorited = !_isFavorited;
        _isLoadingFavorite = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0A192F);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_placeDescription, style: const TextStyle(fontSize: 16, height: 1.5)),
            ),
            if (widget.place.imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    widget.place.imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.directions_walk, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text('${widget.place.distance.toStringAsFixed(1)} Km', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time, size: 16, color: Colors.black54),
                  Text('${(widget.place.distance * 12).ceil()} min', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(width: 12),
                  Text(widget.place.category, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // <<< BOTÕES DE AÇÃO AGORA VÊM PRIMEIRO >>>
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
              child: Column(
                children: [
                  DetailOptionButton(icon: Icons.location_on_outlined, text: 'Rotas', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RouteSuggestionScreen(place: widget.place)));
                  }),
                  DetailOptionButton(
                      icon: Icons.star_outline,
                      text: 'Avaliar',
                      onTap: () async {
                        final bool? reviewSubmitted = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewPlaceScreen(place: widget.place),
                          ),
                        );
                        if (reviewSubmitted == true) {
                          _refreshReviews();
                        }
                      }
                  ),
                  DetailOptionButton(
                    icon: _isFavorited ? Icons.bookmark : Icons.bookmark_border,
                    text: 'Favoritar local',
                    onTap: _toggleFavorite,
                    isLoading: _isLoadingFavorite,
                    isActive: _isFavorited,
                  ),
                  DetailOptionButton(icon: Icons.report_problem_outlined, text: 'Reportar problemas / vandalismo', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReportProblemScreen(place: widget.place)));
                  }),
                ],
              ),
            ),

            // <<< DIVISÓRIA E SEÇÃO DE AVALIAÇÕES MOVIDAS PARA CÁ >>>
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Divider(height: 2, color: Colors.black26),
            ),
            _buildReviewsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return FutureBuilder<List<PlaceReview>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(child: Text('Seja o primeiro a avaliar este local!')),
          );
        }

        final allReviews = snapshot.data!;
        final reviewsToShow = _showAllReviews ? allReviews : allReviews.take(3).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Avaliações Recentes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...reviewsToShow.map((review) => ReviewCard(review: review)).toList(),
              if (allReviews.length > 3 && !_showAllReviews)
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllReviews = true;
                      });
                    },
                    child: const Text('Ver mais avaliações'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class ReviewCard extends StatefulWidget {
  final PlaceReview review;
  const ReviewCard({super.key, required this.review});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _reviewUserFuture;

  @override
  void initState() {
    super.initState();
    if (widget.review.userId.isNotEmpty) {
      _reviewUserFuture = FirebaseFirestore.instance.collection('users').doc(widget.review.userId).get();
    }
  }

  Widget _buildRatingRow(String title, double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600)),
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
          itemCount: 5,
          itemSize: 18.0,
          direction: Axis.horizontal,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: widget.review.userId.isNotEmpty ? _reviewUserFuture : null,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Row(children: [SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))]);
                }

                String userName = 'Anônimo';
                String? userPhotoUrl;

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  userName = userSnapshot.data!.data()!['name'] ?? 'Anônimo';
                  userPhotoUrl = userSnapshot.data!.data()!['photoUrl'];
                }

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: userPhotoUrl != null ? NetworkImage(userPhotoUrl) : null,
                      child: userPhotoUrl == null ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                );
              },
            ),
            const Divider(height: 20),
            _buildRatingRow('Limpeza', widget.review.limpezaRating),
            _buildRatingRow('Conservação', widget.review.conservacaoRating),
            _buildRatingRow('Segurança', widget.review.segurancaRating),
            const SizedBox(height: 12),
            if (widget.review.comment.isNotEmpty)
              Text(
                widget.review.comment,
                style: TextStyle(color: Colors.grey.shade800, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}


class DetailOptionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isActive;

  const DetailOptionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.amber.shade100 : Colors.white,
          foregroundColor: const Color(0xFF0A192F),
          elevation: 2,
          shadowColor: Colors.black12,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
        ),
        child: isLoading
            ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
            : Row(
          children: [
            Icon(icon, color: isActive ? Colors.amber.shade800 : const Color(0xFF0A192F)),
            const SizedBox(width: 16),
            Text(text, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
