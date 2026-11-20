import 'package:flutty_announcements/src/models.dart';

/// Analytics sink for the announcement lifecycle — implemented by the app
/// (e.g. on top of Firebase Analytics). The package stays backend-agnostic:
/// it reports semantic events, the app maps them to its own event names.
abstract interface class FeatureAnnouncementsAnalytics {
  /// The sheet was just presented — the announcement is marked seen at the
  /// same time.
  void announcementShown(String announcementId);

  /// The sheet was closed — [outcome] is `cta` or `dismiss`.
  void announcementClosed(
    String announcementId,
    FeatureAnnouncementClose outcome,
  );
}

/// Default sink used when the app wires no analytics — drops every event.
final class NoopFeatureAnnouncementsAnalytics
    implements FeatureAnnouncementsAnalytics {
  const NoopFeatureAnnouncementsAnalytics();

  @override
  void announcementShown(String announcementId) {}

  @override
  void announcementClosed(
    String announcementId,
    FeatureAnnouncementClose outcome,
  ) {}
}
