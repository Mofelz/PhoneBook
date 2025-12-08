// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/contact_service.dart';
import 'services/theme_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeService _themeService;
  late String _selectedThemeMode;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
    _loadTheme();
  }

  void _loadTheme() async {
    final mode = await _themeService.loadThemeMode();
    if (mounted) {
      setState(() {
        _selectedThemeMode = mode;
      });
    }
  }

  void _updateTheme(String mode) async {
    await _themeService.saveThemeMode(mode);
    if (mounted) {
      setState(() {
        _selectedThemeMode = mode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final systemBrightness = WidgetsBinding.instance.window.platformBrightness;
    final systemIsDark = systemBrightness == Brightness.dark;

    late ThemeMode themeMode;
    if (_selectedThemeMode == 'system') {
      themeMode = systemIsDark ? ThemeMode.dark : ThemeMode.light;
    } else if (_selectedThemeMode == 'light') {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }

    return MaterialApp(
      title: 'Телефонная книга',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(
        contactService: ContactService(),
        onThemeChanged: _updateTheme,
      ),
    );
  }
}
