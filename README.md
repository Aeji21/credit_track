# CreditTrack — Flutter Setup Guide

## File Structure
```
lib/
├── main.dart                    ← App entry + theme + AppTheme colors
├── data/
│   ├── models.dart              ← Credit model, CreditType, CreditStatus enums
│   └── storage.dart             ← SharedPreferences persistence layer
├── screens/
│   ├── home_screen.dart         ← Dashboard with summary cards + grouped transactions
│   ├── credits_screen.dart      ← Filterable/searchable full credit list
│   ├── calendar_screen.dart     ← Monthly calendar with due date indicators
│   ├── analytics_screen.dart    ← Pie chart + bar chart via fl_chart
│   └── profile_screen.dart      ← User profile, stats, settings
└── widgets/
    ├── credit_card_widget.dart  ← Reusable credit tile + swipe-to-delete
    ├── summary_card.dart        ← Summary card (You Owe / Owed to You)
    └── add_credit_sheet.dart    ← Bottom sheet for add/edit credit
```

## 1. Install Dependencies

```bash
flutter pub get
```

## 2. Fonts (Choose One Option)

### Option A — google_fonts package (easiest)
Add to pubspec.yaml dependencies:
```yaml
google_fonts: ^6.1.0
```
Then in main.dart, replace `fontFamily: 'Syne'` with:
```dart
import 'package:google_fonts/google_fonts.dart';
// Use GoogleFonts.syne() and GoogleFonts.dmSans() in your TextStyles
```

### Option B — Local font files
1. Download from Google Fonts: https://fonts.google.com/specimen/Syne and https://fonts.google.com/specimen/DM+Sans
2. Place .ttf files in `assets/fonts/`
3. Uncomment the fonts section in pubspec.yaml

## 3. Run the App

```bash
# iOS Simulator
flutter run -d ios

# Android Emulator  
flutter run -d android

# List available devices
flutter devices
```

## 4. Build for iOS (TestFlight / App Store)

```bash
flutter build ios --release
```
Then open `ios/Runner.xcworkspace` in Xcode and archive for distribution.

## Features
- ✅ Home dashboard with You Owe / Owed to You summary cards
- ✅ Add credit with smart quick-parse (e.g. "Zus Coffee - 150")
- ✅ Credits list with real-time search + filter (All/Overdue/Upcoming/Paid)
- ✅ Swipe to delete + tap to edit
- ✅ Calendar view with colored dot indicators for due dates
- ✅ Analytics: doughnut chart + bar chart per person (fl_chart)
- ✅ Profile with stats and people management
- ✅ Local persistence via SharedPreferences (offline-first)
- ✅ Dark theme only (deep navy + blue/green/red/purple accents)
- ✅ Demo data pre-seeded on first launch
