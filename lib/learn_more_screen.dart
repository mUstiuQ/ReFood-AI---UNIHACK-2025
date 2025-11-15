import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dashboard_screen.dart'; // Uncomment when ready

class LearnMoreScreen extends StatelessWidget {
  const LearnMoreScreen({super.key});

  static final List<Map<String, dynamic>> wasteStats = [
    {
      'year': '2022 Data',
      'amount': '1.05 Billion Tons',
      'description': 'Total food waste generated globally',
      'description_long': 'This equals 19% of all food available to consumers. (Source: UN Food Waste Index 2024)',
      'imageUrl': 'assets/images/waste_total.jpg' // <-- Cale locală
    },
    {
      'year': 'The Climate Cost',
      'amount': '8-10% of GHGs',
      'description': 'Global greenhouse emissions from food waste',
      'description_long': 'If food waste were a country, it would be the 3rd largest emitter of greenhouse gases after the US and China.',
      'imageUrl': 'assets/images/waste_climate.jpg' // <-- Cale locală
    },
    {
      'year': 'The Human Cost',
      'amount': '1/3 of all food',
      'description': 'Is lost or wasted globally',
      'description_long': 'This lost food could feed billions, yet 783 million people faced hunger in 2022. (Source: FAO & WFP)',
      'imageUrl': 'assets/images/waste_human.jpg' // <-- Cale locală
    }
  ];


  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

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
          // 2. REZOLVAT: Eroarea de RenderFlex Overflow
          padding: EdgeInsets.only(top: isMobile ? 16 : 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isMobile),
                  _buildOurTeamSection(context, isMobile),
                  _buildFoodWasteCrisisSection(context, isMobile),
                  _buildWorstYearsSection(context, isMobile),
                  _buildFinalCTA(context, isMobile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft, size: 24),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            color: Colors.blueGrey.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learn More',
                  style: TextStyle(
                      fontSize: isMobile ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade900),
                ),
                Text('About our mission and the food waste crisis',
                    style: TextStyle(color: Colors.blueGrey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOurTeamSection(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24.0),
      child: AnimatedInView(
        delay: 0,
        child: Card(
          elevation: 16,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLarge = constraints.maxWidth > 800;
              return Flex(
                direction: isLarge ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: isLarge ? null : 300,
                    width: isLarge ? constraints.maxWidth / 2 : double.infinity,
                    // Poți pune aici poza echipei (așa cum am discutat anterior)
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/echipa.jpg'), // <-- Înlocuiește cu poza ta
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // 3. REZOLVAT: Eroarea de Crash (am șters 'Expanded')
                  Padding(
                    padding: EdgeInsets.all(isLarge ? 48.0 : (isMobile ? 24.0 : 32.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(colors: [Colors.green.shade500, Colors.teal.shade500]),
                              ),
                              child: const Icon(LucideIcons.users, size: 24, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Text('Our Team',
                                style: TextStyle(
                                    fontSize: isMobile ? 24 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade900)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "We're a passionate group of software developers, environmental activists, and food tech enthusiasts united by one mission: to end food waste through intelligent technology.",
                          style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              color: Colors.blueGrey.shade700,
                              height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "With backgrounds in AI, sustainability science, and full-stack development, our diverse team brings together cutting-edge technical expertise and deep commitment to environmental impact.",
                          style: TextStyle(
                              fontSize: isMobile ? 15 : 16,
                              color: Colors.blueGrey.shade600,
                              height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            _buildTag('🤖 AI Experts', Colors.green),
                            _buildTag('🌱 Sustainability Advocates', Colors.blue),
                            _buildTag('💻 Full-Stack Developers', Colors.purple),
                            _buildTag('🔧 Embedded Developers', Colors.orange),
                            _buildTag('🏛️ Solving Civic Problems Enjoyers', Colors.pink),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green.shade50, Colors.teal.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            '"Building the future of sustainable food management, one line of code at a time."',
                            style: TextStyle(
                                fontSize: isMobile ? 15 : 16,
                                color: Colors.blueGrey.shade800,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border.all(color: color.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color.shade700),
      ),
    );
  }

  Widget _buildFoodWasteCrisisSection(BuildContext context, bool isMobile) {
    return AnimatedInView(
      delay: 0.2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24.0),
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.alertTriangle, size: 20, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Text('Global Crisis', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade900)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('The Food Waste Crisis',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900)),
            const SizedBox(height: 8),
            Text('Understanding the magnitude of the problem we\'re solving together',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: isMobile ? 16 : 18, color: Colors.blueGrey.shade600)),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                final isLarge = constraints.maxWidth > 900;
                return GridView.count(
                  crossAxisCount: isLarge ? 3 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isLarge ? 1.5 : (isMobile ? 3.0 : 3.0),
                  children: [
                    _buildStatCard(LucideIcons.globe, '1/3', 'of all food produced globally is wasted', Colors.blue),
                    _buildStatCard(LucideIcons.trendingUp, '\$1 Trillion', 'annual economic cost of food waste', Colors.red),
                    _buildStatCard(LucideIcons.leaf, '8-10%', 'of global greenhouse gas emissions', Colors.green),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, MaterialColor color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color.shade600),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorstYearsSection(BuildContext context, bool isMobile) {
    return AnimatedInView(
      delay: 0.4,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Record-Breaking Waste Years',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900)),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth > 700 ? 2 : 1,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    // Raportul de aspect este crucial pentru imaginile întinse
                    childAspectRatio: constraints.maxWidth > 700 ? 0.9 : (isMobile ? 0.8 : 0.9),
                  ),
                  itemCount: wasteStats.length,
                  itemBuilder: (context, index) {
                    final stat = wasteStats[index];
                    return AnimatedStatCard(stat: stat, index: index, isMobile: isMobile);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalCTA(BuildContext context, bool isMobile) {
    return AnimatedInView(
      delay: 0.8,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24.0),
        child: Card(
          elevation: 16,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 32 : 48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.teal.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text('Join Us in Making a Difference',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 16),
                Text(
                  'Together, we can reduce food waste, save money, and protect our planet for future generations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isMobile ? 16 : 18, color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    try {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    } catch (e) {
                      debugPrint('Navigation error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dashboard not available yet')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade700,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: isMobile ? 14 : 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Get Started Today',
                      style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- WIDGET DE ANIMAȚIE (IN VIEW) ---

class AnimatedInView extends StatefulWidget {
  final Widget child;
  final double delay;

  const AnimatedInView({super.key, required this.child, this.delay = 0});

  @override
  State<AnimatedInView> createState() => _AnimatedInViewState();
}

class _AnimatedInViewState extends State<AnimatedInView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
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

// --- CARDUL STATISTICII CU IMAGINEA ÎNTINSĂ ---

class AnimatedStatCard extends StatefulWidget {
  final Map<String, dynamic> stat;
  final int index;
  final bool isMobile;

  const AnimatedStatCard({super.key, required this.stat, required this.index, required this.isMobile});

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    final double startX = widget.index == 0 ? -0.1 : 0.1;
    _slide = Tween<Offset>(begin: Offset(startX, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: 600 + widget.index * 200), () {
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
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 4. REZOLVAT: Imagini întinse
              Flexible( // <-- Am adăugat Flexible
                flex: 1, // Poți ajusta flex (1, 2, etc.)
                child: Container(
                  // height: 192, // <-- Am șters înălțimea fixă
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(widget.stat['imageUrl']!), // Folosim AssetImage
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.stat['year']!,
                              style: TextStyle(
                                  fontSize: widget.isMobile ? 28 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text(widget.stat['amount']!,
                              style: TextStyle(color: Colors.green.shade300, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(widget.isMobile ? 20 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.stat['description']!,
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade700)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.stat['description_long'] as String, // Folosim noul câmp
                        style: TextStyle(fontSize: 13, color: Colors.red.shade900, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}