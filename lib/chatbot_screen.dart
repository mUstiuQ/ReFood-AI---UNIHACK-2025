import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Simulare client API (pentru a înlocui base44.integrations.Core.InvokeLLM)
class AIService {
  static Future<String> invokeLLM(String prompt) async {
    // Simulează o întârziere și un răspuns de la un model LLM
    await Future.delayed(const Duration(seconds: 2));

    // Logică simplă de răspuns (înlocuiește cu API-ul tău real)
    if (prompt.toLowerCase().contains('hello') || prompt.toLowerCase().contains('salut')) {
      return 'Salut! Mă bucur că ești aici. Cum pot să te ajut să reduci risipa alimentară?';
    } else if (prompt.toLowerCase().contains('reduce food waste')) {
      return 'Pentru a reduce risipa, începe prin a verifica frigiderul înainte de a merge la cumpărături și folosește metoda FIFO (First In, First Out) în bucătărie. Poți folosi și rețete creative pentru resturi!';
    } else {
      return 'Îmi cer scuze, dar nu pot răspunde la întrebarea ta chiar acum. Încearcă să mă întrebi despre sfaturi de stocare, rețete cu resturi sau planificare a meselor.';
    }
  }
}

class Message {
  final String role; // 'user' sau 'assistant'
  final String content;

  Message({required this.role, required this.content});
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  final List<Message> _messages = [
    Message(
      role: 'assistant',
      content:
      'Hello! 👋 I\'m your ReFood AI assistant. I can help you with food waste reduction tips, recipe suggestions, storage advice, and sustainability questions. How can I help you today?',
    )
  ];

  final List<String> _quickActions = const [
    'How can I reduce food waste?',
    'Recipe ideas with leftovers',
    'Best way to store vegetables',
    'Tips for meal planning'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSend() async {
    final userMessage = _textController.text.trim();
    if (userMessage.isEmpty || _isLoading) return;

    _textController.clear();

    setState(() {
      _messages.add(Message(role: 'user', content: userMessage));
      _isLoading = true;
    });

    // Asigură scroll la mesajul utilizatorului
    _scrollToBottom();

    // Construiește promptul
    final prompt = """
        You are a helpful ReFood AI assistant specializing in food waste reduction, sustainability, recipe suggestions, and food storage tips. 
        
        User question: $userMessage

        Provide helpful, practical advice in a friendly tone. Keep responses concise but informative.
        """;

    try {
      final response = await AIService.invokeLLM(prompt);

      setState(() {
        _messages.add(Message(role: 'assistant', content: response));
      });
    } catch (error) {
      setState(() {
        _messages.add(Message(
            role: 'assistant',
            content: 'I apologize, but I encountered an error. Please try again.'));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      // Asigură scroll la răspunsul asistentului
      _scrollToBottom();
    }
  }

  void _onQuickActionTap(String action) {
    _textController.text = action;
    _handleSend();
  }

  @override
  Widget build(BuildContext context) {
    // Definirea gradientului de fundal (from-blue-50 via-white to-cyan-50)
    final backgroundGradient = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.blue.shade50,
          Colors.white,
          Colors.cyan.shade50,
        ],
      ),
    );

    return Scaffold(
      body: Container(
        decoration: backgroundGradient,
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              _buildHeader(context),

              // MESSAGES CONTAINER
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        // Afișează indicatorul de încărcare (Thinking...)
                        return _buildThinkingIndicator();
                      }
                      final message = _messages[index];
                      return _buildMessageBubble(message, index);
                    },
                  ),
                ),
              ),

              // QUICK ACTIONS
              if (_messages.length == 1 && !_isLoading) _buildQuickActions(),

              // INPUT AREA
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: Colors.blueGrey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          )
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft, size: 20),
            onPressed: () => Navigator.pop(context), // Navigare înapoi la Dashboard
            color: Colors.blueGrey.shade700,
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [Colors.blue.shade500, Colors.cyan.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI Assistant',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              Text('Always here to help',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, int index) {
    final bool isUser = message.role == 'user';
    final Color bubbleColor = isUser ? const Color(0xFF1E88E5) : Colors.white; // Blue/Cyan Gradient pentru user, Alb pentru assistant
    final Color textColor = isUser ? Colors.white : Colors.blueGrey.shade800;

    // Simulează motion.div initial={{ opacity: 0, y: 20 }}
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ScaleTransition( // Simulează o animație de apariție (initial: scale 0.9, animate: scale 1.0)
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(
              parent: AlwaysStoppedAnimation(1.0), // Nu folosim controller explicit pentru fiecare mesaj
              curve: Curves.easeOut,
            )
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
              bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isUser ? 0.2 : 0.05),
                blurRadius: 4,
              )
            ],
            // Aplică gradient pentru user, similar cu 'bg-gradient-to-br from-blue-600 to-cyan-600'
            gradient: isUser
                ? LinearGradient(
              colors: [Colors.blue.shade600, Colors.cyan.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
          ),
          child: isUser
              ? Text(message.content, style: TextStyle(color: textColor))
              : MarkdownBody(
            data: message.content,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: TextStyle(color: textColor, fontSize: 14),
              // Poți adăuga mai multe stiluri pentru Markdown aici (h1, strong, etc.)
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    // Simulează thinking indicator cu motion.div
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blueGrey.shade200),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)), // blue-500
              ),
            ),
            const SizedBox(width: 8),
            Text('Thinking...', style: TextStyle(color: Colors.blueGrey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: _quickActions.map((action) {
          // Simulează motion.button cu whileHover/whileTap și staggered animation
          return GestureDetector(
            onTap: () => _onQuickActionTap(action),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blueGrey.shade200),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  )
                ],
              ),
              child: Text(
                action,
                style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade700),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.blueGrey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Ask me anything about food waste...",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blueGrey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blueGrey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2), // Focus border similar cu blue-500
                ),
              ),
              onSubmitted: (_) => _handleSend(), // Permite trimiterea cu tasta Enter
              keyboardType: TextInputType.multiline,
              maxLines: null,
              enabled: !_isLoading,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _textController.text.trim().isEmpty || _isLoading ? null : _handleSend,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: Color(0xFF3B82F6), // blue-600
              disabledBackgroundColor: Colors.blueGrey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.blue.shade300,
            ),
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(LucideIcons.send, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}