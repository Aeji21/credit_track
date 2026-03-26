import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/models.dart';
import '../data/storage.dart';
import '../main.dart';
import '../widgets/credit_card_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Credit> _credits = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _credits = CreditStorage.loadCredits());

  double get _oweTotal => _credits.where((c) => c.type == CreditType.owe).fold(0, (a, c) => a + c.amount);
  double get _recvTotal => _credits.where((c) => c.type == CreditType.recv).fold(0, (a, c) => a + c.amount);
  double get _net => _recvTotal - _oweTotal;

  Map<String, double> get _byPerson {
    final map = <String, double>{};
    for (final c in _credits) {
      map[c.person] = (map[c.person] ?? 0) + c.amount;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final byPerson = _byPerson;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _load(),
          color: AppTheme.blue,
          backgroundColor: AppTheme.bg2,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Analytics', style: TextStyle(fontFamily: 'Syne', fontSize: 22, fontWeight: FontWeight.w700)),
                  Text('Financial overview', style: TextStyle(fontSize: 12, color: AppTheme.text2)),
                ]),
              ),

              // Stats row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Expanded(child: _StatCard(label: 'You Owe', value: '₱${_oweTotal.toStringAsFixed(0)}', color: AppTheme.red)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(label: 'Owed to You', value: '₱${_recvTotal.toStringAsFixed(0)}', color: AppTheme.green)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    label: 'Net Balance',
                    value: '₱${_net.abs().toStringAsFixed(0)}',
                    color: _net >= 0 ? AppTheme.green : AppTheme.red,
                  )),
                ]),
              ),
              const SizedBox(height: 16),

              // Pie chart
              if (_credits.isNotEmpty)
                _ChartCard(
                  title: 'Overview',
                  subtitle: 'You Owe vs. Owed to You',
                  child: SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          child: PieChart(PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 50,
                            sections: [
                              PieChartSectionData(
                                value: _oweTotal == 0 ? 0.01 : _oweTotal,
                                color: AppTheme.red,
                                title: '',
                                radius: 40,
                              ),
                              PieChartSectionData(
                                value: _recvTotal == 0 ? 0.01 : _recvTotal,
                                color: AppTheme.green,
                                title: '',
                                radius: 40,
                              ),
                            ],
                          )),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Legend(color: AppTheme.red, label: 'You Owe', value: '₱${_oweTotal.toStringAsFixed(0)}'),
                            const SizedBox(height: 14),
                            _Legend(color: AppTheme.green, label: 'Owed to You', value: '₱${_recvTotal.toStringAsFixed(0)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Bar chart by person
              if (byPerson.isNotEmpty)
                _ChartCard(
                  title: 'By Person',
                  subtitle: 'Total credit amount per person',
                  child: SizedBox(
                    height: 200,
                    child: BarChart(BarChartData(
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIdx, rod, rodIdx) {
                            final name = byPerson.keys.elementAt(groupIdx);
                            return BarTooltipItem(
                              '$name\n₱${rod.toY.toStringAsFixed(0)}',
                              const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (v, _) => Text('₱${v.toInt()}',
                              style: const TextStyle(fontSize: 10, color: AppTheme.text3)),
                        )),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final keys = byPerson.keys.toList();
                            final i = v.toInt();
                            if (i < 0 || i >= keys.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(keys[i], style: const TextStyle(fontSize: 11, color: AppTheme.text2)),
                            );
                          },
                        )),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(color: AppTheme.border, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: byPerson.entries.toList().asMap().entries.map((e) {
                        final i = e.key;
                        final entry = e.value;
                        final col = personColor(entry.key);
                        return BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: entry.value,
                            color: col.withOpacity(0.8),
                            width: 28,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: byPerson.values.reduce((a, b) => a > b ? a : b) * 1.1,
                              color: col.withOpacity(0.08),
                            ),
                          ),
                        ]);
                      }).toList(),
                    )),
                  ),
                ),

              // Extra stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Expanded(child: _StatCard(
                    label: 'Total Credits',
                    value: '${_credits.length}',
                    color: AppTheme.blue,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    label: 'Paid',
                    value: '${_credits.where((c) => c.status == CreditStatus.paid).length}',
                    color: AppTheme.green,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    label: 'Overdue',
                    value: '${_credits.where((c) => c.status == CreditStatus.overdue).length}',
                    color: AppTheme.red,
                  )),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _ChartCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.card,
      border: Border.all(color: AppTheme.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontFamily: 'Syne', fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.text3)),
        const SizedBox(height: 20),
        child,
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.card,
      border: Border.all(color: AppTheme.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontFamily: 'Syne', fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.text3,
            letterSpacing: 0.3, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label, value;
  const _Legend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.text2)),
        Text(value, style: const TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    ],
  );
}
