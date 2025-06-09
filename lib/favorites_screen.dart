import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_desbrava/widgets/place_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Place>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _fetchFavoritePlaces();
  }

  // Função para buscar e processar os lugares favoritos
  Future<List<Place>> _fetchFavoritePlaces() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    // 1. Obter a localização atual do utilizador para calcular as distâncias
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }
    Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // 2. Buscar os IDs dos lugares favoritados
    final favoritesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    if (favoritesSnapshot.docs.isEmpty) {
      return [];
    }

    List<Future<DocumentSnapshot>> placeFutures = [];

    for (var favoriteDoc in favoritesSnapshot.docs) {
      placeFutures.add(
          FirebaseFirestore.instance.collection('places').doc(favoriteDoc.id).get()
      );
    }

    // 3. Executa todas as buscas de lugares em paralelo
    final placeDocs = await Future.wait(placeFutures);

    // 4. Mapeia os documentos para objetos Place e calcula a distância
    List<Place> favoritePlaces = [];
    for (var doc in placeDocs) {
      if(doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('location') && data['location'] is GeoPoint) {
          GeoPoint placeLocation = data['location'];
          double distanceInMeters = Geolocator.distanceBetween(
              userPosition.latitude, userPosition.longitude,
              placeLocation.latitude, placeLocation.longitude
          );

          // <<< ATUALIZADO AQUI >>>
          // Adiciona o campo 'address' ao criar o objeto Place
          favoritePlaces.add(Place(
            id: doc.id,
            name: data['name'] ?? 'Nome indisponível',
            category: data['category'] ?? 'Sem categoria',
            imageUrl: data['imageUrl'] ?? '',
            address: data['address'] ?? 'Endereço não informado', // Adicionado
            location: placeLocation,
            distance: distanceInMeters / 1000,
          ));
        }
      }
    }

    return favoritePlaces;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F0F0),
      child: FutureBuilder<List<Place>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar favoritos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Você ainda não favoritou nenhum local.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          List<Place> places = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: places.length,
            itemBuilder: (context, index) {
              return PlaceCard(place: places[index]);
            },
          );
        },
      ),
    );
  }
}
