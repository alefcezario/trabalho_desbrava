import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_desbrava/widgets/place_card.dart'; // Reutiliza a classe Place
import 'package:url_launcher/url_launcher.dart';

class RouteSuggestionScreen extends StatefulWidget {
  final Place place;

  const RouteSuggestionScreen({super.key, required this.place});

  @override
  State<RouteSuggestionScreen> createState() => _RouteSuggestionScreenState();
}

class _RouteSuggestionScreenState extends State<RouteSuggestionScreen> {
  late GoogleMapController _mapController;

  // <<< REMOÇÃO DA LÓGICA DE GEOCODIFICAÇÃO >>>
  // Não precisamos mais de descobrir o endereço, ele já vem no objeto 'place'.

  void _launchGoogleMaps() async {
    final lat = widget.place.location.latitude;
    final lng = widget.place.location.longitude;
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Não foi possível abrir o Google Maps.');
    }
  }

  String _getTravelInfo() {
    final walkingTimeMinutes = (widget.place.distance * 12).ceil();
    if (walkingTimeMinutes > 30) {
      final carTimeMinutes = (widget.place.distance * 4).ceil();
      if (carTimeMinutes < 60) {
        return '$carTimeMinutes min de carro';
      } else {
        final hours = carTimeMinutes ~/ 60;
        final minutes = carTimeMinutes % 60;
        return '${hours}h ${minutes > 0 ? '${minutes}min' : ''} de carro';
      }
    }
    return '$walkingTimeMinutes min a pé';
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0A192F);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rota Sugerida'),
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.place.location.latitude, widget.place.location.longitude),
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(widget.place.id),
                  position: LatLng(widget.place.location.latitude, widget.place.location.longitude),
                ),
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              width: double.infinity,
              color: const Color(0xFFF0F0F0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // <<< ATUALIZADO PARA USAR O NOVO CAMPO >>>
                  InfoRow(icon: Icons.location_on, text: widget.place.address),
                  const SizedBox(height: 16),
                  InfoRow(icon: Icons.directions_walk, text: '${widget.place.distance.toStringAsFixed(1)} Km'),
                  const SizedBox(height: 16),
                  InfoRow(icon: Icons.access_time, text: _getTravelInfo()),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: darkBlue,
                            side: const BorderSide(color: darkBlue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _launchGoogleMaps,
                          child: const Text('Começar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Center(child: Text('Complete e receba!', style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  const Center(child: Icon(Icons.shield, color: Colors.grey, size: 40)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const InfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0A192F)),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
