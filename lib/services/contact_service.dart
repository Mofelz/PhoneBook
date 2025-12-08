// lib/services/contact_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/contact.dart';
import 'dart:convert';

class ContactService {
  static const String _storageKey = 'contacts';
  final SharedPreferences _prefs;

  ContactService(this._prefs);

  static Future<ContactService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ContactService(prefs);
  }

  List<Contact> getContacts() {
    final contactsJson = _prefs.getStringList(_storageKey) ?? [];
    return contactsJson.map((c) => Contact.fromMap(jsonDecode(c))).toList();
  }

  void saveContacts(List<Contact> contacts) {
    final contactsJson = contacts.map((c) => jsonEncode(c.toMap())).toList();
    _prefs.setStringList(_storageKey, contactsJson);
  }

  void addContact(String name, String phone) {
    final contacts = getContacts();
    final id = const Uuid().v4();
    contacts.add(Contact(id: id, name: name, phone: phone));
    saveContacts(contacts);
  }

  void deleteContact(String id) {
    final contacts = getContacts();
    contacts.removeWhere((c) => c.id == id);
    saveContacts(contacts);
  }

  // ✅ Добавляем метод обновления
  void updateContact(Contact updatedContact) {
    final contacts = getContacts();
    final index = contacts.indexWhere((c) => c.id == updatedContact.id);
    if (index != -1) {
      contacts[index] = updatedContact;
      saveContacts(contacts);
    }
  }

  void addContactFromObject(Contact contact) {
    final contacts = getContacts();
    contacts.add(contact);
    saveContacts(contacts);
  }
}
