class TicketModel {
  final String eventTitle;
  final String subtitle; // e.g. "Oliver Tree Concert: Indonesia"
  final DateTime eventDate;
  final String time;
  final String venue;
  final String seat;
  final String imageUrl; // or asset path
  final String ticketId; // used for QR code

  TicketModel({
    required this.eventTitle,
    required this.subtitle,
    required this.eventDate,
    required this.time,
    required this.venue,
    required this.seat,
    required this.imageUrl,
    required this.ticketId,
  });
}