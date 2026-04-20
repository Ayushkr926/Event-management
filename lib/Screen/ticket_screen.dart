import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/flipcard/gesture_flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../model/ticket_model.dart';
import '../provider/ticket_provider.dart';
import '../utils/color.dart';

class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}


class _TicketsScreenState extends ConsumerState<TicketsScreen> {
  late final FlipCardController _flipController;

  final GlobalKey<FlipCardState> con1 = GlobalKey<FlipCardState>();
  late double _ticketCardHeight;
  late double _ticketCardWidth;




  @override
  void initState() {
    super.initState();
    _flipController = FlipCardController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ticketCardHeight = MediaQuery.of(context).size.height * 0.7;
    _ticketCardWidth = MediaQuery.of(context).size.width * 0.9;
  }
  @override
  Widget build(BuildContext context) {
    final ticket = ref.watch(ticketProvider);
    final isFlipped = ref.watch(isTicketFlippedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tickets",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: implement share ticket
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTicketCard(context, ref, ticket, isFlipped),
              const SizedBox(height: 40),
              _buildActionButtons(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(
      BuildContext context,
      WidgetRef ref,
      TicketModel ticket,
      bool isFlipped,
      ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        ref.read(isTicketFlippedProvider.notifier).state = !isFlipped;
      },
      child: GestureFlipCard(
        animationDuration: const Duration(milliseconds: 500),
        axis: FlipAxis.vertical,
        enableController: false,
        frontWidget: _buildFrontSide(
          context,
          ticket,
          key: const ValueKey('front'),
        ),
        backWidget: _buildBackSide(
          ticket,
          key: const ValueKey('back'),
        ),
      ),
    );
  }


  Widget _buildFrontSide(BuildContext context ,TicketModel ticket, {required Key key}) {
    return SizedBox(
      key: key,
      height: _ticketCardHeight,
      width: _ticketCardWidth,
      child: Container(

        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardcolor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Event header image with rounded top
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/live.jpeg",
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          color: Colors.grey[850],
                          child: const Icon(Icons.broken_image, size: 80, color: Colors.white54),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                // Yellow perforated bar (visual accent)
                Container(
                  height: 14,
                  width: double.infinity,
                  color: const Color(0xffF3FF5A),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Main yellow background
                      Container(
                        height: 24,
                        width: double.infinity,
                        color: const Color(0xffF3FF5A),
                      ),

                      // Subtle perforated/shadow effect (horizontal indent in center)
                      Positioned(
                        top: 10, // vertical position of the "cut"
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 40), // space from edges
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main ticket content - white background, black text
                Stack(
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width*0.7,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(28),bottomLeft: Radius.circular(28)),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & main date
                          Center(
                            child: Text(
                              ticket.subtitle,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              DateFormat('dd MMMM yyyy').format(ticket.eventDate),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Dotted line separator (more realistic look)
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.grey[400]!,
                                  width: 1.5,
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                            child: Row(
                              children: List.generate(
                                40,
                                    (index) => Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    height: 1,
                                    color: index % 2 == 0 ? Colors.transparent : Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Info rows
                          _buildInfoRow("Date", DateFormat('MMM dd, yyyy').format(ticket.eventDate)),
                          const SizedBox(height: 16),
                          _buildInfoRow("Time", ticket.time),
                          const SizedBox(height: 16),
                          _buildInfoRow("Venue", ticket.venue),
                          const SizedBox(height: 16),
                          _buildInfoRow("Seat", ticket.seat),

                          const SizedBox(height: 12),


                          // Tap hint
                          const Center(
                            child: Text(
                              "Flip to show Qr Ticket",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                        bottom: 70,
                        right: -15,
                        child: Container(
                          height: 35,
                          width: 34,
                          decoration: BoxDecoration(
                            color: AppColors.cardcolor,
                            shape: BoxShape.circle
                        ),)),

                    Positioned(
                        bottom: 70,
                        left: -15,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              color: AppColors.cardcolor,
                              shape: BoxShape.circle
                          ),))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackSide(TicketModel ticket, {required Key key}) {
    return SizedBox(
      key: key,
      height: _ticketCardHeight,
      width: _ticketCardWidth,
      child: Container(
        key: key,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: const Color(0xff181818),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              QrImageView(
                data: ticket.ticketId,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: Color(0xff000000),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Scan to Enter Event",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Ticket ID: ${ticket.ticketId}",
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 15),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              // TODO: Download / save ticket logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ticket download started...")),
              );
            },
            icon: const Icon(Icons.download_rounded, color: Colors.black),
            label: const Text(
              "Get a Ticket",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffF3FF5A),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(isTicketFlippedProvider.notifier).state = true;
            },
            icon: const Icon(Icons.calendar_month, color: Color(0xffF3FF5A)),
            label: const Text(
              "Add To Calender",
              style: TextStyle(color: Color(0xffF3FF5A)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xffF3FF5A), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            ),
          ),
        ),
      ],
    );
  }
}