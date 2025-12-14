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

    // Ярко-оранжевый акцент (Material рекомендует использовать контрастные, но не агрессивные оттенки)
    const Color orangeAccent = Color(0xFFFF6D00); // или #FF5722

    return MaterialApp(
      title: 'Телефонная книга',
      themeMode: themeMode,

      // СВЕТЛАЯ ТЕМА
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        colorScheme: ColorScheme.fromSeed(
          seedColor: orangeAccent,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100, // светло-серый фон полей
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: orangeAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: orangeAccent, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: orangeAccent,
            foregroundColor: Colors.white,
          ),
        ),
      ),

      // ТЁМНАЯ ТЕМА
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // абсолютно чёрный фон
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        colorScheme: ColorScheme.fromSeed(
          seedColor: orangeAccent,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1e1e1e), // тёмно-серый фон полей
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: orangeAccent, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: orangeAccent,
            foregroundColor: Colors.white,
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.white,
          textColor: Colors.white,
        ),
        cardColor: const Color(0xFF1e1e1e), // фон карточек контактов
      ),

      home: HomeScreen(
        contactService: ContactService(),
        onThemeChanged: _updateTheme,
      ),
    );
  }
}
