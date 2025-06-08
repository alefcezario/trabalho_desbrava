import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart'; // Importa a geolocalização

// Modelo para guardar as informações de cada lugar
// <<< ATUALIZADO para incluir a distância >>>
class Place {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final GeoPoint location;
  double distance; // Distância calculada em Km

  Place({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.location,
    this.distance = 0.0,
  });
}

class CategoryPlacesScreen extends StatefulWidget {
  final String categoryName;

  const CategoryPlacesScreen({super.key, required this.categoryName});

  @override
  State<CategoryPlacesScreen> createState() => _CategoryPlacesScreenState();
}

class _CategoryPlacesScreenState extends State<CategoryPlacesScreen> {
  late Future<List<Place>> _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = _fetchAndSortPlacesByCategory();
  }

  // <<< FUNÇÃO ATUALIZADA >>>
  // Agora ela também obtém a localização e calcula a distância
  Future<List<Place>> _fetchAndSortPlacesByCategory() async {
    // 1. Obter a localização do utilizador
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }
    Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // 2. Buscar os lugares no Firestore, filtrando pela categoria
    QuerySnapshot placesSnapshot = await FirebaseFirestore.instance
        .collection('places')
        .where('category', isEqualTo: widget.categoryName)
        .get();

    List<Place> places = [];
    for (var doc in placesSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data.containsKey('location') && data['location'] is GeoPoint) {
        GeoPoint placeLocation = data['location'];

        // 3. Calcula a distância para cada lugar
        double distanceInMeters = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          placeLocation.latitude,
          placeLocation.longitude,
        );

        places.add(Place(
          id: doc.id,
          name: data['name'] ?? 'Nome indisponível',
          category: data['category'] ?? 'Sem categoria',
          imageUrl: data['imageUrl'] ?? '',
          location: placeLocation,
          distance: distanceInMeters / 1000, // Converte para Km
        ));
      }
    }

    // 4. Ordena a lista pela distância (do mais próximo para o mais distante)
    places.sort((a, b) => a.distance.compareTo(b.distance));

    return places;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: const Color(0xFF0A192F),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFFF0F0F0),
        child: FutureBuilder<List<Place>>(
          future: _placesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Nenhum lugar encontrado para "${widget.categoryName}".'));
            }

            List<Place> places = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: places.length,
              itemBuilder: (context, index) {
                // Reutilizamos o mesmo cartão da tela de "Lugares Próximos"
                return PlaceCardWithDistance(place: places[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

// <<< WIDGET ATUALIZADO >>>
// Este é o cartão que mostra todas as informações, incluindo distância.
class PlaceCardWithDistance extends StatelessWidget {
  final Place place;
  const PlaceCardWithDistance({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    IconData travelIcon;
    String formattedTravelTime;

    final walkingTimeMinutes = (place.distance * 12).ceil();

    if (walkingTimeMinutes > 30) {
      travelIcon = Icons.directions_car;
      final carTimeMinutes = (place.distance * 4).ceil();
      if (carTimeMinutes < 60) {
        formattedTravelTime = '$carTimeMinutes min';
      } else {
        final hours = carTimeMinutes ~/ 60;
        final minutes = carTimeMinutes % 60;
        formattedTravelTime = '${hours}h ${minutes > 0 ? '${minutes}min' : ''}';
      }
    } else {
      travelIcon = Icons.directions_walk;
      formattedTravelTime = '$walkingTimeMinutes min';
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            place.imageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 150,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(travelIcon, size: 16, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text('${place.distance.toStringAsFixed(1)} Km', style: const TextStyle(color: Colors.black54)),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time, size: 16, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(formattedTravelTime, style: const TextStyle(color: Colors.black54)),
                        ],
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A192F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Começar'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
