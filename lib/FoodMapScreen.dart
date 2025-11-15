import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'DashboardScreen.dart'; // Navigare înapoi la Dashboard

// Widget personalizat pentru a simula animația de intrare
class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final double delay;

  const AnimatedEntrance({super.key, required this.child, this.delay = 0});

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slide = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

class FoodMapScreen extends StatefulWidget {
  const FoodMapScreen({super.key});

  @override
  State<FoodMapScreen> createState() => _FoodMapScreenState();
}

class _FoodMapScreenState extends State<FoodMapScreen> {
  final MapController _mapController = MapController();
  String _searchQuery = '';
  static const LatLng _timisoaraCenter = LatLng(45.7489, 21.2087);

  // Corecția 1: Am păstrat tiparea corectă a listei (deși nu este strict necesară, ajută Dart)
  final List<Map<String, dynamic>> locations = const [
    // NGOs
    {'name': 'Asociația Banca pentru Alimente', 'type': 'NGO', 'position': LatLng(45.7536, 21.2257), 'address': 'Str. Memorandului 5', 'description': 'Food bank accepting donations for families in need', 'icon': LucideIcons.heart, 'rating': null, 'color': Colors.green},
    {'name': 'Caritas Eparhial Timișoara', 'type': 'NGO', 'position': LatLng(45.7589, 21.2298), 'address': 'Bd. Regele Ferdinand I 2', 'description': 'Catholic charity accepting food for vulnerable people', 'icon': LucideIcons.heart, 'rating': null, 'color': Colors.green},
    {'name': 'Fundația Providența', 'type': 'NGO', 'position': LatLng(45.7421, 21.2147), 'address': 'Str. Ciprian Porumbescu 3', 'description': 'Foundation supporting low-income families', 'icon': LucideIcons.heart, 'rating': null, 'color': Colors.green},
    {'name': 'Crucea Roșie Timișoara', 'type': 'NGO', 'position': LatLng(45.7467, 21.2089), 'address': 'Str. Ghika Budișteanu 10', 'description': 'Red Cross accepting food donations', 'icon': LucideIcons.heart, 'rating': null, 'color': Colors.green},

    // Homeless Shelters
    {'name': 'Casa Ioana - Homeless Shelter', 'type': 'Homeless Shelter', 'position': LatLng(45.7398, 21.2278), 'address': 'Str. Lidia 15', 'description': 'Shelter providing meals for homeless people', 'icon': LucideIcons.home, 'rating': null, 'color': Colors.blue},
    {'name': 'Refugiul Sfântului Francisc', 'type': 'Homeless Shelter', 'position': LatLng(45.7612, 21.2156), 'address': 'Str. Soarelui 8', 'description': 'Day center for homeless with meal service', 'icon': LucideIcons.home, 'rating': null, 'color': Colors.blue},
    {'name': 'Adăpostul Speranței', 'type': 'Homeless Shelter', 'position': LatLng(45.7341, 21.2198), 'address': 'Str. Tudor Vladimirescu 20', 'description': 'Emergency shelter accepting food donations', 'icon': LucideIcons.home, 'rating': null, 'color': Colors.blue},
    {'name': 'Centrul Social Betania', 'type': 'Homeless Shelter', 'position': LatLng(45.7556, 21.2412), 'address': 'Calea Șagului 45', 'description': 'Social center supporting homeless individuals', 'icon': LucideIcons.home, 'rating': null, 'color': Colors.blue},

    // Animal Shelters
    // Corecția 2: 'icon': LucideIcons.pawPrint -> LucideIcons.paw
    {'name': 'Adăpostul de Câini Timișoara', 'type': 'Animal Shelter', 'position': LatLng(45.7289, 21.1987), 'address': 'Str. Mehala 102', 'description': 'Dog shelter accepting suitable food donations', 'icon': LucideIcons.dog, 'rating': null, 'color': Colors.purple},
    {'name': 'Asociația Maidanez', 'type': 'Animal Shelter', 'position': LatLng(45.7667, 21.2534), 'address': 'Str. Circumvalațiunii 12', 'description': 'Animal rescue accepting pet food', 'icon': LucideIcons.dog, 'rating': null, 'color': Colors.purple},
    {'name': 'Suflete Libere - Animal Rescue', 'type': 'Animal Shelter', 'position': LatLng(45.7112, 21.2245), 'address': 'Str. Ghiroda 78', 'description': 'Shelter for dogs and cats', 'icon': LucideIcons.dog, 'rating': null, 'color': Colors.purple},
    {'name': 'Patrocle Animal Shelter', 'type': 'Animal Shelter', 'position': LatLng(45.7734, 21.1923), 'address': 'Str. Fabricii 34', 'description': 'Large animal shelter accepting donations', 'icon': LucideIcons.dog, 'rating': null, 'color': Colors.purple},

    // Top Restaurants in Timișoara
    {'name': 'Locanda del Corso', 'type': 'Restaurant', 'position': LatLng(45.7575, 21.2290), 'address': 'Piața Unirii 6', 'description': 'Italian fine dining with exceptional pasta and wine selection', 'icon': LucideIcons.utensils, 'rating': 4.9, 'cuisine': 'Italian', 'color': Colors.orange},
    {'name': 'Restaurant 1752', 'type': 'Restaurant', 'position': LatLng(45.7562, 21.2281), 'address': 'Str. Alba Iulia 1', 'description': 'Traditional Romanian cuisine in elegant atmosphere', 'icon': LucideIcons.utensils, 'rating': 4.8, 'cuisine': 'Romanian', 'color': Colors.orange},
    {'name': 'Casa Bunicii', 'type': 'Restaurant', 'position': LatLng(45.7534, 21.2248), 'address': 'Str. Eugeniu de Savoya 18', 'description': 'Authentic Romanian home cooking and cozy ambiance', 'icon': LucideIcons.utensils, 'rating': 4.7, 'cuisine': 'Romanian', 'color': Colors.orange},
    {'name': 'Sushi Master', 'type': 'Restaurant', 'position': LatLng(45.7498, 21.2312), 'address': 'Bd. Liviu Rebreanu 120', 'description': 'Fresh sushi and Japanese specialties', 'icon': LucideIcons.utensils, 'rating': 4.6, 'cuisine': 'Japanese', 'color': Colors.orange},
    {'name': 'La Copac', 'type': 'Restaurant', 'position': LatLng(45.7445, 21.2276), 'address': 'Aleea Crizantemelor 3', 'description': 'Garden restaurant with local and international dishes', 'icon': LucideIcons.utensils, 'rating': 4.8, 'cuisine': 'International', 'color': Colors.orange},
    {'name': 'Brasserie Hochmeister', 'type': 'Restaurant', 'position': LatLng(45.7589, 21.2267), 'address': 'Str. Mercy 8', 'description': 'German cuisine and craft beers in historic setting', 'icon': LucideIcons.utensils, 'rating': 4.7, 'cuisine': 'German', 'color': Colors.orange},
    {'name': 'Fior di Panna', 'type': 'Restaurant', 'position': LatLng(45.7587, 21.2302), 'address': 'Piața Libertății 5', 'description': 'Best gelato and Italian desserts in town', 'icon': LucideIcons.utensils, 'rating': 4.9, 'cuisine': 'Italian', 'color': Colors.orange},
    {'name': 'El Torito', 'type': 'Restaurant', 'position': LatLng(45.7456, 21.2198), 'address': 'Bd. Take Ionescu 46', 'description': 'Authentic Mexican food and cocktails', 'icon': LucideIcons.utensils, 'rating': 4.5, 'cuisine': 'Mexican', 'color': Colors.orange},
    {'name': 'Pizza Napoletana', 'type': 'Restaurant', 'position': LatLng(45.7523, 21.2356), 'address': 'Str. Circumvalațiunii 50', 'description': 'Wood-fired authentic Neapolitan pizza', 'icon': LucideIcons.utensils, 'rating': 4.8, 'cuisine': 'Italian', 'color': Colors.orange},
    {'name': 'Corso Wine & Dine', 'type': 'Restaurant', 'position': LatLng(45.7581, 21.2278), 'address': 'Str. Alba Iulia 7', 'description': 'Fine dining with extensive wine list', 'icon': LucideIcons.utensils, 'rating': 4.7, 'cuisine': 'International', 'color': Colors.orange},
    {'name': "Lloyd's Restaurant", 'type': 'Restaurant', 'position': LatLng(45.7612, 21.2289), 'address': 'Str. Mărășești 1-3', 'description': 'Elegant restaurant in historic Lloyd Palace', 'icon': LucideIcons.utensils, 'rating': 4.6, 'cuisine': 'International', 'color': Colors.orange},
    {'name': 'Trattoria al Gallo', 'type': 'Restaurant', 'position': LatLng(45.7467, 21.2267), 'address': 'Str. Lucian Blaga 15', 'description': 'Cozy Italian trattoria with homemade pasta', 'icon': LucideIcons.utensils, 'rating': 4.8, 'cuisine': 'Italian', 'color': Colors.orange},
    {'name': 'Grădina Bulevard', 'type': 'Restaurant', 'position': LatLng(45.7534, 21.2189), 'address': 'Bd. Revoluției 1989 nr. 17', 'description': 'Garden terrace restaurant with diverse menu', 'icon': LucideIcons.utensils, 'rating': 4.5, 'cuisine': 'International', 'color': Colors.orange},
    {'name': 'Bufet Social', 'type': 'Restaurant', 'position': LatLng(45.7598, 21.2312), 'address': 'Str. Popa Șapcă 15', 'description': 'Retro-style restaurant with traditional dishes', 'icon': LucideIcons.utensils, 'rating': 4.6, 'cuisine': 'Romanian', 'color': Colors.orange},
    {'name': 'Kana Asian Kitchen', 'type': 'Restaurant', 'position': LatLng(45.7489, 21.2245), 'address': 'Str. Take Ionescu 74', 'description': 'Pan-Asian cuisine with modern twist', 'icon': LucideIcons.utensils, 'rating': 4.7, 'cuisine': 'Asian', 'color': Colors.orange},
    {'name': 'Terra Verde', 'type': 'Restaurant', 'position': LatLng(45.7556, 21.2398), 'address': 'Calea Șagului 78', 'description': 'Farm-to-table organic dining', 'icon': LucideIcons.utensils, 'rating': 4.6, 'cuisine': 'Organic', 'color': Colors.orange},
    {'name': 'La Nonna', 'type': 'Restaurant', 'position': LatLng(45.7423, 21.2334), 'address': 'Str. Făgărașului 2', 'description': 'Family-style Italian restaurant', 'icon': LucideIcons.utensils, 'rating': 4.7, 'cuisine': 'Italian', 'color': Colors.orange},
    {'name': 'Casa cu Flori', 'type': 'Restaurant', 'position': LatLng(45.7645, 21.2267), 'address': 'Aleea Rozelor 5', 'description': 'Romantic garden restaurant with local cuisine', 'icon': LucideIcons.utensils, 'rating': 4.8, 'cuisine': 'Romanian', 'color': Colors.orange},
    {'name': 'La Bonne Bouche', 'type': 'Restaurant', 'position': LatLng(45.7512, 21.2289), 'address': 'Str. Emanuil Ungureanu 20', 'description': 'French bistro with classic dishes', 'icon': LucideIcons.utensils, 'rating': 4.6, 'cuisine': 'French', 'color': Colors.orange},
    // Corecția 3: Eliminarea cheii 'type' duplicată
    {'name': 'Pescarus', 'type': 'Restaurant', 'position': LatLng(45.7378, 21.2156), 'address': 'Str. Poeta 34', 'description': 'Fresh seafood and fish specialties', 'icon': LucideIcons.utensils, 'rating': 4.7, 'cuisine': 'Seafood', 'color': Colors.orange},
  ];

  List<Map<String, dynamic>> get _filteredLocations {
    if (_searchQuery.isEmpty) return locations;
    final query = _searchQuery.toLowerCase();
    return locations.where((loc) {
      return loc['name'].toString().toLowerCase().contains(query) ||
          loc['type'].toString().toLowerCase().contains(query) ||
          (loc['cuisine'] != null && loc['cuisine'].toString().toLowerCase().contains(query));
    }).toList();
  }

  // Crează un marker personalizat colorat (simulează L.divIcon)
  Marker _buildCustomMarker(Map<String, dynamic> location) {
    return Marker(
      point: location['position'] as LatLng,
      width: 48,
      height: 48,
      child: GestureDetector(
        onTap: () {
          // Deschide PopUp-ul la tap (Flutter Map nu face asta automat ca Leaflet)
          _mapController.move(location['position'] as LatLng, 16);
          _showMarkerPopup(location);
        },
        child: Container(
          decoration: BoxDecoration(
            color: location['color'] as Color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
              )
            ],
          ),
          child: Icon(
            location['icon'] as IconData,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  // Afișează conținutul PopUp-ului într-un Dialog (simulează Leaflet Popup)
  void _showMarkerPopup(Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.all(20),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            gradient: LinearGradient(
              colors: [location['color'] as Color, (location['color'] as Color)],
            ),
          ),
          child: Text(
            location['name'] as String,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location['type'] as String, style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600)),
            if (location['rating'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(LucideIcons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(location['rating'].toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                    if (location['cuisine'] != null)
                      Text(' • ${location['cuisine']}', style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade500)),
                  ],
                ),
              ),
            const Divider(),
            Text(location['address'] as String, style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(location['description'] as String, style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Centrează harta și deschide Popup-ul la tap din listă
  void _handleLocationClick(Map<String, dynamic> location) {
    _mapController.move(location['position'] as LatLng, 16);
    _showMarkerPopup(location);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        // Culorile din React: from-red-50 via-white to-orange-50
        colors: [Colors.red.shade50, Colors.white, Colors.orange.shade50],
      ),
    );

    return Scaffold(
      body: Container(
        decoration: backgroundGradient,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header și Buton Back
                    _buildHeader(context),
                    const SizedBox(height: 16),

                    // Search Bar
                    _buildSearchBar(),
                    const SizedBox(height: 16),

                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isLarge = constraints.maxWidth > 800;
                          return Flex(
                            direction: isLarge ? Axis.horizontal : Axis.vertical,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Map Container
                              Expanded(
                                flex: isLarge ? 2 : 1,
                                child: _buildMapContainer(constraints.maxHeight),
                              ),
                              if (isLarge) const SizedBox(width: 16),

                              // Location List
                              Expanded(
                                flex: isLarge ? 1 : 1,
                                child: _buildLocationList(isLarge),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 24),
          onPressed: () {
            Navigator.pop(context); // Navigare înapoi la Dashboard
          },
          color: Colors.blueGrey.shade700,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Food Map - Timișoara',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
            Text('Find donation centers, shelters, and top restaurants in Timișoara',
                style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600)),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search for restaurants, NGOs, shelters...',
                  prefixIcon: Icon(LucideIcons.search, color: Colors.blueGrey.shade400),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.navigation, size: 20),
              label: const Text('Timișoara'),
              onPressed: () {
                _mapController.move(_timisoaraCenter, 13);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600, // from-red-600 to-orange-600
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapContainer(double maxHeight) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: maxHeight, // Se întinde pe toată înălțimea disponibilă
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _timisoaraCenter,
            initialZoom: 13.0,
            onTap: (_, __) {
              // Poate adăuga logica de închidere a popup-urilor dacă ar fi native
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.refood_ai',
            ),
            MarkerLayer(
              markers: _filteredLocations.map((loc) => _buildCustomMarker(loc)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationList(bool isLarge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isLarge ? 0 : 16.0, bottom: 8.0),
          child: Text('All Locations (${_filteredLocations.length})',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredLocations.length,
            itemBuilder: (context, index) {
              final location = _filteredLocations[index];
              final color = location['color'] as Color;

              return AnimatedEntrance(
                delay: index * 0.02,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _handleLocationClick(location),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(colors: [color, color]),
                              ),
                              child: Icon(location['icon'] as IconData, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(location['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                                  Row(
                                    children: [
                                      Text(location['type'] as String, style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade600)),
                                      if (location['rating'] != null)
                                        Row(
                                          children: [
                                            const Text(' • ', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                                            const Icon(LucideIcons.star, size: 12, color: Colors.amber),
                                            Text(location['rating'].toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                    ],
                                  ),
                                  Text(location['address'] as String, style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade500)),
                                  const SizedBox(height: 4),
                                  Text(location['description'] as String, style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}