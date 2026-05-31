import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart'; // 1. Import package device_preview

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // 2. Bungkus runApp dengan DevicePreview
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment – Smart Payment',
      debugShowCheckedModeBanner: false,
      // 3. Tambahkan konfigurasi agar sinkron dengan bingkai HP Device Preview
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0E1A),
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4A843),
          secondary: Color(0xFF6C63FF),
          surface: Color(0xFF161829),
        ),
        useMaterial3: true,
      ),
      home: const PaymentScreen(),
    );
  }
}

// ───────────────────────────────────────────────────────────
//  DATA MODEL
// ───────────────────────────────────────────────────────────
class PaymentCategory {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const PaymentCategory({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

const List<PaymentCategory> _categories = [
  PaymentCategory(
    label: 'Water',
    icon: Icons.water_drop_rounded,
    bgColor: Color(0xFF1A2740),
    iconColor: Color(0xFF4FC3F7),
  ),
  PaymentCategory(
    label: 'Electricity',
    icon: Icons.bolt_rounded,
    bgColor: Color(0xFF2A2010),
    iconColor: Color(0xFFFFD54F),
  ),
  PaymentCategory(
    label: 'Gas',
    icon: Icons.local_fire_department_rounded,
    bgColor: Color(0xFF2A1515),
    iconColor: Color(0xFFFF7043),
  ),
  PaymentCategory(
    label: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    bgColor: Color(0xFF201530),
    iconColor: Color(0xFFCE93D8),
  ),
  PaymentCategory(
    label: 'Phone',
    icon: Icons.smartphone_rounded,
    bgColor: Color(0xFF0F2020),
    iconColor: Color(0xFF80CBC4),
  ),
  PaymentCategory(
    label: 'Credit Card',
    icon: Icons.credit_card_rounded,
    bgColor: Color(0xFF1A1A2E),
    iconColor: Color(0xFF7986CB),
  ),
  PaymentCategory(
    label: 'Insurance',
    icon: Icons.verified_user_rounded,
    bgColor: Color(0xFF0A2218),
    iconColor: Color(0xFF66BB6A),
  ),
  PaymentCategory(
    label: 'Mortgage',
    icon: Icons.house_rounded,
    bgColor: Color(0xFF261510),
    iconColor: Color(0xFFFFAB40),
  ),
  PaymentCategory(
    label: 'More',
    icon: Icons.grid_view_rounded,
    bgColor: Color(0xFF1A1A1A),
    iconColor: Color(0xFFBDBDBD),
  ),
];

// ───────────────────────────────────────────────────────────
//  MAIN SCREEN
// ───────────────────────────────────────────────────────────
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  late final AnimationController _cardController;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;

  late final List<AnimationController> _itemControllers;
  late final List<Animation<double>> _itemFades;
  late final List<Animation<Offset>> _itemSlides;

  int _selectedNav = 1;

  @override
  void initState() {
    super.initState();

    // Card animation
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));
    _cardFade = CurvedAnimation(parent: _cardController, curve: Curves.easeIn);

    // Grid items stagger animation
    _itemControllers = List.generate(
      _categories.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _itemFades = _itemControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _itemSlides = _itemControllers
        .map(
          (c) => Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
              .animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)),
        )
        .toList();

    // Kick off animations
    _cardController.forward();
    for (int i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 300 + i * 60), () {
        if (mounted) _itemControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    for (final c in _itemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildBalanceCard(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Categories payment'),
                    const SizedBox(height: 16),
                    _buildCategoryGrid(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Recent Transactions'),
                    const SizedBox(height: 12),
                    _buildRecentTransactions(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF161829),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2D45), width: 1),
            ),
            child: const Icon(Icons.menu_rounded, color: Color(0xFFD4A843), size: 20),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'PaYo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD4A843),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF161829),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2D45), width: 1),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: Color(0xFFD4A843), size: 20),
          ),
        ],
      ),
    );
  }

  // ── BALANCE CARD ─────────────────────────────────────────
  Widget _buildBalanceCard() {
    return SlideTransition(
      position: _cardSlide,
      child: FadeTransition(
        opacity: _cardFade,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1C1E35), Color(0xFF252848)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF3A3D60), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A843).withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFD4A843).withOpacity(0.15),
                        child: const Icon(Icons.person_rounded,
                            color: Color(0xFFD4A843), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF7F84A8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Fauzaan Mujahid',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A843).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFD4A843),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Total Balance',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF7F84A8),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '$ 4.180.200',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _cardAction(Icons.add_rounded, 'Top Up'),
                  const SizedBox(width: 12),
                  _cardAction(Icons.send_rounded, 'Transfer'),
                  const SizedBox(width: 12),
                  _cardAction(Icons.history_rounded, 'History'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardAction(IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showSnack(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFD4A843).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFFD4A843).withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFD4A843), size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFD4A843),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SECTION TITLE ─────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const Text(
          'Lihat semua',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFFD4A843),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── CATEGORY GRID ─────────────────────────────────────────
  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, i) {
        final cat = _categories[i];
        return SlideTransition(
          position: _itemSlides[i],
          child: FadeTransition(
            opacity: _itemFades[i],
            child: _CategoryTile(
              category: cat,
              onTap: () => _showSnack(cat.label),
            ),
          ),
        );
      },
    );
  }

  // ── RECENT TRANSACTIONS ───────────────────────────────────
  Widget _buildRecentTransactions() {
    final List<_TxData> txs = [
      _TxData('PLN Prabayar', 'Listrik', Icons.bolt_rounded,
          const Color(0xFFFFD54F), '-Rp 150.000', '28 Mei'),
      _TxData('PDAM Kota', 'Air', Icons.water_drop_rounded,
          const Color(0xFF4FC3F7), '-Rp 75.000', '25 Mei'),
      _TxData('Top Up Saldo', 'Transfer Masuk', Icons.arrow_downward_rounded,
          const Color(0xFF66BB6A), '+Rp 500.000', '22 Mei'),
    ];
    return Column(
      children: txs.map((tx) => _TransactionTile(data: tx)).toList(),
    );
  }

  // ── BOTTOM NAV ────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      Icons.home_rounded,
      Icons.payment_rounded,
      Icons.bar_chart_rounded,
      Icons.person_rounded,
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF161829),
        border: Border(top: BorderSide(color: Color(0xFF2A2D45), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == _selectedNav;
          return GestureDetector(
            onTap: () => setState(() => _selectedNav = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFD4A843).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                items[i],
                color: selected
                    ? const Color(0xFFD4A843)
                    : const Color(0xFF4A4E6E),
                size: 24,
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showSnack(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka: $label'),
        backgroundColor: const Color(0xFF1C1E35),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
//  CATEGORY TILE
// ───────────────────────────────────────────────────────────
class _CategoryTile extends StatefulWidget {
  final PaymentCategory category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.9, upperBound: 1.0, value: 1.0);
    _scale = _press;
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    return GestureDetector(
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) {
        _press.forward();
        widget.onTap();
      },
      onTapCancel: () => _press.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161829),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2A2D45), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cat.bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(cat.icon, color: cat.iconColor, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                cat.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB0B4D0),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
//  TRANSACTION TILE
// ───────────────────────────────────────────────────────────
class _TxData {
  final String title, subtitle, amount, date;
  final IconData icon;
  final Color iconColor;
  const _TxData(this.title, this.subtitle, this.icon, this.iconColor,
      this.amount, this.date);
}

class _TransactionTile extends StatelessWidget {
  final _TxData data;
  const _TransactionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final isCredit = data.amount.startsWith('+');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161829),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2D45), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF7F84A8)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.amount,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCredit ? const Color(0xFF66BB6A) : Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                data.date,
                style:
                    const TextStyle(fontSize: 10, color: Color(0xFF7F84A8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}