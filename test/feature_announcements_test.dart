import 'package:flutty_announcements/flutty_announcements.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStore extends Mock implements FeatureAnnouncementStore {}

class MockAnalytics extends Mock implements FeatureAnnouncementsAnalytics {}

void main() {
  const announcement = FeatureAnnouncement(
    id: 'notifications',
    releasedIn: '1.3',
    title: LocalizedText(en: 'Title', fr: 'Titre'),
    body: LocalizedText(en: 'Body', fr: 'Corps'),
  );

  late MockStore store;
  late MockAnalytics analytics;

  FeatureAnnouncements service({String? appVersion}) => FeatureAnnouncements(
    store: store,
    analytics: analytics,
    appVersion: appVersion,
  );

  setUpAll(() {
    registerFallbackValue(FeatureAnnouncementClose.dismiss);
  });

  setUp(() {
    store = MockStore();
    analytics = MockAnalytics();
    when(() => store.seenIds()).thenAnswer((_) async => <String>{});
    when(() => store.markSeen(any())).thenAnswer((_) async {});
    when(() => analytics.announcementShown(any())).thenReturn(null);
    when(() => analytics.announcementClosed(any(), any())).thenReturn(null);
  });

  group('pendingAnnouncement', () {
    test('returns the announcement matching the running minor', () async {
      final result = await service(appVersion: '1.3.2+15')
          .pendingAnnouncement([announcement]);
      expect(result, announcement);
    });

    test('a patch version does not expire the announcement', () async {
      for (final version in ['1.3.0', '1.3.9+2', '1.3.10-beta']) {
        final result = await service(appVersion: version)
            .pendingAnnouncement([announcement]);
        expect(result, announcement, reason: version);
      }
    });

    test('another minor hides the announcement', () async {
      for (final version in ['1.2.9', '1.4.0', '2.0.0']) {
        final result = await service(appVersion: version)
            .pendingAnnouncement([announcement]);
        expect(result, isNull, reason: version);
      }
    });

    test('a seen announcement is skipped', () async {
      when(() => store.seenIds()).thenAnswer((_) async => {'notifications'});
      final result = await service(appVersion: '1.3.0')
          .pendingAnnouncement([announcement]);
      expect(result, isNull);
    });

    test('returns the first eligible announcement in config order', () async {
      const skipped = FeatureAnnouncement(
        id: 'old',
        releasedIn: '1.2',
        title: LocalizedText(en: 'x', fr: 'x'),
        body: LocalizedText(en: 'x', fr: 'x'),
      );
      const second = FeatureAnnouncement(
        id: 'second',
        releasedIn: '1.3',
        title: LocalizedText(en: 'x', fr: 'x'),
        body: LocalizedText(en: 'x', fr: 'x'),
      );
      final result = await service(appVersion: '1.3.0')
          .pendingAnnouncement([skipped, announcement, second]);
      expect(result, announcement);
    });

    test('empty config returns null', () async {
      final result = await service(appVersion: '1.3.0').pendingAnnouncement([]);
      expect(result, isNull);
    });
  });

  group('announcementShown', () {
    test('marks seen then reports analytics', () async {
      await service(appVersion: '1.3.0').announcementShown(announcement);
      verifyInOrder([
        () => store.markSeen('notifications'),
        () => analytics.announcementShown('notifications'),
      ]);
    });
  });

  group('announcementClosed', () {
    test('reports the outcome to analytics', () async {
      await service(
        appVersion: '1.3.0',
      ).announcementClosed(announcement, outcome: FeatureAnnouncementClose.cta);
      verify(
        () => analytics.announcementClosed(
          'notifications',
          FeatureAnnouncementClose.cta,
        ),
      );
    });
  });
}
