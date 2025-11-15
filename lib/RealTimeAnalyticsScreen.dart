import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'DashboardScreen.dart'; // Navigare înapoi la Dashboard

// Widget pentru a simula animația de intrare
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
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


class RealTimeAnalyticsScreen extends StatefulWidget {
  const RealTimeAnalyticsScreen({super.key});

  @override
  State<RealTimeAnalyticsScreen> createState() => _RealTimeAnalyticsScreenState();
}

class _RealTimeAnalyticsScreenState extends State<RealTimeAnalyticsScreen> {
  // Stări pentru datele live (simulează useState)
  List<Map<String, dynamic>> _liveData = [];
  int _currentWaste = 1285;
  double _totalToday = 125000;
  Timer? _updateTimer;

  // Date statice (din codul React)
  final List<Map<String, dynamic>> _globalStats = const [
    { 'region': 'North America', 'waste': 95000, 'trend': '+2.3%' },
    { 'region': 'Europe', 'waste': 88000, 'trend': '+1.8%' },
    { 'region': 'Asia', 'waste': 142000, 'trend': '+3.1%' },
    { 'region': 'South America', 'waste': 37000, 'trend': '+2.7%' }
  ];


  @override
  void initState() {
    super.initState();
    _initializeLiveData();
    _startLiveUpdates();
  }

  void _initializeLiveData() {
    // Initializează datele inițiale (similar cu initialData din React)
    _liveData = List.generate(20, (i) => ({
      'time': i.toString(),
      'waste': Random().nextDouble() * 100 + 1200,
    }));
  }

  void _startLiveUpdates() {
    // Simulează real-time updates (setInterval)
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;

      final now = DateTime.now();
      final timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      final newWaste = Random().nextDouble() * 100 + 1200;

      setState(() {
        // Actualizează graficul (păstrează doar ultimele 20 de puncte)
        if (_liveData.length >= 20) {
          _liveData = _liveData.sublist(_liveData.length - 19);
        }
        _liveData.add({ 'time': timeStr, 'waste': newWaste });

        _currentWaste = newWaste.round();
        _totalToday += Random().nextDouble() * 50;
      });
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Gradient: from-blue-50 via-white to-cyan-50
            colors: [Colors.blue.shade50, Colors.white, Colors.cyan.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 32),

                    // Live Stats
                    _buildLiveStats(),
                    const SizedBox(height: 32),

                    // Live Chart
                    _buildLiveChart(),
                    const SizedBox(height: 32),

                    // Regional Breakdown
                    _buildRegionalBreakdown(),
                    const SizedBox(height: 32),

                    // Final CTA
                    _buildFinalCTA(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 24),
          onPressed: () => Navigator.pop(context),
          color: Colors.blueGrey.shade700,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Real-Time Analytics',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
            Text('Live food waste data from around the world',
                style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600)),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: constraints.maxWidth > 900 ? 3 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth > 900 ? 2.5 : 4.0,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Live Now (Red Gradient)
            AnimatedEntrance(
              delay: 0,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.red.shade600, Colors.orange.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.activity, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          const Text('LIVE NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          // Pulse effect
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.red.shade100, shape: BoxShape.circle)),
                        ],
                      ),
                      const Spacer(),
                      Text('$_currentWaste kg', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text('Food wasted per second globally', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),

            // Total Today (Blue)
            AnimatedEntrance(
              delay: 0.1,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.trendingDown, color: Colors.blue.shade600, size: 24),
                          const SizedBox(width: 8),
                          Text('TODAY', style: TextStyle(color: Colors.blueGrey.shade600, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Spacer(),
                      Text('${_totalToday.round().toLocaleString()} tons', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                      const Text('Total food wasted today', style: TextStyle(color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ),
            ),

            // Economic Impact (Amber)
            AnimatedEntrance(
              delay: 0.2,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.alertCircle, color: Colors.amber.shade600, size: 24),
                          const SizedBox(width: 8),
                          Text('IMPACT', style: TextStyle(color: Colors.blueGrey.shade600, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Spacer(),
                      Text('\$1.2M', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                      const Text('Economic loss per minute', style: TextStyle(color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLiveChart() {
    return AnimatedEntrance(
      delay: 0.3,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(colors: [Colors.blue.shade500, Colors.cyan.shade500]),
                    ),
                    child: const Icon(LucideIcons.activity, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Live Waste Monitor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                      Text('Real-time global food waste tracking (kg/second)', style: TextStyle(color: Colors.blueGrey.shade600)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.red.shade500, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('LIVE', style: TextStyle(color: Colors.red.shade500, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 350,
                child: LineChart(
                  LineChartData(
                    minY: 1150, // Ajustat pentru a arăta fluctuațiile
                    maxY: 1350,
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < _liveData.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8.0,
                                child: Text(_liveData[index]['time'] as String, style: const TextStyle(fontSize: 10)),
                              );
                            }
                            return const Text('');
                          },
                          interval: 1,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}', style: const TextStyle(fontSize: 12));
                          },
                          reservedSize: 40,
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                      getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: const LineTouchData(enabled: false), // Dezactivează touch pentru simplitate
                    lineBarsData: [
                      LineChartBarData(
                        spots: _liveData.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(), entry.value['waste'].toDouble());
                        }).toList(),
                        isCurved: true,
                        color: Colors.red.shade600,
                        barWidth: 3,
                        dotData: const FlDotData(show: false), // dot: false
                        //isAnimationActive: false, // Oprește animația implicită pentru a arăta fluxul continuu
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegionalBreakdown() {
    return AnimatedEntrance(
      delay: 0.4,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                    child: const Icon(LucideIcons.globe, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Regional Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                      Text('Food waste by region (tons/day)', style: TextStyle(color: Colors.blueGrey.shade600)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.5,
                ),
                itemCount: _globalStats.length,
                itemBuilder: (context, index) {
                  final stat = _globalStats[index];
                  final trendColor = stat['trend'].toString().startsWith('+') ? Colors.red : Colors.green;

                  return AnimatedEntrance(
                    delay: 0.5 + index * 0.1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueGrey.shade200)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(stat['region'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: trendColor.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(stat['trend'] as String, style: TextStyle(color: trendColor.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(stat['waste'].toLocaleString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                          const Text('tons wasted daily', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalCTA(BuildContext context) {
    return AnimatedEntrance(
      delay: 0.8,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(32),
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
              const Text('Help Us Reduce These Numbers',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              const Text(
                'Every person using ReFood AI makes a real difference in fighting food waste',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.sparkles, size: 24),
                label: const Text('Start Making an Impact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extensie simplă pentru formatarea numerelor (simulează toLocaleString)
extension NumberExtension on num {
  String toLocaleString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }
}