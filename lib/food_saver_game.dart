import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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

class FoodSaverGame extends StatefulWidget {
  const FoodSaverGame({super.key});

  @override
  _FoodSaverGameState createState() => _FoodSaverGameState();
}

class _FoodSaverGameState extends State<FoodSaverGame>
    with SingleTickerProviderStateMixin {
  int score = 0;
  int level = 1;
  double foodSaved = 0;
  bool gameActive = false;

  List<FoodItem> fallingItems = [];
  double playerPosition = 0.5;

  Timer? spawnTimer;
  Timer? gameTimer;

  late AnimationController moveController;
  late Animation<double> moveAnimation;

  final List<IconData> foodIcons = [
    Icons.apple,
    Icons.cookie,
    Icons.local_pizza,
    Icons.icecream,
  ];

  @override
  void initState() {
    super.initState();

    moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280), // smooth movement
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

    spawnTimer = Timer.periodic(
      Duration(milliseconds: max(350, 1500 - level * 120)),
          (_) => spawnFood(),
    );

    gameTimer = Timer.periodic(
      const Duration(milliseconds: 40),
          (_) => updateGame(),
    );
  }

  void endGame() {
    setState(() => gameActive = false);
    spawnTimer?.cancel();
    gameTimer?.cancel();
  }

  void spawnFood() {
    final rand = Random();
    setState(() {
      fallingItems.add(
        FoodItem(
          id: DateTime.now().millisecondsSinceEpoch,
          x: rand.nextDouble(),
          y: 0,
          icon: foodIcons[rand.nextInt(foodIcons.length)],
        ),
      );
    });
  }

  void updateGame() {
    setState(() {
      List<FoodItem> updated = [];

      for (var item in fallingItems) {
        item.y += 0.02 + level * 0.005;

        bool caught = (item.x - playerPosition).abs() < 0.08 && item.y > 0.85;

        if (caught) {
          score += 10;
          foodSaved += 0.5;
          if (score % 100 == 0) level += 1;
        } else if (item.y < 1.2) {
          updated.add(item);
        }
      }

      fallingItems = updated;
    });
  }

  // FIXED SMOOTH MOVEMENT — ALWAYS STARTS FROM CURRENT POSITION
  void animatePlayerTo(double newX) {
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
    animatePlayerTo((playerPosition - 0.06).clamp(0.0, 1.0));
  }

  void movePlayerRight() {
    animatePlayerTo((playerPosition + 0.06).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Score: $score", style: const TextStyle(fontSize: 18)),
                  Text("Level: $level", style: const TextStyle(fontSize: 18)),
                  Text("${foodSaved.toStringAsFixed(1)} kg",
                      style: const TextStyle(fontSize: 18)),
                  if (gameActive)
                    ElevatedButton(
                      onPressed: endGame,
                      child: const Text("End"),
                    ),
                ],
              ),
            ),

            // GAME AREA
            Expanded(
              child: Stack(
                children: [
                  // FALLING FOOD
                  ...fallingItems.map((item) {
                    return Positioned(
                      top: item.y * (screenH - 220),
                      left: item.x * (screenW - 40),
                      child: Icon(
                        item.icon,
                        size: 40,
                        color: Colors.orange,
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.teal, Colors.green],
                        ),
                      ),
                      child: const Icon(Icons.star,
                          color: Colors.white, size: 45),
                    ),
                  ),
                ],
              ),
            ),

            // CONTROL BUTTONS
            if (gameActive)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: movePlayerLeft,
                      child: const Icon(Icons.arrow_left),
                    ),
                    ElevatedButton(
                      onPressed: movePlayerRight,
                      child: const Icon(Icons.arrow_right),
                    ),
                  ],
                ),
              ),

            if (!gameActive)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: startGame,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  child: const Text("Start Game", style: TextStyle(fontSize: 22)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
