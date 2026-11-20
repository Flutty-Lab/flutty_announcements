import 'package:material_ui/material_ui.dart';

/// Text localized inline in the announcements config: fr and en live next to
/// the announcement itself rather than in arb keys — all the copy of an
/// announcement is read and edited in one place when preparing a release.
class LocalizedText {
  const LocalizedText({required this.en, required this.fr});

  final String en;
  final String fr;

  /// English is the fallback for any uncovered locale — same choice as the
  /// localization delegates (first supported locale).
  String resolve(Locale locale) => locale.languageCode == 'fr' ? fr : en;
}

/// How the announcement sheet was closed — the `outcome` parameter passed to
/// [FeatureAnnouncementsAnalytics.announcementClosed].
enum FeatureAnnouncementClose { cta, dismiss }

/// A feature highlight presented at launch, once per device.
///
/// Announcements are declared in a versioned `const` list owned by the app:
/// an announcement is eligible as long as the app runs on the same minor
/// version as [releasedIn] — a patch keeps it, the next minor expires it
/// (older features belong to onboarding, not announcements).
class FeatureAnnouncement {
  const FeatureAnnouncement({
    required this.id,
    required this.releasedIn,
    required this.title,
    required this.body,
    this.bullets = const [],
    this.cta,
    this.icon = Icons.auto_awesome,
    this.preview,
  });

  /// Stable identifier, persisted among the "seen" ones — never reuse it for
  /// another announcement.
  final String id;

  /// `major.minor` version of the release introducing the feature (e.g.
  /// `'1.3'`).
  final String releasedIn;

  final LocalizedText title;
  final LocalizedText body;
  final List<LocalizedText> bullets;

  /// Action button at the bottom of the sheet (e.g. open the settings);
  /// `null` for a purely informative announcement.
  final FeatureAnnouncementCta? cta;

  /// Header pictogram of the sheet.
  final IconData icon;

  /// Screenshot-like preview shown under the body — e.g. an excerpt of the
  /// feature's settings page, to show where it happens rather than explain
  /// it. Must have a `const` constructor to stay inside the `const` config.
  final Widget? preview;
}

/// An announcement CTA: its localized label plus an opaque [payload] handed
/// back to `FeatureAnnouncementTrigger.onCta`.
///
/// The payload is typically a route object (e.g. an auto_route
/// `PageRouteInfo`) — it keeps the config `const`-constructible while the
/// package stays router-agnostic.
class FeatureAnnouncementCta {
  const FeatureAnnouncementCta({required this.label, this.payload});

  final LocalizedText label;
  final Object? payload;
}
