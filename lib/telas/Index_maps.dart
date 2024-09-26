import 'package:appis_app/assets/components/NavBar.dart';
import 'package:appis_app/service/autenticacaoServico.dart';
import 'package:appis_app/telas/Visualizar_Producoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appis_app/service/apiarioServico.dart';
import 'package:appis_app/models/cadastroApiarios.dart';
import 'package:appis_app/assets/colors/colors.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({Key? key}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  int _selectedIndex = 1;
  LatLng? _selectedLocation;
  List<Marker> _apiarioMarkers = [];
  bool _isLoading = true;
  List<ApiariosModelo> _apiariosList = []; // Armazena a lista de apiários

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop();
  }

  // Navega para a tela de detalhes do apiário
  void _onMarkerTapped(ApiariosModelo apiario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesApiario(apiario),
      ),
    );
  }

  Future<void> _fetchApiarios() async {
    setState(() {
      _isLoading = true;
    });

    ApiarioServico apiarioServico = ApiarioServico();
    try {
      List<ApiariosModelo> apiarios = await apiarioServico.fetchApiarios();
      setState(() {
        _apiariosList = apiarios;
        _apiarioMarkers = apiarios.map((apiario) {
          // Extrai a latitude e longitude da localização
          List<String> coords = apiario.localizacao?.split(',') ?? ['0', '0'];
          double latitude = double.tryParse(coords[0]) ?? 0.0;
          double longitude = double.tryParse(coords[1]) ?? 0.0;

          return Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(latitude, longitude),
            builder: (ctx) => GestureDetector(
              onTap: () => _onMarkerTapped(apiario), // Redireciona para detalhes
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40.0,
              ),
            ),
          );
        }).toList();
      });
    } catch (e) {
      print('Erro ao buscar apiários: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchApiarios();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Mapa de Apiários',
        style: TextStyle(color: Colors.black), // Texto preto
      ),
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(Icons.menu, color: Colors.black), // Ícone do menu em preto
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        },
      ),
      backgroundColor: paletaDeCores.amareloClaro, 
    ),
    drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: paletaDeCores.amareloClaro,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Deslogar'),
            onTap: () {
              AutenticacaoServico().deslogar();
            },
          ),
        ],
      ),
    ),
    backgroundColor: paletaDeCores.fundoApp,
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : FlutterMap(
            options: MapOptions(
              center: LatLng(-15.993525230106863, -47.990546794695035),
              zoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _apiarioMarkers,
              ),
              if (_selectedLocation != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _selectedLocation!,
                      color: Colors.yellow.withOpacity(0.5),
                      borderStrokeWidth: 2,
                      borderColor: Colors.yellow,
                      useRadiusInMeter: true,
                      radius: 1000, // Raio em metros (1 km)
                    ),
                  ],
                ),
            ],
          ),
    bottomNavigationBar: buildBottomNavigationBar(context, _selectedIndex),
  );
}

}

