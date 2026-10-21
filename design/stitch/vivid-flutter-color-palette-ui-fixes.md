# Flutter Design System & Color Palette Architecture: Vivid & Pastel "Look and Feel"

Based directly on the exact sampled hex values and visual styling from `look_and_feel.jpg`.

---

## 1. What Caused the Mismatch?

When translating the mock to code, standard Material defaults or darker fallbacks caused issues:
1. **Avatar Cards & Kuma Bear / Borders**: 
   - *Issue:* Bear icon card felt like a muddy/dark brown box, and selected border was heavy.
   - *Correction:* The reference card surfaces are ultra-soft pastel creamy peach/off-white (`#FFFDF9` to `#FFF8F0`) with warm pastel icon containers (`#FFF3E3`, `#FFE8E8`, `#F3E8FF`), and soft warm borders (`#F7EFE4` or `#F4ECE1`).
2. **Text Field / Input Border**: 
   - *Issue:* Rendered black or dark charcoal (`#2D2621` or default Material grey).
   - *Correction:* Input borders in `look_and_feel.jpg` never use black. Unfocused inputs use a very subtle warm biscuit border (`#F0E5D8` or `#EFE5D6`), with a soft cream fill (`#FAF5EE`). Focused/active input uses vivid sunny orange (`#FFA944` or `#FF9838`) with zero black strokes.
3. **Money Badges & Selected Currency Pill**: 
   - *Issue:* Selected chip was an opaque/muddy orange, while unselected had drab borders.
   - *Correction:* In `look_and_feel.jpg`, active pills and chips use a warm, luminous tangerine yellow-orange gradient/solid (`#FF9E44` to `#FFA73F`) with crisp white icons/text, and unselected chips use clean warm cream (`#FFF7EE` or `#FFFFFF`) with a delicate warm biscuit border (`#EFE3D3`) and warm amber text (`#997352`).

---

## 2. Corrected Color Palette (`app_colors.dart`)

```dart
// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // --- Vibrant Accent & Action Colors (Exact from look_and_feel.jpg) ---
  static const Color primary = Color(0xFFFF9E44);       // Vivid Warm Tangerine / Orange (FAB, Primary Buttons, Active Tabs)
  static const Color primaryLight = Color(0xFFFFE8D2);  // Soft luminous peach / highlight fill
  static const Color primarySubtle = Color(0xFFFFF3E6); // Extra soft cream-orange for chip/card backgrounds
  static const Color primaryDark = Color(0xFFE88523);   // Pressed state

  // --- Secondary Accents ---
  static const Color coral = Color(0xFFFF7E6B);         // Vivid Coral / Food / Accent
  static const Color coralLight = Color(0xFFFFEDE9);    // Soft Coral tint
  static const Color mint = Color(0xFF48D38A);          // Clean energetic Mint Green (Income / Success)
  static const Color mintLight = Color(0xFFE6F9F0);     // Mint container tint
  static const Color sky = Color(0xFF5AB4FF);           // Fresh Sky Blue (Transport / Info)
  static const Color skyLight = Color(0xFFEBF6FF);      // Sky container tint
  static const Color lavender = Color(0xFFB590F8);      // Soft Lavender / Entertainment
  static const Color lavenderLight = Color(0xFFF4EEFF);  // Lavender container tint

  // --- Backgrounds & Scaffold (Light Mode) ---
  // Notice the reference is a warm vanilla/almond milk tone, NOT sterile white and NOT grey.
  static const Color scaffoldBg = Color(0xFFFFF9F2);    // Creamy Warm Vanilla (Main screen background)
  static const Color cardSurface = Color(0xFFFFFFFF);   // Crisp White for floating cards & modals
  static const Color surfaceWarm = Color(0xFFFFF6ED);   // Warm tinted secondary card surface
  static const Color modalSurface = Color(0xFFFFFFFF);  // Pure clean white for bottom sheet modal

  // --- Borders & Outlines (NEVER use black or dark grey!) ---
  static const Color borderLight = Color(0xFFF4ECE2);    // Ultra soft divider and card outline
  static const Color borderInput = Color(0xFFEDE2D4);    // Input field resting border (warm biscuit)
  static const Color borderInputFocused = Color(0xFFFF9E44); // Primary active focus border

  // --- Typography (Warm, Rich Charcoal, NEVER Pure Black) ---
  static const Color textHeadline = Color(0xFF332923);  // Deep Warm Espresso Charcoal (Headings, amounts)
  static const Color textBody = Color(0xFF4A3E36);      // Warm Charcoal body text
  static const Color textMuted = Color(0xFF9E9188);     // Soft warm taupe-gray for secondary labels/subtitles
  static const Color textPlaceholder = Color(0xFFC7BCB3);// Light warm placeholder hint text

  // --- Avatar & Category Specific Palettes ---
  static const Color avatarNekoBg = Color(0xFFFFF1DF);  // Warm honey-peach for Cat
  static const Color avatarPiggyBg = Color(0xFFFFEAE7); // Sweet pastel rose for Piggy
  static const Color avatarKumaBg = Color(0xFFF7ECE1);  // Creamy almond for Bear (warm, never dark brown)
  static const Color avatarBobaBg = Color(0xFFEFE9FC);  // Soft lilac for Boba / Coffee

  // --- Dark Mode Schema (Warm Espresso, NOT Blue-Black) ---
  static const Color darkScaffoldBg = Color(0xFF1C1917); // Rich dark roast espresso
  static const Color darkSurface = Color(0xFF292420);    // Warm elevated dark surface
  static const Color darkSurfaceWarm = Color(0xFF36302B);// Sub-card / input fill
  static const Color darkBorder = Color(0xFF423B35);     // Soft dark border
  static const Color darkTextPrimary = Color(0xFFFAF4EE);// Milk foam cream text
  static const Color darkTextMuted = Color(0xFFA89E96);  // Warm gray secondary text
}
```

---

## 3. Usage Rules & Implementation Guide for Your Flutter Widgets

### A. Avatar Selection Cards
* **Normal / Unselected:**
  - Background: `AppColors.cardSurface` (`#FFFFFF`) or tinted avatar bg (`AppColors.avatarNekoBg`, etc.)
  - Border: `Border.all(color: AppColors.borderLight, width: 1.5)`
  - Bear icon should sit in `avatarKumaBg` (`#F7ECE1`) with warm chocolate accents (`#6B4B35`), **not** a muddy brown box!
* **Selected State:**
  - Background: `AppColors.primarySubtle` (`#FFF3E6`)
  - Border: `Border.all(color: AppColors.primary, width: 2.0)` (`#FF9E44`)
  - Indicator badge: Solid `AppColors.primary` circle with white checkmark.

### B. Input Field (Fixing the Black Border)
Make sure your Flutter `InputDecorationTheme` explicitly sets both `border` and `enabledBorder`:
```dart
InputDecoration(
  filled: true,
  fillColor: AppColors.surfaceWarm, // #FFF6ED
  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: const BorderSide(color: AppColors.borderInput, width: 1.2), // Warm biscuit, NOT black!
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
  ),
  hintStyle: const TextStyle(color: AppColors.textPlaceholder),
)
```

### C. Currency Pills & Badges (Fixing Opaque Orange)
* **Selected Currency Pill (e.g., JPY):**
  - Background: `AppColors.primary` (`#FF9E44`) — vivid, sunny, cheerful.
  - Text & Check Icon: Pure White (`#FFFFFF`, `FontWeight.w700`).
  - Shadow: Soft warm drop shadow `BoxShadow(color: Color(0x33FF9E44), blurRadius: 10, offset: Offset(0, 3))`.
* **Unselected Currency Pills (USD, EUR, GBP):**
  - Background: `AppColors.cardSurface` (`#FFFFFF`).
  - Border: `Border.all(color: AppColors.borderLight, width: 1.2)`.
  - Text: `AppColors.textMuted` or `AppColors.textBody` (`FontWeight.w600`).
  - Symbol: Soft primary tint (`#FFA959`).
