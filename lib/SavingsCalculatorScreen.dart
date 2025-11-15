import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'NewStartPage.dart'; // Navigare înapoi la Home

class SavingsCalculatorScreen extends StatefulWidget {
  const SavingsCalculatorScreen({super.key});

  @override
  State<SavingsCalculatorScreen> createState() => _SavingsCalculatorScreenState();
}

class _SavingsCalculatorScreenState extends State<SavingsCalculatorScreen> {
  // Stările din React (useState)
  int familySize = 4;
  int monthlyGroceries = 800;

  // Constante
  final double wastePercentage = 30; // 30% waste
  final double reductionWithApp = 40; // 40% reduction of waste

  // Controllere pentru formular
  final TextEditingController _familyController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _familyController.text = familySize.toString();
    _budgetController.text = monthlyGroceries.toString();
  }

  double get monthlyWaste => (monthlyGroceries * wastePercentage) / 100;
  double get monthlySavings => (monthlyWaste * reductionWithApp) / 100;
  double get annualSavings => monthlySavings * 12;
  double get tenYearSavings => annualSavings * 10;

  // Datele pentru grafice
  List<Map<String, dynamic>> get yearlyProjection {
    return List.generate(10, (i) {
      final year = 2025 + i;
      // În codul React era o eroare în calculul cumulatului. Am simplificat la o acumulare liniară.
      final cumulative = annualSavings * (i + 1);
      return {
        'year': year.toString(),
        'savings': annualSavings,
        'cumulative': cumulative,
      };
    });
  }

  final List<Map<String, dynamic>> savingsBreakdown = const [
    { 'name': 'Fruits & Vegetables', 'value': 28, 'color': Color(0xFF10B981) }, // green-600
    { 'name': 'Meat & Fish', 'value': 25, 'color': Color(0xFF3B82F6) },      // blue-500
    { 'name': 'Dairy Products', 'value': 18, 'color': Color(0xFFF59E0B) },  // amber-500
    { 'name': 'Bread & Bakery', 'value': 15, 'color': Color(0xFFEC4899) },   // pink-500
    { 'name': 'Other', 'value': 14, 'color': Color(0xFF8B5CF6) },          // purple-500
  ];

  void _updateValues() {
    if (_familyController.text.isNotEmpty && _budgetController.text.isNotEmpty) {
      setState(() {
        familySize = int.tryParse(_familyController.text) ?? 1;
        monthlyGroceries = int.tryParse(_budgetController.text) ?? 100;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Gradient: from-amber-50 via-white to-yellow-50
            colors: [Colors.amber.shade50, Colors.white, Colors.yellow.shade50],
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
                    const SizedBox(height: 24),

                    // 1. Calculator Input & Results
                    _buildCalculatorCard(),
                    const SizedBox(height: 24),

                    // 2. Projection Chart
                    _buildProjectionChart(),
                    const SizedBox(height: 24),

                    // 3. Breakdown & What You Could Buy
                    _buildBreakdownSection(),
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
            Text('Savings Calculator',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
            Text('Calculate how much your family can save with ReFood AI',
                style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600)),
          ],
        ),
      ],
    );
  }

  Widget _buildCalculatorCard() {
    // Culori din React: emerald/teal, amber/yellow, blue/cyan
    final Color greenStart = Colors.green.shade500;
    final Color tealEnd = Colors.teal.shade500;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(colors: [Colors.amber.shade500, Colors.yellow.shade500]),
                  ),
                  child: const Icon(LucideIcons.calculator, size: 24, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text('Your Family Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
              ],
            ),
            const SizedBox(height: 24),

            // INPUTS
            LayoutBuilder(
              builder: (context, constraints) {
                return Flex(
                  direction: constraints.maxWidth > 500 ? Axis.horizontal : Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Family Size', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey.shade700)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _familyController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _updateValues(),
                            decoration: InputDecoration(
                              hintText: 'e.g., 4',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (constraints.maxWidth > 500) const SizedBox(width: 24),
                    if (constraints.maxWidth <= 500) const SizedBox(height: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monthly Grocery Budget (\$)', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey.shade700)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _updateValues(),
                            decoration: InputDecoration(
                              hintText: 'e.g., 800',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // RESULTS
            LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: constraints.maxWidth > 600 ? 3 : 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: constraints.maxWidth > 600 ? 1.5 : 3.5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildResultBox('Monthly Savings', '\$${monthlySavings.toStringAsFixed(2)}', Colors.green.shade500, Colors.teal.shade50),
                      _buildResultBox('Annual Savings', '\$${annualSavings.toStringAsFixed(2)}', Colors.amber.shade500, Colors.yellow.shade50),
                      _buildResultBox('10-Year Savings', '\$${tenYearSavings.toStringAsFixed(2)}', Colors.blue.shade500, Colors.cyan.shade50),
                    ],
                  );
                }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBox(String title, String value, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: bgColor,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: color.shade700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color.shade900)),
        ],
      ),
    );
  }


  Widget _buildProjectionChart() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
                  child: const Icon(LucideIcons.trendingUp, size: 24, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Savings Projection (2025-2035)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                    Text('Your cumulative savings over the next decade', style: TextStyle(color: Colors.blueGrey.shade600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: tenYearSavings * 1.1,
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < yearlyProjection.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8.0,
                              child: Text(yearlyProjection[index]['year'] as String, style: const TextStyle(fontSize: 12)),
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
                          if (value == 0) return const Text('\$0');
                          if (value % 500 == 0) return Text('\$${value.toInt()}', style: const TextStyle(fontSize: 12));
                          return const Text('');
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
                  lineTouchData: const LineTouchData(enabled: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: yearlyProjection.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['cumulative'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.green.shade600,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: Colors.green.shade600.withOpacity(0.3)),
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

  Widget _buildBreakdownSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Flex(
          direction: constraints.maxWidth > 900 ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(colors: [Colors.purple.shade500, Colors.pink.shade500]),
                            ),
                            child: const Icon(LucideIcons.dollarSign, size: 24, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Text('Savings by Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sections: savingsBreakdown.map((data) {
                              return PieChartSectionData(
                                color: data['color'] as Color,
                                value: data['value'].toDouble(),
                                title: '${data['name']}: ${data['value']}%',
                                radius: 100,
                                titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                badgeWidget: Text('${data['value']}%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                                badgePositionPercentageOffset: 0.9,
                              );
                            }).toList(),
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...savingsBreakdown.map((data) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(color: data['color'] as Color, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('${data['name']}: ${data['value']}%', style: TextStyle(color: Colors.blueGrey.shade700)),
                          ],
                        ),
                      )).toList()
                    ],
                  ),
                ),
              ),
            ),
            if (constraints.maxWidth > 900) const SizedBox(width: 24),
            Expanded(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('What You Could Buy Instead', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                      const SizedBox(height: 24),
                      ...[
                        { 'item': '🏖️ Family Vacation', 'multiplier': 2.0 },
                        { 'item': '📱 New Smartphone', 'multiplier': 0.7 },
                        { 'item': '🎓 Online Courses', 'multiplier': 0.5 },
                        { 'item': '🌱 Home Garden Setup', 'multiplier': 0.3 }
                      ].map((item) {
                        final cost = annualSavings * (item['multiplier'] as double);
                        final yearsToSave = (cost / annualSavings).ceil();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item['item'] as String, style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade900)),
                                    Text('\$${cost.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade600)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Save for $yearsToSave year(s) with ReFood AI',
                                  style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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
}

extension on Color {
  Color? get shade700 => null;

  Color? get shade900 => null;
}