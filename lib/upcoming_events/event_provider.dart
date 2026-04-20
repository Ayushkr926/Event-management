import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Create_event/model/event_model.dart';

class EventProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<EventModel> _allEvents = [];
  bool _isLoading = false;
  String? _error;

  // ── Getters ────────────────────────────────────────────────────────
  List<EventModel> get allEvents => List.unmodifiable(_allEvents);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Constructor: fetch on init ─────────────────────────────────────
  EventProvider() {
    fetchEvents();
  }

  // ── Fetch all published events from Firestore ──────────────────────
  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'published')
          .orderBy('startDate')
          .get();

      _allEvents = snapshot.docs
          .map((doc) => _fromMap(doc.id, doc.data()))
          .toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to load events: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Filter by date (matches startDate "yyyy-MM-dd") ────────────────
  List<EventModel> filteredEventsByDate(DateTime selectedDate) {
    final dateStr = _toDateString(selectedDate);
    return _allEvents.where((e) => e.startDate == dateStr).toList();
  }

  // ── Check if a date has any events ────────────────────────────────
  bool hasEventsOnDate(DateTime date) {
    final dateStr = _toDateString(date);
    return _allEvents.any((e) => e.startDate == dateStr);
  }

  // ── All dates that have events (for calendar dot indicators) ───────
  Set<String> get datesWithEvents =>
      _allEvents.map((e) => e.startDate).toSet();

  // ── Helpers ────────────────────────────────────────────────────────
  String _toDateString(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // ── Map Firestore document → EventModel ───────────────────────────
  EventModel _fromMap(String docId, Map<String, dynamic> data) {
    // Location
    final locMap = data['location'] as Map<String, dynamic>? ?? {};
    final location = EventLocation(
      venueName: locMap['venueName'] ?? '',
      address: locMap['address'] ?? '',
      city: locMap['city'] ?? '',
      state: locMap['state'] ?? '',
      country: locMap['country'] ?? '',
      postalCode: locMap['postalCode'] ?? '',
      googleMapsLink: locMap['googleMapsLink'] ?? '',
      landmark: locMap['landmark'] ?? '',
      parkingAvailable: locMap['parkingAvailable'] ?? false,
    );

    // Online details
    final onlineMap = data['onlineDetails'] as Map<String, dynamic>? ?? {};
    final onlineDetails = OnlineDetails(
      platform: onlineMap['platform'] ?? '',
      meetingLink: onlineMap['meetingLink'] ?? '',
      meetingId: onlineMap['meetingId'] ?? '',
      passcode: onlineMap['passcode'] ?? '',
    );

    // Organizer
    final orgMap = data['organizer'] as Map<String, dynamic>? ?? {};
    final organizer = OrganizerInfo(
      name: orgMap['name'] ?? '',
      photo: orgMap['photo'] ?? '',
      organization: orgMap['organization'] ?? '',
      bio: orgMap['bio'] ?? '',
      email: orgMap['email'] ?? '',
      phone: orgMap['phone'] ?? '',
      website: orgMap['website'] ?? '',
    );

    // Attendee settings
    final attMap = data['attendeeSettings'] as Map<String, dynamic>? ?? {};
    final attendeeSettings = AttendeeSettings(
      maxAttendees: attMap['maxAttendees'] ?? 100,
      minAttendees: attMap['minAttendees'] ?? 0,
      approvalRequired: attMap['approvalRequired'] ?? false,
      privacy: attMap['privacy'] ?? 'public',
    );

    // Tickets
    final ticketsList = data['tickets'] as List<dynamic>? ?? [];
    final tickets = ticketsList.map((t) {
      final m = t as Map<String, dynamic>;
      return TicketType(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        price: (m['price'] as num?)?.toDouble() ?? 0.0,
        quantity: m['quantity'] ?? 0,
        salesStartDate: m['salesStartDate'] ?? '',
        salesEndDate: m['salesEndDate'] ?? '',
        isFree: m['isFree'] ?? true,
      );
    }).toList();

    // Agenda
    final agendaList = data['agenda'] as List<dynamic>? ?? [];
    final agenda = agendaList.map((a) {
      final m = a as Map<String, dynamic>;
      return AgendaItem(
        id: m['id'] ?? '',
        title: m['title'] ?? '',
        speakerName: m['speakerName'] ?? '',
        startTime: m['startTime'] ?? '',
        endTime: m['endTime'] ?? '',
        description: m['description'] ?? '',
      );
    }).toList();

    // Speakers
    final speakersList = data['speakers'] as List<dynamic>? ?? [];
    final speakers = speakersList.map((s) {
      final m = s as Map<String, dynamic>;
      return Speaker(
        id: m['id'] ?? '',
        photo: m['photo'] ?? '',
        name: m['name'] ?? '',
        title: m['title'] ?? '',
        company: m['company'] ?? '',
        bio: m['bio'] ?? '',
        linkedin: m['linkedin'] ?? '',
        twitter: m['twitter'] ?? '',
        website: m['website'] ?? '',
      );
    }).toList();

    // Notifications
    final notifMap = data['notifications'] as Map<String, dynamic>? ?? {};
    final notifications = EventNotifications(
      reminder24h: notifMap['reminder24h'] ?? true,
      reminder1h: notifMap['reminder1h'] ?? true,
      email: notifMap['email'] ?? true,
      push: notifMap['push'] ?? true,
    );

    return EventModel(
      id: docId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      bannerImage: data['bannerImage'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      language: data['language'] ?? 'English',
      startDate: data['startDate'] ?? '',
      endDate: data['endDate'] ?? '',
      timezone: data['timezone'] ?? 'UTC',
      eventType: data['eventType'] ?? 'in-person',
      isRecurring: data['isRecurring'] ?? false,
      location: location,
      onlineDetails: onlineDetails,
      organizer: organizer,
      attendeeSettings: attendeeSettings,
      tickets: tickets,
      isPaidEvent: data['isPaidEvent'] ?? false,
      agenda: agenda,
      speakers: speakers,
      gallery: List<String>.from(data['gallery'] ?? []),
      promoVideo: data['promoVideo'] ?? '',
      hashtags: List<String>.from(data['hashtags'] ?? []),
      rules: data['rules'] ?? '',
      ageRestriction: data['ageRestriction'] ?? '',
      dressCode: data['dressCode'] ?? '',
      whatToBring: data['whatToBring'] ?? '',
      codeOfConduct: data['codeOfConduct'] ?? '',
      notifications: notifications,
      visibility: data['visibility'] ?? 'public',
      status: data['status'] ?? 'draft',
      featured: data['featured'] ?? false,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}