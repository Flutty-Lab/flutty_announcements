import 'package:flutty_announcements/src/analytics.dart';
import 'package:flutty_announcements/src/announcement_store.dart';
import 'package:flutty_announcements/src/models.dart';

/// What's-new announcements — which feature to highlight at launch, and the
/// tracking of what this device already saw.
class FeatureAnnouncements {
  const FeatureAnnouncements({
    required this.appVersion,
    this.store = const SharedPreferencesAnnouncementStore(),
    this.analytics = const NoopFeatureAnnouncementsAnalytics(),
  });

  /// Persistence of the seen ids — defaults to SharedPreferences with the
  /// `flutty_announcements_seen` key.
  final FeatureAnnouncementStore store;

  /// Analytics sink — defaults to a no-op.
  final FeatureAnnouncementsAnalytics analytics;

  /// Full version of the running app (`'1.3.2+15'`) — provided by the app,
  /// typically `(await PackageInfo.fromPlatform()).version`. Announcements
  /// are scoped to its `major.minor`.
  final String appVersion;

  /// The first eligible, not-yet-seen announcement of [announcements] (the
  /// versioned config), `null` otherwise — eligible means "same minor version
  /// as the running app".
  Future<FeatureAnnouncement?> pendingAnnouncement(
    List<FeatureAnnouncement> announcements,
  ) async {
    final seen = await store.seenIds();
    final minor = _runningMinor();
    for (final announcement in announcements) {
      if (announcement.releasedIn == minor && !seen.contains(announcement.id)) {
        return announcement;
      }
    }
    return null;
  }

  /// The announcement was just presented: mark it seen right away — an app
  /// killed with the sheet open must not show it again at next launch.
  Future<void> announcementShown(FeatureAnnouncement announcement) async {
    await store.markSeen(announcement.id);
    analytics.announcementShown(announcement.id);
  }

  /// The sheet was closed — [outcome] is `cta` or `dismiss`.
  Future<void> announcementClosed(
    FeatureAnnouncement announcement, {
    required FeatureAnnouncementClose outcome,
  }) async {
    analytics.announcementClosed(announcement.id, outcome);
  }

  /// `major.minor` of [appVersion] ('1.3.2+15' → '1.3') — announcements are
  /// scoped to a minor: a patch keeps them, the next minor expires them.
  String _runningMinor() {
    final segments = appVersion.split('+').first.split('-').first.split('.');
    return segments.take(2).join('.');
  }
}
