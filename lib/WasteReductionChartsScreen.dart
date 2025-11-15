import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'NewStartPage.dart'; // Navigare înapoi la Home (Start Page)

class WasteReductionChartsScreen extends StatefulWidget {
  const WasteReductionChartsScreen({super.key});

  @override
  State<WasteReductionChartsScreen> createState() => _WasteReductionChartsScreenState();
}

class _WasteReductionChartsScreenState extends State<WasteReductionChartsScreen> {
  // Datele pentru graficele Liniare (kg/lună)
  final List<Map<String, dynamic>> projectionData = const [
    {'year': '2025', 'withApp': 60, 'withoutApp': 100},
    {'year': '2027', 'withApp': 48, 'withoutApp': 105},
    {'year': '2029', 'withApp': 38, 'withoutApp': 110},
    {'year': '2031', 'withApp': 30, 'withoutApp': 115},
    {'year': '2033', 'withApp': 24, 'withoutApp': 120},
    {'year': '2035', 'withApp': 20, 'withoutApp': 125}
  ];

  // Datele pentru graficele cu Bare (reducere %)
  final List<Map<String, dynamic>> impactData = const [
    {'category': 'Fruits & Vegetables', 'reduction': 45},
    {'category': 'Dairy Products', 'reduction': 38},
    {'category': 'Bread & Bakery', 'reduction': 42},
    {'category': 'Meat & Fish', 'reduction': 35},
    {'category': 'Leftovers', 'reduction': 50}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Folosim culorile Green/Teal solicitate
            colors: [Colors.green.shade50, Colors.white, Colors.teal.shade50],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Grafic 1: Proiecție 10 ani (Linii)
                        AnimatedInView(
                          delay: 0,
                          child: _buildProjectionChart(),
                        ),

                        // Grafic 2: Reducere pe Categorii (Bare)
                        AnimatedInView(
                          delay: 0.2,
                          child: _buildCategoryChart(),
                        ),

                        // Beneficii Cheie
                        _buildKeyBenefits(),
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
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft, size: 24),
            onPressed: () {
              // Navigare înapoi la Home (NewStartPage)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewStartPage(),
                ),
              );
            },
            color: Colors.blueGrey.shade700,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Waste Reduction Projections',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900),
              ),
              Text('How ReFood AI will reduce food waste from 2025 to 2035',
                  style: TextStyle(color: Colors.blueGrey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionChart() {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    // Gradient Green/Teal
                    gradient: LinearGradient(colors: [Colors.green.shade500, Colors.teal.shade500]),
                  ),
                  child: const Icon(LucideIcons.trendingDown, size: 24, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('10-Year Waste Reduction Forecast',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                    Text('Comparing households with and without ReFood AI',
                        style: TextStyle(color: Colors.blueGrey.shade600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 400,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 130,
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Afișează anii pe axa X
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8.0,
                            child: Text(projectionData[value.toInt()]['year'] as String, style: const TextStyle(fontSize: 12)),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == 130) return const Text('');
                          return Text('${value.toInt()}', style: const TextStyle(fontSize: 12));
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.blueGrey.shade100, strokeWidth: 1),
                    getDrawingVerticalLine: (value) => FlLine(color: Colors.blueGrey.shade100, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: true),
                  lineBarsData: [
                    // Linia 1: Without App (Roșu)
                    LineChartBarData(
                      spots: projectionData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['withoutApp'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.red.shade600,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                    // Linia 2: With App (Verde)
                    LineChartBarData(
                      spots: projectionData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['withApp'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.green.shade600,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  // Legenda manuală (Recharts o face automat, aici trebuie manual)
                  // Vom folosi un widget separat pentru legendă
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),

            // Impact Summary
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50, // MODIFICAT: emerald.shade50 -> green.shade50
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200), // MODIFICAT: emerald.shade200 -> green.shade200
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎯 Impact Summary',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900)), // MODIFICAT
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.green.shade800, height: 1.5), // MODIFICAT
                      children: <TextSpan>[
                        const TextSpan(text: 'By 2035, households using ReFood AI will reduce their food waste by '),
                        const TextSpan(text: '84%', style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' compared to those without, preventing over '),
                        const TextSpan(text: '1,260 kg', style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' of food from being wasted over the decade.'),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.green.shade600, 'With ReFood AI'),
        const SizedBox(width: 20),
        _buildLegendItem(Colors.red.shade600, 'Without ReFood AI'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade700)),
      ],
    );
  }


  Widget _buildCategoryChart() {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(colors: [Colors.teal.shade500, Colors.cyan.shade500]),
                  ),
                  child: const Icon(LucideIcons.leaf, size: 24, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Waste Reduction by Category',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                    Text('Average reduction percentage across food types',
                        style: TextStyle(color: Colors.blueGrey.shade600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 350,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 60,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Afișează categoriile pe axa X
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            angle: -45, // Roștește pentru a face loc etichetelor lungi
                            space: 12.0,
                            child: Text(impactData[value.toInt()]['category'] as String, style: const TextStyle(fontSize: 12)),
                          );
                        },
                        reservedSize: 70,
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('');
                          return Text('${value.toInt()}%', style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.blueGrey.shade100, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: impactData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data['reduction'].toDouble(),
                          color: Colors.green.shade600,
                          width: 16,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyBenefits() {
    final benefits = [
      {
        'title': 'AI-Powered Tracking',
        'description': 'Smart algorithms learn your consumption patterns and predict expiration dates',
        'colorStart': Colors.green.shade500,
        'colorEnd': Colors.teal.shade500,
      },
      {
        'title': 'Automated Reminders',
        'description': 'Get notified before food expires so you can use it in time',
        'colorStart': Colors.blue.shade500,
        'colorEnd': Colors.cyan.shade500,
      },
      {
        'title': 'Recipe Suggestions',
        'description': 'Discover creative ways to use ingredients before they spoil',
        'colorStart': Colors.purple.shade500,
        'colorEnd': Colors.pink.shade500,
      }
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: MediaQuery.of(context).size.width > 900 ? 1.5 : 3.0,
      ),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        return AnimatedInView(
          delay: 0.4 + index * 0.1,
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(colors: [benefit['colorStart'] as Color, benefit['colorEnd'] as Color]),
                    ),
                    child: Center(
                      child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(benefit['title'] as String,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                  const SizedBox(height: 4),
                  Text(benefit['description'] as String, style: TextStyle(color: Colors.blueGrey.shade600)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget pentru a simula "motion.div whileInView"
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

    // Declanșează animația cu delay
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