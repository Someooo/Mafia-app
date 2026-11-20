/// Faction alignment in the Obsidian Syndicate universe.
///
/// Pure Dart domain entity with zero Flutter or UI dependencies.
enum RoleTeam {
  mafia,
  citizens;

  String get arabicLabel {
    switch (this) {
      case RoleTeam.mafia:
        return 'المافيا';
      case RoleTeam.citizens:
        return 'المواطنون';
    }
  }

  /// Corner index initial as specified in DESIGN.md ("م" for Mafia, "مـ" for Citizen).
  String get cornerIndex {
    switch (this) {
      case RoleTeam.mafia:
        return 'م';
      case RoleTeam.citizens:
        return 'مـ';
    }
  }

  /// Playing card suit symbol associated with the faction.
  String get suitSymbol {
    switch (this) {
      case RoleTeam.mafia:
        return '♠';
      case RoleTeam.citizens:
        return '♦';
    }
  }
}

/// Centralized asset paths matching the exact files in `assets/images/` and `assets/audio/`.
///
/// Pure Dart constants with zero Flutter dependencies.
abstract final class GameAssets {
  static const String logo = 'assets/images/لوقو النيتف سبلاش.jpg';
  static const String cardBack = 'assets/images/ظهر البطاقه.png';

  static const String mafiaLeader = 'assets/images/شيخ المافيا.jpg';
  static const String silencerMafia = 'assets/images/مافيا التسكيت.jpg';
  static const String regularMafia = 'assets/images/مافيا عادي.jpg';
  static const String citizensLeader = 'assets/images/شيخ المواطنين.jpg';
  static const String medic = 'assets/images/بنت الصالحين (طبيبة).jpg';
  static const String avengerVillager = 'assets/images/ولد الصالحين.jpg';
  static const String sniper = 'assets/images/قناص الصالحين.jpg';
  static const String regularCitizen = 'assets/images/مواطن صالح.jpg';

  // Night-1 Moderator Audio Assets (relative to `assets/` for AudioPlayer AssetSource, and full paths)
  static const String nightSleepAudioSource = 'audio/night_sleep.mp3';
  static const String mafiaWakeAudioSource = 'audio/mafia_wake.mp3';
  static const String mafiaSleepAudioSource = 'audio/mafia_sleep.mp3';
  static const String cityWakeAudioSource = 'audio/city_wake.mp3';

  static const String nightSleepAudio = 'assets/audio/night_sleep.mp3';
  static const String mafiaWakeAudio = 'assets/audio/mafia_wake.mp3';
  static const String mafiaSleepAudio = 'assets/audio/mafia_sleep.mp3';
  static const String cityWakeAudio = 'assets/audio/city_wake.mp3';

  /// All card and branding image paths to pre-cache into Flutter's ImageCache.
  static const List<String> allCardAndBrandAssets = [
    logo,
    cardBack,
    mafiaLeader,
    silencerMafia,
    regularMafia,
    citizensLeader,
    medic,
    avengerVillager,
    sniper,
    regularCitizen,
  ];
}

/// Immutable pure-Dart domain model representing a Mafia role card.
class GameRole {
  const GameRole({
    required this.id,
    required this.title,
    required this.description,
    required this.isMandatory,
    required this.team,
    required this.imagePath,
    this.isOptionalSelectable = false,
  });

  final String id;
  final String title;
  final String description;
  final bool isMandatory;
  final RoleTeam team;
  final String imagePath;
  final bool isOptionalSelectable;

  // --- Mandatory Roles (4) ---

  static const GameRole mafiaLeader = GameRole(
    id: 'mafia_leader',
    title: 'شيخ المافيا',
    description: 'يختار ضحية كل ليلة',
    isMandatory: true,
    team: RoleTeam.mafia,
    imagePath: GameAssets.mafiaLeader,
  );

  static const GameRole silencerMafia = GameRole(
    id: 'silencer_mafia',
    title: 'مافيا التسكيت',
    description: 'يمنع لاعباً من الكلام',
    isMandatory: true,
    team: RoleTeam.mafia,
    imagePath: GameAssets.silencerMafia,
  );

  static const GameRole citizensLeader = GameRole(
    id: 'citizens_leader',
    title: 'شيخ المواطنين',
    description: 'يقود النقاش ويكشف المؤامرات',
    isMandatory: true,
    team: RoleTeam.citizens,
    imagePath: GameAssets.citizensLeader,
  );

  static const GameRole medic = GameRole(
    id: 'medic',
    title: 'المسعف',
    description: 'ينقذ لاعباً من القتل',
    isMandatory: true,
    team: RoleTeam.citizens,
    imagePath: GameAssets.medic,
  );

  // --- Optional Toggleable Roles (3) ---

  static const GameRole avengerVillager = GameRole(
    id: 'avenger_villager',
    title: 'ولد الصالحين',
    description: 'يسحب لاعباً معه',
    isMandatory: false,
    isOptionalSelectable: true,
    team: RoleTeam.citizens,
    imagePath: GameAssets.avengerVillager,
  );

  static const GameRole sniper = GameRole(
    id: 'sniper',
    title: 'القناص',
    description: 'يطلق على المافيا ليلاً',
    isMandatory: false,
    isOptionalSelectable: true,
    team: RoleTeam.citizens,
    imagePath: GameAssets.sniper,
  );

  static const GameRole regularMafia = GameRole(
    id: 'regular_mafia',
    title: 'مافيا عادي',
    description: 'يتآمر مع فريقه',
    isMandatory: false,
    isOptionalSelectable: true,
    team: RoleTeam.mafia,
    imagePath: GameAssets.regularMafia,
  );

  // --- Standard Filler Role ---

  static const GameRole regularCitizen = GameRole(
    id: 'regular_citizen',
    title: 'مواطن صالح',
    description: 'يبحث مع فريقه',
    isMandatory: false,
    isOptionalSelectable: false,
    team: RoleTeam.citizens,
    imagePath: GameAssets.regularCitizen,
  );

  /// Exactly 4 mandatory roles required in every match (N >= 6).
  static const List<GameRole> mandatoryRoles = [
    citizensLeader,
    medic,
    mafiaLeader,
    silencerMafia,
  ];

  /// Optional roles that can be toggled on/off in the setup screen.
  static const List<GameRole> optionalRoles = [
    avengerVillager,
    sniper,
    regularMafia,
  ];

  /// Complete encyclopedia of all 8 roles for the Role Guide bottom sheet.
  static const List<GameRole> allRoles = [
    mafiaLeader,
    silencerMafia,
    regularMafia,
    citizensLeader,
    medic,
    avengerVillager,
    sniper,
    regularCitizen,
  ];

  static GameRole? findOptionalById(String id) {
    for (final role in optionalRoles) {
      if (role.id == id) {
        return role;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is GameRole && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
