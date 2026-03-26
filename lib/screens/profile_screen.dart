import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/storage.dart';
import '../main.dart';
import '../widgets/credit_card_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Credit> _credits = [];
  List<String> _persons = [];
  String _name = 'Student';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() {
    _credits = CreditStorage.loadCredits();
    _persons = CreditStorage.loadPersons();
    _name    = CreditStorage.loadName();
  });

  @override
  Widget build(BuildContext context) {
    final paid    = _credits.where((c) => c.status == CreditStatus.paid).length;
    final overdue = _credits.where((c) => c.status == CreditStatus.overdue).length;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text('Profile', style: TextStyle(fontFamily: 'Syne', fontSize: 22, fontWeight: FontWeight.w700)),
            ),

            // Avatar + name
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.blue, AppTheme.purple],
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(initials(_name),
                        style: const TextStyle(fontFamily: 'Syne', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(height: 14),
                  Text(_name, style: const TextStyle(fontFamily: 'Syne', fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('CreditTrack Member', style: TextStyle(fontSize: 13, color: AppTheme.text3)),
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                _StatTile(value: '${_credits.length}', label: 'Credits', color: AppTheme.blue),
                const SizedBox(width: 10),
                _StatTile(value: '$paid', label: 'Paid', color: AppTheme.green),
                const SizedBox(width: 10),
                _StatTile(value: '$overdue', label: 'Overdue', color: AppTheme.red),
              ]),
            ),
            const SizedBox(height: 32),

            // Section label
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text('SETTINGS', style: TextStyle(fontSize: 11, color: AppTheme.text3,
                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ),

            _MenuItem(
              icon: Icons.edit_outlined,
              iconBg: AppTheme.blue.withOpacity(0.15),
              iconColor: AppTheme.blue,
              label: 'Edit Name',
              onTap: _editName,
            ),
            _MenuItem(
              icon: Icons.group_outlined,
              iconBg: AppTheme.purple.withOpacity(0.15),
              iconColor: AppTheme.purple,
              label: 'Manage People',
              onTap: _managePersons,
              subtitle: '${_persons.length} people',
            ),
            _MenuItem(
              icon: Icons.delete_outline_rounded,
              iconBg: AppTheme.red.withOpacity(0.12),
              iconColor: AppTheme.red,
              label: 'Clear All Data',
              labelColor: AppTheme.red,
              onTap: _clearData,
            ),

            const SizedBox(height: 40),
            const Center(
              child: Text('CreditTrack v1.0 · Made for students',
                  style: TextStyle(fontSize: 12, color: AppTheme.text3)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editName() async {
    final ctrl = TextEditingController(text: _name);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Name', style: TextStyle(fontFamily: 'Syne', color: AppTheme.text1)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppTheme.text1),
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppTheme.text2))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.blue, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await CreditStorage.saveName(result);
      _load();
    }
  }

  Future<void> _managePersons() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          backgroundColor: AppTheme.bg2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('People', style: TextStyle(fontFamily: 'Syne', color: AppTheme.text1)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._persons.map((p) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: personColor(p).withOpacity(0.15),
                    child: Text(initials(p), style: TextStyle(fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w700, color: personColor(p))),
                  ),
                  title: Text(p, style: const TextStyle(color: AppTheme.text1, fontSize: 14)),
                )),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(
                    controller: ctrl,
                    style: const TextStyle(color: AppTheme.text1),
                    decoration: const InputDecoration(hintText: 'Add person…'),
                  )),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (ctrl.text.trim().isNotEmpty) {
                        await CreditStorage.addPerson(ctrl.text.trim());
                        ctrl.clear();
                        setSt(() => _persons = CreditStorage.loadPersons());
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.blue, foregroundColor: Colors.white, elevation: 0),
                    child: const Text('Add'),
                  ),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done', style: TextStyle(color: AppTheme.blue))),
          ],
        ),
      ),
    );
    _load();
  }

  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Data', style: TextStyle(fontFamily: 'Syne', color: AppTheme.text1)),
        content: const Text('This will delete all your credits. This cannot be undone.',
            style: TextStyle(color: AppTheme.text2)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.text2))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear', style: TextStyle(color: AppTheme.red))),
        ],
      ),
    );
    if (confirm == true) {
      await CreditStorage.clearAll();
      _load();
    }
  }
}

class _StatTile extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatTile({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontFamily: 'Syne', fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.text3, letterSpacing: 0.3)),
        ],
      ),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label;
  final Color? labelColor;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.label, required this.onTap, this.labelColor, this.subtitle,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: labelColor ?? AppTheme.text1)),
              if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppTheme.text3)),
            ],
          )),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.text3, size: 20),
        ],
      ),
    ),
  );
}
