import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_desbrava/place_detail_screen.dart';

// <<< ATUALIZADO >>> Adicionado o campo 'address'
class Place {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String address; // NOVO CAMPO
  final GeoPoint location;
  double distance;

  Place({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.address, // NOVO CAMPO
    required this.location,
    this.distance = 0.0,
  });
}

// O widget do cartão, que já funciona com a lógica de navegação
class PlaceCard extends StatelessWidget {
  final Place place;
  const PlaceCard({super.key, required this.place});

  String _formatTravelTime(double distance) {
    final walkingTimeMinutes = (distance * 12).ceil();
    if (walkingTimeMinutes > 30) {
      final carTimeMinutes = (distance * 4).ceil();
      if (carTimeMinutes < 60) {
        return '$carTimeMinutes min';
      } else {
        final hours = carTimeMinutes ~/ 60;
        final minutes = carTimeMinutes % 60;
        return '${hours}h ${minutes > 0 ? '${minutes}min' : ''}';
      }
    } else {
      return '$walkingTimeMinutes min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedTravelTime = _formatTravelTime(place.distance);
    final IconData travelIcon = (place.distance * 12).ceil() > 30 ? Icons.directions_car : Icons.directions_walk;

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
                          const SizedBox(width: 12),
                          Text(place.category, style: const TextStyle(color: Colors.black54)),
                        ],
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceDetailScreen(place: place),
                      ),
                    );
                  },
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
