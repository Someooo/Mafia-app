# مافيا — موزع الأدوار الذكي | Mafia Role Dealer (`Obsidian Syndicate`)

<p align="center">
  <img src="assets/images/لوقو النيتف سبلاش.jpg" alt="Mafia App Logo" width="180" />
</p>

<p align="center">
  <strong>An offline-first, zero-latency Arabic party role-dealer mobile application built with Flutter, Clean Architecture, and the Obsidian Syndicate Design System.</strong>
</p>

<p align="center">
  <a href="https://github.com/Someooo/Mafia-app"><img src="https://img.shields.io/badge/GitHub-Someooo%2FMafia--app-161616?style=flat-square&logo=github" alt="Repository" /></a>
  <img src="https://img.shields.io/badge/Flutter-3.24%2B-02569B?style=flat-square&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20%2B%20BLoC-D90429?style=flat-square" alt="Clean Architecture" />
  <img src="https://img.shields.io/badge/Directionality-Arabic%20RTL-0D0D0D?style=flat-square" alt="Arabic RTL" />
  <img src="https://img.shields.io/badge/Mode-100%25%20Offline-2E7D32?style=flat-square" alt="Offline" />
</p>

---

## 1. Project Overview | نظرة عامة على المشروع

**Mafia Role Dealer (`مافيا — لعبة الذكاء والشك`)** solves a classic friction point in live tabletop social-deduction sessions: worn or marked paper cards, unbalanced manual deck assembly, and accidental role peeking when passing cards around the table.

Engineered as a **single-device Pass-and-Play dealer**, the application mathematically balances the role deck for **6 to 18 players**, shuffles roles using a cryptographically secure random number generator (`Random.secure()`), and enforces strict single-card reveal locks with a full-screen privacy handoff shield between turns.

---

## 2. Key Features | المميزات الرئيسية

- **Cryptographic Fisher-Yates Shuffling (`Random.secure()`):** Guarantees an unbiased, unpredictable role distribution on every deal and reshuffle.
- **Dynamic Role Balancing Engine (`6–18` Players):**
  - Always enforces the **4 mandatory roles**: `شيخ المواطنين` (Citizens Leader), `المسعف` (Medic), `شيخ المافيا` (Mafia Leader), and `مافيا التسكيت` (Silencer Mafia).
  - Supports toggling **optional tactical roles** (`ولد الصالحين` Avenger, `القناص` Sniper, `مافيا عادي` Regular Mafia) while mathematically preventing `remainingCitizenCount` from dropping below `0`.
  - Automatically fills remaining player slots with `مواطن صالح` (Regular Citizen).
- **Anti-Cheat Pass-and-Play Card Locking:**
  - When a card is flipped open, all other grid cards are immediately locked and dimmed (`revealedCardIndex != null`).
  - Once viewed and claimed (`فهمت - اضغط للإخفاء`), the card permanently transitions to a locked `تم السحب` slot and triggers an opaque privacy shield (`مرر الهاتف للاعب رقم X لفتح بطاقة`) to prevent screen peeking during phone handoff.
- **3D Y-Axis Perspective Card Flip (`Matrix4.rotationY`):** Smooth `520ms` cubic 3D flip animation with counter-rotated front-face rendering and pre-cached role artwork (`precacheImage`) for zero-flicker performance on mid-range Android devices.
- **Tactile Haptics & Accidental Exit Guard:**
  - Distinct haptic impulses (`HapticFeedback.lightImpact`, `mediumImpact`, `heavyImpact`) on counter adjustments, card flips, claims, and reshuffles.
  - Hardware back-navigation guard (`PopScope`) during active deals to prevent accidental round loss.
- **Automated Night-1 Audio & Visual Moderator (`NightModeratorScreen`):**
  - Automatically launches after the final card is claimed, guiding the table through the 4 Night-1 phases (`everyoneSleep` 15s, `mafiaWake` 12s with pulsing crimson aura, `mafiaSleep` 5s, `everyoneWake` 3s) with offline MP3 voiceovers (`assets/audio/*.mp3`) and controls for **إعادة الصوت**, **إعادة الليلة من البداية**, and **تخطي**.
- **Post-Deal Verification Vault & Live Faction Balance (`VerificationVaultScreen`):**
  - Tracks live surviving counts (`المافيا الأحياء` vs `الصالحون الأحياء`), detects automatic win conditions (`isMafiaVictory` / `isCitizensVictory`), verifies eliminated players by player number (`1..N`), and supports **جولة جديدة (إعادة خلط فورية)** instant rematches.
- **Offline Settings Persistence (`SharedPreferences`):** Automatically saves and restores the group's preferred `playerCount` and enabled optional roles across sessions with serialized FIFO write safety.

---

## 3. Roles Encyclopedia | دليل الأدوار

| الدور (Arabic Title) | المعرف (`id`) | الفريق (`Team`) | النوع (`Category`) | القدرة السرية (`Description`) |
| :--- | :--- | :--- | :--- | :--- |
| **شيخ المافيا** | `mafia_leader` | المافيا (`♠ م`) | أساسي إجباري | يختار ضحية كل ليلة |
| **مافيا التسكيت** | `silencer_mafia` | المافيا (`♠ م`) | أساسي إجباري | يمنع لاعباً من الكلام |
| **مافيا عادي** | `regular_mafia` | المافيا (`♠ م`) | تكتيكي اختياري | يتآمر مع فريقه |
| **شيخ المواطنين** | `citizens_leader` | المواطنون (`♦ مـ`) | أساسي إجباري | يقود النقاش ويكشف المؤامرات |
| **المسعف** | `medic` | المواطنون (`♦ مـ`) | أساسي إجباري | ينقذ لاعباً من القتل |
| **ولد الصالحين** | `avenger_villager` | المواطنون (`♦ مـ`) | تكتيكي اختياري | يسحب لاعباً معه |
| **القناص** | `sniper` | المواطنون (`♦ مـ`) | تكتيكي اختياري | يطلق على المافيا ليلاً |
| **مواطن صالح** | `regular_citizen` | المواطنون (`♦ مـ`) | مواطن أساسي (تلقائي) | يبحث مع فريقه |

---

## 4. Architecture & Tech Stack | البنية المعمارية والتقنيات

### Design System: *Obsidian Syndicate*
The UI is built exclusively on a **single fixed dark theme** (`AppTheme.theme`) and a **fixed Arabic-only RTL layout** (`Locale('ar')`, `TextDirection.rtl`) tailored for low-light party environments:
- **Tier 0 Obsidian Canvas:** `#0D0D0D`
- **Tier 1 Resting Card Surface:** `#161616` with `1px` `#262626` border
- **Tier 2 Raised Surface & Sheets:** `#1A1A1A` with `1px` `#333333` border
- **Tier 3 Active Target & CTA:** `#D90429` (Syndicate Crimson) with `25%` crimson atmospheric glow (`0x40D90429`)
- **Typography:** `IBM Plex Sans Arabic` with strict `FontStyle.normal` (zero faux italics) and `FontFeature.liningFigures()` for crisp Western Arabic numerals (`0–9`).

### Technical Stack
- **Framework:** Flutter (`SDK ^3.6.1`, Material 3)
- **State Management:** `flutter_bloc` (`GameCubit` & immutable `GameState`)
- **Local Storage:** `shared_preferences` (`GameSettingsStorage`)
- **Typography & Localization:** `google_fonts` (`IBM Plex Sans Arabic`), `flutter_localizations` (forced `ar` RTL)
- **Native Branding:** `flutter_launcher_icons`, `flutter_native_splash` (with Android 12+ adaptive icon support)

---

## 5. Folder Structure | هيكل المجلدات

```text
MafiaApp/
├── android/
│   └── app/
│       ├── build.gradle                  # R8 minifyEnabled & shrinkResources release config
│       ├── proguard-rules.pro            # Release ProGuard rules
│       └── src/main/AndroidManifest.xml  # Arabic app label ("مافيا") & portrait orientation lock
├── assets/
│   ├── audio/                            # Night-1 moderator voiceover MP3s (night_sleep, mafia_wake, mafia_sleep, city_wake)
│   └── images/                           # 2:3 Role portraits, card back, and splash logo
├── lib/
│   ├── main.dart                         # App entry point, FlutterNativeSplash, portrait lock, RTL builder & BlocProvider
│   ├── core/
│   │   └── theme/
│   │       ├── app_colors.dart           # Obsidian Syndicate color palette & SyndicateColorsExtension
│   │       ├── app_dimensions.dart       # 8pt spatial rhythm, corner radii & flat planar tiers
│   │       ├── app_theme.dart            # Single unified Material 3 dark ThemeData
│   │       └── app_typography.dart       # IBM Plex Sans Arabic typography scale
│   └── features/
│       └── game/
│           ├── data/
│           │   └── game_settings_storage.dart  # SharedPreferences persistence service
│           ├── domain/
│           │   ├── entities/
│           │   │   ├── game_role.dart          # GameRole definitions, RoleTeam & GameAssets pre-caching
│           │   │   └── playable_card.dart      # PlayableCard entity & CardRevealStatus lifecycle
│           │   └── services/
│           │       └── role_shuffler.dart      # Cryptographic Fisher-Yates RoleShuffler
│           └── presentation/
│               ├── cubit/
│               │   ├── game_cubit.dart             # Setup, sequential dealing, vault & instant rematch logic
│               │   ├── game_state.dart             # Immutable GameState with live faction balance & win detection
│               │   ├── night_moderator_cubit.dart  # Automated 4-phase Night-1 audio & timer state machine
│               │   └── night_moderator_state.dart  # NightModeratorPhase & NightModeratorState
│               ├── pages/
│               │   ├── home_screen.dart                # Noir landing screen & Role Guide trigger
│               │   ├── setup_screen.dart               # Player counter (6-18) & role toggle dashboard
│               │   ├── play_grid_screen.dart           # 2:3 card grid, 3D spotlight modal & privacy shield
│               │   ├── night_moderator_screen.dart     # Automated Night-1 audio & visual moderator
│               │   └── verification_vault_screen.dart  # Live faction balance bar, player verification & instant rematch
│               └── widgets/
│                   ├── flip_card_widget.dart   # 3D Matrix4.rotationY animated 2:3 card widget
│                   └── role_guide_sheet.dart   # Modal bottom sheet showcasing all 8 roles
├── test/
│   ├── widget_test.dart                        # RTL & navigation widget smoke test
│   └── features/game/
│       ├── domain/
│       │   └── role_shuffler_test.dart         # Deck size, mandatory roles & variance unit tests
│       └── presentation/cubit/
│           ├── game_cubit_test.dart            # Anti-cheat locking, sequential binding, win detection & persistence tests
│           └── night_moderator_cubit_test.dart # 4-phase Night-1 timer, audio replay, restart & skip unit tests
├── PRIVACY_POLICY.md                           # 100% Offline Google Play Store privacy policy
└── pubspec.yaml                                # Dependencies, assets, launcher icons & native splash
```

---

## 6. Quick Start & Build Commands | التشغيل والبناء

### Prerequisites
- Flutter SDK `>=3.24.0` (Dart `^3.6.1`)

### 1. Install Dependencies & Generate Native Branding
```bash
git clone https://github.com/Someooo/Mafia-app.git
cd Mafia-app
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### 2. Run Static Analysis & Automated Tests
```bash
flutter analyze
flutter test
```

### 3. Build Production Release APKs (Split-per-ABI)
```bash
flutter build apk --release --split-per-abi
```

The shrink-optimized release APKs will be output to:
`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

---

## 7. Privacy & License | الخصوصية

This application operates **100% offline**, collects zero personal data, and requires no internet permissions or user accounts. See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for full details.
