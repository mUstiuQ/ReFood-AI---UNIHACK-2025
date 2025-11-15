import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Folosim LucideIcons pentru consistență
import 'DashboardScreen.dart'; // Pentru navigare înapoi

class DonateFoodPage extends StatefulWidget {
  const DonateFoodPage({super.key});

  @override
  State<DonateFoodPage> createState() => _DonateFoodPageState();
}

class _DonateFoodPageState extends State<DonateFoodPage>
    with TickerProviderStateMixin {
  String? selectedType;
  bool showSuccess = false;

  final _formKey = GlobalKey<FormState>();
  final _foodCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // donation types (UI config)
  final List<Map<String, dynamic>> donationTypes = const [
    {
      "id": "animals",
      "title": "Animal Shelters",
      "description": "Help feed animals in need at local shelters",
      "color": 0xFFFF9800, // Orange
      "icon": LucideIcons.dog, // Schimbat din Icons.pets în LucideIcons.paw
    },
    {
      "id": "ngo",
      "title": "NGO Organizations",
      "description": "Support NGOs feeding communities",
      "color": 0xFF2196F3, // Blue
      "icon": LucideIcons.users, // Schimbat din Icons.groups în LucideIcons.users
    },
    {
      "id": "homeless",
      "title": "Homeless People",
      "description": "Provide meals to those experiencing homelessness",
      "color": 0xFFE91E63, // Pink
      "icon": LucideIcons.home, // Schimbat din Icons.home_rounded în LucideIcons.home
    },
  ];

  // Verificare Box Hive
  Box get _box {
    if (!Hive.isBoxOpen('donations')) {
      // Aceasta se poate întâmpla dacă main.dart nu a apucat să se încarce corect la pornire
      // O lăsăm ca o mică apărare, deși nu ar trebui să se întâmple în producție
      throw Exception("Hive donations box is not open. Check main.dart initialization.");
    }
    return Hive.box('donations');
  }

  // ===== API-like (Hive) =====
  Future<List<Map<String, dynamic>>> _listDonations() async {
    // Încarcă valorile și le mapează la tipul corect Map<String, dynamic>
    final vals = _box.values.toList().cast<Map<dynamic, dynamic>>();

    return vals
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
        .reversed // Cele mai noi primele
        .take(5) // Doar 5 recente
        .toList();
  }

  Future<void> _createDonation(Map<String, dynamic> data) async {
    // Validarea este păstrată
    if ((data["food_type"] ?? "").toString().trim().isEmpty) {
      throw Exception("food_type is required");
    }
    if (data["amount"] is! num) {
      throw Exception("amount must be a number");
    }
    if (!["animals", "ngo", "homeless"].contains(data["recipient_type"])) {
      throw Exception("recipient_type invalid");
    }

    final payload = {
      "food_type": data["food_type"],
      "amount": data["amount"],
      "recipient_type": data["recipient_type"],
      "pickup_address": data["pickup_address"],
      "notes": data["notes"],
      "status": "pending",
      "created_date": DateTime.now().toIso8601String(),
    };

    await _box.add(payload);
  }

  Future<void> _handleSubmit() async {
    if (selectedType == null) return;
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;

    try {
      await _createDonation({
        "food_type": _foodCtrl.text.trim(),
        "amount": amount,
        "pickup_address": _addressCtrl.text.trim(),
        "notes": _notesCtrl.text.trim(),
        "recipient_type": selectedType!,
      });

      setState(() => showSuccess = true);
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showSuccess = false;
            selectedType = null;
            _foodCtrl.clear();
            _amountCtrl.clear();
            _addressCtrl.clear();
            _notesCtrl.clear();
            // Aici Hive se va reîncărca automat datorită ValueListenableBuilder
          });
        }
      });
    } catch (e) {
      // Afișează eroarea în UI
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eroare: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFEEF3), Colors.white], // Culori Rose/White
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            // Ascultă box-ul Hive ca să se refacă UI-ul automat
            child: ValueListenableBuilder(
              valueListenable: _box.listenable(),
              builder: (context, Box box, _) {
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _listDonations(),
                  builder: (context, snapshot) {
                    final recent = snapshot.data ?? [];

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.maybePop(context),
                                icon: const Icon(LucideIcons.arrowLeft), // LucideIcons
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Donate Food",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Choose where your food donation goes",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          LayoutBuilder(
                            builder: (context, c) {
                              final isWide = c.maxWidth >= 1000;
                              return Flex(
                                direction: isWide ? Axis.horizontal : Axis.vertical,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Stânga: options / form / success
                                  SizedBox(
                                    width: isWide ? c.maxWidth * 0.66 : c.maxWidth,
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: selectedType == null
                                          ? _buildTypeGrid(c)
                                          : (showSuccess
                                          ? _buildSuccessCard()
                                          : _buildFormCard()),
                                    ),
                                  ),
                                  const SizedBox(height: 16, width: 16),
                                  // Dreapta: recent
                                  SizedBox(
                                    width: isWide ? c.maxWidth * 0.32 : c.maxWidth,
                                    child: _buildRecentDonations(recent),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Donation options ----------
  Widget _buildTypeGrid(BoxConstraints constraints) {
    final cols = constraints.maxWidth >= 768 ? 3 : 1;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: donationTypes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, i) {
        final t = donationTypes[i];
        return _CardButton(
          onTap: () => setState(() => selectedType = t["id"] as String),
          color: Color(t["color"] as int),
          icon: t["icon"] as IconData,
          title: t["title"] as String,
          description: t["description"] as String,
        );
      },
    );
  }

  // ---------- Form ----------
  Widget _buildFormCard() {
    return _Surface(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Donation Details",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => selectedType = null),
                child: const Text("Change Type"),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Form(
            key: _formKey,
            child: Column(
              children: [
                _input(
                  controller: _foodCtrl,
                  label: "Food Type",
                  hint: "e.g., Fresh vegetables, Cooked meals, Canned goods",
                ),
                _input(
                  controller: _amountCtrl,
                  label: "Amount (kg)",
                  hint: "e.g., 5.0",
                  keyboard: TextInputType.number,
                  validator: (v) =>
                  (double.tryParse((v ?? "").replaceAll(',', '.')) == null)
                      ? "Enter a valid number"
                      : null,
                ),
                _input(
                  controller: _addressCtrl,
                  label: "Pickup Address",
                  hint: "Enter your address",
                ),
                _input(
                  controller: _notesCtrl,
                  label: "Additional Notes (Optional)",
                  hint: "Any special instructions or details...",
                  maxLines: 4,
                  required: false,
                ),
                const SizedBox(height: 8),

                GestureDetector(
                  onTap: _handleSubmit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE11D48), Color(0xFFDB2777)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.heart, color: Colors.white), // LucideIcons.heart
                        SizedBox(width: 8),
                        Text(
                          "Submit Donation",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Success ----------
  Widget _buildSuccessCard() {
    return _Surface(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(LucideIcons.checkCircle, size: 84, color: Color(0xFF10B981)), // LucideIcons.checkCircle
          SizedBox(height: 16),
          Text(
            "Thank You! 🎉",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Your donation has been submitted successfully\nSomeone will contact you soon for pickup",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  // ---------- Recent ----------
  Widget _buildRecentDonations(List<Map<String, dynamic>> recent) {
    return _Surface(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Donations",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 14),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text("No donations yet", style: TextStyle(color: Color(0xFF64748B))),
              ),
            ),
          ...recent.map((d) {
            final rt = d["recipient_type"];
            final iconBg = rt == "animals"
                ? const Color(0xFFFFEDD5)
                : rt == "ngo"
                ? const Color(0xFFDBEAFE)
                : const Color(0xFFFFE4E6);
            final iconColor = rt == "animals"
                ? const Color(0xFFF97316)
                : rt == "ngo"
                ? const Color(0xFF2563EB)
                : const Color(0xFFE11D48);

            IconData itemIcon = LucideIcons.utensils; // Icoana implicită
            if (rt == "animals") itemIcon = LucideIcons.dog;
            if (rt == "ngo") itemIcon = LucideIcons.users;
            if (rt == "homeless") itemIcon = LucideIcons.home;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(itemIcon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${d["food_type"]}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        Text("${d["amount"]} kg",
                            style: const TextStyle(
                                fontSize: 12.5, color: Color(0xFF475569))),
                        Text("${d["status"]}".toUpperCase(),
                            style: const TextStyle(
                                fontSize: 11.5, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------- Helpers UI ----------
  Widget _input({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    bool required = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: validator ??
                (v) {
              if (!required) return null;
              if (v == null || v.trim().isEmpty) return "Required";
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}

// --------- mici componente de suprafață ----------
class _Surface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Surface({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.06),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final IconData icon;
  final String title;
  final String description;

  const _CardButton({
    required this.onTap,
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _Surface(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(description, style: const TextStyle(color: Color(0xFF475569))),
          ],
        ),
      ),
    );
  }
}