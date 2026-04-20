// lib/models/event_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class EventLocation {
  String venueName;
  String address;
  String city;
  String state;
  String country;
  String postalCode;
  String googleMapsLink;
  String landmark;
  bool parkingAvailable;

  EventLocation({
    this.venueName = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.postalCode = '',
    this.googleMapsLink = '',
    this.landmark = '',
    this.parkingAvailable = false,
  });

  Map<String, dynamic> toMap() => {
    'venueName': venueName,
    'address': address,
    'city': city,
    'state': state,
    'country': country,
    'postalCode': postalCode,
    'googleMapsLink': googleMapsLink,
    'landmark': landmark,
    'parkingAvailable': parkingAvailable,
  };
}

class OnlineDetails {
  String platform;
  String meetingLink;
  String meetingId;
  String passcode;

  OnlineDetails({
    this.platform = '',
    this.meetingLink = '',
    this.meetingId = '',
    this.passcode = '',
  });

  Map<String, dynamic> toMap() => {
    'platform': platform,
    'meetingLink': meetingLink,
    'meetingId': meetingId,
    'passcode': passcode,
  };
}

class OrganizerInfo {
  String name;
  String photo;
  String organization;
  String bio;
  String email;
  String phone;
  String website;

  OrganizerInfo({
    this.name = '',
    this.photo = '',
    this.organization = '',
    this.bio = '',
    this.email = '',
    this.phone = '',
    this.website = '',
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'photo': photo,
    'organization': organization,
    'bio': bio,
    'email': email,
    'phone': phone,
    'website': website,
  };
}

class AttendeeSettings {
  int maxAttendees;
  int minAttendees;
  bool approvalRequired;
  String privacy;

  AttendeeSettings({
    this.maxAttendees = 100,
    this.minAttendees = 0,
    this.approvalRequired = false,
    this.privacy = 'public',
  });

  Map<String, dynamic> toMap() => {
    'maxAttendees': maxAttendees,
    'minAttendees': minAttendees,
    'approvalRequired': approvalRequired,
    'privacy': privacy,
  };
}

class TicketType {
  String id;
  String name;
  double price;
  int quantity;
  String salesStartDate;
  String salesEndDate;
  bool isFree;

  TicketType({
    required this.id,
    this.name = '',
    this.price = 0.0,
    this.quantity = 0,
    this.salesStartDate = '',
    this.salesEndDate = '',
    this.isFree = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'salesStartDate': salesStartDate,
    'salesEndDate': salesEndDate,
    'isFree': isFree,
  };
}

class AgendaItem {
  String id;
  String title;
  String speakerName;
  String startTime;
  String endTime;
  String description;

  AgendaItem({
    required this.id,
    this.title = '',
    this.speakerName = '',
    this.startTime = '',
    this.endTime = '',
    this.description = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'speakerName': speakerName,
    'startTime': startTime,
    'endTime': endTime,
    'description': description,
  };
}

class Speaker {
  String id;
  String photo;
  String name;
  String title;
  String company;
  String bio;
  String linkedin;
  String twitter;
  String website;

  Speaker({
    required this.id,
    this.photo = '',
    this.name = '',
    this.title = '',
    this.company = '',
    this.bio = '',
    this.linkedin = '',
    this.twitter = '',
    this.website = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'photo': photo,
    'name': name,
    'title': title,
    'company': company,
    'bio': bio,
    'linkedin': linkedin,
    'twitter': twitter,
    'website': website,
  };
}

class EventNotifications {
  bool reminder24h;
  bool reminder1h;
  bool email;
  bool push;

  EventNotifications({
    this.reminder24h = true,
    this.reminder1h = true,
    this.email = true,
    this.push = true,
  });

  Map<String, dynamic> toMap() => {
    'reminder24h': reminder24h,
    'reminder1h': reminder1h,
    'email': email,
    'push': push,
  };
}

class EventModel {
  String? id;
  String title;
  String description;
  String category;
  String bannerImage;
  List<String> tags;
  String language;
  String startDate;
  String endDate;
  String timezone;
  String eventType; // 'in-person' | 'online' | 'hybrid'
  bool isRecurring;
  EventLocation location;
  OnlineDetails onlineDetails;
  OrganizerInfo organizer;
  AttendeeSettings attendeeSettings;
  List<TicketType> tickets;
  bool isPaidEvent;
  List<AgendaItem> agenda;
  List<Speaker> speakers;
  List<String> gallery;
  String promoVideo;
  List<String> hashtags;
  String rules;
  String ageRestriction;
  String dressCode;
  String whatToBring;
  String codeOfConduct;
  EventNotifications notifications;
  String visibility;
  String status;
  bool featured;
  Timestamp? createdAt;

  EventModel({
    this.id,
    this.title = '',
    this.description = '',
    this.category = '',
    this.bannerImage = '',
    List<String>? tags,
    this.language = 'English',
    this.startDate = '',
    this.endDate = '',
    this.timezone = 'UTC',
    this.eventType = 'in-person',
    this.isRecurring = false,
    EventLocation? location,
    OnlineDetails? onlineDetails,
    OrganizerInfo? organizer,
    AttendeeSettings? attendeeSettings,
    List<TicketType>? tickets,
    this.isPaidEvent = false,
    List<AgendaItem>? agenda,
    List<Speaker>? speakers,
    List<String>? gallery,
    this.promoVideo = '',
    List<String>? hashtags,
    this.rules = '',
    this.ageRestriction = '',
    this.dressCode = '',
    this.whatToBring = '',
    this.codeOfConduct = '',
    EventNotifications? notifications,
    this.visibility = 'public',
    this.status = 'draft',
    this.featured = false,
    this.createdAt,
  })  : tags = tags ?? [],
        location = location ?? EventLocation(),
        onlineDetails = onlineDetails ?? OnlineDetails(),
        organizer = organizer ?? OrganizerInfo(),
        attendeeSettings = attendeeSettings ?? AttendeeSettings(),
        tickets = tickets ?? [],
        agenda = agenda ?? [],
        speakers = speakers ?? [],
        gallery = gallery ?? [],
        hashtags = hashtags ?? [],
        notifications = notifications ?? EventNotifications();

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'category': category,
    'bannerImage': bannerImage,
    'tags': tags,
    'language': language,
    'startDate': startDate,
    'endDate': endDate,
    'timezone': timezone,
    'eventType': eventType,
    'isRecurring': isRecurring,
    'location': location.toMap(),
    'onlineDetails': onlineDetails.toMap(),
    'organizer': organizer.toMap(),
    'attendeeSettings': attendeeSettings.toMap(),
    'tickets': tickets.map((t) => t.toMap()).toList(),
    'isPaidEvent': isPaidEvent,
    'agenda': agenda.map((a) => a.toMap()).toList(),
    'speakers': speakers.map((s) => s.toMap()).toList(),
    'gallery': gallery,
    'promoVideo': promoVideo,
    'hashtags': hashtags,
    'rules': rules,
    'ageRestriction': ageRestriction,
    'dressCode': dressCode,
    'whatToBring': whatToBring,
    'codeOfConduct': codeOfConduct,
    'notifications': notifications.toMap(),
    'visibility': visibility,
    'status': status,
    'featured': featured,
    'createdAt': createdAt ?? Timestamp.now(),
  };
}