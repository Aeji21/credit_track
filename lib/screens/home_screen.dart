import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/storage.dart';
import '../main.dart';
import '../widgets/credit_card_widget.dart';
import '../widgets/summary_card.dart';
import '../widgets/add_credit_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Credit> _credits = [];
  String _name = 'Student';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _credits = CreditStorage.loadCredits();
      _name    = CreditStorage.loadName();
    });
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  double get _oweTotal => _credits
      .where((c) => c.type == CreditType.owe && c.status != CreditStatus.paid)
      .fold(0, (a, c) => a + c.amount);

  double get _recvTotal => _credits
      .where((c) => c.type == CreditType.recv && c.status != CreditStatus.paid)
      .fold(0, (a, c) => a + c.amount);

  int get _oweCount => _credits.where((c) => c.type == CreditType.owe && c.status != CreditStatus.paid).length;
  int get _recvCount => _credits.where((c) => c.type == CreditType.recv && c.status != CreditStatus.paid).length;

  Map<String, List<Credit>> get _grouped {
    final recent = _credits.reversed.take(12).toList();
    final map = <String, List<Credit>>{};
    for (final c in recent) {
      map.putIfAbsent(c.person, () => []).add(c);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _load(),
          color: AppTheme.blue,
          backgroundColor: AppTheme.bg2,
          child: CustomScrollView(
            slivers: [
              // App bar
              SliverToBoxAdapter(child: _buildHeader()),
              // Greeting
              SliverToBoxAdapter(child: _buildGreeting()),
              // Summary cards
              SliverToBoxAdapter(child: _buildSummary()),
              // Recent activity header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                  child: Row(
                    children: [
                      const Text('Recent Activity',
                          style: TextStyle(fontFamily: 'Syne', fontSize: 16, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: const Text('See All', style: TextStyle(fontSize: 12, color: AppTheme.blue, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ),
              // Groups
              if (_grouped.isEmpty)
                const SliverToBoxAdapter(child: _EmptyState())
              else
                SliverList(
                  delegate: SliverChildListDelegate(
                    _grouped.entries.map((e) => _GroupCard(
                      person: e.key,
                      credits: e.value,
                      onRefresh: _load,
                    )).toList(),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Row(
      children: [
        RichText(text: const TextSpan(children: [
          TextSpan(text: 'Credit', style: TextStyle(fontFamily: 'Syne', fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.text1)),
          TextSpan(text: 'Track', style: TextStyle(fontFamily: 'Syne', fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.blue)),
        ])),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.blue, AppTheme.purple]),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(initials(_name), style: const TextStyle(fontFamily: 'Syne', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ],
    ),
  );

  Widget _buildGreeting() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_greeting.toUpperCase(),
            style: const TextStyle(fontSize: 11, color: AppTheme.text3, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text('Hey, $_name 👋',
            style: const TextStyle(fontFamily: 'Syne', fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Track your credits effortlessly',
            style: TextStyle(fontSize: 13, color: AppTheme.text2)),
        const SizedBox(height: 24),
      ],
    ),
  );

  Widget _buildSummary() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Expanded(child: SummaryCard(
          label: 'YOU OWE',
          amount: '₱${_oweTotal.toStringAsFixed(0)}',
          subtitle: '$_oweCount pending',
          color: AppTheme.red,
          icon: Icons.arrow_upward_rounded,
        )),
        const SizedBox(width: 12),
        Expanded(child: SummaryCard(
          label: 'OWED TO YOU',
          amount: '₱${_recvTotal.toStringAsFixed(0)}',
          subtitle: '$_recvCount pending',
          color: AppTheme.green,
          icon: Icons.arrow_downward_rounded,
        )),
      ],
    ),
  );
}

class _GroupCard extends StatelessWidget {
  final String person;
  final List<Credit> credits;
  final VoidCallback onRefresh;

  const _GroupCard({required this.person, required this.credits, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final col = personColor(person);
    final total = credits.fold(0.0, (a, c) => a + c.amount);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Group header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: col.withOpacity(0.15), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(initials(person), style: TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w700, color: col)),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(person, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('${credits.length} transaction${credits.length > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.text3)),
                ]),
                const Spacer(),
                Text('₱${total.toStringAsFixed(0)}',
                    style: TextStyle(fontFamily: 'Syne', fontSize: 14, fontWeight: FontWeight.w700, color: col)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          // Transactions
          ...credits.map((tx) => _TxRow(credit: tx, onRefresh: onRefresh)),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final Credit credit;
  final VoidCallback onRefresh;
  const _TxRow({required this.credit, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final amtColor = credit.type == CreditType.owe ? AppTheme.red : AppTheme.green;
    final sign     = credit.type == CreditType.owe ? '−' : '+';

    return InkWell(
      onTap: () => _openEdit(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
        child: Row(
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(credit.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  credit.dueDate != null ? _fmtDate(credit.dueDate!) : 'No due date',
                  style: const TextStyle(fontSize: 11, color: AppTheme.text3),
                ),
              ],
            )),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('$sign₱${credit.amount.toStringAsFixed(0)}',
                  style: TextStyle(fontFamily: 'Syne', fontSize: 14, fontWeight: FontWeight.w700, color: amtColor)),
              const SizedBox(height: 4),
              StatusBadge(status: credit.status),
            ]),
          ],
        ),
      ),
    );
  }

  void _openEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCreditSheet(existing: credit),
    ).then((saved) { if (saved == true) onRefresh(); });
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month-1]} ${d.day}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(60),
      child: Column(children: [
        Text('💳', style: TextStyle(fontSize: 48)),
        SizedBox(height: 16),
        Text('No credits yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.text2)),
        SizedBox(height: 6),
        Text('Tap + to add your first credit', style: TextStyle(fontSize: 13, color: AppTheme.text3)),
      ]),
    ),
  );
}
