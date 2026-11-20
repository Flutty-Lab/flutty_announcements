import 'package:material_ui/material_ui.dart';
import 'package:flutty_announcements/flutty_announcements.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appVersion = (await PackageInfo.fromPlatform()).version;
  runApp(ExampleApp(appVersion: appVersion));
}

/// The app's versioned config — `releasedIn` must match the running
/// `major.minor` (this example is versioned 1.0.x) for the announcement to
/// be eligible. One entry shows once per device, then never again.
const announcements = <FeatureAnnouncement>[
  FeatureAnnouncement(
    id: 'demo_feature',
    releasedIn: '1.0',
    icon: Icons.auto_awesome,
    title: LocalizedText(
      en: 'A brand new feature',
      fr: 'Une toute nouvelle feature',
    ),
    body: LocalizedText(
      en: 'This is what a launch announcement looks like.',
      fr: 'Voilà à quoi ressemble une annonce de lancement.',
    ),
    bullets: [
      LocalizedText(
        en: 'Shown once per device',
        fr: 'Affichée une seule fois par appareil',
      ),
      LocalizedText(
        en: 'Tied to the minor version',
        fr: 'Liée à la version mineure',
      ),
    ],
    cta: FeatureAnnouncementCta(
      label: LocalizedText(en: 'Open the demo page', fr: 'Ouvrir la démo'),
      payload: '/demo',
    ),
  ),
];

class ExampleApp extends StatelessWidget {
  const ExampleApp({required this.appVersion, super.key});

  final String appVersion;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FeatureAnnouncementTrigger(
        announcements: announcements,
        // In a real app, also wire your SharedPreferences key and your
        // FeatureAnnouncementsAnalytics implementation here.
        service: FeatureAnnouncements(appVersion: appVersion),
        onCta: (context, cta) {
          // `cta.payload` is whatever you stored — a route object, an id…
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (_) => const DemoPage()));
        },
        child: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutty_announcements')),
      body: const Center(child: Text('Home')),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo')),
      body: const Center(child: Text('Reached via the CTA')),
    );
  }
}
