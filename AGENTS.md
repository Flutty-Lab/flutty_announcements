# AGENTS.md — flutty_announcements

Flutter package (`pub.dev: flutty_announcements`) for in-app "what's new"
announcements: a bottom sheet highlighting a feature once per device, gated
by the running app's minor version. Lives in the `flutty_core` workspace.
Extracted and generalized from Pocket Money.

## Big picture

- `lib/src/feature_announcements.dart` — `FeatureAnnouncements`: eligibility
  (`pendingAnnouncement` = same `major.minor` as the running app AND not yet
  seen on this device), `announcementShown` marks seen *before* the sheet
  opens, `announcementClosed` reports the outcome.
- `lib/src/models.dart` — the `const` config model: `FeatureAnnouncement`
  (id, `releasedIn`, fr/en `LocalizedText`, bullets, icon, preview, cta) and
  `FeatureAnnouncementCta` (label + opaque `payload` handed to `onCta`).
- `lib/src/announcement_store.dart` — `FeatureAnnouncementStore` abstraction;
  `SharedPreferencesAnnouncementStore` is the only impl (seen ids stay local
  to the device, never server-side — by design).
- `lib/src/analytics.dart` — `FeatureAnnouncementsAnalytics` sink implemented
  by each app; `NoopFeatureAnnouncementsAnalytics` is the default.
- `lib/src/feature_announcement_sheet.dart` — pure-presentation bottom sheet;
  `FeatureAnnouncementSheet.show(context, ...)` returns the close outcome.
- `lib/src/feature_announcement_trigger.dart` — `FeatureAnnouncementTrigger`
  sits on the app's root widget; one attempt per session, post-frame.

## Conventions agents should follow

- **No audience concept**: one announcement = one presentation for everyone
  on the device (Pocket Money's parent/beneficiary split was dropped).
- The package stays backend-agnostic: no Firebase, no GetIt, no auto_route
  dependency — apps wire DI, analytics and routing themselves.
- Widgets import `package:flutter/material.dart`, **not** `material_ui`:
  it resolves the consumer app's `Theme` on both Flutter eras (framework
  Material on 3.47 — where `material_ui`'s own `Theme` would see nothing —
  and the re-exported `material_ui` on 3.50+). Spacing constants mirror
  `flutty_ds`' `Dimens` values, internalized to avoid a version coupling.
- `cta.payload` is opaque (`Object?`) — apps typically store a route object
  and handle it in the trigger's `onCta`; the package never navigates.
- The seen-ids store is device-local by contract — do not add a remote sync.
- Announcement eligibility is minor-version scoped (`releasedIn`) — do not
  add date-based or flag-based gating without a product decision.
- Code, dartdoc and docs are in English (workspace convention); announcement
  *content* (`LocalizedText`) is fr+en, English being the fallback locale.
- A future evolution may add multi-page (carousel) content — keep the sheet
  able to host a `PageView` without breaking the config model.
- Tests use mocktail + `SharedPreferences.setMockInitialValues` — no
  Firebase, no platform channels needed.

## Tests

```bash
flutter test   # from packages/flutty_announcements
```
