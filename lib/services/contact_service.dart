// lib/services/contact_service.dart
import 'dart:async';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart'; // для getApplicationDocumentsDirectory

// Для Web
import 'package:sembast_web/sembast_web.dart';

import '../models/contact.dart';

class ContactService {
  static final ContactService _instance = ContactService._();
  factory ContactService() => _instance;
  ContactService._();

  Completer<Database>? _dbCompleter;

  Future<Database> get _db async {
    _dbCompleter ??= Completer();
    if (!_dbCompleter!.isCompleted) {
      _openDatabase();
    }
    return _dbCompleter!.future;
  }

  Future<void> _openDatabase() async {
    try {
      Database db;
      if (isWeb) {
        db = await databaseFactoryWeb.openDatabase('contacts.db');
      } else {
        final appDocDir = await getApplicationDocumentsDirectory();
        final dbPath = p.join(appDocDir.path, 'contacts.db');
        db = await databaseFactoryIo.openDatabase(dbPath);
      }
      _dbCompleter!.complete(db);
    } catch (e) {
      _dbCompleter!.completeError(e);
    }
  }

  StoreRef<String, Map<String, dynamic>> get _contactStore =>
      stringMapStoreFactory.store('contacts');

  StoreRef<String, Map<String, dynamic>> get _store =>
      stringMapStoreFactory.store('contacts');

  Future<void> addContact(Contact contact) async {
    final db = await _db;
    await _contactStore.record(contact.id).put(db, contact.toMap());
  }

  Future<void> updateContact(Contact contact) async {
    final db = await _db;
    await _contactStore.record(contact.id).put(db, contact.toMap());
  }

  Future<void> deleteContact(String id) async {
    final db = await _db;
    await _contactStore.record(id).delete(db);
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await _db;
    // ❗ Исправление: sortBy заменён на finder с SortOrder
    final finder = Finder(sortOrders: [SortOrder('name')]);
    final records = await _store.find(db, finder: finder);
    return records.map((r) => Contact.fromMap(r.value)).toList();
  }
}

// Определяем, Web или нет
bool get isWeb {
  // В Dart на Web: 0 == 0.0 → true
  // ignore: undefined_identifier
  return identical(0, 0.0);
}
