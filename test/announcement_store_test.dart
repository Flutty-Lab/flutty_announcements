import 'package:flutty_announcements/flutty_announcements.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const store = SharedPreferencesAnnouncementStore(key: 'test_seen');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('seenIds is empty on first launch', () async {
    expect(await store.seenIds(), isEmpty);
  });

  test('markSeen persists the id', () async {
    await store.markSeen('a');
    await store.markSeen('b');
    expect(await store.seenIds(), {'a', 'b'});
  });

  test('markSeen is idempotent', () async {
    await store.markSeen('a');
    await store.markSeen('a');
    expect(await store.seenIds(), {'a'});
  });

  test('stores with different keys do not share state', () async {
    const other = SharedPreferencesAnnouncementStore(key: 'other_seen');
    await store.markSeen('a');
    expect(await other.seenIds(), isEmpty);
  });
}
