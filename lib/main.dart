import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/storage.dart';
import 'screens/home_screen.dart';
import 'screens/credits_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/add_credit_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CreditStorage.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const CreditTrackApp());
}

class CreditTrackApp extends StatelessWidget {
  const CreditTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CreditTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}

class AppTheme {
  static const bg = Color(0xFF080C14);
  static const bg2 = Color(0xFF0E1420);
  static const bg3 = Color(0xFF141B2D);
  static const card = Color(0xFF111827);
  static const card2 = Color(0xFF192033);
  static const blue = Color(0xFF3B82F6);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const orange = Color(0xFFF97316);
  static const purple = Color(0xFFA855F7);
  static const text1 = Color(0xFFF1F5F9);
  static const text2 = Color(0xFF94A3B8);
  static const text3 = Color(0xFF475569);
  static const border = Color(0x12FFFFFF);
  static const border2 = Color(0x1FFFFFFF);

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: blue,
      surface: card,
      onSurface: text1,
    ),
    fontFamily: 'DMSans',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontFamily: 'Syne', fontWeight: FontWeight.w800, color: text1),
      displayMedium: TextStyle(
          fontFamily: 'Syne', fontWeight: FontWeight.w700, color: text1),
      titleLarge: TextStyle(
          fontFamily: 'Syne', fontWeight: FontWeight.w700, color: text1),
      titleMedium: TextStyle(
          fontFamily: 'Syne', fontWeight: FontWeight.w600, color: text1),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: text1),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: text2),
      labelSmall: TextStyle(fontWeight: FontWeight.w500, color: text3),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bg2,
      selectedItemColor: blue,
      unselectedItemColor: text3,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      iconTheme: IconThemeData(color: text1),
      titleTextStyle: TextStyle(
        fontFamily: 'Syne',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: text1,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bg3,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: blue, width: 1.5),
      ),
      hintStyle: const TextStyle(color: text3),
      labelStyle: const TextStyle(color: text2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

// ─── MAIN SHELL ──────────────────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CreditsScreen(),
    CalendarScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      floatingActionButton: _idx <= 1
          ? FloatingActionButton(
              onPressed: () => _openAdd(context),
              backgroundColor: AppTheme.blue,
              elevation: 0,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.credit_card_rounded), label: 'Credits'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void _openAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCreditSheet(),
    ).then((_) => setState(() {}));
  }
}
