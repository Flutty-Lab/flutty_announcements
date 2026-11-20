import 'package:flutty_announcements/flutty_announcements.dart';
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAnalytics extends Mock implements FeatureAnnouncementsAnalytics {}

void main() {
  const announcement = FeatureAnnouncement(
    id: 'notifications',
    releasedIn: '1.3',
    title: LocalizedText(en: 'Notifications are here', fr: 'Notifs'),
    body: LocalizedText(en: 'Body', fr: 'Corps'),
    cta: FeatureAnnouncementCta(
      label: LocalizedText(en: 'Enable', fr: 'Activer'),
      payload: 'settings-route',
    ),
  );

  late MockAnalytics analytics;

  FeatureAnnouncements service() =>
      FeatureAnnouncements(analytics: analytics, appVersion: '1.3.0');

  Widget app({
    List<FeatureAnnouncement> announcements = const [announcement],
    void Function(BuildContext, FeatureAnnouncementCta)? onCta,
  }) => MaterialApp(
    home: FeatureAnnouncementTrigger(
      announcements: announcements,
      service: service(),
      onCta: onCta,
      child: const Scaffold(body: Text('home')),
    ),
  );

  setUpAll(() {
    registerFallbackValue(FeatureAnnouncementClose.dismiss);
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    analytics = MockAnalytics();
    when(() => analytics.announcementShown(any())).thenReturn(null);
    when(() => analytics.announcementClosed(any(), any())).thenReturn(null);
  });

  testWidgets('presents the pending announcement over the child', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Notifications are here'), findsOneWidget);
    expect(find.text('New in this version'), findsOneWidget);
    verify(() => analytics.announcementShown('notifications'));
  });

  testWidgets('marks the announcement seen before the sheet closes', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('flutty_announcements_seen'), ['notifications']);
  });

  testWidgets('shows nothing when nothing is pending', (tester) async {
    SharedPreferences.setMockInitialValues({
      'flutty_announcements_seen': ['notifications'],
    });
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Notifications are here'), findsNothing);
  });

  testWidgets('close button reports a dismiss outcome', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    verify(
      () => analytics.announcementClosed(
        'notifications',
        FeatureAnnouncementClose.dismiss,
      ),
    );
  });

  testWidgets('cta reports the outcome and calls onCta with the payload', (
    tester,
  ) async {
    FeatureAnnouncementCta? tapped;
    await tester.pumpWidget(app(onCta: (_, cta) => tapped = cta));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enable'));
    await tester.pumpAndSettle();

    verify(
      () => analytics.announcementClosed(
        'notifications',
        FeatureAnnouncementClose.cta,
      ),
    );
    expect(tapped?.payload, 'settings-route');
  });
}
