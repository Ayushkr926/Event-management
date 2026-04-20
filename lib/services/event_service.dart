import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../model/event_model.dart';

class EventService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  static const String _collection = 'events';

  CollectionReference<Map<String, dynamic>> get _eventsRef =>
      _firestore.collection(_collection);

  /// Creates a new event in Firestore.
  /// Generates a new document ID and saves the model.
  Future<void> createEvent(EventModel event) async {
    try {
      final docRef = _eventsRef.doc(event.eventId);
      await docRef.set(event.toMap());
      notifyListeners();
    } catch (e) {
      debugPrint('[EventService] Error creating event: $e');
      rethrow;
    }
  }

  /// Uploads an image file to Firebase Storage under the 'event_banners' path.
  /// Returns the download URL.
  Future<String> uploadEventBanner(File imageFile, String eventId) async {
    try {
      final ext = imageFile.path.split('.').last;
      final ref = _storage.ref().child('event_banners').child('\${eventId}_\${DateTime.now().millisecondsSinceEpoch}.$ext');
      
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('[EventService] Error uploading banner: $e');
      rethrow;
    }
  }

  /// Optional: Get stream of all upcoming events
  Stream<List<EventModel>> getUpcomingEvents() {
    return _eventsRef
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromDocument(doc))
            .toList());
  }

  /// Optional: Get events by specific organizer
  Stream<List<EventModel>> getEventsByOrganizer(String organizerId) {
    return _eventsRef
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromDocument(doc))
            .toList());
  }
}
