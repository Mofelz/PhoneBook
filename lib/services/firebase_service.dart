// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contact.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Получаем или создаём анонимного пользователя
  Future<void> _ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  // Коллекция контактов текущего пользователя
  Future<CollectionReference<Contact>> _getContactsCollection() async {
    await _ensureSignedIn();
    final userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .withConverter<Contact>(
          fromFirestore: (snapshot, _) => Contact.fromMap(snapshot.data()!),
          toFirestore: (contact, _) => contact.toMap(),
        );
  }

  // Добавить контакт
  Future<void> addContact(Contact contact) async {
    final collection = await _getContactsCollection();
    await collection.doc(contact.id).set(contact);
  }

  // Обновить контакт
  Future<void> updateContact(Contact contact) async {
    final collection = await _getContactsCollection();
    await collection.doc(contact.id).set(contact);
  }

  // Удалить контакт
  Future<void> deleteContact(String id) async {
    final collection = await _getContactsCollection();
    await collection.doc(id).delete();
  }

  // // Получить поток контактов (реактивно!)
  // Stream<List<Contact>> getContactsStream() {
  //   return _getContactsCollection()
  //       .then((collection) {
  //         return collection.snapshots().map((snapshot) {
  //           return snapshot.docs.map((doc) => doc.data()).toList();
  //         });
  //       })
  //       .asStream()
  //       .asyncExpand((stream) => stream);
  // }
  Stream<List<Contact>> getContactsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('contacts')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Contact.fromMap(doc.data())).toList(),
        );
  }
}
