import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'DashboardScreen.dart'; // Asigură-te că calea este corectă
import 'LearnMoreScreen.dart';
import 'LeaderBoard.dart';
import 'UserReviewsScreen.dart';
import 'WasteReductionChartsScreen.dart';
import 'SavingsCalculatorScreen.dart';
import 'RealTimeAnalyticsScreen.dart';


class NewStartPage extends StatefulWidget {
  const NewStartPage({super.key});

  @override
  State<NewStartPage> createState() => _NewStartPageState();
}

class _NewStartPageState extends State<NewStartPage>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;

  late AnimationController _heroController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );

    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_heroController);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _isVisible = true);
        _heroController.forward();
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  // Feature cards
  final List<Map<String, dynamic>> features = const [
    {
      'icon': LucideIcons.brain,
      'title': 'AI-Powered Intelligence',
      'description':
      'Advanced algorithms analyze food waste patterns and optimize your inventory',
      'colorStart': Color(0xFF10B981),
      'colorEnd': Color(0xFF14B8A6),
    },
    {
      'icon': LucideIcons.leafyGreen,
      'title': 'Sustainability First',
      'description':
      'Reduce waste, save costs, and make a positive environmental impact',
      'colorStart': Color(0xFF22C55E),
      'colorEnd': Color(0xFF10B981),
    },
    {
      'icon': LucideIcons.chefHat,
      'title': 'Recipe Recommendations',
      'description':
      'Smart suggestions based on available ingredients and expiration dates',
      'colorStart': Color(0xFFF97316),
      'colorEnd': Color(0xFFF59E0B),
    },
    {
      'icon': LucideIcons.trendingUp,
      'title': 'Real-Time Analytics',
      'description':
      'Track savings, waste reduction, and sustainability metrics in real-time',
      'colorStart': Color(0xFF3B82F6),
      'colorEnd': Color(0xFF06B6D4),
      'page': '/analytics'
    },
    {
      'icon': LucideIcons.zap,
      'title': 'Smart Automation',
      'description':
      'AI basket recognition with expiration tracking and phone notifications',
      'colorStart': Color(0xFF9333EA),
      'colorEnd': Color(0xFFEC4899),
      'page': '/automation'
    },
    {
      'icon': LucideIcons.trophy, // icon de leaderboard / gamification
      'title': 'LeaderBoard',
      'description': 'Rececy leaderboard using wasting food',
      'colorStart': Color(0xFF6366F1), // indigo-ish
      'colorEnd': Color(0xFF06B6D4),   // cyan
      'page': '/leaderboard',          // momentan va arăta WIP la tap
    },
  ];

  @override
  Widget build(BuildContext context) {
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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  const AnimatedBlobBackground(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _opacityAnimation,
                            child: Column(
                              children: [
                                const SizedBox(height: 80),

                                // ====== HERO BADGE CU LOGO FĂRĂ FUNDAL VERDE ======
                                AnimatedScale(
                                  scale: _isVisible ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.elasticOut,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      border: Border.all(
                                          color: Colors.green.shade200),
                                      borderRadius: BorderRadius.circular(40),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 10,
                                          color: Colors.black.withOpacity(0.1),
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // LOGO MAI MARE, FĂRĂ BACKGROUND VERDE
                                        SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: Image.asset(
                                            'assets/images/logo.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          "ReFood AI",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const RotationSparkles(),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // Heading principal
                                Text(
                                  "Reduce Food Waste\nwith AI Intelligence",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade900,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Transform your kitchen into a sustainable powerhouse. Save money, reduce waste, and help the planet with intelligent food management.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blueGrey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Slogan
                                AnimatedOpacity(
                                  opacity: _isVisible ? 1 : 0,
                                  duration:
                                  const Duration(milliseconds: 800),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        LinearGradient(
                                          colors: [
                                            Colors.orange.shade600,
                                            Colors.green.shade600,
                                            Colors.teal.shade600
                                          ],
                                        ).createShader(bounds),
                                    child: const Text(
                                      "\"Don't waste it! Taste it!\"",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Butoane CTA
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedScale(
                                      scale: _isVisible ? 1.0 : 0.9,
                                      duration:
                                      const Duration(milliseconds: 500),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                              const DashboardScreen(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          LucideIcons.sparkles,
                                          size: 24,
                                        ),
                                        label: const Text(
                                          "Get Started",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32, vertical: 20),
                                          backgroundColor: Colors.teal.shade600,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(16),
                                          ),
                                          elevation: 12,
                                          shadowColor: Colors.green.shade500
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    AnimatedScale(
                                      scale: _isVisible ? 1.0 : 0.9,
                                      duration:
                                      const Duration(milliseconds: 500),
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                              const LearnMoreScreen(),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 32, vertical: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(16),
                                          ),
                                          side: BorderSide(
                                            color: Colors.blueGrey.shade300,
                                            width: 2,
                                          ),
                                          foregroundColor:
                                          Colors.blueGrey.shade700,
                                        ),
                                        child: const Text(
                                          "Learn More",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 60),

                                const FloatingStatsSection(),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Features
            SliverToBoxAdapter(
              child: FeaturesSection(features: features),
            ),

            // CTA finală
            const SliverToBoxAdapter(
              child: FinalCTASection(),
            ),

            // Footer
            const SliverToBoxAdapter(
              child: FooterSection(),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== WIDGETS AUXILIARE ===================

class AnimatedBlobBackground extends StatelessWidget {
  const AnimatedBlobBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -150,
            right: -100,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 2 * 3.14159),
              duration: const Duration(seconds: 20),
              builder: (context, angle, child) {
                return Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: 384,
                    height: 384,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade400,
                          Colors.teal.shade400
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: -2 * 3.14159),
              duration: const Duration(seconds: 25),
              builder: (context, angle, child) {
                return Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: 384,
                    height: 384,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.amber.shade400
                        ],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RotationSparkles extends StatefulWidget {
  const RotationSparkles({super.key});

  @override
  State<RotationSparkles> createState() => _RotationSparklesState();
}

class _RotationSparklesState extends State<RotationSparkles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(period: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween<double>(begin: 0.0, end: 0.05).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
        ),
      ),
      child: Icon(
        LucideIcons.sparkles,
        color: Colors.green.shade500,
        size: 16,
      ),
    );
  }
}

class FloatingStatsSection extends StatelessWidget {
  const FloatingStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'value': '40%',
        'label': 'Average Waste Reduction',
        'note': 'Click to see projections →'
      },
      {
        'value': '\$850',
        'label': 'Annual Savings per Household',
        'note': 'Click to calculate →'
      },
      {
        'value': '10k+',
        'label': 'Happy Users',
        'note': 'Click to read reviews →'
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth > 768 ? 3 : 1,
              childAspectRatio: 2.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return StatCard(stat: stat);
            },
          );
        },
      ),
    );
  }
}

class StatCard extends StatefulWidget {
  final Map<String, dynamic> stat;
  const StatCard({super.key, required this.stat});

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  double _scale = 1.0;
  double _elevation = 8.0;

  void _onTapDown(_) {
    setState(() {
      _scale = 0.98;
      _elevation = 4.0;
    });
  }

  void _onTapUp(_) {
    setState(() {
      _scale = 1.0;
      _elevation = 8.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
      _elevation = 8.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _elevation = 12.0),
      onExit: (_) => setState(() => _elevation = 8.0),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          if (widget.stat['label'] == 'Average Waste Reduction') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WasteReductionChartsScreen(),
              ),
            );
          } else if (widget.stat['label'] ==
              'Annual Savings per Household') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SavingsCalculatorScreen(),
              ),
            );
          } else if (widget.stat['label'] == 'Happy Users') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserReviewsScreen(),
              ),
            );
          } else if (widget.stat['page'] == '/analytics') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RealTimeAnalyticsScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text('Navigare la ${widget.stat['label']} (WIP)'),
              ),
            );
          }
        },
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          child: Card(
            elevation: _elevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.blueGrey.shade200,
                width: 1.5,
              ),
            ),
            color: Colors.white.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.green.shade600,
                        Colors.teal.shade600
                      ],
                    ).createShader(bounds),
                    child: Text(
                      widget.stat['value'] as String,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.stat['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.stat['note'] as String,
                    style: TextStyle(
                      color: Colors.blueGrey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FeaturesSection extends StatelessWidget {
  final List<Map<String, dynamic>> features;
  const FeaturesSection({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                "Intelligent Features for\nModern Kitchens",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Powered by cutting-edge AI to make sustainable living effortless",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey.shade600,
                ),
              ),
              const SizedBox(height: 60),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                      constraints.maxWidth > 900 ? 3 : 1,
                      childAspectRatio:
                      constraints.maxWidth > 900 ? 1.0 : 2.5,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: features.length,
                    itemBuilder: (context, index) {
                      return FeatureCard(
                        feature: features[index],
                        index: index,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final Map<String, dynamic> feature;
  final int index;
  const FeatureCard({super.key, required this.feature, required this.index});

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _inViewController;
  late Animation<double> _scaleAnimation;
  double _yOffset = 0;
  double _hoverScale = 1.0;
  double _elevation = 4.0;

  @override
  void initState() {
    super.initState();

    _inViewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _inViewController,
        curve: Curves.easeOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _inViewController.forward();
    });
  }

  @override
  void dispose() {
    _inViewController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    setState(() {
      _yOffset = isHovering ? -8 : 0;
      _hoverScale = isHovering ? 1.02 : 1.0;
      _elevation = isHovering ? 16.0 : 4.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color colorStart = widget.feature['colorStart'];
    final Color colorEnd = widget.feature['colorEnd'];
    final bool isClickable = widget.feature['page'] != null;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: isClickable
            ? () {
          final pagePath = widget.feature['page'];

          if (pagePath == '/analytics') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RealTimeAnalyticsScreen(),
              ),
            );
          } else if (pagePath == '/leaderboard') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecipeLeaderboardPage(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Navigare la ${widget.feature['title']} (WIP)'),
              ),
            );
          }
        }
            : null,
        child: AnimatedBuilder(
          animation: _inViewController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _yOffset),
              child: Transform.scale(
                scale: _scaleAnimation.value * _hoverScale,
                child: Card(
                  elevation: _elevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.blueGrey.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [colorStart, colorEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            widget.feature['icon'] as IconData,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.feature['title'] as String,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.feature['description'] as String,
                          style: TextStyle(
                            color: Colors.blueGrey.shade600,
                            height: 1.5,
                          ),
                        ),
                        if (isClickable)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              "Click to explore →",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade600,
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

class FinalCTASection extends StatelessWidget {
  const FinalCTASection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade600,
            Colors.teal.shade600,
            Colors.green.shade600
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Text(
                "Ready to Transform Your Kitchen?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Join thousands making a difference. Start reducing waste and saving money today.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green.shade50,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.zap, size: 24),
                label: const Text(
                  "Start Your Journey",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 20),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 15,
                  shadowColor:
                  Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      color: Colors.blueGrey.shade900,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO ÎN FOOTER FĂRĂ FUNDAL VERDE
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "ReFood AI",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "© 2025 AQUALIX TEAM",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
