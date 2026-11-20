import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/game_role.dart';
import '../domain/services/role_shuffler.dart';

/// Persists and restores the player's last round setup configuration.
class GameSettingsStorage {
  const GameSettingsStorage([this._prefs]);

  static const String _playerCountKey = 'obsidian_syndicate_player_count';
  static const String _optionalRolesKey = 'obsidian_syndicate_optional_roles';

  final SharedPreferences? _prefs;

  Future<SharedPreferences> _getInstance() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  /// Loads persisted player count and enabled optional role IDs.
  Future<({int playerCount, Set<String> enabledOptionalRoleIds})>
      loadSettings() async {
    final SharedPreferences prefs = await _getInstance();

    final int rawCount =
        prefs.getInt(_playerCountKey) ?? RoleShuffler.minPlayers;
    final int playerCount =
        rawCount.clamp(RoleShuffler.minPlayers, RoleShuffler.maxPlayers);

    final List<String> savedRoleIds =
        prefs.getStringList(_optionalRolesKey) ?? const <String>[];

    final Set<String> validOptionalIds = GameRole.optionalRoles
        .map((GameRole role) => role.id)
        .toSet();

    final int maxOptionalAllowed =
        playerCount - GameRole.mandatoryRoles.length;

    final Set<String> enabledOptionalRoleIds = <String>{};
    for (final String id in savedRoleIds) {
      if (validOptionalIds.contains(id) &&
          enabledOptionalRoleIds.length < maxOptionalAllowed) {
        enabledOptionalRoleIds.add(id);
      }
    }

    return (
      playerCount: playerCount,
      enabledOptionalRoleIds: enabledOptionalRoleIds,
    );
  }

  /// Persists the current player count and enabled optional role IDs.
  Future<void> saveSettings({
    required int playerCount,
    required Set<String> enabledOptionalRoleIds,
  }) async {
    final SharedPreferences prefs = await _getInstance();
    await prefs.setInt(_playerCountKey, playerCount);
    await prefs.setStringList(
      _optionalRolesKey,
      enabledOptionalRoleIds.toList(growable: false),
    );
  }
}
