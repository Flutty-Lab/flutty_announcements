# flutty_announcements

In-app "what's new" announcements for Flutter: a bottom sheet that highlights
a new feature **once per device**, shown at launch, and only while the app
runs on the **same minor version** that introduced the feature.

- Versioned `const` config — declaring an announcement is part of the release diff
- Eligibility gated by `releasedIn` = `major.minor` (a patch keeps it, the next minor expires it)
- Seen ids persisted locally (SharedPreferences, key namespaced by the app)
- Analytics-agnostic (`FeatureAnnouncementsAnalytics`), router-agnostic (CTA payload + `onCta`)
- Ready-made UI: `FeatureAnnouncementTrigger` + `FeatureAnnouncementSheet`

## Quick start

```yaml
dependencies:
  flutty_announcements: ^0.1.0
```

### 1. Declare your announcements

Keep a `const` config file — edit it at each release:

```dart
const featureAnnouncements = <FeatureAnnouncement>[
  FeatureAnnouncement(
    id: 'notifications',                    // stable id, never reused
    releasedIn: '1.3',                      // minor of the shipping release
    icon: Icons.notifications_outlined,
    title: LocalizedText(
      en: 'Notifications are here',
      fr: 'Les notifications arrivent',
    ),
    body: LocalizedText(
      en: 'Get a heads-up when something needs you.',
      fr: 'Sois prévenu quand quelque chose t\'attend.',
    ),
    bullets: [
      LocalizedText(en: 'Off by default', fr: 'Désactivées par défaut'),
      LocalizedText(
        en: 'Filtered by type',
        fr: 'Filtrables par type',
      ),
    ],
    cta: FeatureAnnouncementCta(
      label: LocalizedText(en: 'Enable them', fr: 'Activer'),
      payload: SettingsRoute(),             // e.g. an auto_route route
    ),
  ),
];
```

### 2. Mount the trigger on the authenticated root

```dart
FeatureAnnouncementTrigger(
  announcements: featureAnnouncements,
  service: FeatureAnnouncements(
    store: SharedPreferencesAnnouncementStore(key: 'my_app_announcements_seen'),
    analytics: MyAnnouncementsAnalytics(),   // optional
  ),
  onCta: (context, cta) {
    final route = cta.payload;
    if (route != null) context.router.push(route as PageRouteInfo);
  },
  child: MyHomePage(),
)
```

A single attempt is made per session, after the first frame. The announcement
is marked **seen before the sheet opens** — an app killed on the sheet won't
show it again.

### 3. Wire analytics (optional)

```dart
class MyAnnouncementsAnalytics implements FeatureAnnouncementsAnalytics {
  @override
  void announcementShown(String id) =>
      analytics.log('feature_announcement_shown', {'announcement_id': id});

  @override
  void announcementClosed(String id, FeatureAnnouncementClose outcome) =>
      analytics.log('feature_announcement_closed', {
        'announcement_id': id,
        'outcome': outcome.name,
      });
}
```

## Version semantics

| `releasedIn` | Running version | Shown? |
|---|---|---|
| `1.3` | `1.3.0`, `1.3.9+42` | yes, once |
| `1.3` | `1.4.0` | no — expired |
| `1.3` | `1.2.9` | no — not yet |

An entry older than the running minor can simply be removed from the config
at the next release.

## Example

See `example/` for a runnable app showing a launch announcement with a CTA.

---

Extracted and generalized from Pocket Money.
