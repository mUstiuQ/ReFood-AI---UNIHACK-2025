import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'NewStartPage.dart'; // Navigare înapoi la Home

// --- CLASA DE DATE ---

class Review {
  final String id;
  final int rating;
  final String reviewText;
  final String reviewerName;
  final DateTime createdDate;

  Review({
    required this.id,
    required this.rating,
    required this.reviewText,
    required this.reviewerName,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'rating': rating,
    'review_text': reviewText,
    'reviewer_name': reviewerName,
    'created_date': createdDate.toIso8601String(),
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] as String,
    rating: json['rating'] as int,
    reviewText: json['review_text'] as String,
    reviewerName: json['reviewer_name'] as String,
    createdDate: DateTime.parse(json['created_date'] as String),
  );

  static List<Review> decodeList(String jsonString) {
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((d) => Review.fromJson(d)).toList();
  }

  static String encodeList(List<Review> reviews) => jsonEncode(reviews.map((r) => r.toJson()).toList());
}

// --- CLASA PRINCIPALĂ ---

class UserReviewsScreen extends StatefulWidget {
  const UserReviewsScreen({super.key});

  @override
  State<UserReviewsScreen> createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends State<UserReviewsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showForm = false;
  int _rating = 0;
  String _reviewText = '';
  String _reviewerName = '';
  bool _isSubmitting = false;

  List<Review> _reviews = [];
  final int initialBaseUsers = 10000; // Pentru a simula '10k+'

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  // Simulare de apel la baza de date (shared_preferences)
  Future<void> _loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final String? reviewsJson = prefs.getString('reviews');

    if (reviewsJson != null) {
      setState(() {
        // Încarcă și sortează după dată descrescător
        _reviews = Review.decodeList(reviewsJson)
          ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
      });
    }
  }

  Future<void> _saveReview(Review newReview) async {
    _reviews.insert(0, newReview);
    _reviews = _reviews.sublist(0, _reviews.length > 50 ? 50 : _reviews.length); // Limitează la 50

    final prefs = await SharedPreferences.getInstance();
    final String encoded = Review.encodeList(_reviews);
    await prefs.setString('reviews', encoded);
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold(0, (sum, r) => sum + r.rating);
    return total / _reviews.length;
  }

  int get _totalHappyUsers => initialBaseUsers + _reviews.length;


  void _handleSubmit() async {
    if (_formKey.currentState!.validate() && _rating > 0) {
      _formKey.currentState!.save();

      setState(() => _isSubmitting = true);

      // Simulare creare recenzie async
      await Future.delayed(const Duration(milliseconds: 1000));

      final newReview = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        rating: _rating,
        reviewText: _reviewText,
        reviewerName: _reviewerName,
        createdDate: DateTime.now(),
      );

      await _saveReview(newReview);

      setState(() {
        _isSubmitting = false;
        _showForm = false;
        _rating = 0;
        _reviewText = '';
        _reviewerName = '';
      });
    } else if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating.')),
      );
    }
  }

  // --- WIDGET BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Gradient: from-purple-50 via-white to-pink-50
            colors: [Colors.purple.shade50, Colors.white, Colors.pink.shade50],
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

                    // Stats Overview
                    _buildStatsOverview(),
                    const SizedBox(height: 32),

                    // Write Review Button
                    if (!_showForm)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => _showForm = true),
                          icon: const Icon(LucideIcons.star, size: 24),
                          label: const Text('Write a Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            backgroundColor: Colors.purple.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                    // Review Form
                    if (_showForm) _buildReviewForm(),

                    // Reviews List
                    if (_reviews.isNotEmpty || !_showForm) _buildReviewsList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
            Text('User Reviews',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
            Text('See how ReFood AI has helped families worldwide',
                style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth > 600 ? 2.5 : 4.0,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard('Average Rating', _averageRating.toStringAsFixed(1), LucideIcons.star, Colors.amber),
            _buildStatCard('Happy Users', _totalHappyUsers.toStringAsFixed(0), LucideIcons.users, Colors.teal),
            _buildStatCard('Total Reviews', _reviews.length.toString(), LucideIcons.trendingUp, Colors.purple),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, MaterialColor color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(colors: [color.shade500, color.shade300]),
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                Text(title, style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReviewForm() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Share Your Experience', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                const SizedBox(height: 24),

                // Name Input
                Text('Your Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _reviewerName,
                  onChanged: (val) => _reviewerName = val,
                  validator: (val) => val!.isEmpty ? 'Name is required' : null,
                  decoration: const InputDecoration(hintText: 'Enter your name'),
                ),
                const SizedBox(height: 20),

                // Rating Selector
                Text('Rating', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    return IconButton(
                      icon: Icon(
                        LucideIcons.star,
                        color: starValue <= _rating ? Colors.amber : Colors.grey.shade300,
                        size: 40,
                      ),
                      onPressed: () => setState(() => _rating = starValue),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Review Textarea
                Text('Your Review', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _reviewText,
                  onChanged: (val) => _reviewText = val,
                  maxLines: 5,
                  validator: (val) => val!.isEmpty ? 'Review text is required' : null,
                  decoration: const InputDecoration(hintText: 'Tell us how ReFood AI helped you...'),
                ),
                const SizedBox(height: 32),

                // Submit/Cancel Buttons
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () => setState(() => _showForm = false),
                      child: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    if (_reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 64.0),
          child: Column(
            children: [
              Icon(LucideIcons.star, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No reviews yet', style: TextStyle(fontSize: 18, color: Colors.blueGrey.shade600)),
              Text('Be the first to share your experience!', style: TextStyle(color: Colors.blueGrey.shade500)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 32.0, bottom: 16),
          child: Text('Recent Customer Feedback', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
        ),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
          ),
          itemCount: _reviews.length,
          itemBuilder: (context, index) {
            final review = _reviews[index];
            return _buildReviewCard(review, index);
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review, int index) {
    return AnimatedEntrance(
      delay: index * 0.1,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.purple.shade500,
                    child: Text(review.reviewerName.isNotEmpty ? review.reviewerName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(review.reviewerName, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                        Row(
                          children: List.generate(5, (i) => Icon(
                            LucideIcons.star,
                            size: 16,
                            color: i < review.rating ? Colors.amber : Colors.grey.shade300,
                            // LINIEREA 'fill: i < review.rating' A FOST ELIMINATĂ
                          )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(review.reviewText, style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade700), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text(
                'Reviewed on: ${review.createdDate.day}/${review.createdDate.month}/${review.createdDate.year}',
                style: TextStyle(fontSize: 10, color: Colors.blueGrey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar pentru animația de intrare
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
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