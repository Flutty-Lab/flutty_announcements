## 0.1.1

- Relax the Flutter constraint to `>=3.47.0` — the package uses no 3.50-only API, so apps still on Flutter 3.47 can consume it (matching the published floor of the other `flutty_*` packages).
- Drop the `material_ui` and `flutty_ds` dependencies: the widgets import `package:flutter/material.dart`, which resolves the app's `Theme` on both worlds (framework Material on Flutter 3.47, re-exported `material_ui` on 3.50+) — `material_ui`'s own `Theme` would not see a framework `MaterialApp`'s theme. Spacing constants are internalized.

## 0.1.0

- Package creation: `FeatureAnnouncements` (eligibility by running minor version, once-per-device tracking, analytics hooks), `FeatureAnnouncement` / `LocalizedText` / `FeatureAnnouncementCta` config model, `FeatureAnnouncementSheet` + `FeatureAnnouncementTrigger` UI, `FeatureAnnouncementStore` persisted in SharedPreferences, `FeatureAnnouncementsAnalytics` interface. Extracted and generalized from Pocket Money.
