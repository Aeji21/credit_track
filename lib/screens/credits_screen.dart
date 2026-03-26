import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/storage.dart';
import '../main.dart';
import '../widgets/credit_card_widget.dart';
import '../widgets/add_credit_sheet.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});
  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  List<Credit> _all = [];
  String _filter = 'All';
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _all = CreditStorage.loadCredits());

  List<Credit> get _filtered {
    var list = _all.toList();
    if (_filter != 'All') {
      final s = CreditStatus.values.firstWhere((s) => s.label == _filter);
      list = list.where((c) => c.status == s).toList();
    }
    if (_search.isNotEmpty) {
      list = list
          .where((c) =>
              c.title.toLowerCase().contains(_search) ||
              c.person.toLowerCase().contains(_search))
          .toList();
    }
    return list;
  }

  double get _total => _filtered.fold(0, (a, c) => a + c.amount);

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('All Credits',
                            style: TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        const Text('Every transaction, one place',
                            style:
                                TextStyle(fontSize: 12, color: AppTheme.text2)),
                      ]),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.blue.withOpacity(0.15),
                      border: Border.all(color: AppTheme.blue.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('₱${_total.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.blue)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _search = v.toLowerCase()),
                style: const TextStyle(color: AppTheme.text1, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by title or person…',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.text3, size: 20),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              color: AppTheme.text3, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          })
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter pills
            SizedBox(
              height: 36,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: ['All', 'Overdue', 'Upcoming', 'Paid'].map((f) {
                  final active = _filter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? AppTheme.blue : Colors.transparent,
                        border: Border.all(
                            color: active ? AppTheme.blue : AppTheme.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(f,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: active ? Colors.white : AppTheme.text2)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // List
            Expanded(
              child: list.isEmpty
                  ? const _EmptyFiltered()
                  : RefreshIndicator(
                      onRefresh: () async => _load(),
                      color: AppTheme.blue,
                      backgroundColor: AppTheme.bg2,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          if (i >= list.length) return const SizedBox();
                          return CreditCardWidget(
                            credit: list[i],
                            onTap: () => _openEdit(list[i]),
                            onDelete: () => _delete(list[i].id),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEdit(Credit c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCreditSheet(existing: c),
    ).then((saved) {
      if (saved == true) _load();
    });
  }

  Future<void> _delete(int id) async {
    await CreditStorage.deleteCredit(id);
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Credit deleted'),
            backgroundColor: AppTheme.bg3,
            behavior: SnackBarBehavior.floating),
      );
    }
  }
}

class _EmptyFiltered extends StatelessWidget {
  const _EmptyFiltered();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('🔍', style: TextStyle(fontSize: 40)),
          SizedBox(height: 16),
          Text('No credits found',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.text2)),
          SizedBox(height: 6),
          Text('Try a different filter or search',
              style: TextStyle(fontSize: 13, color: AppTheme.text3)),
        ]),
      );
}
