import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/ticket_model.dart';

final ticketProvider = StateProvider<TicketModel>((ref) {
  return TicketModel(
    eventTitle: "Oliver Tree Concert",
    subtitle: "Oliver Tree Concert: Indonesia",
    eventDate: DateTime(2024, 12, 29),
    time: "10:00 PM",
    venue: "Gelora Bung Karno",
    seat: "No Seat",
    imageUrl: "assets/images/oliver_tree_concert.jpg", // or network URL
    ticketId: "OLIVER-TREE-2024-IDN-987654",
  );
});

final isTicketFlippedProvider = StateProvider<bool>((ref) => false);