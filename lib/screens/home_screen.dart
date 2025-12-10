// lib/screens/home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/contact.dart';
import '../services/contact_service.dart';
import '../services/theme_service.dart';
import '../utils/phone_formatter.dart';
import 'add_contact_screen.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  final ContactService contactService;
  final void Function(String) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.contactService,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Contact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() {
    setState(() {
      _contactsFuture = widget.contactService.getAllContacts();
    });
  }

  Future<void> _launchCall(String phone) async {
    if (kIsWeb) return;

    // Извлекаем только цифры
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    String dialNumber;
    if (digitsOnly.length == 11) {
      if (digitsOnly[0] == '8') {
        dialNumber = '+7${digitsOnly.substring(1)}';
      } else if (digitsOnly[0] == '7') {
        dialNumber = '+7${digitsOnly.substring(1)}';
      } else {
        dialNumber = digitsOnly; // fallback
      }
    } else if (digitsOnly.length == 10) {
      // Возможно, номер без кода страны (редко, но бывает)
      dialNumber = '+7$digitsOnly';
    } else {
      dialNumber = digitsOnly; // fallback
    }

    await launchUrl(Uri(scheme: 'tel', path: dialNumber));
  }

  Future<void> _copyPhone(String phone) async {
    if (!kIsWeb) return;
    await Clipboard.setData(ClipboardData(text: phone));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Номер скопирован')));
  }

  void _editContact(Contact contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContactScreen(
          id: contact.id,
          name: contact.name,
          phone: contact.phone,
          avatarBase64: contact.avatarBase64,
        ),
      ),
    );

    if (result == null) return;

    if (result['delete'] == true) {
      await widget.contactService.deleteContact(contact.id);
    } else {
      final updated = Contact(
        id: result['id'] ?? contact.id,
        name: result['name'] as String,
        phone: result['phone'] as String,
        avatarBase64: result['avatarBase64'] as String?,
      );
      if (result['id'] != null) {
        await widget.contactService.updateContact(updated);
      } else {
        final newContact = Contact(
          id: const Uuid().v4(),
          name: result['name'] as String,
          phone: result['phone'] as String,
          avatarBase64: result['avatarBase64'] as String?,
        );
        await widget.contactService.addContact(newContact);
      }
    }
    _loadContacts();
  }

  void _addNewContact() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddContactScreen()),
    );

    if (result != null && result['delete'] != true) {
      final contact = Contact(
        id: const Uuid().v4(),
        name: result['name'] as String,
        phone: result['phone'] as String,
        avatarBase64: result['avatarBase64'] as String?,
      );
      await widget.contactService.addContact(contact);
      _loadContacts();
    }
  }

  void _showThemeDialog() async {
    final currentMode = await ThemeService().loadThemeMode();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Тема'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Системная'),
              value: 'system',
              groupValue: currentMode,
              onChanged: (value) {
                widget.onThemeChanged(value!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('Светлая'),
              value: 'light',
              groupValue: currentMode,
              onChanged: (value) {
                widget.onThemeChanged(value!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('Тёмная'),
              value: 'dark',
              groupValue: currentMode,
              onChanged: (value) {
                widget.onThemeChanged(value!);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Телефонная книга'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_medium),
            onPressed: _showThemeDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final contacts = snapshot.data ?? [];
          if (contacts.isEmpty) {
            return const Center(child: Text('Нет контактов'));
          }
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    backgroundImage: contact.avatarBase64 != null
                        ? MemoryImage(base64Decode(contact.avatarBase64!))
                        : null,
                    child: contact.avatarBase64 != null
                        ? null
                        : Text(
                            contact.name.isNotEmpty == true
                                ? contact.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                  ),
                  title: Text(contact.name ?? ''),
                  subtitle: Text(formatPhoneNumber(contact.phone ?? '')),
                  trailing: kIsWeb
                      ? IconButton(
                          icon: const Icon(Icons.copy, color: Colors.blue),
                          onPressed: () => _copyPhone(contact.phone ?? ''),
                        )
                      : IconButton(
                          icon: const Icon(Icons.call, color: Colors.green),
                          onPressed: () => _launchCall(contact.phone ?? ''),
                        ),
                  onTap: () => _editContact(contact),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Удалить?'),
                        content: Text('Удалить ${contact.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Нет'),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.contactService.deleteContact(contact.id);
                              _loadContacts();
                              Navigator.pop(ctx);
                            },
                            child: const Text(
                              'Да',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewContact,
        child: const Icon(Icons.add),
      ),
    );
  }
}
