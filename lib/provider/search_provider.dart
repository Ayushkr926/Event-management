import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../Create_event/model/event_model.dart';



// Simple in-memory recent searches (persist later with shared_preferences/hive)
final recentSearchesProvider = StateProvider<List<String>>((ref) => []);

// The current search query (debounced)
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<EventModel>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  // Simulate API/network delay
  await Future.delayed(Duration(milliseconds: 500 + (query.length * 80)));

  // Mock events – now matches your new EventModel
  final allEvents = [
    EventModel(
      title: "Redsketch Academy",
      category: "Video Editing",
      bannerImage: "assets/images/onboarding5.jpg",
      startDate: "2026-02-20",
      endDate: "2026-02-20",
      timezone: "GMT+05:30",
      eventType: "in-person",
      location: EventLocation(
        venueName: "Redsketch Studio",
        city: "Valencia",
        address: "otra calle",
        country: "Spain",
      ),
      status: "published",
    ),

    EventModel(
      title: "YouTube Growth Bootcamp",
      category: "Content Creation",
      bannerImage: "assets/images/onboarding1.jpg",
      startDate: "2026-02-20",
      endDate: "2026-02-20",
      timezone: "GMT+05:30",
      eventType: "online",
      onlineDetails: OnlineDetails(
        platform: "Zoom",
        meetingLink: "https://zoom.us/example",
      ),
      status: "published",
    ),

    /// ===== 21 Feb 2026 =====
    EventModel(
      title: "Flutter Meetup",
      category: "Tech Talk",
      bannerImage: "assets/images/onboarding3.jpg",
      startDate: "2026-02-21",
      endDate: "2026-02-21",
      timezone: "GMT+05:30",
      eventType: "in-person",
      location: EventLocation(
        venueName: "Tech Hub",
        city: "Delhi",
        state: "Delhi",
        country: "India",
      ),
      status: "published",
    ),

    EventModel(
      title: "UI/UX Design Sprint",
      category: "Design Workshop",
      bannerImage: "assets/images/onboarding5.jpg",
      startDate: "2026-02-21",
      endDate: "2026-02-21",
      timezone: "GMT+05:30",
      eventType: "in-person",
      location: EventLocation(
        venueName: "Design Studio",
        city: "Noida",
        address: "Sector 62",
        state: "UP",
        country: "India",
      ),
      status: "published",
    ),

    /// ===== 22 Feb 2026 =====
    EventModel(
      title: "AI Workshop",
      category: "Machine Learning",
      bannerImage: "assets/images/onboarding1.jpg",
      startDate: "2026-02-22",
      endDate: "2026-02-22",
      timezone: "GMT+05:30",
      eventType: "in-person",
      location: EventLocation(
        venueName: "Innovation Center",
        city: "Bangalore",
        state: "Karnataka",
        country: "India",
      ),
      status: "published",
    ),

    /// ===== 25 Feb 2026 =====
    EventModel(
      title: "Startup Pitch Night",
      category: "Entrepreneurship",
      bannerImage: "assets/images/onboarding3.jpg",
      startDate: "2026-02-25",
      endDate: "2026-02-25",
      timezone: "GMT+05:30",
      eventType: "in-person",
      location: EventLocation(
        venueName: "Startup Hub",
        city: "Gurgaon",
        state: "Haryana",
        country: "India",
      ),
      status: "published",
    ),
  ];

  if (query.isEmpty) {
    return allEvents;
  }

  // Simple client-side filtering (replace with backend search in production)
  return allEvents.where((event) {
    final searchLower = query.toLowerCase();
    return event.title.toLowerCase().contains(searchLower) ||
        event.category.toLowerCase().contains(searchLower);
  }).toList();
});