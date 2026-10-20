# Flutter Design System & Color Palette Architecture: Expenses App

Based on the aesthetic in `look_and_feel.jpg` applied to your initial profile creation workflow (`Untitled.png`).

---

## 1. Design Principles & UX Enhancements

### Key Flaws in the Original Workflow (`Untitled.png`):
1. **Cold & Sterile Minimalist UI:** Harsh plain white background, sharp contrast dark greens, generic stock material dialogs.
2. **Abrupt Dialog Overlays:** Bottom-center cramped modal popups with harsh dark 60% dim backdrop disconnect the onboarding experience.
3. **Empty Initial State:** A blank white screen with tiny centered text fails to convey excitement or value.
4. **Currency Selector UX:** Full modal swap for currency selection with basic text rows lacks flag icons, currency symbols, and quick suggestions (e.g., Based on locale / Most popular).

### UX Enhancements in the New Design:
- **Welcoming Onboarding Hero:** Cute cat mascot illustration, warm greeting, and clear value proposition ("Track easily, save smartly, 100% offline & local").
- **Fluid Bottom Sheet / Modal Card:** Gentle warm blur scrim with rounded sheet curves (`borderRadius: 32.0`), spacious touch targets (minimum 48dp), clear progress micro-copy.
- **Searchable Currency Selector:** Fast search input with rounded pill design, currency badges with symbols (`$`, `€`, `¥`, `£`), flag/code tags, and quick-pick favorites chip group.
- **Micro-feedback & Validation:** Real-time profile preview card showing how the account will appear with avatar selection and chosen currency token.

---

## 2. Reusable Color Palette & Flutter Schema

```dart
// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // --- Brand & Primary Accents ---
  static const Color primary = Color(0xFFFF9F43);       // Warm Tangerine / Orange (CTAs, floating action, active tabs)
  static const Color primaryLight = Color(0xFFFFEAD1);  // Soft Warm Peach (hover states, selected chips, icon backdrops)
  static const Color primaryDark = Color(0xFFE58325);   // Pressed/Focus primary state

  // --- Secondary Accents ---
  static const Color secondary = Color(0xFFFF8577);     // Coral / Expense indicator / Highlights
  static const Color secondaryLight = Color(0xFFFFE5E2);// Light Coral background for expense tags

  // --- Semantic Indicators ---
  static const Color income = Color(0xFF2ECC71);        // Cheerful Mint Green (Income / Positive balance)
  static const Color incomeBg = Color(0xFFE8F8F0);      // Income badge background
  static const Color expense = Color(0xFFFF5252);       // Soft Red/Tangerine (Expenses / Alerts)
  static const Color expenseBg = Color(0xFFFFEEEE);      // Expense badge background
  static const Color info = Color(0xFF54A0FF);          // Soft Sky Blue (Categories like Transport, Info)
  static const Color infoBg = Color(0xFFEBF3FF);

  // --- Light Theme Neutrals ---
  static const Color lightBg = Color(0xFFFAF7F2);        // Warm Cream main scaffold background
  static const Color lightSurface = Color(0xFFFFFFFF);   // Pure white for elevated cards & modals
  static const Color lightSurfaceWarm = Color(0xFFFFF9F2); // Subtle warm tinted container surface
  static const Color lightBorder = Color(0xFFF0EAE1);    // Soft warm divider & outline
  static const Color lightTextPrimary = Color(0xFF2D2621); // Warm Charcoal (High legibility body & headings)
  static const Color lightTextSecondary = Color(0xFF8C827A); // Warm Muted Gray (captions, subtitle)
  static const Color lightTextPlaceholder = Color(0xFFBDB3AA); // Input hints & search placeholder

  // --- Dark Mode Neutrals ---
  static const Color darkBg = Color(0xFF181614);         // Deep Warm Espresso background
  static const Color darkSurface = Color(0xFF24201D);    // Elevated dark card background
  static const Color darkSurfaceWarm = Color(0xFF2D2824);// Slightly elevated surfaces / dialogs
  static const Color darkBorder = Color(0xFF38322D);     // Subtle dark outline
  static const Color darkTextPrimary = Color(0xFFF7F2EC); // Cream White for readability
  static const Color darkTextSecondary = Color(0xFFA69D95); // Muted warm gray
  static const Color darkTextPlaceholder = Color(0xFF6E6760); // Dark placeholder
}
```

---

## 3. Usage Rules Matrix: When & How to Apply

| Token | Flutter Material Role | Where to Use | Rules & UX Guidelines |
|---|---|---|---|
| `primary` (`#FF9F43`) | `colorScheme.primary` | Main CTA buttons, Floating Action Button, active navigation tab, primary toggles | Only 1 dominant primary action per viewport. Always pair with white text (`#FFFFFF`) for contrast. |
| `primaryLight` (`#FFEAD1`) | `colorScheme.primaryContainer` | Selected chip pill backgrounds, icon badge backdrops, subtle notification pills | Use for secondary states or icon circles. Text inside should be `primaryDark` or `textPrimary`. |
| `lightBg` / `darkBg` | `scaffoldBackgroundColor` | App background behind scrollable lists & dashboards | Do not use pure `#FFFFFF` in light mode or `#000000` in dark mode. The warm tone is critical to the playful look. |
| `lightSurface` / `darkSurface` | `cardColor` / `dialogBackgroundColor` | Bottom sheets, cards, transaction list tiles, popup modals | Give cards `borderRadius: BorderRadius.circular(24)` and subtle warm shadows (`BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 4))`). |
| `income` & `expense` | Semantic Tags | Amounts, +/- indicators, category icons | Never use standard harsh red/green; use warm pastel variations with their accompanying `Bg` tinted badge containers. |
| `textPrimary` | `textTheme.bodyLarge` / `titleLarge` | Screen headings, card titles, amount numbers | Keep at least 650+ font weight for headers (use rounded font like `GoogleFonts.quicksand()` or `GoogleFonts.nunito()`). |
| `textSecondary` | `textTheme.bodyMedium` / `labelMedium` | Timestamps, subtitles, "Data stays on device" privacy note | Provides secondary hierarchy without cluttering screen. |

---

## 4. Flutter Theme Configuration Widget (Light & Dark Mode)

```dart
// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.expense,
      ),
      fontFamily: GoogleFonts.nunito().fontFamily,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w800, fontSize: 24),
        titleLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w700, fontSize: 16),
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.lightTextSecondary, fontWeight: FontWeight.w500, fontSize: 13),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceWarm,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.lightTextPlaceholder, fontSize: 14),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.darkSurfaceWarm,
        onPrimaryContainer: AppColors.primaryLight,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.expense,
      ),
      fontFamily: GoogleFonts.nunito().fontFamily,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w800, fontSize: 24),
        titleLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700, fontSize: 16),
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary, fontWeight: FontWeight.w500, fontSize: 13),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceWarm,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.darkTextPlaceholder, fontSize: 14),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
    );
  }
}
```
