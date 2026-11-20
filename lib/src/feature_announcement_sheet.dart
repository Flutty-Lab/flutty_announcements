import 'package:material_ui/material_ui.dart';
import 'package:flutty_ds/dimens.dart';
import 'package:flutty_announcements/src/models.dart';

const _defaultOverline = LocalizedText(
  en: 'New in this version',
  fr: 'Nouveau dans cette version',
);
const _defaultCloseLabel = LocalizedText(en: 'Close', fr: 'Fermer');

/// The "what's new" bottom sheet: title, pitch, optional screenshot-like
/// preview and key points of a new feature, plus an optional CTA (e.g. open
/// the settings).
///
/// Pure presentation widget — it reports how it was closed
/// ([FeatureAnnouncementClose]); the caller marks the announcement seen,
/// logs the analytics event and follows the CTA.
class FeatureAnnouncementSheet extends StatelessWidget {
  const FeatureAnnouncementSheet({
    required this.announcement,
    this.overline = _defaultOverline,
    this.closeLabel = _defaultCloseLabel,
    super.key,
  });

  /// Shows the sheet as a modal bottom sheet and resolves to how it was
  /// closed (`null` when dismissed without an explicit action — the caller
  /// should treat it as [FeatureAnnouncementClose.dismiss]).
  static Future<FeatureAnnouncementClose?> show(
    BuildContext context,
    FeatureAnnouncement announcement, {
    LocalizedText? overline,
    LocalizedText? closeLabel,
  }) => showModalBottomSheet<FeatureAnnouncementClose>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => FeatureAnnouncementSheet(
      announcement: announcement,
      overline: overline ?? _defaultOverline,
      closeLabel: closeLabel ?? _defaultCloseLabel,
    ),
  );

  final FeatureAnnouncement announcement;

  /// Small caps label above the title ("New in this version").
  final LocalizedText overline;

  /// Label of the secondary button closing the sheet ("Close").
  final LocalizedText closeLabel;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Dimens.doubleSpacing,
            0,
            Dimens.doubleSpacing,
            Dimens.doubleSpacing,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _IconBadge(icon: announcement.icon)),
              SizedBox(height: Dimens.doubleSpacing),
              Text(
                overline.resolve(locale),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                announcement.title.resolve(locale),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              SizedBox(height: Dimens.standardSpacing),
              Text(
                announcement.body.resolve(locale),
                textAlign: TextAlign.center,
              ),
              if (announcement.preview != null) ...[
                SizedBox(height: Dimens.doubleSpacing),
                announcement.preview!,
              ],
              for (final bullet in announcement.bullets)
                _Bullet(text: bullet.resolve(locale)),
              SizedBox(height: Dimens.doubleSpacing),
              if (announcement.cta != null)
                FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(FeatureAnnouncementClose.cta),
                  child: Text(announcement.cta!.label.resolve(locale)),
                ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(FeatureAnnouncementClose.dismiss),
                child: Text(closeLabel.resolve(locale)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The announcement icon in a tinted disc — the visual hook at the top of
/// the sheet.
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(Dimens.doubleSpacing),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 32, color: colors.onPrimaryContainer),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Dimens.standardSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: Dimens.halfSpacing),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
