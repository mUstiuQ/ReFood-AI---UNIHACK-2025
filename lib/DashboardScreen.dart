import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'ImageDetectionPage.dart';
import 'FoodMapScreen.dart';
import 'SavingsCalculatorScreen.dart';
import 'FoodSaverGameScreen.dart';
import 'DonateFood.dart';

// Importă celelalte pagini necesare (asigură-te că aceste căi sunt corecte)
import 'NewStartPage.dart';
import 'chatbot_screen.dart';
// import   'TimisoaraMapScreen.dart';// Dacă ai implementat harta

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  // Animatie pentru Header (simuleaza initial/animate)
  late AnimationController _headerController;
  late Animation<Offset> _headerSlide;
  late Animation<double> _headerOpacity;

  // Animatie pentru Stats Section
  late AnimationController _statsController;
  late Animation<double> _statsOpacity;

  // Controllere pentru Feature Grid
  final List<AnimationController> _featureControllers = [];

  final List<Map<String, dynamic>> features = const [
    {
      'title': 'AI Chat Assistant',
      'description': 'Get instant help and recommendations from our AI helper',
      'icon': LucideIcons.messageCircle,
      'colorStart': Color(0xFF3B82F6), // blue-500
      'colorEnd': Color(0xFF06B6D4), // cyan-500
      'page': '/chat-bot'
    },
    {
      'title': 'Food Scanner',
      'description': 'Scan food items to check freshness and get insights',
      'icon': LucideIcons.camera,
      'colorStart': Color(0xFF9333EA), // purple-500
      'colorEnd': Color(0xFFEC4899), // pink-500
      'page': '/image-detection'
    },
    {
      'title': 'Food Map',
      'description': 'Find nearby restaurants and food donation centers',
      'icon': LucideIcons.mapPin,
      'colorStart': Color(0xFFEF4444), // red-500
      'colorEnd': Color(0xFFF97316), // orange-500
      'page': '/food-map'
    },
    {
      'title': 'Restaurant Deals',
      'description': 'Discover amazing deals and offers for newcomers',
      'icon': LucideIcons.utensils,
      'colorStart': Color(0xFFF59E0B), // amber-500
      'colorEnd': Color(0xFFFCD34D), // yellow-500
      'page': '/restaurant-deals'
    },
    {
      'title': 'Food Saver Game',
      'description': 'Play, save food, and compete on the leaderboard',
      'icon': LucideIcons.trophy,
      'colorStart': Color(0xFF10B981), // emerald-500
      'colorEnd': Color(0xFF14B8A6), // teal-500
      'page': '/food-saver-game'
    },
    {
      'title': 'Donate Food',
      'description': 'Choose where to donate: animals, NGOs, or homeless',
      'icon': LucideIcons.heart,
      'colorStart': Color(0xFFF43F5E), // rose-500
      'colorEnd': Color(0xFFEC4899), // pink-500
      'page': '/donate-food'
    }
  ];

  final List<Map<String, dynamic>> _statData = const [
    {'label': 'Food Saved', 'value': '0 kg', 'color': 'emerald'},
    {'label': 'CO₂ Reduced', 'value': '0 kg', 'color': 'blue'},
    {'label': 'Money Saved', 'value': '\$0', 'color': 'amber'}
  ];


  @override
  void initState() {
    super.initState();

    // 1. Header Animation
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_headerController);

    // 2. Stats Section Animation
    _statsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _statsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_statsController);

    // Declanșează animațiile principale
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _statsController.forward();
    });

    // Declanșează animațiile cardurilor cu delay
    for (int i = 0; i < features.length; i++) {
      final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
      _featureControllers.add(controller);
      Future.delayed(Duration(milliseconds: 300 + i * 100), () {
        if (mounted) controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _statsController.dispose();
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Widget pentru un singur card de Feature
  Widget _buildFeatureCard(Map<String, dynamic> feature, int index) {
    final controller = _featureControllers[index];

    return FeatureCardAnimated(
      feature: feature,
      index: index,
      controller: controller,
      // Navigare din Dashboard la paginile specifice
      onTap: () {
        if (feature['page'] == '/chat-bot') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  ChatBotPage(),
            ),
          );
        }
        else if (feature['page'] == '/image-detection') { // NOU: Logica Food Scanner
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageDetectionPage(),
            ),
          );
        }

        else if (feature['page'] == '/food-map') { // NOU: Logica Food Map
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FoodMapScreen(),
            ),
          );
        }

        else if(feature['page'] == '/donate-food') { // NOU: Logica DonateFood
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DonateFoodPage(),
            ),
          );
        }

        else if(feature['page'] == '/food-saver-game') { // NOU: Logica Jocului
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FoodSaverGame(),
            ),
          );
        }

        else if (feature['page'] == '/analytics') { // NOU: Logica Analytics
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SavingsCalculatorScreen(), // Navighează la calculator
            ),
          );
        }

        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigare la ${feature['title']} (WIP)')),
          );
        }
      },
    );
  }




  // Widget pentru o singură statistică
  Widget _buildStatCard(Map<String, dynamic> stat, int index) {
    final Color color;
    switch (stat['color']) {
      case 'emerald': color = Colors.green.shade600; break;
      case 'blue': color = Colors.blue.shade600; break;
      case 'amber': color = Colors.amber.shade600; break;
      default: color = Colors.grey;
    }

    // Simulează scale și delay
    final Animation<double> scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _statsController,
        curve: Interval(
          0.3 + index * 0.1, // Staggered delay
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    return ScaleTransition(
      scale: scale,
      child: FadeTransition(
        opacity: _statsOpacity,
        child: Card(
          color: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                      ).createShader(const Rect.fromLTWH(0, 0, 100, 40)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.blueGrey.shade600,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definirea gradientului de fundal (from-slate-50 via-white to-emerald-50)
    final backgroundGradient = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.grey.shade50,
          Colors.white,
          Colors.green.shade50,
        ],
      ),
    );

    return Scaffold(
      body: Container(
        decoration: backgroundGradient,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // NOU: Butonul "Back to Home"
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        // Navigare înapoi la noul ecran de pornire
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewStartPage(),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.home, size: 20),
                      label: const Text(
                        "Back to Home",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueGrey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // HEADER (Simulează motion.div initial/animate)
                  FadeTransition(
                    opacity: _headerOpacity,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 48),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                border: Border.all(color: Colors.green.shade200),
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1))
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.sparkles, color: Colors.green.shade500, size: 20),
                                  const SizedBox(width: 8),
                                  Text("ReFood AI Dashboard", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Welcome to Your\nSmart Kitchen",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey.shade900,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Choose a feature below to start reducing waste and making a difference",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueGrey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // FEATURE GRID
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: features.length,
                    itemBuilder: (context, index) {
                      return _buildFeatureCard(features[index], index);
                    },
                  ),

                  // STATS SECTION (Simulează motion.div initial/animate)
                  FadeTransition(
                    opacity: _statsOpacity,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 64),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: constraints.maxWidth > 768 ? 3 : 1,
                              childAspectRatio: constraints.maxWidth > 768 ? 2.5 : 4.5,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _statData.length,
                            itemBuilder: (context, index) {
                              return _buildStatCard(_statData[index], index);
                            },
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===================================
// WIDGETS AUXILIARE
// ===================================

// Wrapper pentru Feature Card, gestionând animațiile de intrare și hover
class FeatureCardAnimated extends StatefulWidget {
  final Map<String, dynamic> feature;
  final int index;
  final AnimationController controller;
  final VoidCallback onTap;

  const FeatureCardAnimated({
    super.key,
    required this.feature,
    required this.index,
    required this.controller,
    required this.onTap,
  });

  @override
  State<FeatureCardAnimated> createState() => _FeatureCardAnimatedState();
}

class _FeatureCardAnimatedState extends State<FeatureCardAnimated> with SingleTickerProviderStateMixin {
  // Animații pentru hover
  double _scale = 1.0;
  double _yOffset = 0.0;
  late AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    // Animație pentru rotirea iconiței la hover
    _iconController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    setState(() {
      // Simulează whileHover={{ y: -8, scale: 1.02 }}
      _scale = isHovering ? 1.02 : 1.0;
      _yOffset = isHovering ? -8 : 0;
    });

    // Rotația iconiței la hover
    if (isHovering) {
      _iconController.repeat(min: 0.0, max: 1.0, reverse: true);
    } else {
      _iconController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> opacity = Tween<double>(begin: 0.0, end: 1.0).animate(widget.controller);
    final Animation<Offset> slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeOut),
    );
    final textGradient = LinearGradient(colors: [widget.feature['colorStart'], widget.feature['colorEnd']]);


    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: FadeTransition(
              opacity: opacity,
              child: SlideTransition(
                position: slide,
                child: AnimatedScale(
                  scale: _scale,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.translationValues(0, _yOffset, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueGrey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1 + (_yOffset.abs() / 160)),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Container (cu animație de rotație la hover)
                        RotationTransition(
                          turns: Tween<double>(begin: 0, end: 0.1).animate(_iconController),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [widget.feature['colorStart'], widget.feature['colorEnd']],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.feature['colorEnd'].withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: Icon(widget.feature['icon'] as IconData, color: Colors.white, size: 40),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          widget.feature['title'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        Text(
                          widget.feature['description'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blueGrey.shade600, height: 1.4),
                        ),

                        // Hover Indicator
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _scale > 1.0 ? 1.0 : 0.0,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => textGradient.createShader(bounds),
                                  child: const Text(
                                    "Get Started",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedArrow(colorStart: widget.feature['colorStart'], colorEnd: widget.feature['colorEnd']),
                              ],
                            ),
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
      },
    );
  }
}

// Săgeată animată (similară cu codul tău anterior)
class AnimatedArrow extends StatefulWidget {
  final Color colorStart;
  final Color colorEnd;

  const AnimatedArrow({super.key, required this.colorStart, required this.colorEnd});

  @override
  State<AnimatedArrow> createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: false);

    _slideAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 5), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 5, end: 0), weight: 1),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [widget.colorStart, widget.colorEnd],
            ).createShader(bounds),
            child: const Text(
              "→",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}