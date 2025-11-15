import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'DashboardScreen.dart'; // Asigură-te că DashboardScreen.dart este calea corectă
import 'LearnMoreScreen.dart';
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
  // Simulează useState(false) și useEffect pentru isVisible
  bool _isVisible = false;

  // Controller pentru animația principală a secțiunii Hero
  late AnimationController _heroController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Inițializează controller-ul pentru efectul de intrare (initial/animate)
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // initial: y: 30 (echivalent cu 0.1)
      end: Offset.zero, // animate: y: 0
    ).animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_heroController);

    // 2. Declanșează animația de intrare după o scurtă întârziere
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

  // Locații și culori pentru cardurile Feature
  final List<Map<String, dynamic>> features = const [
    {
      'icon': LucideIcons.brain,
      'title': 'AI-Powered Intelligence',
      'description': 'Advanced algorithms analyze food waste patterns and optimize your inventory',
      'colorStart': Color(0xFF10B981), // emerald-500
      'colorEnd': Color(0xFF14B8A6), // teal-500
    },
    {
      'icon': LucideIcons.leafyGreen,
      'title': 'Sustainability First',
      'description': 'Reduce waste, save costs, and make a positive environmental impact',
      'colorStart': Color(0xFF22C55E), // green-500
      'colorEnd': Color(0xFF10B981), // emerald-500
    },
    {
      'icon': LucideIcons.chefHat,
      'title': 'Recipe Recommendations',
      'description': 'Smart suggestions based on available ingredients and expiration dates',
      'colorStart': Color(0xFFF97316), // orange-500
      'colorEnd': Color(0xFFF59E0B), // amber-500
    },
    {
      'icon': LucideIcons.trendingUp,
      'title': 'Real-Time Analytics',
      'description': 'Track savings, waste reduction, and sustainability metrics in real-time',
      'colorStart': Color(0xFF3B82F6), // blue-500
      'colorEnd': Color(0xFF06B6D4), // cyan-500
      'page': '/analytics' // Marcat ca pagină navigabilă
    },
    {
      'icon': LucideIcons.zap,
      'title': 'Smart Automation',
      'description': 'AI basket recognition with expiration tracking and phone notifications',
      'colorStart': Color(0xFF9333EA), // purple-500
      'colorEnd': Color(0xFFEC4899), // pink-500
      'page': '/automation' // Marcat ca pagină navigabilă
    }
  ];

  @override
  Widget build(BuildContext context) {
    // Gradientul de fundal (from-slate-50 via-white to-emerald-50)
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
                  // 1. Elemente de Fundal Animate (Blobs)
                  const AnimatedBlobBackground(),

                  // 2. Secțiunea Hero (Text și CTA)
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
                                // Logo Placeholder
                                AnimatedScale(
                                  scale: _isVisible ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.elasticOut,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      border: Border.all(color: Colors.green.shade200),
                                      borderRadius: BorderRadius.circular(40),
                                      boxShadow: [
                                        BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 48, height: 48,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            gradient: LinearGradient(colors: [Colors.green.shade500, Colors.teal.shade500]),
                                          ),
                                          child: const Icon(LucideIcons.leafyGreen, color: Colors.white, size: 24),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text("ReFood AI", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                                        const SizedBox(width: 8),
                                        const RotationSparkles(), // Animație Sparkles
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                // Main Heading
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
                                // Slogan Animată
                                AnimatedOpacity(
                                  opacity: _isVisible ? 1 : 0,
                                  duration: const Duration(milliseconds: 800),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [Colors.orange.shade600, Colors.green.shade600, Colors.teal.shade600],
                                    ).createShader(bounds),
                                    child: const Text(
                                      "\"Don't waste it! Taste it!\"",
                                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // CTA Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Butonul "Get Started" (Navighează la Dashboard)
                                    AnimatedScale(
                                      scale: _isVisible ? 1.0 : 0.9,
                                      duration: const Duration(milliseconds: 500),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // NAVIGARE CORECTĂ: Înlocuiește Start Page cu Dashboard
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const DashboardScreen(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(LucideIcons.sparkles, size: 24),
                                        label: const Text("Get Started", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                          backgroundColor: Colors.teal.shade600,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          elevation: 12,
                                          shadowColor: Colors.green.shade500.withOpacity(0.4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    // Butonul "Learn More"
                                    AnimatedScale(

                                      scale: _isVisible ? 1.0 : 0.9,
                                      duration: const Duration(milliseconds: 500),
                                      child: OutlinedButton(
                                        onPressed: () {
                                          // ADAUGĂ ACEASTĂ LOGICĂ DE NAVIGARE:
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const LearnMoreScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text("Learn More", style: TextStyle(fontSize: 18)),

                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          side: BorderSide(color: Colors.blueGrey.shade300, width: 2),
                                          foregroundColor: Colors.blueGrey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 60),

                                // Floating Stats (Clickable)
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

            // 3. Secțiunea Features
            SliverToBoxAdapter(
              child: FeaturesSection(features: features),
            ),

            // 4. Secțiunea CTA Finală
            const SliverToBoxAdapter(
              child: FinalCTASection(),
            ),

            // 5. Footer
            const SliverToBoxAdapter(
              child: FooterSection(),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARE ---

// Widget pentru Fundalul Animat (simulează Framer Motion cu repeat: Infinity)
class AnimatedBlobBackground extends StatelessWidget {
  const AnimatedBlobBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Blob Top Right (emerald-400 to teal-400)
          Positioned(
            top: -150,
            right: -100,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 2 * 3.14159), // 0 to 360 degrees in radians
              duration: const Duration(seconds: 20),
              builder: (context, angle, child) {
                return Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: 384, // w-96
                    height: 384, // h-96
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.teal.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Blob Bottom Left (orange-400 to amber-400)
          Positioned(
            bottom: -150,
            left: -100,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: -2 * 3.14159), // Rotate invers
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
                        colors: [Colors.orange.shade400, Colors.amber.shade400],
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

// Widget pentru animația Sparkles
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
    // Simulează animate={{ rotate: [0, 10, -10, 0] }} transition={{ duration: 2, repeat: Infinity, repeatDelay: 3 }}
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(period: const Duration(seconds: 5)); // 2s animație, 3s pauză = 5s
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
          curve: const Interval(0.0, 0.4, curve: Curves.easeInOut), // Rotație în prima 40%
        ),
      ),
      child: Icon(LucideIcons.sparkles, color: Colors.green.shade500, size: 16),
    );
  }
}

// Secțiunea de Statistici (acum sunt Link-uri)
class FloatingStatsSection extends StatelessWidget {
  const FloatingStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'value': '40%', 'label': 'Average Waste Reduction', 'note': 'Click to see projections →'},
      {'value': '\$850', 'label': 'Annual Savings per Household', 'note': 'Click to calculate →'},
      {'value': '10k+', 'label': 'Happy Users', 'note': 'Click to read reviews →'},
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

// Cardul de Statistică cu efect de Hover/Tap
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
          // Aici s-ar face navigarea către paginile specifice (e.g., WasteReductionCharts)

          if (widget.stat['label'] == 'Average Waste Reduction') {
            // Navigare la Ecranul de Grafice (WasteReductionChartsScreen)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WasteReductionChartsScreen(),
              ),
            );
          }

            else if (widget.stat['label'] == 'Annual Savings per Household') { // NOU: Annual Savings
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SavingsCalculatorScreen(),
              ),
            );
          }

          else if (widget.stat['label'] == 'Happy Users') { // NOU: Logica User Reviews
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserReviewsScreen(),
              ),
            );
          }

          else if (widget.stat['page'] == '/analytics') { // LOGICA FINALĂ ANALYTICS
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RealTimeAnalyticsScreen(),
              ),
            );
          }

           else {
            // Logica pentru celelalte carduri rămâne ca simplu SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigare la ${widget.stat['label']} (WIP)')),
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
              side: BorderSide(color: Colors.blueGrey.shade200, width: 1.5),
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
                      colors: [Colors.green.shade600, Colors.teal.shade600],
                    ).createShader(bounds),
                    child: Text(
                      widget.stat['value'] as String,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Culoarea albă este necesară pentru a funcționa ShaderMask
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.stat['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blueGrey.shade700, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.stat['note'] as String,
                    style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 12),
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


// Secțiunea de Caracteristici
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
                style: TextStyle(fontSize: 18, color: Colors.blueGrey.shade600),
              ),
              const SizedBox(height: 60),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 900 ? 3 : 1,
                      childAspectRatio: constraints.maxWidth > 900 ? 1.0 : 2.5,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: features.length,
                    itemBuilder: (context, index) {
                      return FeatureCard(feature: features[index], index: index);
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

// Cardul de Feature cu animație la intrare și la hover
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
    // Simulează whileInView
    _inViewController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _inViewController,
        curve: Curves.easeOut,
      ),
    );

    // Declanșează animația la scurt timp după creare
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
      // Simulează whileHover={{ y: -8, scale: 1.02 }}
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
        onTap: isClickable ? () {
          final pagePath = widget.feature['page'];

          if (pagePath == '/analytics') {
            // LOGICA NOUĂ: Navigare la Real-Time Analytics
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RealTimeAnalyticsScreen(),
              ),
            );
          } else {
            // Logica existentă (pentru Smart Automation etc.)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigare la ${widget.feature['title']} (WIP)')),
            );
          }
        } : null,

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
                    side: BorderSide(color: Colors.blueGrey.shade200, width: 1.5),
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
                          child: Icon(widget.feature['icon'] as IconData, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.feature['title'] as String,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.feature['description'] as String,
                          style: TextStyle(color: Colors.blueGrey.shade600, height: 1.5),
                        ),
                        if (isClickable)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              "Click to explore →",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade600),
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


// Secțiunea CTA Finală
class FinalCTASection extends StatelessWidget {
  const FinalCTASection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.teal.shade600, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Text(
                "Ready to Transform Your Kitchen?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                "Join thousands making a difference. Start reducing waste and saving money today.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.green.shade50),
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
                label: const Text("Start Your Journey", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 15,
                  shadowColor: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Secțiunea Footer
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      color: Colors.blueGrey.shade900, // bg-slate-900
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(colors: [Colors.green.shade500, Colors.teal.shade500]),
                    ),
                    child: const Icon(LucideIcons.leafyGreen, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text("ReFood AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "© 2024 ReFood AI. Making the world more sustainable, one meal at a time.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}