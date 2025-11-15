import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Folosim un pachet similar cu 'lucide-react'
import 'chatbot_screen.dart';

// Clasa de bază pentru widget-ul Dashboard
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

//test

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // Controllere pentru animatii (simulând Framer Motion 'initial' și 'animate')
  late AnimationController _headerController;
  final List<AnimationController> _featureControllers = [];
  late AnimationController _statsController;

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

  @override
  void initState() {
    super.initState();

    // 1. Header Animation (opacity: 0 -> 1, y: -20 -> 0)
    _headerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    // Pentru a simula y translation, folosim un Tween
    _headerController.forward();

    // 2. Feature Grid Animations (staggered delay)
    for (int i = 0; i < features.length; i++) {
      final controller = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500));
      _featureControllers.add(controller);
      Future.delayed(Duration(milliseconds: 300 + i * 100), () {
        if (mounted) controller.forward();
      });
    }

    // 3. Stats Section Animation (opacity, scale)
    _statsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _statsController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    _statsController.dispose();
    super.dispose();
  }

  // Widgetul pentru o singură caracteristică (Card)
  Widget _buildFeatureCard(Map<String, dynamic> feature, int index) {
    final controller = _featureControllers[index];
    final Animation<double> opacity = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    final Animation<Offset> slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Simulează initial: opacity: 0, y: 20
        return FadeTransition(
          opacity: opacity,
          child: SlideTransition(
            position: slide,
            child: FeatureCardContent(
              feature: feature,
              colorStart: feature['colorStart'],
              colorEnd: feature['colorEnd'],
              icon: feature['icon'],
            ),
          ),
        );
      },
    );
  }

  // Widgetul pentru statistici
  Widget _buildStatCard(Map<String, dynamic> stat, int index) {
    final Color color;
    switch (stat['color']) {
      case 'emerald':
        color = Colors.green.shade600;
        break;
      case 'blue':
        color = Colors.blue.shade600;
        break;
      case 'amber':
        color = Colors.amber.shade600;
        break;
      default:
        color = Colors.grey;
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
        opacity: _statsController,
        child: Card(
          color: Colors.white.withOpacity(0.6),
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
    // Definirea gradientului de fundal
    final backgroundGradient = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.grey.shade50, // from-slate-50
          Colors.white, // via-white
          Colors.green.shade50, // to-emerald-50
        ],
      ),
    );

    // Animarea Header-ului
    final headerSlide = Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    final headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_headerController);

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
                  // --------------------------
                  // HEADER (AnimatedOpacity + SlideTransition)
                  // --------------------------
                  FadeTransition(
                    opacity: headerOpacity,
                    child: SlideTransition(
                      position: headerSlide,
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
                                shadows: [
                                  Shadow(
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1))
                                ],
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

                  // --------------------------
                  // FEATURE GRID
                  // --------------------------
                  StaggeredGrid.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2, // 3 coloane pe desktop, 2 pe mobil
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: List.generate(
                      features.length,
                          (index) => _buildFeatureCard(features[index], index),
                    ),
                  ),

                  // --------------------------
                  // STATS SECTION
                  // --------------------------
                  Padding(
                    padding: const EdgeInsets.only(top: 64),
                    child: StaggeredGrid.count(
                      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1, // 3 coloane pe desktop, 1 pe mobil
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        {'label': 'Food Saved', 'value': '0 kg', 'color': 'emerald'},
                        {'label': 'CO₂ Reduced', 'value': '0 kg', 'color': 'blue'},
                        {'label': 'Money Saved', 'value': '\$0', 'color': 'amber'},
                      ].map((stat) => _buildStatCard(stat, [
                        {'label': 'Food Saved', 'value': '0 kg', 'color': 'emerald'},
                        {'label': 'CO₂ Reduced', 'value': '0 kg', 'color': 'blue'},
                        {'label': 'Money Saved', 'value': '\$0', 'color': 'amber'},
                      ].indexOf(stat))).toList(),
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

// Widgetul separat pentru conținutul cardului (pentru a gestiona Hover/Tap)
class FeatureCardContent extends StatefulWidget {
  final Map<String, dynamic> feature;
  final Color colorStart;
  final Color colorEnd;
  final IconData icon;

  const FeatureCardContent({
    super.key,
    required this.feature,
    required this.colorStart,
    required this.colorEnd,
    required this.icon,
  });

  @override
  State<FeatureCardContent> createState() => _FeatureCardContentState();
}

class _FeatureCardContentState extends State<FeatureCardContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _yOffsetAnimation;

  @override
  void initState() {
    super.initState();
    // Simulează whileHover={{ y: -8, scale: 1.02 }} și whileTap={{ scale: 0.98 }}
    _hoverController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.02), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.02, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));

    _yOffsetAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    if (isHovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gradient pentru textul "Get Started"
    final textGradient = LinearGradient(
      colors: [widget.colorStart, widget.colorEnd],
    );

    // Gestionează animațiile de hover/tap
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTapDown: (_) => _hoverController.animateTo(0.5, curve: Curves.easeOut), // Simulează whileTap
        onTapUp: (_) => _hoverController.reverse(),
        onTapCancel: () => _hoverController.reverse(),
        onTap: ()
        {

          if (widget.feature['page'] == '/chat-bot') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatBotScreen(), // Navighează la noul ecran
              ),
            );
          }


          // Navigare (similar cu Link to={createPageUrl(feature.page)})
          // Navigator.pushNamed(context, widget.feature['page']);
        },
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _yOffsetAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.blueGrey.shade200)),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Container (cu animație de rotație la hover)
                        IconWithRotation(
                          colorStart: widget.colorStart,
                          colorEnd: widget.colorEnd,
                          icon: widget.icon,
                          isHovered: _hoverController.isAnimating || _hoverController.value > 0, // Daca e in starea de hover
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
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          widget.feature['description'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blueGrey.shade600),
                        ),

                        // Hover Indicator
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _hoverController.value > 0.01 ? 1.0 : 0.0,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24.0),
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
                                ArrowAnimation(
                                  colorStart: widget.colorStart,
                                  colorEnd: widget.colorEnd,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Widget separat pentru Icon (gestionează rotația)
class IconWithRotation extends StatefulWidget {
  final Color colorStart;
  final Color colorEnd;
  final IconData icon;
  final bool isHovered;

  const IconWithRotation({
    super.key,
    required this.colorStart,
    required this.colorEnd,
    required this.icon,
    required this.isHovered,
  });

  @override
  State<IconWithRotation> createState() => _IconWithRotationState();
}

class _IconWithRotationState extends State<IconWithRotation>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Simulează whileHover={{ rotate: [0, -10, 10, 0] }}
    _iconController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    // Rotație ușoară
    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
    // Simulează group-hover:scale-110
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant IconWithRotation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovered && oldWidget.isHovered == false) {
      _iconController.forward(from: 0.0);
    } else if (!widget.isHovered && oldWidget.isHovered == true) {
      _iconController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _iconController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [widget.colorStart, widget.colorEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.colorEnd.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Icon(widget.icon, color: Colors.white, size: 40),
            ),
          ),
        );
      },
    );
  }
}

// Widget separat pentru săgeata animată
class ArrowAnimation extends StatefulWidget {
  final Color colorStart;
  final Color colorEnd;

  const ArrowAnimation({super.key, required this.colorStart, required this.colorEnd});

  @override
  State<ArrowAnimation> createState() => _ArrowAnimationState();
}

class _ArrowAnimationState extends State<ArrowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrowController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Simulează animate={{ x: [0, 5, 0] }} transition={{ duration: 1, repeat: Infinity }}
    _arrowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();

    _slideAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 5), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 5, end: 0), weight: 1),
    ]).animate(_arrowController);
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _arrowController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [widget.colorStart, widget.colorEnd],
            ).createShader(bounds),
            child: const Text(
              "→",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}