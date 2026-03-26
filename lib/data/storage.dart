import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class CreditStorage {
  static late SharedPreferences _prefs;
  static const _creditsKey = 'credits_v2';
  static const _personsKey = 'persons_v2';
  static const _profileKey = 'profile_v2';
  static const _nextIdKey  = 'next_id_v2';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Seed demo data on first launch
    if (!_prefs.containsKey(_creditsKey)) {
      await _seedDemo();
    }
  }

  // ── Credits ──────────────────────────────────────────────────────────────
  static List<Credit> loadCredits() {
    final raw = _prefs.getStringList(_creditsKey) ?? [];
    return raw.map((e) => Credit.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> saveCredits(List<Credit> credits) async {
    final raw = credits.map((c) => jsonEncode(c.toMap())).toList();
    await _prefs.setStringList(_creditsKey, raw);
  }

  static Future<Credit> addCredit(Credit c) async {
    final credits = loadCredits();
    credits.add(c);
    await saveCredits(credits);
    return c;
  }

  static Future<void> updateCredit(Credit updated) async {
    final credits = loadCredits();
    final idx = credits.indexWhere((c) => c.id == updated.id);
    if (idx >= 0) credits[idx] = updated;
    await saveCredits(credits);
  }

  static Future<void> deleteCredit(int id) async {
    final credits = loadCredits()..removeWhere((c) => c.id == id);
    await saveCredits(credits);
  }

  // ── Persons ───────────────────────────────────────────────────────────────
  static List<String> loadPersons() =>
      _prefs.getStringList(_personsKey) ?? ['You', 'Fel', 'John', 'Mae'];

  static Future<void> savePersons(List<String> persons) async =>
      await _prefs.setStringList(_personsKey, persons);

  static Future<void> addPerson(String name) async {
    final persons = loadPersons();
    if (!persons.contains(name)) {
      persons.add(name);
      await savePersons(persons);
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────
  static String loadName() => _prefs.getString(_profileKey) ?? 'Student';
  static Future<void> saveName(String name) async =>
      await _prefs.setString(_profileKey, name);

  // ── Next ID ───────────────────────────────────────────────────────────────
  static int nextId() {
    final id = _prefs.getInt(_nextIdKey) ?? 6;
    _prefs.setInt(_nextIdKey, id + 1);
    return id;
  }

  // ── Clear All ─────────────────────────────────────────────────────────────
  static Future<void> clearAll() async {
    await _prefs.remove(_creditsKey);
    await _prefs.remove(_nextIdKey);
  }

  // ── Seed ──────────────────────────────────────────────────────────────────
  static Future<void> _seedDemo() async {
    final now = DateTime.now();
    final credits = [
      Credit(id: 1, title: 'Zus Coffee', amount: 150, person: 'Fel', type: CreditType.owe, status: CreditStatus.overdue, dueDate: now.subtract(const Duration(days: 7))),
      Credit(id: 2, title: 'Grab Fare', amount: 85, person: 'Fel', type: CreditType.owe, status: CreditStatus.upcoming, dueDate: now.add(const Duration(days: 3))),
      Credit(id: 3, title: 'Lunch Kainan', amount: 220, person: 'John', type: CreditType.recv, status: CreditStatus.upcoming, dueDate: now.add(const Duration(days: 5))),
      Credit(id: 4, title: 'Mcdo Dinner', amount: 310, person: 'John', type: CreditType.recv, status: CreditStatus.paid),
      Credit(id: 5, title: 'Notes Printing', amount: 45, person: 'You', type: CreditType.owe, status: CreditStatus.upcoming),
    ];
    await saveCredits(credits);
    await _prefs.setInt(_nextIdKey, 6);
  }
}
