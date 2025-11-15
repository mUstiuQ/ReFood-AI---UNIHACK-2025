import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'DashboardScreen.dart'; // Navigare înapoi la Dashboard

// Clasa de date pentru obiectele care cad
class FoodItem {
  final int id;
  double x;
  double y;
  final IconData icon;

  FoodItem({
    required this.id,
    required this.x,
    required this.y,
    required this.icon,
  });
}

class FoodSaverGameScreen extends StatefulWidget {
  const FoodSaverGameScreen({super.key});

  @override
  _FoodSaverGameScreenState createState() => _FoodSaverGameScreenState();
}

class _FoodSaverGameScreenState extends State<FoodSaverGameScreen>
    with SingleTickerProviderStateMixin {
  int score = 0;
  int level = 1;
  double foodSaved = 0; // kg
  bool gameActive = false;

  // Am eliminat logica GameScore și persistența fișierelor (dart:io / path_provider)
  // pentru compatibilitate maximă și rulare imediată.

  // Datele jocului
  List<FoodItem> fallingItems = [];
  double playerPosition = 0.5; // Poziție orizontală între 0.0 și 1.0

  Timer? spawnTimer;
  Timer? gameTimer;

  late AnimationController moveController;
  late Animation<double> moveAnimation;

  final List<IconData> foodIcons = const [
    LucideIcons.apple,
    LucideIcons.cookie,
    LucideIcons.pizza,
    LucideIcons.milk,
    LucideIcons.carrot,
    LucideIcons.egg,
  ];

  @override
  void initState() {
    super.initState();

    moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    spawnTimer?.cancel();
    gameTimer?.cancel();
    moveController.dispose();
    super.dispose();
  }

  void startGame() {
    setState(() {
      score = 0;
      level = 1;
      foodSaved = 0;
      fallingItems.clear();
      playerPosition = 0.5;
      gameActive = true;
    });

    spawnTimer?.cancel();
    gameTimer?.cancel();

    // Rata de apariție scade cu nivelul (max 1500ms, min 350ms)
    spawnTimer = Timer.periodic(
      Duration(milliseconds: max(350, 1500 - level * 100)),
          (_) => spawnFood(),
    );

    // Rata de refresh a jocului
    gameTimer = Timer.periodic(
      const Duration(milliseconds: 40),
          (_) => updateGame(),
    );
  }

  void endGame() {
    setState(() => gameActive = false);
    spawnTimer?.cancel();
    gameTimer?.cancel();
    // Nu apelăm saveScore()
    _showGameOverDialog();
  }

  void spawnFood() {
    final rand = Random();
    setState(() {
      fallingItems.add(
        FoodItem(
          id: DateTime.now().millisecondsSinceEpoch,
          x: rand.nextDouble().clamp(0.1, 0.9), // Evită marginile extreme
          y: 0,
          icon: foodIcons[rand.nextInt(foodIcons.length)],
        ),
      );
    });
  }

  void updateGame() {
    setState(() {
      List<FoodItem> updated = [];
      bool missedFood = false;

      for (var item in fallingItems) {
        // Viteza crește cu nivelul
        item.y += 0.02 + level * 0.005;

        // Verifică capturarea
        bool caught = (item.x - playerPosition).abs() < 0.1 && item.y > 0.88;

        if (caught) {
          score += 10;
          foodSaved += 0.1;
          // Crește nivelul
          if (score % 100 == 0) level += 1;
        } else if (item.y < 1.0) { // Cât timp este în ecran
          updated.add(item);
        } else if (item.y >= 1.0) {
          // Dacă rata de cădere depășește limita, jocul se termină
          missedFood = true;
        }
      }

      fallingItems = updated;
      if (missedFood) endGame();
    });
  }

  void animatePlayerTo(double newX) {
    // Animația de mișcare bazată pe controler
    moveAnimation = Tween<double>(
      begin: playerPosition,
      end: newX,
    ).animate(
      CurvedAnimation(
        parent: moveController,
        curve: Curves.easeOutExpo,
      ),
    )..addListener(() {
      setState(() {
        playerPosition = moveAnimation.value;
      });
    });

    moveController.forward(from: 0);
  }

  void movePlayerLeft() {
    animatePlayerTo((playerPosition - 0.1).clamp(0.0, 1.0));
  }

  void movePlayerRight() {
    animatePlayerTo((playerPosition + 0.1).clamp(0.0, 1.0));
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Game Over!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Scorul tău final: $score', style: const TextStyle(fontSize: 18)),
              Text('Nivel atins: $level', style: const TextStyle(fontSize: 18)),
              Text('Mâncare salvată: ${foodSaved.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 18, color: Colors.green)),
              const SizedBox(height: 16),
              const Text('Mâncarea a căzut pe jos! Încearcă din nou!', style: TextStyle(color: Colors.blueGrey)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Începe un joc nou'),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            ),
            TextButton(
              child: const Text('Mergi la Dashboard'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context); // Închide jocul și merge înapoi la Dashboard
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Ne asigurăm că lățimea și înălțimea sunt calculate corect în funcție de padding-uri
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height - 120; // Aproximăm zona de joc

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            _buildGameHeader(context),

            // BEST SCORE DISPLAY (Simplificat)
            // Lăsăm intenționat gol, deoarece persistența locală nu este disponibilă

            // GAME AREA
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(bottom: BorderSide(color: Colors.green.shade700, width: 4)),
                ),
                child: Stack(
                  children: [
                    // FALLING FOOD
                    ...fallingItems.map((item) {
                      return Positioned(
                        top: item.y * screenH,
                        left: item.x * (screenW - 40),
                        child: Icon(
                          item.icon,
                          size: 40,
                          color: item.icon == LucideIcons.cookie || item.icon == LucideIcons.milk
                              ? Colors.brown.shade400
                              : Colors.green.shade700,
                        ),
                      );
                    }).toList(),

                    // PLAYER — SMOOTH POSITION
                    Positioned(
                      bottom: 40,
                      left: playerPosition * (screenW - 80),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)
                          ],
                          gradient: LinearGradient(
                            colors: [Colors.teal.shade600, Colors.green.shade600],
                          ),
                        ),
                        child: const Icon(LucideIcons.shoppingCart,
                            color: Colors.white, size: 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // CONTROL BUTTONS ȘI CTA
            if (gameActive)
              _buildControlButtons()
            else
              _buildStartButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGameHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.blueGrey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () {
              endGame();
              Navigator.pop(context);
            },
            color: Colors.blueGrey.shade700,
          ),

          _buildStatDisplay('Score', score.toString()),
          _buildStatDisplay('Level', level.toString()),
          _buildStatDisplay('Saved', '${foodSaved.toStringAsFixed(1)} kg', color: Colors.green.shade600),

          if (gameActive)
            ElevatedButton(
              onPressed: endGame,
              child: const Text("END", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatDisplay(String title, String value, {Color? color}) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600)),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color ?? Colors.blueGrey.shade900)),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlButton(LucideIcons.arrowLeft, movePlayerLeft),
          _buildControlButton(LucideIcons.arrowRight, movePlayerRight),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      child: Icon(icon, size: 30),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          // Am lăsat Best Score gol momentan, deoarece nu avem persistență
          const Text(
            "Welcome to Food Saver Game!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            "Use the basket to catch food before it hits the floor. Don't let anything go to waste!",
            style: TextStyle(fontSize: 16, color: Colors.blueGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: startGame,
            icon: const Icon(LucideIcons.play, size: 24),
            label: const Text("Start Game", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 10,
            ),
          ),
        ],
      ),
    );
  }
}