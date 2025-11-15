import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'signup_page.dart';
import '../app_theme.dart';
import '../widgets/neon_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unihack_2025/DashboardScreen.dart';

const double cardWidth = 320;
const double cardHeight = 480;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    super.dispose();
  }

  // --- 6. SIGN IN WITH GOOGLE (CORRECTED) ---
  // CORRECTED GOOGLE SIGN-IN FOR google_sign_in 7.x

  Future<void> _signInWithGoogle() async {
    try {
      // 1. Create a GoogleSignIn instance
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: <String>['email'],
      );

      // 2. Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return;
      }

      // 3. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 4. Check if we have the tokens (they might be null in some cases)
      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token from Google Sign-In');
      }

      // 5. Create a new Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,  // Can be null, that's okay
        idToken: googleAuth.idToken,
      );

      // 6. Sign in to Firebase with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 7. Navigate to Dashboard if successful
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to sign in with Google: ${e.message}")),
        );
      }
    } catch (e) {
      // Handle other errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An unexpected error occurred: $e")),
        );
      }
    }
  }

  // --- SIGN IN WITH EMAIL ---
  Future<void> _signIn() async {
    // ... (Your existing, correct signIn code) ...
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      String errorMessage = "An error occurred. Please try again.";
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // --- FORGOT PASSWORD ---
  Future<void> _forgotPassword() async {
    // ... (Your existing, correct forgotPassword code) ...
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter your email to reset password.")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Password reset email sent. Check your inbox.")),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      String errorMessage = "An error occurred.";
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: lightGreenBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ... (All your containers and animations) ...
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
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 25),
                            // *** BUG 1: FIXED ***
                            Image.asset(
                              'assets/images/logo.jpg', // <-- FIXED
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(height: 25),
                            TextField(
                              controller: _emailController,
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
                            TextField(
                              controller: _passwordController,
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
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _forgotPassword,
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: primaryGreen),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed:
                              _signInWithGoogle, // Call your new function
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryGreen,
                                minimumSize: const Size.fromHeight(50),
                                side: const BorderSide(
                                    color: primaryGreen, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?",
                    style: TextStyle(color: grey)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()),
                    );
                  },
                  child: const Text(
                    'Sign Up',
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