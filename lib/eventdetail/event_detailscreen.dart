// lib/screens/event_detail_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Create_event/model/event_model.dart';
import '../utils/color.dart';

class EventDetail extends StatelessWidget {
  final EventModel event;
  const EventDetail({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ── Banner ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _BannerHeader(event: event, size: size),
                  ),
                ),

                _sliver(_TitleCard(event: event)),
                _sliver(_EventMetaCard(event: event)),
                _sliver(_AboutCard(description: event.description, tags: event.tags, hashtags: event.hashtags)),

                if (event.tickets.isNotEmpty)
                  _sliver(_TicketsCard(tickets: event.tickets)),

                if (event.agenda.isNotEmpty)
                  _sliver(_AgendaCard(agenda: event.agenda)),

                if (event.speakers.isNotEmpty)
                  _sliver(_SpeakersCard(speakers: event.speakers)),

                _sliver(_OrganizerCard(organizer: event.organizer)),

                if (event.eventType != 'online')
                  _sliver(_LocationCard(location: event.location, size: size)),

                if (event.eventType != 'in-person' &&
                    event.onlineDetails.platform.isNotEmpty)
                  _sliver(_OnlineCard(details: event.onlineDetails)),

                if (event.gallery.isNotEmpty)
                  _sliver(_GalleryCard(gallery: event.gallery)),

                if (_hasEventInfo(event))
                  _sliver(_EventInfoCard(event: event)),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),

            // ── Floating bottom bar ──────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _FloatingBookBar(event: event),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasEventInfo(EventModel e) =>
      e.ageRestriction.isNotEmpty ||
          e.dressCode.isNotEmpty ||
          e.whatToBring.isNotEmpty ||
          e.rules.isNotEmpty ||
          e.codeOfConduct.isNotEmpty ||
          e.language.isNotEmpty;

  Widget _sliver(Widget child) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
      child: child,
    ),
  );
}

// ════════════════════════════════════════════════════════
// BANNER HEADER
// ════════════════════════════════════════════════════════
class _BannerHeader extends StatelessWidget {
  final EventModel event;
  final Size size;
  const _BannerHeader({required this.event, required this.size});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.4),
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          SizedBox(
            height: size.height * 0.42,
            width: double.infinity,
            child: _buildImage(),
          ),
          // Gradient overlay
          Container(
            height: size.height * 0.42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),
          // Back button
          Positioned(
            top: 12,
            left: 12,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Status + Category badges
          Positioned(
            top: 14,
            right: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Badge(
                  label: event.status.toUpperCase(),
                  color: _statusColor(event.status),
                ),
                if (event.category.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _Badge(label: event.category, color: AppColors.primary),
                ],
              ],
            ),
          ),
          // Bottom info overlay
          Positioned(
            bottom: 14,
            left: 16,
            right: 16,
            child: Row(
              children: [
                if (event.featured)
                  _Badge(
                    label: '★ FEATURED',
                    color: const Color(0xFFFFB800),
                  ),
                const Spacer(),
                _Badge(
                  label: event.eventType.toUpperCase(),
                  color: AppColors.primary.withOpacity(0.85),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (event.bannerImage.isEmpty) {
      return Container(
        color: AppColors.cardcolor,
        child: const Icon(Icons.image_not_supported,
            size: 60, color: Colors.white24),
      );
    }
    // Base64 image (stored in Firestore)
    try {
      final bytes = base64Decode(event.bannerImage);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (_) {
      // Fallback: treat as asset or network URL
      if (event.bannerImage.startsWith('http')) {
        return Image.network(event.bannerImage, fit: BoxFit.cover);
      }
      return Image.asset(event.bannerImage, fit: BoxFit.cover);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}

// ════════════════════════════════════════════════════════
// TITLE CARD
// ════════════════════════════════════════════════════════
class _TitleCard extends StatelessWidget {
  final EventModel event;
  const _TitleCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cheapestTicket = event.tickets.isNotEmpty
        ? event.tickets.reduce(
            (a, b) => a.price < b.price ? a : b)
        : null;

    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: size.width < 360 ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (event.startDate.isNotEmpty)
                  _InfoRow(
                    icon: Icons.calendar_today,
                    text: event.startDate,
                  ),
                if (event.endDate.isNotEmpty &&
                    event.endDate != event.startDate) ...[
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.event_available,
                    text: 'Ends: ${event.endDate}',
                  ),
                ],
                if (event.timezone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.schedule,
                    text: event.timezone,
                  ),
                ],
                if (event.isRecurring) ...[
                  const SizedBox(height: 8),
                  _Badge(label: '🔁 Recurring', color: Colors.blueAccent),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Price box
          Container(
            width: size.width * 0.28,
            decoration: BoxDecoration(
              color: AppColors.seccard,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cheapestTicket == null
                    ? Text('Free',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold))
                    : cheapestTicket.isFree
                    ? Text('Free',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold))
                    : Text(
                  '\$${cheapestTicket.price.toStringAsFixed(0)}',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '${event.attendeeSettings.maxAttendees} seats',
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                if (event.attendeeSettings.approvalRequired) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Approval\nRequired',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// EVENT META CARD  (language, privacy, recurring, dress code, etc.)
// ════════════════════════════════════════════════════════
class _EventMetaCard extends StatelessWidget {
  final EventModel event;
  const _EventMetaCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          if (event.language.isNotEmpty)
            _MetaTile(
                icon: Icons.language, label: 'Language', value: event.language),
          _MetaTile(
              icon: Icons.lock_outline,
              label: 'Privacy',
              value: event.attendeeSettings.privacy.toUpperCase()),
          _MetaTile(
              icon: Icons.visibility_outlined,
              label: 'Visibility',
              value: event.visibility.toUpperCase()),
          if (event.ageRestriction.isNotEmpty)
            _MetaTile(
                icon: Icons.person_outlined,
                label: 'Age',
                value: event.ageRestriction),
          if (event.dressCode.isNotEmpty)
            _MetaTile(
                icon: Icons.checkroom_outlined,
                label: 'Dress Code',
                value: event.dressCode),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// ABOUT CARD
// ════════════════════════════════════════════════════════
class _AboutCard extends StatefulWidget {
  final String description;
  final List<String> tags;
  final List<String> hashtags;
  const _AboutCard(
      {required this.description,
        required this.tags,
        required this.hashtags});

  @override
  State<_AboutCard> createState() => _AboutCardState();
}

class _AboutCardState extends State<_AboutCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: Icons.info_outline, title: 'About Event'),
          const SizedBox(height: 14),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Text(
              widget.description.isEmpty
                  ? 'No description provided.'
                  : widget.description,
              maxLines: _expanded ? null : 4,
              overflow:
              _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14.5, height: 1.65),
            ),
          ),
          if (widget.description.length > 200) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_expanded ? 'Read less' : 'Read more',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primary, size: 20),
                  ),
                ],
              ),
            ),
          ],
          if (widget.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Divider(),
            const SizedBox(height: 12),
            _SectionSubHeader('Tags'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.tags
                  .map((t) => _Badge(label: t, color: AppColors.seccard))
                  .toList(),
            ),
          ],
          if (widget.hashtags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.hashtags
                  .map((h) => _Badge(
                  label: '#$h',
                  color: AppColors.primary.withOpacity(0.15),
                  textColor: AppColors.primary))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// TICKETS CARD
// ════════════════════════════════════════════════════════
class _TicketsCard extends StatelessWidget {
  final List<TicketType> tickets;
  const _TicketsCard({required this.tickets});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: Icons.confirmation_number_outlined, title: 'Tickets'),
          const SizedBox(height: 14),
          ...tickets.map((t) => _TicketRow(ticket: t)).toList(),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final TicketType ticket;
  const _TicketRow({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.seccard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.name,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text('${ticket.quantity} available',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                if (ticket.salesStartDate.isNotEmpty)
                  Text('Sales: ${ticket.salesStartDate} – ${ticket.salesEndDate}',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Text(
            ticket.isFree ? 'FREE' : '\$${ticket.price.toStringAsFixed(2)}',
            style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// AGENDA CARD
// ════════════════════════════════════════════════════════
class _AgendaCard extends StatelessWidget {
  final List<AgendaItem> agenda;
  const _AgendaCard({required this.agenda});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: Icons.list_alt_outlined, title: 'Agenda'),
          const SizedBox(height: 14),
          ...agenda.asMap().entries.map((e) {
            final item = e.value;
            final isLast = e.key == agenda.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: AppColors.primary.withOpacity(0.25),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (item.startTime.isNotEmpty)
                                Text('${item.startTime}  ',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              if (item.endTime.isNotEmpty)
                                Text('– ${item.endTime}',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(item.title,
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          if (item.speakerName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text('🎤 ${item.speakerName}',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                          ],
                          if (item.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(item.description,
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    height: 1.5)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// SPEAKERS CARD
// ════════════════════════════════════════════════════════
class _SpeakersCard extends StatelessWidget {
  final List<Speaker> speakers;
  const _SpeakersCard({required this.speakers});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: Icons.mic_none_outlined, title: 'Speakers'),
          const SizedBox(height: 14),
          ...speakers.map((s) => _SpeakerRow(speaker: s)).toList(),
        ],
      ),
    );
  }
}

class _SpeakerRow extends StatelessWidget {
  final Speaker speaker;
  const _SpeakerRow({required this.speaker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.seccard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _SpeakerAvatar(photo: speaker.photo, name: speaker.name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(speaker.name,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                if (speaker.title.isNotEmpty)
                  Text(speaker.title,
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                if (speaker.company.isNotEmpty)
                  Text(speaker.company,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                if (speaker.bio.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(speaker.bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.5)),
                ],
                // Social links
                if (speaker.linkedin.isNotEmpty ||
                    speaker.twitter.isNotEmpty ||
                    speaker.website.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (speaker.linkedin.isNotEmpty)
                        _SocialChip(label: 'LinkedIn', url: speaker.linkedin),
                      if (speaker.twitter.isNotEmpty)
                        _SocialChip(label: 'Twitter', url: speaker.twitter),
                      if (speaker.website.isNotEmpty)
                        _SocialChip(label: 'Website', url: speaker.website),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeakerAvatar extends StatelessWidget {
  final String photo;
  final String name;
  const _SpeakerAvatar({required this.photo, required this.name});

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (photo.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(photo));
      } catch (_) {
        if (photo.startsWith('http')) {
          imageProvider = NetworkImage(photo);
        } else {
          imageProvider = AssetImage(photo) as ImageProvider;
        }
      }
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primary.withOpacity(0.2),
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20),
      )
          : null,
    );
  }
}

// ════════════════════════════════════════════════════════
// ORGANIZER CARD
// ════════════════════════════════════════════════════════
class _OrganizerCard extends StatelessWidget {
  final OrganizerInfo organizer;
  const _OrganizerCard({required this.organizer});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              icon: Icons.person_outline, title: 'Organizer'),
          const SizedBox(height: 14),
          Row(
            children: [
              _SpeakerAvatar(
                  photo: organizer.photo, name: organizer.name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(organizer.name,
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    if (organizer.organization.isNotEmpty)
                      Text(organizer.organization,
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          if (organizer.bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(organizer.bio,
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.5,
                    height: 1.6)),
          ],
          if (organizer.email.isNotEmpty ||
              organizer.phone.isNotEmpty ||
              organizer.website.isNotEmpty) ...[
            const SizedBox(height: 14),
            _Divider(),
            const SizedBox(height: 12),
            if (organizer.email.isNotEmpty)
              _InfoRow(icon: Icons.email_outlined, text: organizer.email),
            if (organizer.phone.isNotEmpty) ...[
              const SizedBox(height: 6),
              _InfoRow(icon: Icons.phone_outlined, text: organizer.phone),
            ],
            if (organizer.website.isNotEmpty) ...[
              const SizedBox(height: 6),
              _InfoRow(icon: Icons.link, text: organizer.website),
            ],
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// LOCATION CARD
// ════════════════════════════════════════════════════════
class _LocationCard extends StatelessWidget {
  final EventLocation location;
  final Size size;
  const _LocationCard({required this.location, required this.size});

  @override
  Widget build(BuildContext context) {
    final fullAddress = [
      location.venueName,
      location.address,
      location.city,
      location.state,
      location.country,
      if (location.postalCode.isNotEmpty) location.postalCode,
    ].where((s) => s.isNotEmpty).join(', ');

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              icon: Icons.location_on_outlined, title: 'Location'),
          const SizedBox(height: 14),
          // Map placeholder with pin
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/world_map_dark.jpg',
                  height: size.height * 0.2,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: size.height * 0.05,
                  left: size.width * 0.42,
                  child: _MapPin(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (fullAddress.isNotEmpty)
            _InfoRow(icon: Icons.location_on, text: fullAddress),
          if (location.landmark.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoRow(
                icon: Icons.flag_outlined, text: 'Near: ${location.landmark}'),
          ],
          if (location.parkingAvailable) ...[
            const SizedBox(height: 6),
            _InfoRow(
                icon: Icons.local_parking_outlined,
                text: 'Parking available'),
          ],
          if (location.googleMapsLink.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PrimaryChipButton(
              label: 'Open in Maps',
              icon: Icons.map_outlined,
              onTap: () => _launchUrl(location.googleMapsLink),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// ONLINE DETAILS CARD
// ════════════════════════════════════════════════════════
class _OnlineCard extends StatelessWidget {
  final OnlineDetails details;
  const _OnlineCard({required this.details});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              icon: Icons.videocam_outlined, title: 'Online Access'),
          const SizedBox(height: 14),
          if (details.platform.isNotEmpty)
            _InfoRow(icon: Icons.laptop_outlined, text: details.platform),
          if (details.meetingId.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoRow(
                icon: Icons.tag, text: 'Meeting ID: ${details.meetingId}'),
          ],
          if (details.passcode.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoRow(
                icon: Icons.lock_outline,
                text: 'Passcode: ${details.passcode}'),
          ],
          if (details.meetingLink.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PrimaryChipButton(
              label: 'Join Meeting',
              icon: Icons.open_in_new,
              onTap: () => _launchUrl(details.meetingLink),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// GALLERY CARD
// ════════════════════════════════════════════════════════
class _GalleryCard extends StatelessWidget {
  final List<String> gallery;
  const _GalleryCard({required this.gallery});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              icon: Icons.photo_library_outlined, title: 'Gallery'),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: gallery.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 120,
                    child: _buildGalleryImage(gallery[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryImage(String src) {
    if (src.isEmpty) {
      return Container(
          color: AppColors.seccard,
          child: const Icon(Icons.image, color: Colors.white24));
    }
    try {
      return Image.memory(base64Decode(src), fit: BoxFit.cover);
    } catch (_) {
      if (src.startsWith('http')) {
        return Image.network(src, fit: BoxFit.cover);
      }
      return Image.asset(src, fit: BoxFit.cover);
    }
  }
}

// ════════════════════════════════════════════════════════
// EVENT INFO CARD (rules, dress code, what to bring, etc.)
// ════════════════════════════════════════════════════════
class _EventInfoCard extends StatelessWidget {
  final EventModel event;
  const _EventInfoCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              icon: Icons.rule_outlined, title: 'Event Information'),
          const SizedBox(height: 14),
          if (event.whatToBring.isNotEmpty)
            _InfoSection('What to Bring', event.whatToBring,
                Icons.backpack_outlined),
          if (event.rules.isNotEmpty)
            _InfoSection('Rules', event.rules, Icons.gavel_outlined),
          if (event.codeOfConduct.isNotEmpty)
            _InfoSection(
                'Code of Conduct', event.codeOfConduct, Icons.handshake_outlined),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  const _InfoSection(this.title, this.content, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Text(content,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13.5, height: 1.6)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// FLOATING BOOK BAR
// ════════════════════════════════════════════════════════
class _FloatingBookBar extends StatelessWidget {
  final EventModel event;
  const _FloatingBookBar({required this.event});

  @override
  Widget build(BuildContext context) {
    final cheapest = event.tickets.isNotEmpty
        ? event.tickets.reduce((a, b) => a.price < b.price ? a : b)
        : null;

    final priceLabel = cheapest == null
        ? 'Free'
        : cheapest.isFree
        ? 'Free'
        : '\$${cheapest.price.toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardcolor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Price',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              Text(priceLabel,
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                // TODO: navigate to booking flow
              },
              child: Text(
                event.attendeeSettings.approvalRequired
                    ? 'Request to Join'
                    : 'Book Now',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// SHARED SMALL WIDGETS
// ════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.45),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardcolor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: child,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(title,
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _SectionSubHeader extends StatelessWidget {
  final String title;
  const _SectionSubHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1));
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: Colors.white.withOpacity(0.06));
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style:
              TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
        ),
      ],
    );
  }
}

class _MetaTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetaTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.seccard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 0.8)),
              Text(value,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  const _Badge({required this.label, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _PrimaryChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryChipButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.black),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  final String label;
  final String url;
  const _SocialChip({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            border:
            Border.all(color: AppColors.primary.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withOpacity(0.6), blurRadius: 10)
            ],
          ),
          child:
          const Icon(Icons.location_on, size: 18, color: Colors.black),
        ),
        Container(height: 10, width: 2, color: AppColors.primary),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
// URL LAUNCHER HELPER
// ════════════════════════════════════════════════════════
Future<void> _launchUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}