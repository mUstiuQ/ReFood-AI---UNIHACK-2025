import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Recipe {
  final String id;
  final String title;
  final String leftoversUsed;
  final String steps;
  int votes;
  final DateTime createdAt;

  /// Pentru rețetele demo (Unsplash)
  final String? imageUrl;

  /// Pentru rețetele adăugate de utilizator (galerie)
  final File? imageFile;

  bool isLiked;

  Recipe({
    required this.id,
    required this.title,
    required this.leftoversUsed,
    required this.steps,
    required this.votes,
    required this.createdAt,
    this.imageUrl,
    this.imageFile,
    this.isLiked = false,
  });
}

class RecipeLeaderboardPage extends StatefulWidget {
  const RecipeLeaderboardPage({super.key});

  @override
  State<RecipeLeaderboardPage> createState() => _RecipeLeaderboardPageState();
}

class _RecipeLeaderboardPageState extends State<RecipeLeaderboardPage> {
  /// IMAGINI DEMO – nu le schimbăm, doar le folosim
  static const String _bananaMuffinImage =
      'https://images.unsplash.com/photo-1663904458739-5e2ed09582b5?q=80&w=1632&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

  static const String _stirFryImage =
      'https://images.unsplash.com/photo-1588127332622-81dad8da25bc?w=800&auto=format&fit=crop&q=80';

  static const String _pastaBakeImage =
      'https://images.unsplash.com/photo-1522784081430-8ac6a122cbc8?w=800&auto=format&fit=crop&q=80';

  static const String _croutonSaladImage =
      'https://images.unsplash.com/photo-1605291535065-e1d52d2b264a?w=800&auto=format&fit=crop&q=80';

  static const String _roastedVegImage =
      'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=800&auto=format&fit=crop&q=80';

  final List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();

    // Rețete demo (cu URL-uri)
    _recipes.addAll([
      Recipe(
        id: '1',
        title: 'Banana Bread Muffins',
        leftoversUsed: 'Overripe bananas, old yoghurt',
        steps:
        'Mash very ripe bananas, mix with yoghurt, flour and sugar, then bake in muffin tins. Perfect way to save bananas that are almost black.',
        votes: 32,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        imageUrl: _bananaMuffinImage,
      ),
      Recipe(
        id: '2',
        title: 'Leftover Rice Veggie Stir-Fry',
        leftoversUsed: 'Cold rice, stray veggies, soy sauce',
        steps:
        'Use yesterday’s rice, fry any sad veggies in a hot pan, then add the rice and soy sauce. Stir everything for 5–7 minutes until hot and slightly crispy.',
        votes: 25,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        imageUrl: _stirFryImage,
      ),
      Recipe(
        id: '3',
        title: 'Pasta Bake From Yesterday’s Pasta',
        leftoversUsed: 'Cold cooked pasta, tomato sauce, cheese',
        steps:
        'Mix leftover pasta with tomato sauce, top with cheese and bake until the top is golden and bubbly.',
        votes: 20,
        createdAt: DateTime.now().subtract(const Duration(hours: 7)),
        imageUrl: _pastaBakeImage,
      ),
      Recipe(
        id: '4',
        title: 'Crispy Bread Crouton Salad',
        leftoversUsed: 'Old bread, salad greens, any veggies, dressing',
        steps:
        'Cube stale bread, toast with a bit of oil and garlic, then toss with salad greens, leftover veggies and your favourite dressing.',
        votes: 14,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        imageUrl: _croutonSaladImage,
      ),
      Recipe(
        id: '5',
        title: 'Tray-Roasted Leftover Veggies',
        leftoversUsed: 'Soft veggies, wrinkly potatoes, herbs',
        steps:
        'Chop any tired vegetables, toss with oil, salt, pepper and herbs, then roast until caramelised and crispy on the edges.',
        votes: 11,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl: _roastedVegImage,
      ),
    ]);
  }

  // ───────────────── Likes ─────────────────

  void _toggleLike(Recipe recipe) {
    setState(() {
      if (recipe.isLiked) {
        recipe.isLiked = false;
        recipe.votes = recipe.votes - 1;
      } else {
        recipe.isLiked = true;
        recipe.votes = recipe.votes + 1;
      }
      // resort după voturi
      _recipes.sort((a, b) => b.votes.compareTo(a.votes));
    });
  }

  // ───────────────── Add recipe (galerie) ─────────────────

  void _openAddRecipeSheet() {
    final titleController = TextEditingController();
    final leftoversController = TextEditingController();
    final stepsController = TextEditingController();

    File? pickedImageFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (ctx, scrollController) {
            return StatefulBuilder(
              builder: (ctx, setModalState) {
                Future<void> pickFromGallery() async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? file = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (file == null) return;
                  setModalState(() {
                    pickedImageFile = File(file.path);
                  });
                }

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const Text(
                          'Upload a leftover recipe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF022C22),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Share how you rescued leftovers. Add a photo from your gallery that matches the recipe.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Titlu
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Recipe title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Leftovers
                        TextField(
                          controller: leftoversController,
                          decoration: const InputDecoration(
                            labelText: 'Leftovers used',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Pași
                        TextField(
                          controller: stepsController,
                          decoration: const InputDecoration(
                            labelText: 'Short steps / method',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),

                        // Poză din galerie
                        const Text(
                          'Recipe photo (from gallery)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF022C22),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: pickFromGallery,
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF16A34A),
                                width: 1.2,
                              ),
                              color: const Color(0xFFF0FDF4),
                            ),
                            child: pickedImageFile == null
                                ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_rounded,
                                    color: Color(0xFF16A34A),
                                    size: 28,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Tap to choose a photo from gallery',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF047857),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                pickedImageFile!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Butoane
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF16A34A),
                                  side: const BorderSide(
                                      color: Color(0xFF16A34A)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final title = titleController.text.trim();
                                  final leftovers =
                                  leftoversController.text.trim();
                                  final steps = stepsController.text.trim();

                                  if (title.isEmpty || leftovers.isEmpty) {
                                    return;
                                  }

                                  // Dacă nu a ales poză, nu blocăm, dar ar fi nice to have
                                  setState(() {
                                    _recipes.add(
                                      Recipe(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        title: title,
                                        leftoversUsed: leftovers,
                                        steps: steps.isEmpty
                                            ? 'No detailed steps provided.'
                                            : steps,
                                        votes: 0,
                                        createdAt: DateTime.now(),
                                        imageFile: pickedImageFile,
                                      ),
                                    );
                                    _recipes.sort((a, b) =>
                                        b.votes.compareTo(a.votes));
                                  });

                                  Navigator.of(ctx).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                ),
                                child: const Text('Post recipe'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ───────────────── UI main ─────────────────

  @override
  Widget build(BuildContext context) {
    final recipes = [..._recipes]..sort((a, b) => b.votes.compareTo(a.votes));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF0FDF4), Color(0xFFFFFFFF), Color(0xFFE0F2FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 12),
                    _buildSummaryBanner(recipes.length),
                    const SizedBox(height: 12),
                    _buildFilterRow(),
                    const SizedBox(height: 12),
                    _buildRecipeList(recipes),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddRecipeSheet,
        backgroundColor: const Color(0xFF16A34A),
        icon: const Icon(Icons.upload_rounded, color: Colors.white),
        label: const Text(
          'Upload recipe',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // ───────────────── sub-widgets ─────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF065F46)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 8),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leftover Recipe Leaderboard',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF022C22),
              ),
            ),
            Text(
              'Upload recipes using leftover food and upvote the best ideas',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(int count) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(999),
            ),
            child:
            const Icon(Icons.leaderboard, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$count community recipes using leftovers',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF065F46),
              ),
            ),
          ),
          const Text(
            'Most upvoted first',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF047857),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: const [
          _FilterPill(
            label: 'All recipes',
            selected: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(List<Recipe> recipes) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final rank = index + 1;
        return _buildRecipeCard(recipe, rank);
      },
    );
  }

  Widget _buildRecipeCard(Recipe recipe, int rank) {
    final bool liked = recipe.isLiked;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // rank + likes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _toggleLike(recipe),
                  child: Row(
                    children: [
                      Icon(
                        liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 18,
                        color: liked
                            ? const Color(0xFF16A34A) // verde când e like
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.votes.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: liked
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // imagine (local sau URL)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: recipe.imageFile != null
                  ? Image.file(
                recipe.imageFile!,
                fit: BoxFit.cover,
              )
                  : Image.network(
                recipe.imageUrl ?? _roastedVegImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE5E7EB),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFF9CA3AF),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // text
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF022C22),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.recycling_rounded,
                        size: 14,
                        color: Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Leftovers used: ${recipe.leftoversUsed}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recipe.steps,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Posted ${_timeAgo(recipe.createdAt)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} h ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} min ago';
    } else {
      return 'Just now';
    }
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterPill({
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF16A34A) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(
            Icons.list_alt,
            size: 14,
            color: selected ? Colors.white : const Color(0xFF4B5563),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}