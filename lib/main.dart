import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/vibes_theme.dart';
import 'providers/haptic_lab_provider.dart';
import 'views/lab_screen.dart';
import 'views/vault_screen.dart';
import 'views/telemetry_screen.dart';
import 'views/settings_screen.dart';
import 'widgets/pixel_bottom_nav.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce system UI overlay style matching retro-cyber dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: VibesTheme.deepVoid,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HapticLabProvider()),
      ],
      child: const VibesApp(),
    ),
  );
}

class VibesApp extends StatelessWidget {
  const VibesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIBES',
      debugShowCheckedModeBanner: false,
      theme: VibesTheme.darkTheme,
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LabScreen(),
    VaultScreen(),
    TelemetryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibesTheme.deepVoid,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: PixelBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
