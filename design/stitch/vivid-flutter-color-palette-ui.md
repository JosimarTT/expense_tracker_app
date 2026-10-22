# Expense Tracker Design System

## 1. Authority and scope

This document is the source of truth for new views and shared UI components.
It defines typography, exact colors, color roles, spacing, shapes, interaction
states, responsive behavior, and validation expectations.

The baseline is the current Vivid palette, locally bundled Nunito, and the
approved profile-creation refinements. This document does not authorize a visual
redesign of existing views or a change to business behavior.

Priority when references conflict:

1. Explicitly approved product/design changes, incorporated into this document.
2. The normative rules and component recipes in this document.
3. Screen mockups for composition and details not yet specified here.
4. Flutter Material defaults only for properties not specified here.

Older Stitch exports and HTML are references, not competing specifications.
Do not copy their alternate hex values, fonts, shadows, or obsolete preview cards.
All measurements below are Flutter logical pixels; type sizes respect the user's
text scaling. Hex values are opaque RGB unless an opacity is explicitly stated.

Implementation locations:

- [Palette and semantic extension](../../lib/app/theme/app_colors.dart)
- [Light/dark themes and shared component defaults](../../lib/app/theme/app_theme.dart)
- [Profile form](../../lib/features/profiles/presentation/profile_dialog.dart)
- [Currency components](../../lib/features/profiles/presentation/currency_widgets.dart)
- [Approved profile composition reference](./create-profile.png)

## 2. Design principles

- Warm, friendly, local-first: vanilla light surfaces and espresso dark surfaces.
- Clear hierarchy: strong headings and values, restrained supporting text.
- Soft geometry without making every control a pill.
- One dominant primary action per view or modal.
- Use color with text, icons, borders, or selection indicators, never alone.
- Keep offline/privacy copy accurate. Do not advertise unimplemented features.
- Reuse shared components before introducing a new visual variant.

## 3. Exact color tokens

These names and values mirror `AppColors`. In Flutter, prepend `FF` for the
opaque alpha channel: `#FF9E44` becomes `Color(0xFFFF9E44)`.
Do not invent nearby colors, apply arbitrary opacity, or derive new palettes
from a seed for roles already specified here.

### 3.1 Brand and accent colors

| Token | Hex | Role |
|---|---|---|
| primary | #FF9E44 | Main actions, active choices, focus, selection badges |
| primaryLight | #FFE8D2 | Primary container and secondary highlights |
| primarySubtle | #FFF3E6 | Light selected-avatar background |
| primaryDark | #E88523 | Pressed-state accent and selected-avatar label |
| coral | #FF7E6B | Expense/error accent and secondary accent |
| coralLight | #FFEDE9 | Light expense/error container |
| coralForeground | #A63D30 | Readable expense summary foreground on coralLight |
| mint | #48D38A | Income/success accent and valid-name indicator |
| mintLight | #E6F9F0 | Light income/success container |
| mintForeground | #176B42 | Readable income summary foreground on mintLight |
| sky | #5AB4FF | Information accent |
| skyLight | #EBF6FF | Light information container |
| lavender | #B590F8 | Category/decorative accent |
| lavenderLight | #F4EEFF | Matching category/decorative tint |

### 3.2 Light surfaces, borders, and text

| Token | Hex | Role |
|---|---|---|
| scaffoldBg | #FFF9F2 | Main background |
| cardSurface | #FFFFFF | Cards and elevated surfaces |
| modalSurface | #FFFFFF | Dialogs and bottom sheets |
| surfaceWarm | #FFF6ED | Input fills and secondary containers |
| borderLight | #F4ECE2 | Card outlines, dividers, unselected choices |
| borderInput | #EDE2D4 | Resting input and currency-selector border |
| borderInputFocused | #FF9E44 | Focused input border |
| textHeadline | #332923 | Headings, prominent values |
| textBody | #4A3E36 | Body text and actionable labels |
| textMuted | #9E9188 | Supporting copy and secondary labels |
| textPlaceholder | #C7BCB3 | Hints only; never entered values |

### 3.3 Dark surfaces, borders, and text

| Token | Hex | Role |
|---|---|---|
| darkScaffoldBg | #1C1917 | Main background |
| darkSurface | #292420 | Cards, modals, unselected avatar cards |
| darkSurfaceWarm | #36302B | Inputs, selected avatars, semantic containers |
| darkBorder | #423B35 | Component borders and dividers |
| darkTextPrimary | #FAF4EE | Primary text |
| darkTextMuted | #A89E96 | Supporting text and hints |

### 3.4 Reserved avatar/category backgrounds

| Token | Hex |
|---|---|
| avatarNekoBg | #FFF1DF |
| avatarPiggyBg | #FFEAE7 |
| avatarKumaBg | #F7ECE1 |
| avatarBobaBg | #EFE9FC |

These remain available for avatar/category artwork. Do not apply individual
backgrounds to the profile-creation avatar cards: those use one shared surface.

### 3.5 Component-specific colors

| Token | Hex | Role |
|---|---|---|
| currencyBadgeBackground | #FEE2E2 | Light currency-symbol badge fill |
| currencyBadgeBorder | #FECACA | Light currency-symbol badge outline |
| currencyBadgeForeground | #DC2626 | Light currency-symbol text |
| securityNoticeBackground | #FFFBEB | Notice fill, 70% opacity over modal surface |
| securityNoticeBorder | #FDE68A | Notice outline, 70% opacity over modal surface |
| securityNoticeForeground | #D97706 | Notice lock icon, opaque |

The currency colors come from the reference's red-100/red-200/red-600;
the notice colors come from amber-50/amber-200/amber-600.
Do not reuse them for global errors or replace the brand orange with amber.
White foregrounds are `#FFFFFF`; transparent surface tint is intentional.

## 4. Color usage and theme mapping

| Semantic role | Light | Dark |
|---|---|---|
| Scaffold | scaffoldBg | darkScaffoldBg |
| Card/modal surface | cardSurface / modalSurface | darkSurface |
| Warm container/input | surfaceWarm | darkSurfaceWarm |
| Primary text / `onSurface` | textHeadline | darkTextPrimary |
| Body text | textBody | darkTextPrimary |
| Secondary text / `onSurfaceVariant` | textMuted | darkTextMuted |
| Hint text | textPlaceholder | darkTextMuted |
| Standard component border | borderLight | darkBorder |
| Input border | borderInput | darkBorder |
| Focus border | borderInputFocused | borderInputFocused |
| Primary / onPrimary | primary / white | primary / white |
| Primary container | primaryLight | darkSurfaceWarm |
| Income container | mintLight | darkSurfaceWarm |
| onIncomeContainer | mintForeground | mint |
| Expense/error container | coralLight | darkSurfaceWarm |
| onExpenseContainer | coralForeground | coral |
| Information container | skyLight | darkSurfaceWarm |

Income, expense, and information accents remain mint, coral, and sky in both
modes. Use `AppSemanticColors` for these foreground/container pairs. Error
messages must include explicit text, not merely a coral border.

Prefer `Theme.of(context).colorScheme` and `textTheme` for normal widgets.
Use direct `AppColors` references only for explicitly defined component recipes.
Do not assume accent/container pairs meet text-contrast requirements; see section 10.
Do not apply opacity to normal text to create hierarchy: use its named text role.

## 5. Typography

### 5.1 Font and scale

Use locally bundled **Nunito** for all application text. Do not fetch fonts at
runtime or mix in Quicksand/Plus Jakarta Sans from the exported HTML.
Platform emoji fonts are the exception for avatar artwork.

| Role | Flutter basis | Size | Weight | Usage |
|---|---|---|---|---|
| Page headline | headlineMedium | 24 | 800 | Welcome/page headline, prominent totals |
| Modal/page title | titleLarge | 20 | 700 | Dialog/sheet title |
| Section/item title | titleMedium | 16 | 700 | Card title, currency code |
| Main body | bodyLarge | 15 | 600 | Main prose, entered values |
| Supporting body | bodyMedium | 13 | 500 | Subtitle, helper copy, notice |
| Form section label | titleMedium override | 13 | 700 | Profile form labels; tracking 0.5 |
| Primary button | button text style | 16 | 700 | Main action label |
| Avatar label | button text override | 12 | 700 | Neko/Piggy/Kuma/Boba |
| Currency badge symbol | titleMedium override | 24 | 700 | Symbol within the 48px badge |
| Quick-currency label | chip label | 14 | 700 | Symbol and ISO code |

Form section labels use uppercase in the profile form. Body copy and buttons use
sentence case. Preserve currency codes and user-entered capitalization.
The 14px chip size is the explicit target for new implementations; its current
implementation still inherits its size from Material.

Use primary/body colors for content the user must read or act on. Reserve muted
colors for supporting hierarchy, not every paragraph. Avoid light font weights.
Retain the base Nunito/Material line-height and letter-spacing defaults except
the explicit form-label tracking above; no custom global line-height is approved.
Unlisted Material text roles are not additional design tokens.

### 5.2 Scaling and content

- Respect system text scaling; do not clamp the whole app to preserve a mockup.
- Allow headings, error messages, supporting copy, and menu entries to wrap.
- Truncate only compact identity displays, with a full-name tooltip.
- Never shrink normal text with `FittedBox` to fit a layout. The decorative
  currency symbol may scale down within its bounded badge.
- Use locale-aware money formatting and symbols; pair ambiguous symbols with ISO codes.

## 6. Spacing, shapes, borders, and elevation

### 6.1 Spacing vocabulary

| Value | Use |
|---|---|
| 4 | Icon/text micro-gap, title/subtitle |
| 6 | External profile-name label to input; badge inner padding |
| 8 | Standard label/control gap, quick-currency gap |
| 10 | Notice icon/text gap; avatar vertical padding |
| 12 | Avatar-card gap, list-row padding |
| 14 | Notice padding |
| 16 | Standard section gap; profile modal top padding |
| 20 | Major profile section gap; currency picker padding |
| 24 | Profile modal horizontal/bottom padding; page gutter baseline |
| 32 | Large composition separation when needed |

Use these values rather than arbitrary per-view increments. Page compositions may
adapt gutters to available width, but must not compress controls below usability.

### 6.2 Shape and size recipes

| Component | Corner radius | Size/border |
|---|---|---|
| Card/dialog | 24 | Flat, standard border 1 |
| Bottom sheet | 32 at top | Show drag handle |
| Input/currency selector | 20 | Input resting border 1.2 light / 1 dark; focus 2 |
| General filled/elevated action | Stadium | Minimum height 54 |
| Profile Create button | 16 | Minimum height 56; full available form width |
| Text/outlined action | Stadium | Minimum 48 x 48 |
| Avatar card | 16 | Minimum height 76; unselected border 1, selected 2 |
| Currency badge | 16 | 48 x 48; padding 6; border 1 |
| Quick-currency chip | 12 | Padding horizontal 8 / vertical 4; border 1 or selected 1.5 |
| Security notice | 18 | Padding 14; border 1 |
| Avatar selection badge | Circle | Diameter 20; white check icon 12 |

Flat surfaces are the default: zero card, app-bar, and chip elevation and no
surface tint. Do not add shadows to quick-currency chips. Profile controls are
local exceptions to stadium buttons, not a global button-shape change.
Default Material hover/pressed/focus feedback is retained unless specified;
`primaryDark` is reserved for an explicit pressed-color override, not an
instruction that all current buttons already implement one.

## 7. Component recipes and states

### 7.1 Profile creation

- Below 600px viewport width use a bottom sheet; at 600px and above use a dialog.
- Form max width 520; available height capped at 90% after keyboard/safe areas.
- Scroll content; preserve horizontal padding and keyboard access to actions.
- Four equally sized avatar cards span the row, with 12px gaps.
- All unselected cards share surfaceWarm in light mode / darkSurface in dark.
- Selected cards use primarySubtle / darkSurfaceWarm, primary border, and an
  orange circle with a white check anchored to the full card's top-right corner.
- The 20px badge center sits on the corner (10px outward overlap). Reserve enough
  gutter space; the badge must not collide with its neighbor or clip.
- Unselected avatar labels use secondary text; selected labels use primaryDark
  in light mode and darkTextPrimary in dark mode.
- Name label is external; the input contains a person icon and example hint,
  with no duplicate floating label.
- Show a success check only for a nonblank name available among loaded profiles.
  Duplicate checks trim names and compare case-insensitively in this form.
  This is UI validation, not a database-wide uniqueness guarantee.
- Do not include the removed live profile-preview card.
- Currency is immutable once a profile is created. Do not imply a change action.
- Cancel/close preserves the active profile. Do not show backup-restore actions
  until restore is implemented.

### 7.2 Currency selector and symbol badge

- Selector row: warm fill, input border, 20px radius; show symbol, ISO code,
  currency name, a formatted example, and the search affordance.
- Light symbol badge uses the three currencyBadge tokens, all opaque.
- Dark symbol badge uses darkSurfaceWarm, darkBorder, and coralLight text.
- The badge is decorative; the selector's textual code/name carries its meaning.
- Currency picker dialog: max width 480 and 85% of available height; padding 20.
- Search matches supported names/codes/countries. Show explicit no-results text,
  result counts, and a clear-search affordance. Cancellation preserves selection.

### 7.3 Quick-currency chips

- USD, EUR, JPY, GBP, BRL in one horizontally scrollable row; do not wrap.
- Include a locale-aware symbol and ISO code; selection adds a trailing check.
- Selected: primary fill/border, white text/symbol/check, border width 1.5.
- Unselected: warm surface, standard border width 1, body text, muted symbol.
- Use weight 700, radius 12, zero resting and pressed elevation.
- Preserve selected semantics, keyboard interaction, and currency-name tooltips.
- These are selectable controls styled as compact badges, not passive labels.

### 7.4 Currency/privacy notice

- Light: securityNoticeBackground and securityNoticeBorder at 70% opacity.
- Dark: darkSurfaceWarm fill and darkBorder outline.
- Both: opaque securityNoticeForeground lock icon, size 18; 10px text gap.
- Text uses supporting body size but primary text color for readability.
- Explain currency locking and on-device storage; do not present it as a failure.
- Do not reuse coral/error styling for this informational notice.

### 7.5 Shared form, loading, and error behavior

- Validate required values inline, preserve input on failure, and reveal the field
  with the error when it is outside the viewport.
- While saving, disable repeat submission and controls; show saving text.
  Block close/back/barrier dismissal during the pending profile save.
- Show storage and validation failures explicitly and provide a valid retry path.
- Loading, empty, content, and error are separate states; never show empty success
  content when a storage operation has failed.
- Inputs retain named resting, focus, error, and focused-error borders.
- For unspecified disabled/hover/pressed states use shared Material theme
  behavior, not ad hoc opacity changes in individual views.

### 7.6 Home, Transactions, and Stats composition

The approved [look-and-feel reference](./look_and_feel.jpg) defines the
composition of these three views. Its sample amounts, artwork, colors, and
fonts do not replace this document's tokens or imply seeded user data.

- Bottom navigation: Home, Transactions, central Add action, Stats, Profile.
  Keep selected semantics and a container highlight in addition to color.
- Home: a single profile-selector/month-controls header without a separate
  greeting/avatar row; settings remain accessible through the Profile tab.
  Retain screen titles on Transactions, Stats, and Profile.
  Follow with expense/income cards, spending overview
  with category donut and legend, then the three latest transactions and View all.
  The Recent transactions header has no total-count badge.
  Home and Transactions end after their content without a generic motivational
  footer. Retain actionable empty-state guidance.
  Do not show a separate remaining-to-allocate card or budget action on Home.
- Summary-card direction arrows sit immediately before the Expenses/Income
  labels in one compact row, with the amount below. Arrows indicate money
  direction, not a comparison or trend, and do not repeat the accessible label.
  Use 24px rounded Material call-made/call-received arrows for stronger visual
  weight without changing the card padding or semantic colors.
- Summary-card label, amount, and arrow share `onIncomeContainer` or
  `onExpenseContainer`. These explicit foregrounds preserve semantic hues and
  provide at least 4.5:1 contrast against their containers in both themes
  (light income 5.96:1, light expense 5.57:1; dark 6.79:1 and 5.23:1).
  Existing chart accents and transaction colors are unchanged.
- Transactions: searchable category/notes, All/Income/Expense/Savings filters,
  newest/oldest sorting, and Today/Yesterday/calendar-date groups. Category is
  the primary label; notes are secondary. Normal transaction rows place the
  amount and date/time in a right-aligned column, with date/time below amount.
  Home shows Today, Yesterday, or 2–6 days ago when viewing the current month.
  Older and future entries show a localized calendar date (for example Oct 14);
  previous-month views use calendar dates throughout. Include the year for
  entries outside the current year. Transactions shows time under its
  existing date-group headings. The date tooltip exposes the full timestamp.
  Large text and long amounts retain a stacked fallback; generated savings
  retain their read-only explanation. Tap-to-edit remains available on Home
  and Transactions for editable entries; saving requires explicit confirmation.
  Home has no inline delete icons. Transactions retains its discoverable delete
  icons and confirmation dialog; generated savings cannot be edited or deleted.
  Transaction rows use 16px horizontal content padding with no additional
  vertical content padding: retain ListTile's intrinsic vertical spacing and
  touch targets rather than adding height around its existing layout.
- Stats: actual total expenses, comparison against the previous full calendar
  month, category breakdown, daily expense trend, and a factual encouragement
  card. A compact monthly summary below the analytics shows income, expenses,
  savings, and remaining to allocate (income minus expenses minus savings).
  Preserve negative remainders and zero-income values; do not substitute an
  ambiguous "used" percentage or progress bar. Budget editing, percentages,
  and bucket progress follow the summary. Hide the summary and show the
  existing explicit error when totals exceed the supported range.
- All views share the selected profile and calendar month. Savings and income
  are excluded from expense charts. Archived categories remain in history.
- Chart colors cycle through coral, sky, lavender, mint, and primary tokens.
  Category legends use three aligned columns: category left, amount centered,
  whole-number percentage right. Long category names use one-line ellipsis;
  tapping the name reveals a tooltip and semantics retain the full name.
  Place the legend below the donut when measured amounts, available width,
  or text scaling make a side-by-side layout too cramped. Never truncate money.
  Independently rounded percentages can sum to 99% or 101%.
  Home uses a compact 112px donut with the legend alongside it at normal text
  sizes. Show all categories when there are five or fewer; otherwise show the
  four largest individual categories and aggregate the rest as Other, always
  last even when its combined amount is larger. Use the same grouping in the
  donut and legend, exact summed minor units, and a neutral textMuted /
  darkTextMuted segment for Other. Its tooltip and semantics identify the
  grouped categories, and tapping opens Stats, which retains the full breakdown.
  Omit Home's repeated month and show its total only once: inside the donut if
  it fits, otherwise above it. Large text or long amounts can still stack the
  legend below the chart. Never shrink text or clip money to force two columns.
  Use exact formatted amounts and named categories in legends; colors alone
  must not carry meaning. Daily-chart semantics list dates and amounts.
- Never invent percentage changes, savings achievements, or chart segments.
  Explicitly show no-data states; omit comparison percentages when the previous
  month's expense total is zero. Compare whole months, not a fictional week.
- Aggregate minor units exactly before converting normalized chart ratios to
  floating point. Surface out-of-range display totals rather than truncating.
- Use existing Nunito type roles, 24px cards, flat surfaces, 12/16/24px spacing,
  semantic income/expense containers, Material icons, and bundled artwork.
- Keep the header in the scrollable content so long identities and 2x text
  cannot push content outside a narrow screen. Keep controls reachable at 320px.
- No database, sync, receipt, bank, or monetization changes are implied.

## 8. Layout, icons, and motion

- Use safe areas and available viewport dimensions, not device-name checks.
- Desktop layouts constrain readable form width rather than stretching fields
  across the entire window.
- Preserve scrolling with keyboard insets and large text. No fixed-height text
  containers that overflow at 2x text scale.
- Use Material icons for actions/status and locally bundled assets for artwork.
  Avatar emoji may differ by platform; exact cross-platform artwork is not promised.
- Reuse existing navigation and modal helpers; do not stack duplicate create forms.
- Keep existing Material route/interaction transitions. Profile validation reveal
  scroll uses 200ms. No new decorative animation or custom motion curve is specified.
- Respect reduced-animation preferences when adding motion in the future.

## 9. Implementation checklist for new views

1. Identify semantic roles and reuse an existing component recipe.
2. Use the exact palette tokens and Nunito type roles; no arbitrary color literals.
3. Implement light and dark states together, including selection/focus/errors.
4. Apply the spacing/shape recipe; document necessary new variants before reuse.
5. Include loading, empty, error, success, and pending-interaction behavior.
6. Verify selection without relying only on color; provide labels and tooltips.
7. Add focused widget tests for layout, states, and any new token mapping.
8. Exercise narrow 320px, standard 390px, and desktop widths, including 2x text.
9. Run relevant tests, analyzer, and an appropriate build without launching the
   app/emulator. Visual verification is performed manually by the user.
10. Update this document when an approved design rule changes.

## 10. Known gaps and proposals (not approved visual changes)

The rules above preserve the current palette; they do not certify accessibility.
Do not silently darken or substitute colors to resolve these issues.

| Gap | Current evidence / impact | Follow-up |
|---|---|---|
| Low contrast | White on primary is about 2.05:1; muted text on white about 3.06:1; placeholder on surfaceWarm about 1.74:1 | Review against 4.5:1 normal-text / 3:1 large-text targets and approve changes separately |
| Focus visibility | Orange focus border on surfaceWarm is about 1.92:1 | Review a non-color-only/high-contrast focus treatment |
| Washed-out supporting text | bodyMedium defaults to muted; avatar labels are also muted | Consider body text color for essential copy, keeping muted only for secondary hierarchy |
| Compact touch targets | Quick chips use compact density and shrink-wrapped hit areas | Review expanded invisible targets of at least 48 x 48 without enlarging the visual pills |
| Partial type-scale enforcement | Shared theme defines five text roles; chips inherit font size; avatar labels inherit button weight | Centralize named styles and explicit sizes in a later code change |
| Inherited Material metrics | Line height, chip label padding, and some state colors remain framework defaults | Add explicit tokens only when a reviewed design requires deterministic metrics |
| No app-wide adoption audit | Older feature views may use local styles outside these recipes | Audit and migrate view by view; this document-only change does not restyle them |

Retained accessibility requirements: meaningful semantics, keyboard access,
non-color-only selection, text scaling, clear validation messages, and visible
loading/error states. Known palette exceptions must remain visible in this list
until resolved through an approved design change.
