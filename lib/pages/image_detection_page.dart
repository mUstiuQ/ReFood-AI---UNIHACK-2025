import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';


class ImageDetectionPage extends StatefulWidget {
  const ImageDetectionPage({super.key});

  @override
  State<ImageDetectionPage> createState() => _ImageDetectionPageState();
}

class _ImageDetectionPageState extends State<ImageDetectionPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _analysis;

  // TODO: move this out of code later (env / secret), for hackathon it's ok:
  static const String _apiKey = 'AIzaSyBEU3k_LbMxtl7I4LlVxOd5YF-29kfEWLc';

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file =
        await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;

    setState(() {
      _selectedImage = File(file.path);
      _analysis = null;
    });
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysis = null;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();

      final model = GenerativeModel(
        model: 'gemini-2.0-flash', // or gemini-1.5-pro
        apiKey: _apiKey,
      );

      final prompt = TextPart(
        '''Analyze this food image and provide:

You are a helpful ReFood AI assistant.Rules:1.1. What food items you can identify
2. Freshness assessment (Fresh, Good, Needs attention, or Spoiled)
3. Storage recommendations
4. Recipe suggestions if the food is still good
5. Estimated days until spoilage
2. Provide practical and friendly advice.3. Respond in plain text only. Do NOT use Markdown, asterisks, dashes, or bullet points. Give text in simple sentences or numbered steps if needed.
 ignore all images that DO NOT contain real food images for example drawings of food must not be answered to!
 add detailed recepies for the food in the picture 
 for the last point tell the user how to check if food is spoiled on the spot
Format your response in a clear, structured way.''',
      );

      final imagePart = DataPart('image/jpeg', bytes);

      final response =
          await model.generateContent([Content.multi([prompt, imagePart])]);

      setState(() {
        _analysis = response.text ?? 'No analysis text returned.';
      });
    } catch (e) {
      setState(() {
        _analysis = 'Error analyzing image: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F3FF), Color(0xFFFFFFFF), Color(0xFFFFF1F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Food Scanner',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF020617),
                              ),
                            ),
                            Text(
                              'AI-powered food freshness detection',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Upload card
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _selectedImage == null
                            ? _buildEmptyState()
                            : _buildSelectedState(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_analysis != null) _buildAnalysisCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            ),
          ),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          'Upload Food Image',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF020617),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Take a photo or upload an image to analyze',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Upload Image'),
              onPressed: () => _pickImage(ImageSource.gallery),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              onPressed: () => _pickImage(ImageSource.camera),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            _selectedImage!,
            height: 260,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isAnalyzing ? 'Analyzing…' : 'Analyze Food'),
              onPressed: _isAnalyzing ? null : _analyzeImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _analysis = null;
                });
              },
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text('Choose Another'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                    ),
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF020617),
                      ),
                    ),
                    Text(
                      'AI-powered food assessment',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            SelectableText(
              _analysis ?? '',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
