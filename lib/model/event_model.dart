import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final List<String> tags;

  // Date and Time
  final DateTime startDate;
  final DateTime endDate;
  final String startTime;
  final String endTime;

  // Location
  final String eventType; // "Offline", "Online", "Hybrid"
  final String venueName;
  final String address;
  final String city;
  final String state;
  final String country;
  // Use GeoPoint for map location in Firestore
  final GeoPoint? locationPoint;
  final String meetingLink;

  // Tickets
  final String ticketType; // "Free", "Paid"
  final double ticketPrice;
  final int totalTickets;
  final int ticketsSold;
  final int maxTicketsPerUser;
  final DateTime? ticketSaleStartDate;
  final DateTime? ticketSaleEndDate;

  // Organizer
  final String organizerId;
  final String organizerName;
  final String organizerEmail;
  final String organizerPhone;

  // Policies
  final String refundPolicy;
  final String ageRestrictions;
  final String entryRules;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.tags = const [],
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.eventType,
    this.venueName = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.locationPoint,
    this.meetingLink = '',
    required this.ticketType,
    required this.ticketPrice,
    required this.totalTickets,
    this.ticketsSold = 0,
    required this.maxTicketsPerUser,
    this.ticketSaleStartDate,
    this.ticketSaleEndDate,
    required this.organizerId,
    required this.organizerName,
    required this.organizerEmail,
    required this.organizerPhone,
    this.refundPolicy = '',
    this.ageRestrictions = '',
    this.entryRules = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'tags': tags,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'startTime': startTime,
      'endTime': endTime,
      'eventType': eventType,
      'venueName': venueName,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'locationPoint': locationPoint,
      'meetingLink': meetingLink,
      'ticketType': ticketType,
      'ticketPrice': ticketPrice,
      'totalTickets': totalTickets,
      'ticketsSold': ticketsSold,
      'maxTicketsPerUser': maxTicketsPerUser,
      'ticketSaleStartDate': ticketSaleStartDate != null ? Timestamp.fromDate(ticketSaleStartDate!) : null,
      'ticketSaleEndDate': ticketSaleEndDate != null ? Timestamp.fromDate(ticketSaleEndDate!) : null,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerEmail': organizerEmail,
      'organizerPhone': organizerPhone,
      'refundPolicy': refundPolicy,
      'ageRestrictions': ageRestrictions,
      'entryRules': entryRules,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory EventModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return EventModel(
      eventId: data['eventId'] ?? doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      eventType: data['eventType'] ?? 'Offline',
      venueName: data['venueName'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
      locationPoint: data['locationPoint'],
      meetingLink: data['meetingLink'] ?? '',
      ticketType: data['ticketType'] ?? 'Free',
      ticketPrice: (data['ticketPrice'] ?? 0).toDouble(),
      totalTickets: data['totalTickets'] ?? 0,
      ticketsSold: data['ticketsSold'] ?? 0,
      maxTicketsPerUser: data['maxTicketsPerUser'] ?? 1,
      ticketSaleStartDate: (data['ticketSaleStartDate'] as Timestamp?)?.toDate(),
      ticketSaleEndDate: (data['ticketSaleEndDate'] as Timestamp?)?.toDate(),
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      organizerEmail: data['organizerEmail'] ?? '',
      organizerPhone: data['organizerPhone'] ?? '',
      refundPolicy: data['refundPolicy'] ?? '',
      ageRestrictions: data['ageRestrictions'] ?? '',
      entryRules: data['entryRules'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
