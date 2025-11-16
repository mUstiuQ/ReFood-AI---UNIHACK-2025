import 'package:flutter/material.dart';
import 'dart:math';
import '../app_theme.dart'; // Import shared theme
import '../widgets/neon_background.dart'; // Import shared widget
import 'login_page.dart'; // <--- ca să putem naviga înapoi la LoginPage

// --- Page Constants ---
const double cardWidth = 320;
// Increased height to make room for the extra field
const double cardHeight = 560;

// --- Main Sign Up Page Widget ---
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  // Controllere pentru câmpuri (utile dacă vrei ulterior să legi de backend)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));

    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
    _controller.repeat();

    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// 🔥 DEMO: „magărie” de prezentare
  /// Nu verifică nimic, nu scrie în baza de date.
  /// Doar arată cum AR ARĂTA logica reală (comentată)
  /// și apoi te duce înapoi la LoginPage.
  Future<void> _fakeSignUp() async {
    // -----------------------------
    // AICI AR FI LOGICA REALĂ CU BAZA DE DATE (Firebase, API, etc.)
    // Toată secțiunea de mai jos e DOAR EXEMPLU și este comentată.
    //
    // import 'package:firebase_auth/firebase_auth.dart';
    // import 'package:cloud_firestore/cloud_firestore.dart';
    //
    // try {
    //   final email = _emailController.text.trim();
    //   final password = _passwordController.text.trim();
    //
    //   // 1. Creare user în Firebase Auth
    //   final userCredential = await FirebaseAuth.instance
    //       .createUserWithEmailAndPassword(email: email, password: password);
    //
    //   // 2. Salvare info user și în Firestore
    //   final user = userCredential.user;
    //   if (user != null) {
    //     await FirebaseFirestore.instance
    //         .collection('users')
    //         .doc(user.uid)
    //         .set({
    //       'email': email,
    //       'createdAt': FieldValue.serverTimestamp(),
    //     });
    //   }
    // } catch (e) {
    //   // tratare erori reale
    //   debugPrint('Sign up error: $e');
    // }
    // -----------------------------

    // Pentru DEMO: mergem direct înapoi la LoginPage
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: lightGreenBg, // Use light green background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- This is the animated card ---
            ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Base card with shadow
                  Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade100,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // 2. Top-left animated border
                  Positioned(
                    top: cardHeight / 2,
                    left: cardWidth / 2,
                    child: NeonBackground(
                      width: cardWidth,
                      height: cardHeight,
                      alignment: Alignment.topLeft,
                      animation: _animation,
                      colors: const [
                        Colors.transparent,
                        primaryGreen, // Use green
                      ],
                    ),
                  ),
                  // 3. Bottom-right animated border
                  Positioned(
                    bottom: cardHeight / 2,
                    right: cardWidth / 2,
                    child: NeonBackground(
                      height: cardHeight,
                      width: cardWidth,
                      alignment: Alignment.bottomRight,
                      animation: _animation,
                      colors: const [
                        primaryGreen, // Use green
                        Colors.transparent,
                      ],
                    ),
                  ),
                  // 4. Inner container with form
                  GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      width: cardWidth - 10,
                      height: cardHeight - 10,
                      decoration: const BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      // --- This is the Sign Up Form ---
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 25),
                            // Logo (uses the same asset)
                            Image.asset(
                              'assets/images/logo.png',
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(height: 25),
                            // Email Field
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Colors.grey[600],
                                ),
                                labelText: 'Email',
                                filled: true,
                                fillColor: Colors.grey[100],
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                  borderSide: BorderSide(
                                    color: primaryGreen,
                                    width: 2,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 15),
                            // Password Field
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.grey[600],
                                ),
                                labelText: 'Password',
                                filled: true,
                                fillColor: Colors.grey[100],
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                  borderSide: BorderSide(
                                    color: primaryGreen,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Confirm Password Field
                            TextField(
                              controller: _confirmController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock_clock_outlined,
                                  color: Colors.grey[600],
                                ),
                                labelText: 'Confirm Password',
                                filled: true,
                                fillColor: Colors.grey[100],
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                  borderSide: BorderSide(
                                    color: primaryGreen,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            // Button
                            ElevatedButton(
                              onPressed: _fakeSignUp, // 👈 MAGĂRIA DE DEMO
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      // --- End of form ---
                    ),
                  ),
                ],
              ),
            ),
            // --- "Go Back" Button ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account?",
                  style: TextStyle(color: grey),
                ),
                TextButton(
                  onPressed: () {
                    // Ne întoarcem la LoginPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
