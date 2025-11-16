// lib/pages/restaurant_deals_page.dart
//  flutter_map: ^7.0.0
//  latlong2: ^0.9.0
//  geolocator: ^12.0.0
//  http: ^1.2.0

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:url_launcher/url_launcher.dart';

class RestaurantDeal {
  final String restaurant;
  final String discountLabel; // ex: "30% OFF"
  final int discountPercent; // ex: 30
  final String description;
  final String imageUrl;
  final String timeLeft;
  final String locationLabel;
  final double rating;
  final String category; // 'organic', 'sustainable', 'surplus'
  final latlng.LatLng coords;
  final String? address;

  final double originalPrice;
  final double discountedPrice;

  const RestaurantDeal({
    required this.restaurant,
    required this.discountLabel,
    required this.discountPercent,
    required this.description,
    required this.imageUrl,
    required this.timeLeft,
    required this.locationLabel,
    required this.rating,
    required this.category,
    required this.coords,
    required this.originalPrice,
    required this.discountedPrice,
    this.address,
  });
}

// internal helper for "What you can get" rows
class _DealOption {
  final String title;
  final String subtitle;
  final double price;

  _DealOption({
    required this.title,
    required this.subtitle,
    required this.price,
  });
}

class RestaurantDealsPage extends StatefulWidget {
  const RestaurantDealsPage({super.key});

  @override
  State<RestaurantDealsPage> createState() => _RestaurantDealsPageState();
}

class _RestaurantDealsPageState extends State<RestaurantDealsPage> {
  // MapTiler key
  static const String _mapTilerKey = 'iTTwv7awaRdGh4JvQkbp';

  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();

  // for scrolling list when tapping a marker
  final Map<String, GlobalKey> _cardKeys = {};

  String _filter = 'all';
  RestaurantDeal? _selectedDeal;

  final List<RestaurantDeal> _deals = [];
  latlng.LatLng? _userLocation;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initLocationAndLoadDeals();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // small helper used everywhere
  bool _containsAny(String src, List<String> keys) {
    return keys.any((k) => src.contains(k));
  }

  // ───────────────── LOCATION + DATA ─────────────────

  Future<void> _initLocationAndLoadDeals() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Location permission denied. Cannot load nearby places.';
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _userLocation = latlng.LatLng(pos.latitude, pos.longitude);

      await _fetchNearbyPlaces(pos.latitude, pos.longitude);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to get location or load places: $e';
      });
    }
  }

  Future<void> _fetchNearbyPlaces(double lat, double lng) async {
    final String overpassQuery = '''
[out:json][timeout:25];
(
  node["amenity"~"restaurant|cafe|fast_food"](around:2000,$lat,$lng);
  way["amenity"~"restaurant|cafe|fast_food"](around:2000,$lat,$lng);
  relation["amenity"~"restaurant|cafe|fast_food"](around:2000,$lat,$lng);

  node["shop"~"supermarket|convenience|bakery|greengrocer|deli|butcher|organic"](around:2000,$lat,$lng);
  way["shop"~"supermarket|convenience|bakery|greengrocer|deli|butcher|organic"](around:2000,$lat,$lng);
  relation["shop"~"supermarket|convenience|bakery|greengrocer|deli|butcher|organic"](around:2000,$lat,$lng);
);
out center 40;
''';

    final uri = Uri.parse('https://overpass-api.de/api/interpreter');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'data': overpassQuery},
    );

    if (response.statusCode != 200) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Overpass API error: HTTP ${response.statusCode}';
      });
      return;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = (data['elements'] as List<dynamic>? ?? []);

    final random = Random();

    const discountLabels = [
      '20% OFF',
      '25% OFF',
      '30% OFF',
      '40% OFF',
      '50% OFF'
    ];
    const timeOptions = [
      '30 minutes',
      '1 hour',
      '2 hours',
      '3 hours',
      '5 hours'
    ];
    const categories = ['organic', 'sustainable', 'surplus'];

    // ── Brand-specific images (approximate real food from those chains) ──
    const Map<String, String> chainImages = {
      "mcdonald's":
      'https://images.unsplash.com/photo-1619881589316-56c7f9e6b587?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'kfc':
      'https://plus.unsplash.com/premium_photo-1683139916670-38113db90cb9?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8a2ZjfGVufDB8fDB8fHww',
      'subway':
      'https://images.unsplash.com/photo-1521390188846-e2a3a97453a0?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'starbucks':
      'https://images.unsplash.com/photo-1504753793650-d4a2b783c15e?w=900&h=600&fit=crop',
      'pizza hut':
      'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=900&h=600&fit=crop',
      'domino\'s':
      'https://images.unsplash.com/photo-1548365328-9daaf8eca8ac?w=900&h=600&fit=crop',
      'lidl':
      'https://images.unsplash.com/photo-1580915411920-8e2959b35f73?w=900&h=600&fit=crop',
      'kaufland':
      'https://images.unsplash.com/photo-1542838132-92c53300491e?w=900&h=600&fit=crop',
      'mega image':
      'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=900&h=600&fit=crop',
      'profi':
      'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8Z3JvY2VyaWVzfGVufDB8fDB8fHww',
      'carrefour':
      'https://images.unsplash.com/photo-1579113800032-c38bd7635818?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'timisoareana':
      'https://plus.unsplash.com/premium_photo-1695658864487-a5a9882c3626?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8YmVlcnxlbnwwfHwwfHx8MA%3D%3D',
      'heineken':
      'https://images.unsplash.com/photo-1541542684-4e5b6e8b21f2?w=900&h=600&fit=crop',
    };

    // ── Category image pools (pizza, burger, cafe, etc.) ──
    const pizzaImages = [
      'https://images.unsplash.com/photo-1548365328-9daaf8eca8ac?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1601924582970-9238bcb495d9?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=900&h=600&fit=crop',
    ];

    const burgerImages = [
      'https://images.unsplash.com/photo-1550547660-d9450f859349?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1550317138-10000687a72b?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1508737027454-e6454ef45afd?w=900&h=600&fit=crop',
    ];

    const asianImages = [
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=900&h=600&fit=crop',
    ];

    const cafeImages = [
      'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1504753793650-d4a2b783c15e?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1521017432531-fbd92d768814?w=900&h=600&fit=crop',
    ];

    const kebabImages = [
      'https://images.unsplash.com/photo-1608038509085-7bb9d5c0d52d?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1625944230943-43e7323ac360?w=900&h=600&fit=crop',
    ];

    const bakeryImages = [
      'https://images.unsplash.com/photo-1568254183919-78a4f43a2877?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmFrZXJ5fGVufDB8fDB8fHww',
      'https://images.unsplash.com/photo-1542838132-7a47a8eaf09c?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=900&h=600&fit=crop',
    ];

    const groceryImages = [
      'https://images.unsplash.com/photo-1542838132-7a47a8eaf09c?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1580915411920-8e2959b35f73?w=900&h=600&fit=crop',
    ];

    const produceImages = [
      'https://images.unsplash.com/photo-1511688878353-3a2f5be94cd7?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1524593567613-3cfd152506ac?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=900&h=600&fit=crop',
    ];

    const beerImages = [
      'https://images.unsplash.com/photo-1535958636474-b021ee887b13?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://plus.unsplash.com/premium_photo-1695658864487-a5a9882c3626?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8YmVlcnxlbnwwfHwwfHx8MA%3D%3D',
    ];

    const defaultImages = [
      'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=900&h=600&fit=crop',
      'https://images.unsplash.com/photo-1604908176997-125188ad53aa?w=900&h=600&fit=crop',
    ];

    List<RestaurantDeal> loaded = [];

    for (final item in elements) {
      final m = item as Map<String, dynamic>;
      final tags = m['tags'] as Map<String, dynamic>?;

      if (tags == null) continue;

      final name =
      (tags['name'] as String? ?? tags['brand'] as String? ?? 'Unnamed place')
          .trim();

      double? rLat;
      double? rLng;

      if (m['lat'] != null && m['lon'] != null) {
        rLat = (m['lat'] as num).toDouble();
        rLng = (m['lon'] as num).toDouble();
      } else if (m['center'] != null) {
        final c = m['center'] as Map<String, dynamic>;
        rLat = (c['lat'] as num).toDouble();
        rLng = (c['lon'] as num).toDouble();
      }

      if (rLat == null || rLng == null) continue;

      final cuisine = (tags['cuisine'] as String? ?? '').toLowerCase();
      final amenity = (tags['amenity'] as String? ?? '').toLowerCase();
      final shop = (tags['shop'] as String? ?? '').toLowerCase();
      final lowerName = name.toLowerCase();
      final brandTag = (tags['brand'] as String? ?? '').toLowerCase();
      final combinedName = '$lowerName $brandTag';

      // address
      final street = tags['addr:street'] as String?;
      final house = tags['addr:housenumber'] as String?;
      final city = tags['addr:city'] as String?;
      final postcode = tags['addr:postcode'] as String?;

      String? address;
      final buffer = StringBuffer();
      if (street != null) {
        buffer.write(street);
        if (house != null) buffer.write(' $house');
      }
      if (city != null) {
        if (buffer.isNotEmpty) buffer.write(', ');
        buffer.write(city);
      }
      if (postcode != null) {
        if (buffer.isNotEmpty) buffer.write(' ');
        buffer.write(postcode);
      }
      if (buffer.isNotEmpty) {
        address = buffer.toString();
      }

      // type label
      String typeLabel;
      if (shop.isNotEmpty) {
        typeLabel = shop;
      } else if (amenity.isNotEmpty) {
        typeLabel = amenity;
      } else {
        typeLabel = 'place';
      }

      // Brand-matched description
      String description;
      if (_containsAny(lowerName, ["mcdonald's", 'mc'])) {
        description =
        'Big Mac or cheeseburger menu saved from going to waste at a lower price.';
      } else if (_containsAny(lowerName, ['kfc'])) {
        description =
        'Chicken bucket, strips or wings close to closing time, sold as surplus combo.';
      } else if (_containsAny(lowerName, ['pizza hut', 'domino', 'pizza']) ||
          _containsAny(cuisine, ['pizza', 'italian'])) {
        description =
        'Surplus pizza slices and boxes with toppings still fresh, discounted before closing.';
      } else if (_containsAny(
          lowerName, ['lidl', 'kaufland', 'mega image', 'profi', 'penny', 'carrefour']) ||
          _containsAny(shop, ['supermarket', 'convenience'])) {
        description =
        'Grocery deal box with leftover cucumbers, yoghurt, salad mix and other near-date items.';
      } else if (_containsAny(lowerName, ['starbucks'])) {
        description =
        'End-of-day pastries and sandwiches with a coffee, sold together as an anti-waste bundle.';
      } else if (_containsAny(lowerName, ['cafe', 'coffee']) ||
          amenity.contains('cafe')) {
        description =
        'Pastries, sandwiches and cakes that stayed in the display, packaged in a surprise box.';
      } else if (_containsAny(lowerName, ['bakery', 'patis', 'brutar']) ||
          shop.contains('bakery')) {
        description =
        'Bread, pastries and croissants from today, sold cheaper as a leftover pack.';
      } else if (_containsAny(lowerName, ['kebab', 'doner', 'shaorma']) ||
          _containsAny(cuisine, ['kebab', 'doner'])) {
        description =
        'Kebab or shawarma portions using remaining grilled meat and veggies before closing.';
      } else if (_containsAny(lowerName, ['sushi', 'wok', 'ramen']) ||
          _containsAny(
              cuisine, ['sushi', 'japanese', 'asian', 'chinese', 'thai'])) {
        description =
        'Sushi boxes or wok portions that must be eaten today, offered at a reduced price.';
      } else if (_containsAny(lowerName, ['organic', 'bio']) ||
          _containsAny(shop, ['greengrocer', 'organic', 'farm'])) {
        description =
        'Box of slightly soft but perfectly edible organic fruits and vegetables.';
      } else if (_containsAny(
          lowerName, ['beer', 'bere', 'pub', 'brewery', 'fabrica de bere'])) {
        description =
        'Beer tasting deal with snacks, using opened kegs that must be finished today.';
      } else if (shop.isNotEmpty) {
        description = 'A local $shop with surplus and near-expiry grocery deals.';
      } else if (cuisine.isNotEmpty) {
        description = 'A $typeLabel with $cuisine dishes and surplus combos.';
      } else {
        description = 'A local $typeLabel with at least one anti-waste food offer.';
      }

      // ── choose pool ──
      List<String> imagePool = defaultImages;

      if (_containsAny(lowerName, ['pizza', 'pizzeria']) ||
          _containsAny(cuisine, ['pizza', 'italian'])) {
        imagePool = pizzaImages;
      } else if (_containsAny(lowerName, ['burger', 'mc', 'kfc', 'king']) ||
          _containsAny(cuisine, ['burger', 'american']) ||
          amenity.contains('fast_food')) {
        imagePool = burgerImages;
      } else if (_containsAny(lowerName, ['sushi', 'ramen', 'wok']) ||
          _containsAny(
              cuisine, ['sushi', 'japanese', 'asian', 'chinese', 'thai'])) {
        imagePool = asianImages;
      } else if (_containsAny(lowerName, ['kebab', 'doner', 'shaorma']) ||
          _containsAny(cuisine, ['kebab', 'doner'])) {
        imagePool = kebabImages;
      } else if (_containsAny(lowerName, ['cafe', 'coffee']) ||
          amenity.contains('cafe') ||
          _containsAny(cuisine, ['coffee', 'cafe'])) {
        imagePool = cafeImages;
      } else if (_containsAny(lowerName, ['bakery', 'patis', 'brutar']) ||
          shop.contains('bakery')) {
        imagePool = bakeryImages;
      } else if (_containsAny(lowerName, ['lidl', 'kaufland', 'mega', 'profi']) ||
          _containsAny(lowerName, ['supermarket', 'market']) ||
          _containsAny(shop, ['supermarket', 'convenience'])) {
        imagePool = groceryImages;
      } else if (_containsAny(lowerName, ['bio', 'organic']) ||
          _containsAny(shop, ['greengrocer', 'organic', 'farm'])) {
        imagePool = produceImages;
      } else if (_containsAny(
          lowerName, ['beer', 'bere', 'pub', 'brewery', 'fabrica de bere'])) {
        imagePool = beerImages;
      }

      // brand image first
      String? chainImageUrl;
      chainImages.forEach((key, url) {
        if (combinedName.contains(key)) {
          chainImageUrl = url;
        }
      });

      final String imageUrl =
          chainImageUrl ?? imagePool[random.nextInt(imagePool.length)];

      final rating = 3.5 + random.nextDouble() * 1.5;

      final discountLabel =
      discountLabels[random.nextInt(discountLabels.length)];
      final discountPercent =
          int.tryParse(discountLabel.split('%').first) ?? 20;

      final timeLeft = timeOptions[random.nextInt(timeOptions.length)];
      final category = categories[random.nextInt(categories.length)];

      // prețuri demo (lei)
      final originalPrice = 20 + random.nextInt(60); // 20–79
      final discountedPrice =
          originalPrice * (1 - discountPercent.toDouble() / 100);

      String distanceLabel = 'Nearby';
      if (_userLocation != null) {
        final dist = const latlng.Distance().as(
          latlng.LengthUnit.Kilometer,
          _userLocation!,
          latlng.LatLng(rLat, rLng),
        );
        distanceLabel = '${dist.toStringAsFixed(1)} km away';
      }

      loaded.add(
        RestaurantDeal(
          restaurant: name,
          discountLabel: discountLabel,
          discountPercent: discountPercent,
          description: description,
          imageUrl: imageUrl,
          timeLeft: timeLeft,
          locationLabel: distanceLabel,
          rating: rating,
          category: category,
          coords: latlng.LatLng(rLat, rLng),
          originalPrice: originalPrice.toDouble(),
          discountedPrice: discountedPrice,
          address: address,
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _deals
        ..clear()
        ..addAll(loaded);
      _loading = false;
      _error = null;
    });
  }

  // ─────────────── HELPERS ───────────────

  List<RestaurantDeal> get _filteredDeals {
    if (_filter == 'all') return _deals;
    return _deals.where((d) => d.category == _filter).toList();
  }

  latlng.LatLng get _mapCenter {
    if (_userLocation != null) return _userLocation!;
    final deals = _filteredDeals;
    if (deals.isEmpty) return latlng.LatLng(0, 0);
    double lat = 0, lng = 0;
    for (final d in deals) {
      lat += d.coords.latitude;
      lng += d.coords.longitude;
    }
    return latlng.LatLng(lat / deals.length, lng / deals.length);
  }

  // LIST → MAP (card / Get deal tap)
  void _focusOnDealFromList(RestaurantDeal deal) {
    setState(() => _selectedDeal = deal);
    _mapController.move(deal.coords, 16);

    // scroll până la hartă (sus)
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // MAP → LIST (marker tap)
  void _focusOnDealFromMarker(RestaurantDeal deal) {
    setState(() => _selectedDeal = deal);
    _mapController.move(deal.coords, 16);

    final key = _cardKeys[deal.restaurant];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        alignment: 0.1,
      );
    }
  }

  Future<void> _openInMaps(RestaurantDeal deal) async {
    final lat = deal.coords.latitude;
    final lng = deal.coords.longitude;
    final label = Uri.encodeComponent(deal.restaurant);

    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');
    final webUri =
    Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps app')),
      );
    }
  }

  // builds brand-specific deal options for bottom sheet
  List<_DealOption> _getDealOptions(RestaurantDeal deal) {
    final lowerName = deal.restaurant.toLowerCase();
    final p = deal.discountedPrice;

    // McDonald's
    if (_containsAny(lowerName, ["mcdonald's", 'mc'])) {
      return [
        _DealOption(
          title: 'Big Mac rescue menu',
          subtitle:
          'Big Mac, fries and drink close to end of serving time, sold cheaper instead of wasted.',
          price: p,
        ),
        _DealOption(
          title: 'Cheeseburger & fries pack',
          subtitle:
          'Cheeseburgers and fries that were prepared but not sold in time.',
          price: p * 0.8,
        ),
        _DealOption(
          title: 'Mixed burger surprise bag',
          subtitle:
          'Random mix of burgers and sides from the last batch of the shift.',
          price: p * 1.2,
        ),
      ];
    }

    // KFC-style fried chicken
    if (_containsAny(lowerName, ['kfc'])) {
      return [
        _DealOption(
          title: 'Crispy chicken bucket',
          subtitle:
          'Mixed wings, strips and drumsticks that must be eaten today.',
          price: p,
        ),
        _DealOption(
          title: 'Strips & fries combo',
          subtitle: 'Chicken strips with fries packed as an anti-waste menu.',
          price: p * 0.9,
        ),
        _DealOption(
          title: 'Late-night chicken box',
          subtitle:
          'Various chicken pieces left from the last frying batch of the day.',
          price: p * 1.1,
        ),
      ];
    }

    // Pizza chains / pizzerias
    if (_containsAny(lowerName, ['pizza hut', 'domino', 'pizza', 'pizzeria'])) {
      return [
        _DealOption(
          title: 'Leftover pizza slices box',
          subtitle: 'Assorted slices with different toppings from today.',
          price: p,
        ),
        _DealOption(
          title: 'Family pizza rescue',
          subtitle:
          'One big pizza or two medium pizzas that were cancelled or unsold.',
          price: p * 1.4,
        ),
        _DealOption(
          title: 'Cheesy crust snack pack',
          subtitle: 'Crust pieces, garlic bread and dips saved from waste.',
          price: p * 0.8,
        ),
      ];
    }

    // Supermarkets / grocery: Lidl, Kaufland, Mega, Profi, Penny, Carrefour
    if (_containsAny(
        lowerName, ['lidl', 'kaufland', 'mega image', 'profi', 'penny', 'carrefour'])) {
      return [
        _DealOption(
          title: 'Cucumbers & yoghurt box',
          subtitle:
          'Cucumbers, yoghurt and herbs close to their date, perfect for tzatziki or salads.',
          price: p,
        ),
        _DealOption(
          title: 'Near-date veggie mix',
          subtitle:
          'Tomatoes, peppers, salad greens and other veggies that look a bit tired but are still fine.',
          price: p * 0.9,
        ),
        _DealOption(
          title: 'Dairy rescue pack',
          subtitle:
          'Yoghurt, milk and cheeses with short shelf life, ideal for cooking today.',
          price: p * 1.1,
        ),
      ];
    }

    // Coffee chains / Starbucks / cafés
    if (_containsAny(lowerName, ['starbucks']) ||
        _containsAny(lowerName, ['cafe', 'coffee'])) {
      return [
        _DealOption(
          title: 'End-of-day pastry box',
          subtitle:
          'Muffins, croissants and cakes that were in the display all day.',
          price: p,
        ),
        _DealOption(
          title: 'Sandwich & coffee combo',
          subtitle:
          'Leftover sandwiches + a coffee drink at a reduced price.',
          price: p * 1.2,
        ),
        _DealOption(
          title: 'Sweet surprise bag',
          subtitle:
          'Random sweet pastries that would otherwise be thrown away.',
          price: p * 0.8,
        ),
      ];
    }

    // Bakery / patisserie
    if (_containsAny(lowerName, ['bakery', 'patis', 'brutar'])) {
      return [
        _DealOption(
          title: 'Bread & rolls bundle',
          subtitle:
          'Loaves and buns from today, still fresh but not sold by closing time.',
          price: p,
        ),
        _DealOption(
          title: 'Pastry rescue box',
          subtitle:
          'Croissants, merdenele, sweet rolls and pies left on the shelves.',
          price: p * 1.1,
        ),
        _DealOption(
          title: 'Breakfast for tomorrow',
          subtitle: 'Mix of buns and pastries you can reheat next morning.',
          price: p * 0.9,
        ),
      ];
    }

    // Kebab / shaorma
    if (_containsAny(lowerName, ['kebab', 'doner', 'shaorma'])) {
      return [
        _DealOption(
          title: 'Kebab wrap surplus',
          subtitle:
          'Wraps filled with remaining meat, salad and sauces from the last rotation.',
          price: p,
        ),
        _DealOption(
          title: 'Mixed meat box',
          subtitle:
          'Tray with sliced doner meat, fries and veggies, great for sharing.',
          price: p * 1.3,
        ),
        _DealOption(
          title: 'Late-night shawarma',
          subtitle: 'One big shawarma using the last cuts from the spit.',
          price: p * 1.0,
        ),
      ];
    }

    // Sushi / Asian / wok
    if (_containsAny(lowerName,
        ['sushi', 'wok', 'ramen', 'thai', 'asian', 'chinese']) ||
        deal.description.toLowerCase().contains('sushi')) {
      return [
        _DealOption(
          title: 'Sushi rescue box',
          subtitle:
          'Mixed sushi rolls prepared for the day, still safe and tasty.',
          price: p,
        ),
        _DealOption(
          title: 'Wok & rice combo',
          subtitle:
          'Leftover stir-fry with rice and veggies, reheated and ready.',
          price: p * 0.9,
        ),
        _DealOption(
          title: 'Noodle surprise pack',
          subtitle: 'Various noodle portions combined into one deal.',
          price: p * 1.1,
        ),
      ];
    }

    // Organic / farm / bio
    if (_containsAny(lowerName, ['bio', 'organic']) ||
        deal.category == 'organic') {
      return [
        _DealOption(
          title: 'Organic veggie box',
          subtitle:
          'Carrots, potatoes, onions and other organic veggies that are a bit soft but perfect for soup.',
          price: p,
        ),
        _DealOption(
          title: 'Fruit salvage basket',
          subtitle: 'Apples, pears and other fruits with small bruises.',
          price: p * 0.9,
        ),
        _DealOption(
          title: 'Herbs & greens mix',
          subtitle: 'Herbs and leafy greens that need to be used today.',
          price: p * 0.8,
        ),
      ];
    }

    // Beer / pub
    if (_containsAny(
        lowerName, ['beer', 'bere', 'pub', 'brewery', 'fabrica de bere'])) {
      return [
        _DealOption(
          title: 'Draft beer rescue',
          subtitle: 'Pints from opened kegs that must be finished tonight.',
          price: p,
        ),
        _DealOption(
          title: 'Beer & snacks combo',
          subtitle:
          'Beer plus pretzels, chips or nachos that are close to expiry.',
          price: p * 1.2,
        ),
        _DealOption(
          title: 'Tasting flight',
          subtitle: 'Small glasses of several beers you can sample.',
          price: p * 0.9,
        ),
      ];
    }

    // Fallback generic
    return [
      _DealOption(
        title: 'Meal combo',
        subtitle:
        'Main dish, side and drink with the discount applied instead of wasting it.',
        price: p,
      ),
      _DealOption(
        title: 'Takeaway box',
        subtitle: 'Perfectly good surplus food packed for takeaway.',
        price: p * 0.8,
      ),
      _DealOption(
        title: 'Sharing platter',
        subtitle: 'Ideal to share with friends or family.',
        price: p * 1.2,
      ),
    ];
  }

  void _showDealDetails(RestaurantDeal deal) {
    _focusOnDealFromList(deal); // centrează + scroll la hartă

    final options = _getDealOptions(deal);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            deal.imageUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 120,
                                  height: 120,
                                  color: const Color(0xFFE5E7EB),
                                  child: const Icon(
                                    Icons.restaurant,
                                    color: Color(0xFF9CA3AF),
                                    size: 32,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deal.restaurant,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF022C22),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (deal.address != null)
                                Row(
                                  children: [
                                    const Icon(Icons.place,
                                        size: 16, color: Color(0xFF16A34A)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        deal.address!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF4B5563),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 18, color: Color(0xFFFBBF24)),
                                  const SizedBox(width: 4),
                                  Text(
                                    deal.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF022C22),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.location_on,
                                      size: 16, color: Color(0xFF6B7280)),
                                  const SizedBox(width: 4),
                                  Text(
                                    deal.locationLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 16, color: Color(0xFF6B7280)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Ends in ${deal.timeLeft}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // price section
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Today’s deal',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF047857),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${deal.discountPercent}% discount',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${deal.originalPrice.toStringAsFixed(2)} lei',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9CA3AF),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              Text(
                                '${deal.discountedPrice.toStringAsFixed(2)} lei',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'What you can get',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF022C22),
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (int i = 0; i < options.length; i++) ...[
                      _buildMenuRow(
                        title: options[i].title,
                        subtitle: options[i].subtitle,
                        price: options[i].price,
                      ),
                      if (i != options.length - 1) const SizedBox(height: 6),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openInMaps(deal),
                            icon: const Icon(Icons.map_rounded),
                            label: const Text('Open in Maps'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF16A34A),
                              side:
                              const BorderSide(color: Color(0xFF16A34A)),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openInMaps(deal),
                            icon: const Icon(Icons.shopping_bag_outlined),
                            label: const Text('Go to location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuRow({
    required String title,
    required String subtitle,
    required double price,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: Color(0xFF0369A1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF022C22),
                ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${price.toStringAsFixed(1)} lei',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF16A34A),
          ),
        ),
      ],
    );
  }

  // ─────────────── UI MAIN ───────────────

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredDeals;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF0FDF4), Color(0xFFFFFFFF), Color(0xFFECFDF3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildFilters(),
                    const SizedBox(height: 16),
                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_error != null)
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      )
                    else ...[
                        const Text(
                          'Nearby deals map',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF064E3B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildMap(filtered),
                        const SizedBox(height: 16),
                        _buildDealsList(filtered),
                      ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF065F46)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Restaurant & Shop Deals',
                style: TextStyle(
                  fontSize: 24, // puțin mai mic pentru ecrane mai înguste
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF022C22),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Fresh food, surplus meals & grocery bargains near you',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('all', 'All Deals'),
          const SizedBox(width: 8),
          _buildFilterChip('organic', 'Organic'),
          const SizedBox(width: 8),
          _buildFilterChip('sustainable', 'Sustainable'),
          const SizedBox(width: 8),
          _buildFilterChip('surplus', 'Surplus'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String id, String label) {
    final bool selected = _filter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _filter = id;
            _selectedDeal = null;
          });
        },
        selectedColor: const Color(0xFF16A34A),
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xFF022C22),
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _buildMap(List<RestaurantDeal> filtered) {
    final screenHeight = MediaQuery.of(context).size.height;
    double mapHeight = screenHeight * 0.28; // ~28% din înălțime
    mapHeight = mapHeight.clamp(220.0, 320.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: mapHeight,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _mapCenter,
                initialZoom: 14,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$_mapTilerKey',
                  userAgentPackageName: 'com.unihack.refood',
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ...filtered.map(
                          (deal) => Marker(
                        point: deal.coords,
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _focusOnDealFromMarker(deal),
                          child: Icon(
                            Icons.location_on,
                            color: _selectedDeal?.restaurant == deal.restaurant
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF15803D),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_selectedDeal != null && _selectedDeal!.address != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.place,
                        size: 16,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Text(
                          _selectedDeal!.address!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF022C22),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealsList(List<RestaurantDeal> filtered) {
    final width = MediaQuery.of(context).size.width;
    final bool isTablet = width >= 700;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 1,
        childAspectRatio: isTablet ? 3.2 : 2.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final deal = filtered[index];
        final isSelected = _selectedDeal?.restaurant == deal.restaurant;

        _cardKeys.putIfAbsent(deal.restaurant, () => GlobalKey());
        final cardKey = _cardKeys[deal.restaurant]!;

        return _buildDealCard(deal, isSelected, cardKey);
      },
    );
  }

  Widget _buildDealCard(
      RestaurantDeal deal, bool selected, GlobalKey cardKey) {
    return InkWell(
      key: cardKey,
      onTap: () => _focusOnDealFromList(deal),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;

          final border = Border.all(
            color: selected ? const Color(0xFF22C55E) : Colors.transparent,
            width: 1.5,
          );
          final boxShadow = [
            BoxShadow(
              color: selected
                  ? const Color(0xFF22C55E).withOpacity(0.35)
                  : Colors.black.withOpacity(0.05),
              blurRadius: selected ? 18 : 10,
              offset: const Offset(0, 6),
            ),
          ];

          // Layout vertical pentru ecrane foarte înguste (mai mic decât S20 FE)
          if (isNarrow) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: border,
                boxShadow: boxShadow,
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: Image.network(
                        deal.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              color: const Color(0xFFE5E7EB),
                              child: const Center(
                                child: Icon(
                                  Icons.restaurant,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: _buildCardContent(deal),
                  ),
                ],
              ),
            );
          } else {
            // Layout pe rând pentru telefoane gen Samsung S20 FE și mai mari
            final imageWidth =
            min(190.0, constraints.maxWidth * 0.38); // adaptiv

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: border,
                boxShadow: boxShadow,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(20),
                    ),
                    child: SizedBox(
                      width: imageWidth,
                      height: double.infinity,
                      child: Image.network(
                        deal.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFE5E7EB),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: _buildCardContent(deal),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildCardContent(RestaurantDeal deal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // discount + rating
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_offer,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    deal.discountLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: Color(0xFFFCD34D),
                ),
                const SizedBox(width: 4),
                Text(
                  deal.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF022C22),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          deal.restaurant,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF022C22),
          ),
        ),
        if (deal.address != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.place,
                size: 14,
                color: Color(0xFF16A34A),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  deal.address!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        Text(
          deal.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            const Icon(
              Icons.access_time,
              size: 14,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 4),
            Text(
              'Ends in ${deal.timeLeft}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 14,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 4),
            Text(
              deal.locationLabel,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showDealDetails(deal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: const Text('Get deal'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _openInMaps(deal),
                style: OutlinedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10),
                  foregroundColor: const Color(0xFF16A34A),
                  side: const BorderSide(
                    color: Color(0xFF16A34A),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text('Open in Maps'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
