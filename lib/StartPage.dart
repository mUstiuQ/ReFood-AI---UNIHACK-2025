import 'package:flutter/material.dart';

class ReFoodHome extends StatefulWidget {
  const ReFoodHome({super.key});

  @override
  State<ReFoodHome> createState() => _ReFoodHomeState();
}


class _ReFoodHomeState extends State<ReFoodHome>
    with SingleTickerProviderStateMixin {
  bool visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() => visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // --------------------------
            // HERO SECTION
            // --------------------------
            Stack(
              children: [
                // Background Animated Blobs
                Positioned(
                  top: -200,
                  right: -80,
                  child: AnimatedBlob(
                    colors: [Colors.greenAccent.shade400, Colors.teal.shade300],
                  ),
                ),
                Positioned(
                  bottom: -200,
                  left: -80,
                  child: AnimatedBlob(
                    colors: [Colors.orange.shade400, Colors.amber.shade300],
                  ),
                ),

                // Main Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 100),
                  child: Column(
                    children: [
                      AnimatedOpacity(
                        opacity: visible ? 1 : 0,
                        duration: Duration(milliseconds: 800),
                        child: Column(
                          children: [
                            // Logo Badge
                            AnimatedScale(
                              scale: visible ? 1 : 0.6,
                              duration: Duration(milliseconds: 600),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                      color: Colors.green.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 20,
                                      color: Colors.green.shade200
                                          .withOpacity(0.3),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.green.shade500,
                                            Colors.teal.shade500
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.eco,
                                          color: Colors.white, size: 18),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "ReFood AI",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.star_rounded,
                                        color: Colors.green.shade400, size: 18)
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 40),

                            // Title
                            Text(
                              "Reduce Food Waste\nwith AI Intelligence",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                                height: 1.2,
                              ),
                            ),

                            SizedBox(height: 20),

                            Text(
                              "Transform your kitchen into a sustainable powerhouse. "
                                  "Save money, reduce waste, and help the planet.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),

                            SizedBox(height: 40),

                            // CTA Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 28, vertical: 18),
                                    backgroundColor: Colors.teal.shade600,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 10,
                                  ),
                                  onPressed: () {},
                                  child: Row(
                                    children: [
                                      Text("Get Started",
                                          style:
                                          TextStyle(fontSize: 18)),
                                      SizedBox(width: 8),
                                      Icon(Icons.auto_awesome, size: 22)
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 28, vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text("Learn More",
                                      style: TextStyle(fontSize: 18)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 60),

                      // Floating Stats
                      AnimatedOpacity(
                        opacity: visible ? 1 : 0,
                        duration: Duration(milliseconds: 800),
                        child: StatsGrid(),
                      )
                    ],
                  ),
                )
              ],
            ),

            SizedBox(height: 50),

            // FEATURES SECTION
            FeatureSection(),


            SizedBox(height: 80),

            // CTA FINAL
            FinalCTA(),
          ],
        ),
      ),
    );
  }
}

//
// ------------------------------
// WIDGETS
// ------------------------------
//

// Animated blob background
class AnimatedBlob extends StatelessWidget {
  final List<Color> colors;

  const AnimatedBlob({required this.colors, super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.9, end: 1.2),
      duration: Duration(seconds: 6),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(200),
              //borderRadius: 40,
            ),
          ),
        );
      },
    );
  }
}

class StatsGrid extends StatelessWidget {
  final stats = const [
    {"value": "40%", "label": "Waste Reduction"},
    {"value": "\$850", "label": "Annual Savings"},
    {"value": "10k+", "label": "Active Users"},
  ];

  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: stats
          .map(
            (s) => Container(
          width: 180,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color:
                Colors.grey.shade300.withOpacity(0.5),
              )
            ],
          ),
          child: Column(
            children: [
              Text(
                s["value"]!,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [Colors.green, Colors.teal],
                    ).createShader(Rect.fromLTWH(0, 0, 100, 40)),
                ),
              ),
              SizedBox(height: 6),
              Text(
                s["label"]!,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }
}

// Feature Cards
class FeatureSection extends StatelessWidget {
  final features = const [
    {
      "icon": Icons.smart_toy,
      "title": "AI Intelligence",
      "desc": "Advanced algorithms analyze food waste patterns."
    },
    {
      "icon": Icons.eco,
      "title": "Sustainable Living",
      "desc": "Reduce waste and make a positive environmental impact."
    },
    {
      "icon": Icons.restaurant_menu,
      "title": "Smart Recipes",
      "desc": "Suggestions based on ingredients and expiration dates."
    },
    {
      "icon": Icons.bar_chart,
      "title": "Analytics",
      "desc": "Track your savings and sustainability metrics."
    },
    {
      "icon": Icons.flash_on,
      "title": "Instant Insights",
      "desc": "Actionable recommendations in seconds."
    },
    {
      "icon": Icons.notifications_active,
      "title": "Smart Alerts",
      "desc": "Expiring items and restocking automation."
    },
  ];

  const FeatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Intelligent Features",
          style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.bold, height: 1.3),
        ),
        SizedBox(height: 10),
        Text("Powered by AI for modern, sustainable kitchens",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 18)),
        SizedBox(height: 40),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: features
              .map(
                (f) => Container(
              width: 280,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 14,
                    color: Colors.grey.shade300
                        .withOpacity(0.5),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                            colors: [Colors.green, Colors.teal])),
                    child: Icon(f["icon"] as IconData,
                        size: 32, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(f["title"] as String, // CORECTAT AICI
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(f["desc"] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.4)),
                ],
              ),
            ),
          )
              .toList(),
        ),
      ],
    );
  }
}

// Final CTA
class FinalCTA extends StatelessWidget {
  const FinalCTA({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.teal.shade600],
        ),
      ),
      child: Column(
        children: [
          Text(
            "Ready to Transform Your Kitchen?",
            textAlign: TextAlign.center,
            style:
            TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            "Join thousands making a difference.",
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Start Your Journey",
                    style: TextStyle(color: Colors.green.shade700, fontSize: 18)),
                SizedBox(width: 10),
                Icon(Icons.flash_on, color: Colors.green.shade700)
              ],
            ),
          )
        ],
      ),
    );
  }
}