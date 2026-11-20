import 'package:shared_preferences/shared_preferences.dart';

/// Persistence for the ids of announcements already presented on this device.
abstract interface class FeatureAnnouncementStore {
  /// Ids of every announcement already shown here.
  Future<Set<String>> seenIds();

  /// Records [id] as seen — idempotent.
  Future<void> markSeen(String id);
}

/// [FeatureAnnouncementStore] backed by SharedPreferences — the seen ids are
/// deliberately local to the device: an announcement is marked seen where it
/// was displayed and has nothing to do server-side.
final class SharedPreferencesAnnouncementStore
    implements FeatureAnnouncementStore {
  const SharedPreferencesAnnouncementStore({
    this.key = 'flutty_announcements_seen',
  });

  /// Preference key holding the seen ids — namespace it per app so it never
  /// collides with another consumer of the same store.
  final String key;

  @override
  Future<Set<String>> seenIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(key) ?? []).toSet();
  }

  @override
  Future<void> markSeen(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getStringList(key) ?? [];
    if (seen.contains(id)) return;
    await prefs.setStringList(key, [...seen, id]);
  }
}
