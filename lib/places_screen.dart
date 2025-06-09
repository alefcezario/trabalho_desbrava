import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
// O import 'package:geocoding/geocoding.dart'; foi removido.
import 'package:my_desbrava/widgets/place_card.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  // Variáveis de estado simplificadas
  bool _isLoading = true;
  bool _permissionDenied = false;
  List<Place> _places = [];
  // O TextEditingController foi removido.

  @override
  void initState() {
    super.initState();
    _getUserLocationAndLoadPlaces();
  }

  // Função que tenta obter a localização e carregar os locais
  Future<void> _getUserLocationAndLoadPlaces() async {
    setState(() {
      _isLoading = true;
      _permissionDenied = false; // Reseta o estado de erro ao tentar novamente
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada pelo utilizador.');
        }
      }

      Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await _loadPlaces(userPosition);

    } catch (e) {
      if (mounted) {
        setState(() {
          _permissionDenied = true;
          _isLoading = false;
        });
      }
    }
  }

  // A função _getCoordinatesFromAddress foi removida.

  // A função _loadPlaces permanece a mesma
  Future<void> _loadPlaces(Position userPosition) async {
    QuerySnapshot placesSnapshot = await FirebaseFirestore.instance.collection('places').get();
    List<Place> places = [];

    for (var doc in placesSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('location') && data['location'] is GeoPoint) {
        GeoPoint placeLocation = data['location'];
        double distanceInMeters = Geolocator.distanceBetween(
            userPosition.latitude, userPosition.longitude,
            placeLocation.latitude, placeLocation.longitude
        );

        places.add(Place(
          id: doc.id,
          name: data['name'] ?? 'Nome indisponível',
          category: data['category'] ?? 'Sem categoria',
          imageUrl: data['imageUrl'] ?? '',
          address: data['address'] ?? 'Endereço não informado',
          location: placeLocation,
          distance: distanceInMeters / 1000,
        ));
      }
    }
    places.sort((a, b) => a.distance.compareTo(b.distance));

    if(mounted) {
      setState(() {
        _places = places;
        _isLoading = false;
        _permissionDenied = false;
      });
    }
  }

  // A função _showManualAddressDialog foi removida.

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F0F0),
      child: _buildContent(),
    );
  }

  // Widget que constrói o conteúdo da tela com base no estado
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // UI ATUALIZADA PARA O ESTADO DE PERMISSÃO NEGADA
    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 60, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'Acesso à localização negado',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Para ver os locais mais próximos, precisamos da sua permissão.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 30),
              // Botão único para tentar a permissão novamente
              ElevatedButton(
                onPressed: _getUserLocationAndLoadPlaces,
                child: const Text('Tentar Novamente'),
              )
            ],
          ),
        ),
      );
    }

    if (_places.isEmpty) {
      return const Center(child: Text('Nenhum lugar encontrado.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _places.length,
      itemBuilder: (context, index) {
        return PlaceCard(place: _places[index]);
      },
    );
  }
}
