import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'DashboardScreen.dart';

class GameScore {
  String playerName;
  int score;
  double foodSaved;
  int level;

  GameScore({
    required this.playerName,
    required this.score,
    required this.foodSaved,
    required this.level,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": "GameScore",
      "player_name": playerName,
      "score": score,
      "food_saved": foodSaved,
      "level": level,
    };
  }

  factory GameScore.fromJson(Map<String, dynamic> json) {
    return GameScore(
      playerName: json["player_name"] ?? "Player",
      score: json["score"] ?? 0,
      foodSaved: (json["food_saved"] ?? 0).toDouble(),
      level: json["level"] ?? 1,
    );
  }

  static String encode(GameScore score) => jsonEncode(score.toJson());
  static GameScore decode(String jsonStr) =>
      GameScore.fromJson(jsonDecode(jsonStr));
}

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

  int lives = 3; // ❤️ număr de vieți
  bool gameActive = false;

  GameScore? bestScore;

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
      duration: const Duration(milliseconds: 280),
    );

    loadBestScore();
  }

  Future<String> _filePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/best_score.json';
  }

  Future<void> loadBestScore() async {
    try {
      final path = await _filePath();
      final file = File(path);
      if (file.existsSync()) {
        final content = await file.readAsString();
        setState(() {
          bestScore = GameScore.decode(content);
        });
      }
    } catch (e) {
      // ignore errors
    }
  }

  Future<void> saveScore() async {
    if (bestScore == null || score > bestScore!.score) {
      bestScore = GameScore(
        playerName: "Player",
        score: score,
        foodSaved: foodSaved,
        level: level,
      );
      final path = await _filePath();
      final file = File(path);
      await file.writeAsString(GameScore.encode(bestScore!));
    }
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
      lives = 3; // reset vieți
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

  void endGame({bool gameOver = false}) {
    setState(() => gameActive = false);
    spawnTimer?.cancel();
    gameTimer?.cancel();
    saveScore();

    if (gameOver) {
      // Afișăm un dialog "Game Over"
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Game Over"),
              content: Text(
                  "You missed too many foods!\n\nScore: $score\nLevel: $level\nFood saved: ${foodSaved.toStringAsFixed(1)} kg"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // închide dialogul
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      });
    }
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
    if (!gameActive) return;

    bool shouldGameOver = false;

    setState(() {
      List<FoodItem> updated = [];

      for (var item in fallingItems) {
        item.y += 0.02 + level * 0.005;

        bool caught =
            (item.x - playerPosition).abs() < 0.08 && item.y > 0.85;

        if (caught) {
          score += 10;
          foodSaved += 0.5;
          if (score % 100 == 0) level += 1;
        } else if (item.y >= 1.0) {
          // A CĂZUT JOS NEPRINS → pierzi o viață
          lives -= 1;
          if (lives <= 0) {
            shouldGameOver = true;
          }
        } else if (item.y < 1.2) {
          updated.add(item);
        }
      }

      fallingItems = updated;
    });

    if (shouldGameOver) {
      endGame(gameOver: true);
    }
  }

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
            // HEADER + Back Button
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔙 Back to Dashboard
                  IconButton(
                    icon:
                    const Icon(Icons.arrow_back, size: 28, color: Colors.black87),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),

                  Text("Score: $score",
                      style: const TextStyle(fontSize: 18)),
                  Text("Level: $level",
                      style: const TextStyle(fontSize: 18)),

                  // Vieți rămase
                  Row(
                    children: List.generate(
                      3,
                          (index) => Icon(
                        Icons.favorite,
                        size: 20,
                        color: index < lives ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),

                  Text("${foodSaved.toStringAsFixed(1)} kg",
                      style: const TextStyle(fontSize: 18)),

                  if (gameActive)
                    ElevatedButton(
                      onPressed: () => endGame(gameOver: false),
                      child: const Text("End"),
                    ),
                ],
              ),
            ),

            // BEST SCORE DISPLAY
            if (!gameActive && bestScore != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Best Score: ${bestScore!.score} "
                      "(Level ${bestScore!.level}, "
                      "${bestScore!.foodSaved.toStringAsFixed(1)} kg)",
                  style: const TextStyle(fontSize: 16, color: Colors.green),
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

                  // PLAYER
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
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 45,
                      ),
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
                  child: const Text(
                    "Start Game",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
