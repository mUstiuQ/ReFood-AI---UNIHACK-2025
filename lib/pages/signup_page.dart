import 'package:flutter/material.dart';
import 'dart:math';
import '../app_theme.dart'; // Import shared theme
import '../widgets/neon_background.dart'; // Import shared widget

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
    super.dispose();
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
                      FocusManager.instance.primaryFocus!.unfocus();
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
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                prefixIcon:
                                Icon(Icons.email, color: Colors.grey[600]),
                                labelText: 'Email',
                                filled: true,
                                fillColor: Colors.grey[100],
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                  BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: primaryGreen, width: 2),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 15),
                            // Password Field
                            TextField(
                              obscureText: true,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                prefixIcon:
                                Icon(Icons.lock, color: Colors.grey[600]),
                                labelText: 'Password',
                                filled: true,
                                fillColor: Colors.grey[100],
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                  BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: primaryGreen, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            // *** NEW FIELD ***
                            TextField(
                              obscureText: true,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_clock_outlined,
                                    color: Colors.grey[600]),
                                labelText: 'Confirm Password',
                                filled: true,
                                fillColor: Colors.grey[100],
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                  BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: primaryGreen, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            // *** BUTTON TEXT CHANGED ***
                            ElevatedButton(
                              onPressed: () {
                                // Sign up logic
                              },
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
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
                const Text("Already have an account?",
                    style: TextStyle(color: grey)),
                TextButton(
                  onPressed: () {
                    // This will close the sign up page and go back
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                        color: primaryGreen, fontWeight: FontWeight.bold),
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