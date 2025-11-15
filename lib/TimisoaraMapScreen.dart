import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TimisoaraMapScreen extends StatefulWidget {
  const TimisoaraMapScreen({super.key});

  @override
  State<TimisoaraMapScreen> createState() => _TimisoaraMapScreenState();
}

class _TimisoaraMapScreenState extends State<TimisoaraMapScreen> {
  static const LatLng _timisoara = LatLng(45.7489, 21.2087);
  static const double _zoomLevel = 13.0;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  void _addMarkers() {
    // Definirea locațiilor preluate din codul tău Kotlin
    final List<Map<String, dynamic>> places = [
      // Lidl
      {"pos": const LatLng(45.7575, 21.2170), "name": "Lidl – Str. Gheorghe Lazăr", "type": "Supermarket"},
      {"pos": const LatLng(45.7390, 21.2000), "name": "Lidl – Str. Budai Deleanu 47", "type": "Supermarket"},
      {"pos": const LatLng(45.7480, 21.2170), "name": "Lidl – Calea Martirilor 1989", "type": "Supermarket"},
      {"pos": const LatLng(45.7465, 21.2040), "name": "Lidl – Str. Ion Ionescu de la Brad", "type": "Supermarket"},
      {"pos": const LatLng(45.7505, 21.2135), "name": "Lidl – Str. Simion Bărnuțiu", "type": "Supermarket"},

      // Kaufland
      {"pos": const LatLng(45.7518, 21.2175), "name": "Kaufland – Str. Gheorghe Lazăr 26", "type": "Supermarket"},
      {"pos": const LatLng(45.7445, 21.2102), "name": "Kaufland – Str. D. Bojinca 4", "type": "Supermarket"},
      {"pos": const LatLng(45.7420, 21.2230), "name": "Kaufland – Str. M. Kogălniceanu 11", "type": "Supermarket"},
      {"pos": const LatLng(45.7430, 21.2060), "name": "Kaufland – Str. Chimiștilor 5-9", "type": "Supermarket"},

      // McDonald’s
      {"pos": const LatLng(45.7533, 21.2228), "name": "McDonald’s – Piața Victoriei", "type": "Fast Food"},
      {"pos": const LatLng(45.7490, 21.2050), "name": "McDonald’s – Stadion / Drive‑Thru", "type": "Fast Food"},
      {"pos": const LatLng(45.7515, 21.2195), "name": "McDonald’s – Shopping City Timișoara", "type": "Fast Food"},

      // KFC
      {"pos": const LatLng(45.7570, 21.2160), "name": "KFC – Shopping City / Calea Șagului", "type": "Fast Food"},
      {"pos": const LatLng(45.7470, 21.2065), "name": "KFC – Centru (Str. Goethe)", "type": "Fast Food"},
      {"pos": const LatLng(45.7415, 21.2250), "name": "KFC – Drive‑Thru Calea Buziașului", "type": "Fast Food"},
      {"pos": const LatLng(45.7585, 21.2100), "name": "KFC – Iulius Mall", "type": "Fast Food"},
    ];

    setState(() {
      for (int i = 0; i < places.length; i++) {
        final place = places[i];
        _markers.add(
          Marker(
            markerId: MarkerId('place_$i'),
            position: place['pos'],
            infoWindow: InfoWindow(
              title: place['name'],
              snippet: place['type'],
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Echivalent cu culoarea ta (albastru deschis)
            onTap: () {
              // Logica de click pe marker (similară cu Log.d din Kotlin)
              debugPrint('Marker clicked: ${place['name']} - ${place['type']}');
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locații ReFood Timișoara'),
        backgroundColor: Colors.teal.shade600,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: const CameraPosition(
          target: _timisoara,
          zoom: _zoomLevel,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          // Aici poți salva controller-ul dacă ai nevoie de el ulterior
        },
      ),
    );
  }
}