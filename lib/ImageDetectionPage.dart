import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:typed_data'; // Necesar pentru Uint8List
import 'package:lucide_icons/lucide_icons.dart';
import 'DashboardScreen.dart'; // Navigare înapoi la Dashboard

class ImageDetectionPage extends StatefulWidget {
  const ImageDetectionPage({super.key});

  @override
  State<ImageDetectionPage> createState() => _ImageDetectionPageState();
}

class _ImageDetectionPageState extends State<ImageDetectionPage> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? _imageBytes;

  bool _isAnalyzing = false;
  String? _analysis;

  // ATENȚIE: Cheia API este hardcodată, înlocuiește-o cu cheia ta reală!
  static final String _apiKey = dotenv.env['IMAGINE_API_KEY'] ?? '';

  Future<void> _pickImage(ImageSource source) async {
    // Folosim pickImage din picker
    final XFile? file =
    await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;

    // Citim datele binare ale imaginii
    final bytes = await file.readAsBytes();

    setState(() {
      _imageBytes = bytes;
      _analysis = null;
    });
  }

  Future<void> _analyzeImage() async {
    if (_imageBytes == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysis = null;
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
      );

      // Promptul tău lung este păstrat
      const fullPrompt = '''
Analyze this food image and provide:
1. What food items you can identify
2. Freshness assessment (Fresh, Good, Needs attention, or Spoiled)
3. Storage recommendations
4. Recipe suggestions if the food is still good
5. Estimated days until spoilage
Provide practical and friendly advice. Respond in plain text only. Do NOT use Markdown, asterisks, dashes, or bullet points. Give text in simple sentences or numbered steps if needed.
ignore all images that DO NOT contain real food images for example drawings of food must not be answered to!
add detailed recepies for the food in the picture 
for the last point tell the user how to check if food is spoiled on the spot
also if it's a transparent bottle with a yellowish color it can be "tuica", plant based alcohoolic drink and if it's dark red, it can be homemade wine.
Format your response in a clear, structured way.''';

      final promptPart = TextPart(fullPrompt);

      // Folosim datele binare direct pentru a crea DataPart
      final imagePart = DataPart('image/jpeg', _imageBytes!);

      final response = await model.generateContent([
        Content.multi([promptPart, imagePart])
      ]);

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
            // Culorile din codul React: from-purple-50 via-white to-pink-50
            colors: [Color(0xFFF3E8FF), Color(0xFFFFFFFF), Color(0xFFFCE7F6)],
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
                    _buildHeader(context),
                    const SizedBox(height: 24),

                    // Upload card
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _imageBytes == null
                            ? _buildEmptyState(context)
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          // Navigare înapoi la Dashboard
          icon: const Icon(LucideIcons.arrowLeft, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Food Scanner',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade900,
              ),
            ),
            Text(
              'AI-powered food freshness detection',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon Container (cu gradient purple/pink)
        Container(
          width: 96,
          height: 96,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF9333EA), Color(0xFFEC4899)], // purple-500, pink-500
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEC4899).withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ]
          ),
          child: const Icon(LucideIcons.camera, color: Colors.white, size: 40),
        ),
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
            // Buton: Upload Image
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.upload),
              label: const Text('Upload Image'),
              onPressed: () => _pickImage(ImageSource.gallery),
              style: ElevatedButton.styleFrom(
                // Gradient similar cu purple/pink
                backgroundColor: const Color(0xFF9333EA),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // Buton: Take Photo
            OutlinedButton.icon(
              icon: const Icon(LucideIcons.camera),
              label: const Text('Take Photo'),
              onPressed: () => _pickImage(ImageSource.camera),
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blueGrey.shade700,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  side: BorderSide(color: Colors.blueGrey.shade300)
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
        // Afișează imaginea din bytes
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(
            _imageBytes!,
            height: 260,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          alignment: WrapAlignment.center,
          children: [
            // Buton: Analyze Food
            ElevatedButton.icon(
              icon: _isAnalyzing
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(LucideIcons.sparkles),
              label: Text(_isAnalyzing ? 'Analyzing…' : 'Analyze Food'),
              onPressed: _isAnalyzing ? null : _analyzeImage,
              style: ElevatedButton.styleFrom(
                // Gradient similar cu purple/pink
                backgroundColor: const Color(0xFF9333EA),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // Buton: Choose Another
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _imageBytes = null; // Resetăm bytes
                  _analysis = null;
                });
              },
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blueGrey.shade700,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  side: BorderSide(color: Colors.blueGrey.shade300)
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon Container (green/teal)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    // Culorile au fost ajustate la green/teal, similar cu dashboard-ul.
                    gradient: LinearGradient(
                      colors: [Colors.green.shade500, Colors.teal.shade500],
                    ),
                  ),
                  child: const Icon(LucideIcons.checkCircle,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    Text(
                      'AI-powered food assessment',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            SelectableText(
              _analysis ?? '',
              style: const TextStyle(
                fontSize: 16,
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