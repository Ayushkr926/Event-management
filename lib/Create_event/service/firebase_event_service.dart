// lib/services/firebase_event_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../model/event_model.dart';

class FirebaseEventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  /// Converts a file to Base64 string
  Future<String> fileToBase64(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  /// Saves event to Firestore and returns the document ID
  Future<String> saveEvent(EventModel event) async {
    try {
      final docRef = await _firestore.collection('events').add(event.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save event: $e');
    }
  }

  /// Updates an existing event
  Future<void> updateEvent(String eventId, EventModel event) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .update(event.toMap());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  /// Full create flow: convert all images to Base64 then save to Firestore
  Future<String> createEventWithMedia({
    required EventModel event,
    File? bannerImageFile,
    File? organizerPhotoFile,
    Map<String, File>? speakerPhotos, // speakerId -> File
    List<File>? galleryFiles,
  }) async {
    try {
      // 1. Encode banner image
      if (bannerImageFile != null) {
        event.bannerImage = await fileToBase64(bannerImageFile);
      }

      // 2. Encode organizer photo
      if (organizerPhotoFile != null) {
        event.organizer.photo = await fileToBase64(organizerPhotoFile);
      }

      // 3. Encode speaker photos
      if (speakerPhotos != null) {
        for (final entry in speakerPhotos.entries) {
          final speakerId = entry.key;
          final photoFile = entry.value;
          final idx = event.speakers.indexWhere((s) => s.id == speakerId);
          if (idx != -1) {
            event.speakers[idx].photo = await fileToBase64(photoFile);
          }
        }
      }

      // 4. Encode gallery images
      if (galleryFiles != null && galleryFiles.isNotEmpty) {
        event.gallery = await Future.wait(
          galleryFiles.map((file) => fileToBase64(file)),
        );
      }

      // 5. Save to Firestore
      final String docId = await saveEvent(event);
      return docId;
    } catch (e) {
      throw Exception('Event creation failed: $e');
    }
  }
}