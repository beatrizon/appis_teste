import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const MapScreen({Key? key, required this.onLocationSelected})
      : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    _mapController.move(
        _currentLocation!, 15); // Move o mapa para a localização atual
  }

  void _onMapTap(LatLng location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deseja inserir neste local?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Não', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onLocationSelected(location);
                Navigator.of(context).pop(); // Fecha o mapa
              },
              child: const Text('Sim', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Selecione um Local',
          style: TextStyle(color: Colors.black), // Cor do texto da AppBar
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black), // Cor do ícone "x"
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.amber[800], // Cor da AppBar
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentLocation,
                zoom: 15.0,
                onTap: (tapPosition, point) => _onMapTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        builder: (ctx) =>
                            const Icon(Icons.location_on, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
