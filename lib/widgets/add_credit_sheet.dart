import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/storage.dart';
import '../main.dart';
import 'credit_card_widget.dart';

class AddCreditSheet extends StatefulWidget {
  final Credit? existing;
  const AddCreditSheet({super.key, this.existing});

  @override
  State<AddCreditSheet> createState() => _AddCreditSheetState();
}

class _AddCreditSheetState extends State<AddCreditSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _quickCtrl = TextEditingController();

  List<String> _persons = [];
  String _selectedPerson = 'You';
  CreditStatus _status = CreditStatus.upcoming;
  CreditType _type = CreditType.owe;
  DateTime? _dueDate;

  String? _parsedTitle;
  double? _parsedAmount;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _persons = CreditStorage.loadPersons();
    if (_isEdit) {
      final c = widget.existing!;
      _titleCtrl.text = c.title;
      _amountCtrl.text = c.amount.toString();
      _selectedPerson = c.person;
      _status = c.status;
      _type = c.type;
      _dueDate = c.dueDate;
    } else {
      _selectedPerson = _persons.isNotEmpty ? _persons.first : 'You';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _quickCtrl.dispose();
    super.dispose();
  }

  void _parseQuick(String val) {
    final parts = val.split(RegExp(r'[-–]'));
    if (parts.length >= 2) {
      final title = parts[0].trim();
      final rawAmt = parts.last.trim().replaceAll(RegExp(r'[^\d.]'), '');
      final amt = double.tryParse(rawAmt);
      if (title.isNotEmpty && amt != null) {
        setState(() {
          _parsedTitle = title;
          _parsedAmount = amt;
        });
        _titleCtrl.text = title;
        _amountCtrl.text = rawAmt;
        return;
      }
    }
    setState(() {
      _parsedTitle = null;
      _parsedAmount = null;
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppTheme.blue, surface: AppTheme.bg2),
          dialogTheme: DialogThemeData(backgroundColor: AppTheme.bg2),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _dueDate = d);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (title.isEmpty) {
      _snack('Please enter a title');
      return;
    }
    if (amount == null || amount <= 0) {
      _snack('Please enter a valid amount');
      return;
    }

    if (_isEdit) {
      final updated = widget.existing!.copyWith(
        title: title,
        amount: amount,
        person: _selectedPerson,
        type: _type,
        status: _status,
        dueDate: _dueDate,
        clearDate: _dueDate == null,
      );
      await CreditStorage.updateCredit(updated);
    } else {
      final c = Credit(
        id: CreditStorage.nextId(),
        title: title,
        amount: amount,
        person: _selectedPerson,
        type: _type,
        status: _status,
        dueDate: _dueDate,
      );
      await CreditStorage.addCredit(c);
    }
    if (mounted) Navigator.pop(context, true);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: AppTheme.bg3,
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.border2)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
                child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.border2,
                  borderRadius: BorderRadius.circular(2)),
            )),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(_isEdit ? 'Edit Credit' : 'New Credit',
                  style: const TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 22,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 20),

            // Quick input (add only)
            if (!_isEdit) ...[
              _label('Bank'),
              _pad(TextField(
                controller: _quickCtrl,
                onChanged: _parseQuick,
                decoration:
                    const InputDecoration(hintText: 'e.g. Atome, BPI, Cash'),
                style: const TextStyle(color: AppTheme.text1),
              )),
              if (_parsedTitle != null && _parsedAmount != null)
                _ParsePreview(title: _parsedTitle!, amount: _parsedAmount!),
              const SizedBox(height: 4),
            ],

            _label('Title'),
            _pad(TextField(
              controller: _titleCtrl,
              decoration:
                  const InputDecoration(hintText: 'e.g. Lunch, Grab Fare…'),
              style: const TextStyle(color: AppTheme.text1),
            )),

            _label('Amount (₱)'),
            _pad(TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: '0.00'),
              style: const TextStyle(color: AppTheme.text1),
            )),

            _label('Due Date'),
            _pad(GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.bg3,
                  border: Border.all(color: AppTheme.border2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      _dueDate != null
                          ? _fmtDate(_dueDate!)
                          : 'Select date (optional)',
                      style: TextStyle(
                          color: _dueDate != null
                              ? AppTheme.text1
                              : AppTheme.text3,
                          fontSize: 15),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today_outlined,
                        color: AppTheme.text3, size: 18),
                  ],
                ),
              ),
            )),

            _label('Person'),
            SizedBox(
              height: 44,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: _persons.map((p) {
                  final col = personColor(p);
                  final sel = p == _selectedPerson;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPerson = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? col.withOpacity(0.15) : AppTheme.bg3,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? col : AppTheme.border2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                color: col.withOpacity(0.2),
                                shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text(initials(p),
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: col)),
                          ),
                          const SizedBox(width: 6),
                          Text(p,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: sel ? col : AppTheme.text2)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            _label('Type'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _TypeChip(
                      label: 'I Owe',
                      selected: _type == CreditType.owe,
                      color: AppTheme.orange,
                      onTap: () => setState(() => _type = CreditType.owe)),
                  const SizedBox(width: 10),
                  _TypeChip(
                      label: 'Owed to Me',
                      selected: _type == CreditType.recv,
                      color: AppTheme.green,
                      onTap: () => setState(() => _type = CreditType.recv)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _label('Status'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: CreditStatus.values.map((s) {
                  Color col;
                  switch (s) {
                    case CreditStatus.overdue:
                      col = AppTheme.red;
                    case CreditStatus.upcoming:
                      col = AppTheme.orange;
                    case CreditStatus.paid:
                      col = AppTheme.green;
                  }
                  final sel = s == _status;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _status = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: EdgeInsets.only(
                            right: s != CreditStatus.paid ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: sel ? col.withOpacity(0.15) : AppTheme.bg3,
                          border:
                              Border.all(color: sel ? col : AppTheme.border2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(s.label,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: sel ? col : AppTheme.text2,
                                letterSpacing: 0.3)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Save
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(_isEdit ? 'Save Changes' : 'Save Credit',
                      style: const TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.border2),
                    ),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppTheme.text2, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 8, top: 4),
        child: Text(t,
            style: const TextStyle(
                fontSize: 12,
                color: AppTheme.text2,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3)),
      );

  Widget _pad(Widget child) => Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        child: child,
      );

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

class _ParsePreview extends StatelessWidget {
  final String title;
  final double amount;
  const _ParsePreview({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.blue.withOpacity(0.08),
        border: Border.all(color: AppTheme.blue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨ PARSED',
              style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.blue,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              _Chip(label: 'Title', value: title),
              const SizedBox(width: 8),
              _Chip(label: 'Amount', value: '₱$amount'),
            ],
          )
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label, value;
  const _Chip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: AppTheme.bg3,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppTheme.text3)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.text1,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TypeChip(
      {required this.label,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? color.withOpacity(0.15) : AppTheme.bg3,
              border: Border.all(color: selected ? color : AppTheme.border2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? color : AppTheme.text2)),
          ),
        ),
      );
}
