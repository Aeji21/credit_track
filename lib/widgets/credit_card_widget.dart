import 'package:flutter/material.dart';
import '../data/models.dart';
import '../main.dart';

class CreditCardWidget extends StatelessWidget {
  final Credit credit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CreditCardWidget({
    super.key,
    required this.credit,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final col = personColor(credit.person);
    final amtColor =
        credit.type == CreditType.owe ? AppTheme.red : AppTheme.green;
    final sign = credit.type == CreditType.owe ? '−' : '+';

    return Dismissible(
      key: Key('credit_${credit.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppTheme.red, size: 24),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.bg2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Text('Delete Credit',
                    style:
                        TextStyle(fontFamily: 'Syne', color: AppTheme.text1)),
                content: Text('Delete "${credit.title}"?',
                    style: const TextStyle(color: AppTheme.text2)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel',
                          style: TextStyle(color: AppTheme.text2))),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete',
                          style: TextStyle(color: AppTheme.red))),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              // Avatar
              _Avatar(person: credit.person, color: col),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(credit.title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.text1),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(
                      credit.dueDate != null
                          ? '${credit.person} · ${_fmtDate(credit.dueDate!)}'
                          : '${credit.person} · No due date',
                      style:
                          const TextStyle(fontSize: 12, color: AppTheme.text3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right side
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$sign₱${_fmtAmt(credit.amount)}',
                      style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: amtColor)),
                  const SizedBox(height: 5),
                  StatusBadge(status: credit.status),
                ],
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close_rounded,
                    size: 18, color: AppTheme.text3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtAmt(double n) {
    if (n == n.truncate()) return n.truncate().toString();
    return n.toStringAsFixed(2);
  }

  String _fmtDate(DateTime d) {
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
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _Avatar extends StatelessWidget {
  final String person;
  final Color color;
  const _Avatar({required this.person, required this.color});

  @override
  Widget build(BuildContext context) {
    final parts = person.trim().split(' ');
    final letters =
        parts.where((w) => w.isNotEmpty).map((w) => w[0].toUpperCase()).join();

    final initials = letters.isEmpty
        ? '?'
        : (letters.length >= 2 ? letters.substring(0, 2) : letters);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Syne',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final CreditStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case CreditStatus.overdue:
        bg = AppTheme.red.withOpacity(0.15);
        fg = AppTheme.red;
      case CreditStatus.upcoming:
        bg = AppTheme.orange.withOpacity(0.15);
        fg = AppTheme.orange;
      case CreditStatus.paid:
        bg = AppTheme.green.withOpacity(0.15);
        fg = AppTheme.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.label.toUpperCase(),
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.5)),
    );
  }
}

// ─── HELPERS (shared across screens) ─────────────────────────────────────────
Color personColor(String person) {
  const map = {
    'You': AppTheme.blue,
    'Fel': AppTheme.purple,
    'John': AppTheme.green,
    'Mae': AppTheme.orange,
  };
  if (map.containsKey(person)) return map[person]!;
  final palette = [
    AppTheme.blue,
    AppTheme.purple,
    AppTheme.green,
    AppTheme.orange,
    Colors.pink,
    Colors.teal,
    Colors.amber
  ];
  final hash = person.codeUnits.fold(0, (a, b) => a + b);
  return palette[hash % palette.length];
}

String fmtAmount(double n) =>
    '₱${n.toStringAsFixed(n == n.truncate() ? 0 : 2)}';
String initials(String name) {
  final clean = name.trim();
  if (clean.isEmpty) return '?';

  final parts = clean.split(' ');
  final letters =
      parts.where((w) => w.isNotEmpty).map((w) => w[0].toUpperCase()).join();

  if (letters.isEmpty) return '?';

  return letters.length >= 2 ? letters.substring(0, 2) : letters;
}
