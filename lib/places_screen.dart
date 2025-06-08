import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

// Modelo para guardar as informações de cada lugar
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

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  Future<List<Place>>? _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = _fetchAndSortPlaces();
  }

  // Função principal que busca a localização e os lugares
  Future<List<Place>> _fetchAndSortPlaces() async {
    // 1. Obter permissão e localização do utilizador
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // 2. Buscar todos os lugares no Firestore
    QuerySnapshot placesSnapshot = await FirebaseFirestore.instance.collection('places').get();

    List<Place> places = [];
    for (var doc in placesSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Verificamos se o campo 'location' existe e é do tipo GeoPoint antes de o usar.
      if (data.containsKey('location') && data['location'] is GeoPoint) {
        GeoPoint placeLocation = data['location'];

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
          distance: distanceInMeters / 1000, // Converter para Km
        ));
      } else {
        // Se um lugar não tiver localização, avisamos no console e ignoramo-lo.
        print('Documento ${doc.id} ignorado por não ter uma localização válida.');
      }
    }

    // 4. Ordenar a lista por distância
    places.sort((a, b) => a.distance.compareTo(b.distance));

    return places;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            return const Center(child: Text('Nenhum lugar encontrado.'));
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

// Widget para o cartão de cada lugar
class PlaceCard extends StatelessWidget {
  final Place place;
  const PlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    // <<< LÓGICA DE TEMPO E ÍCONE ATUALIZADA >>>
    IconData travelIcon;
    String formattedTravelTime;

    // Simulação de tempo de viagem a pé (ex: 12 minutos por Km)
    final walkingTimeMinutes = (place.distance * 12).ceil();

    if (walkingTimeMinutes > 30) {
      // Se a caminhada for longa, calcula e mostra o tempo de carro
      travelIcon = Icons.directions_car;
      // Simulação de tempo de carro (ex: 4 minutos por Km)
      final carTimeMinutes = (place.distance * 4).ceil();
      if (carTimeMinutes < 60) {
        formattedTravelTime = '$carTimeMinutes min';
      } else {
        final hours = carTimeMinutes ~/ 60;
        final minutes = carTimeMinutes % 60;
        formattedTravelTime = '${hours}h ${minutes > 0 ? '${minutes}min' : ''}';
      }
    } else {
      // Caso contrário, mostra o tempo a pé
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
                          Icon(travelIcon, size: 16, color: Colors.black54), // Ícone dinâmico
                          const SizedBox(width: 4),
                          Text('${place.distance.toStringAsFixed(1)} Km', style: const TextStyle(color: Colors.black54)),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time, size: 16, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(formattedTravelTime, style: const TextStyle(color: Colors.black54)), // Tempo formatado
                          const SizedBox(width: 12),
                          Text(place.category, style: const TextStyle(color: Colors.black54)),
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
