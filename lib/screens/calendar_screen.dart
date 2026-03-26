import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/storage.dart';
import '../main.dart';
import '../widgets/credit_card_widget.dart';
import '../widgets/add_credit_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Credit> _credits = [];
  late int _year, _month;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _load();
  }

  void _load() => setState(() => _credits = CreditStorage.loadCredits());

  Map<int, List<Credit>> get _dayMap {
    final map = <int, List<Credit>>{};
    for (final c in _credits) {
      if (c.dueDate == null) continue;
      if (c.dueDate!.year == _year && c.dueDate!.month == _month) {
        map.putIfAbsent(c.dueDate!.day, () => []).add(c);
      }
    }
    return map;
  }

  List<Credit> get _selectedCredits {
    if (_selectedDay == null) return [];
    return _dayMap[_selectedDay] ?? [];
  }

  void _changeMonth(int dir) {
    setState(() {
      _month += dir;
      if (_month < 1) {
        _month = 12;
        _year--;
      }
      if (_month > 12) {
        _month = 1;
        _year++;
      }
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayMap = _dayMap;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Due Dates',
                        style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                    Text('Calendar view',
                        style: TextStyle(fontSize: 12, color: AppTheme.text2)),
                  ]),
            ),
            const SizedBox(height: 20),
            // Month nav
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _MonthBtn(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => _changeMonth(-1)),
                  const Spacer(),
                  Text(_monthName,
                      style: const TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  _MonthBtn(
                      icon: Icons.chevron_right_rounded,
                      onTap: () => _changeMonth(1)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Day names
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                    .map((d) => Expanded(
                            child: Center(
                          child: Text(d,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.text3,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3)),
                        )))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildGrid(dayMap),
            ),
            const Divider(color: AppTheme.border, height: 24),
            // Selected day events
            Expanded(child: _buildEvents()),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(Map<int, List<Credit>> dayMap) {
    final firstWeekday = DateTime(_year, _month, 1).weekday % 7;
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final today = DateTime.now();
    final cells = <Widget>[];

    for (int i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int d = 1; d <= daysInMonth; d++) {
      final isToday =
          d == today.day && _month == today.month && _year == today.year;
      final isSel = d == _selectedDay;
      final txs = dayMap[d] ?? [];
      final hasOverdue = txs.any((c) => c.status == CreditStatus.overdue);
      final hasCred = txs.isNotEmpty;

      cells.add(GestureDetector(
        onTap: () =>
            setState(() => _selectedDay = _selectedDay == d ? null : d),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSel
                ? AppTheme.blue
                : (isToday
                    ? AppTheme.blue.withOpacity(0.1)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text('$d',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isToday || isSel ? FontWeight.w700 : FontWeight.w400,
                    color: isSel
                        ? Colors.white
                        : (isToday ? AppTheme.blue : AppTheme.text2),
                  )),
              if (hasCred && !isSel)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: hasOverdue ? AppTheme.red : AppTheme.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              if (isToday && !isSel)
                Positioned(
                  bottom: 4,
                  child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                          color: AppTheme.blue, shape: BoxShape.circle)),
                ),
            ],
          ),
        ),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: cells,
    );
  }

  Widget _buildEvents() {
    if (_selectedDay == null) {
      return const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('📅', style: TextStyle(fontSize: 36)),
        SizedBox(height: 12),
        Text('Select a date to see credits',
            style: TextStyle(fontSize: 13, color: AppTheme.text3)),
      ]));
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final txs = _selectedCredits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text('${months[_month - 1]} $_selectedDay, $_year',
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.text2,
                  fontWeight: FontWeight.w500)),
        ),
        if (txs.isEmpty)
          const Center(
              child: Text('No credits on this day',
                  style: TextStyle(fontSize: 13, color: AppTheme.text3)))
        else
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: txs.map((c) {
                final col = c.status == CreditStatus.overdue
                    ? AppTheme.red
                    : c.status == CreditStatus.paid
                        ? AppTheme.green
                        : AppTheme.orange;
                return GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AddCreditSheet(existing: c),
                  ).then((s) {
                    if (s == true) _load();
                  }),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                                color: col, shape: BoxShape.circle)),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(c.title,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              Text(c.person,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppTheme.text3)),
                            ])),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('₱${c.amount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontFamily: 'Syne',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: c.type == CreditType.owe
                                          ? AppTheme.red
                                          : AppTheme.green)),
                              const SizedBox(height: 4),
                              StatusBadge(status: c.status),
                            ]),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  String get _monthName {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${names[_month - 1]} $_year';
  }
}

class _MonthBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MonthBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.card,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.text2, size: 22),
        ),
      );
}
