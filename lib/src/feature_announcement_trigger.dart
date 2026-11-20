import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutty_announcements/src/feature_announcement_sheet.dart';
import 'package:flutty_announcements/src/feature_announcements.dart';
import 'package:flutty_announcements/src/models.dart';

/// Presents the pending "what's new" announcement, if any — meant to sit on
/// the app's root widget so it shows wherever the user lands.
///
/// A single attempt per session (the widget stays mounted as long as its
/// parent lives): [FeatureAnnouncements.pendingAnnouncement] decides
/// eligibility — running minor version and not yet seen on this device.
class FeatureAnnouncementTrigger extends StatefulWidget {
  const FeatureAnnouncementTrigger({
    required this.child,
    required this.announcements,
    required this.service,
    this.onCta,
    this.overline,
    this.closeLabel,
    super.key,
  });

  final Widget child;

  /// The versioned config — injectable in tests.
  final List<FeatureAnnouncement> announcements;

  /// Service deciding eligibility and tracking seen ids — the app provides
  /// its version, store key and analytics implementation.
  final FeatureAnnouncements service;

  /// Called after the sheet is closed via its CTA — typically pushes a route
  /// built from [FeatureAnnouncementCta.payload]. Left `null`, a CTA only
  /// closes the sheet (the analytics outcome is still `cta`).
  final FutureOr<void> Function(
    BuildContext context,
    FeatureAnnouncementCta cta,
  )?
  onCta;

  /// Chrome labels of the sheet — defaults are fr/en.
  final LocalizedText? overline;
  final LocalizedText? closeLabel;

  @override
  State<FeatureAnnouncementTrigger> createState() =>
      _FeatureAnnouncementTriggerState();
}

class _FeatureAnnouncementTriggerState
    extends State<FeatureAnnouncementTrigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
  }

  Future<void> _maybeShow() async {
    final announcement = await widget.service.pendingAnnouncement(
      widget.announcements,
    );
    if (announcement == null || !mounted) return;
    // Marked seen before the sheet itself: an app killed with the sheet open
    // must not show it again at next launch.
    await widget.service.announcementShown(announcement);
    if (!mounted) return;
    final outcome =
        await FeatureAnnouncementSheet.show(
          context,
          announcement,
          overline: widget.overline,
          closeLabel: widget.closeLabel,
        ) ??
        FeatureAnnouncementClose.dismiss;
    await widget.service.announcementClosed(announcement, outcome: outcome);
    if (outcome == FeatureAnnouncementClose.cta &&
        announcement.cta != null &&
        mounted) {
      await widget.onCta?.call(context, announcement.cta!);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
