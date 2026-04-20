import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Create_event/model/event_model.dart';
import '../eventdetail/event_detailscreen.dart';
import '../provider/search_provider.dart';
import '../utils/color.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  static Route route() =>
      MaterialPageRoute(builder: (_) => const SearchScreen());

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = SearchController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.openView();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  void _addToRecent(String query) {
    if (query.trim().isEmpty) return;
    final recents = ref.read(recentSearchesProvider);
    final updated =
    [query, ...recents.where((e) => e != query)].take(6).toList();
    ref.read(recentSearchesProvider.notifier).state = updated;
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final recents = ref.watch(recentSearchesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SearchBar(
                controller: _searchController,
                focusNode: _focusNode,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white70),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
                hintText: "Search events, categories, venues...",
                hintStyle: WidgetStatePropertyAll(
                  Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white60),
                ),
                backgroundColor: WidgetStatePropertyAll(AppColors.surface),
                elevation: const WidgetStatePropertyAll(0),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                ),
                side: WidgetStatePropertyAll(
                    BorderSide(color: AppColors.border)),
                padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16)),
                onChanged: _onQueryChanged,
                onSubmitted: (value) {
                  _addToRecent(value);
                  _searchController.closeView("");
                },
                trailing: [
                  if (query.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          color: Colors.white70),
                      onPressed: () {
                        _searchController.clear();
                        _onQueryChanged('');
                        _focusNode.requestFocus();
                      },
                    ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: query.isEmpty
                  ? _buildSuggestions(recents)
                  : resultsAsync.when(
                data: (events) => events.isEmpty
                    ? _buildNoResults()
                    : _buildResults(events),
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary)),
                error: (_, __) => Center(
                  child: Text("Error loading results",
                      style: TextStyle(color: Colors.red[300])),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Suggestions / Recents ──────────────────────────────────────────
  Widget _buildSuggestions(List<String> recents) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (recents.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 8),
            child: Text("Recent Searches",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
          ...recents.map((q) => ListTile(
            leading:
            const Icon(Icons.history, color: Colors.white54),
            title: Text(q,
                style: const TextStyle(color: Colors.white)),
            trailing: IconButton(
              icon: const Icon(Icons.north_west_rounded,
                  size: 16, color: Colors.white38),
              onPressed: () {
                _searchController.text = q;
                _onQueryChanged(q);
              },
            ),
            onTap: () {
              _searchController.text = q;
              _onQueryChanged(q);
            },
          )),
          const Divider(color: Colors.white24, height: 32),
        ],
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 12),
          child: Text("Popular Categories",
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            "Concerts",
            "Sports",
            "Festivals",
            "Tech",
            "Exhibitions",
            "Rooftops"
          ]
              .map((cat) => ActionChip(
            label: Text(cat),
            backgroundColor: AppColors.seccard,
            labelStyle:
            const TextStyle(color: Colors.white),
            onPressed: () {
              _searchController.text = cat;
              _onQueryChanged(cat);
            },
          ))
              .toList(),
        ),
      ],
    );
  }

  // ── Results List ───────────────────────────────────────────────────
  Widget _buildResults(List<EventModel> events) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) =>
          _EventCard(event: events[index], isHighlighted: index == 0),
    );
  }

  // ── No Results ─────────────────────────────────────────────────────
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          const Text("No events found",
              style:
              TextStyle(color: Colors.white70, fontSize: 20)),
          const SizedBox(height: 8),
          const Text(
            "Try different keywords or browse categories",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// EVENT CARD
// ══════════════════════════════════════════════════════════════
class _EventCard extends StatelessWidget {
  final EventModel event;
  final bool isHighlighted;

  const _EventCard({required this.event, this.isHighlighted = false});

  // ── Derived helpers ────────────────────────────────────────
  String get _dateLabel {
    if (event.startDate.isNotEmpty && event.endDate.isNotEmpty &&
        event.endDate != event.startDate) {
      return '${event.startDate}  –  ${event.endDate}';
    }
    return event.startDate.isNotEmpty ? event.startDate : 'Date TBA';
  }

  String get _locationLabel {
    if (event.eventType == 'online') {
      return event.onlineDetails.platform.isNotEmpty
          ? 'Online · ${event.onlineDetails.platform}'
          : 'Online';
    }
    final parts = [
      event.location.venueName,
      event.location.city,
      event.location.country,
    ].where((s) => s.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : 'Location TBA';
  }

  bool get _isFree {
    if (!event.isPaidEvent) return true;
    if (event.tickets.isEmpty) return true;
    return event.tickets.any((t) => t.isFree);
  }

  String get _priceLabel {
    if (_isFree) return 'FREE';
    final cheapest =
    event.tickets.reduce((a, b) => a.price < b.price ? a : b);
    return '\$${cheapest.price.toStringAsFixed(0)}+';
  }

  @override
  Widget build(BuildContext context) {
    final fg = isHighlighted ? Colors.black : Colors.white;
    final fgMuted = isHighlighted ? Colors.black87 : Colors.white70;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EventDetail(event: event)),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xffF3FF5A)
              : AppColors.seccard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isHighlighted
              ? [
            BoxShadow(
              color:
              const Color(0xffF3FF5A).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: thumbnail + title + arrow ─────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(
                    bannerImage: event.bannerImage,
                    isHighlighted: isHighlighted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        event.title.isNotEmpty
                            ? event.title
                            : 'Untitled Event',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: fg),
                      ),
                      const SizedBox(height: 4),
                      // Category + event type
                      Row(
                        children: [
                          if (event.category.isNotEmpty)
                            _Chip(
                                label: event.category,
                                highlighted: isHighlighted),
                          const SizedBox(width: 6),
                          _Chip(
                              label: event.eventType,
                              highlighted: isHighlighted),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_outward_rounded,
                    size: 18, color: fgMuted),
              ],
            ),

            const SizedBox(height: 12),

            // ── Date + Location ─────────────────────────────────
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: fgMuted),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(_dateLabel,
                      overflow: TextOverflow.ellipsis,
                      style:
                      TextStyle(fontSize: 12, color: fgMuted)),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: fgMuted),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(_locationLabel,
                      overflow: TextOverflow.ellipsis,
                      style:
                      TextStyle(fontSize: 12, color: fgMuted)),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Bottom row: price + tags ────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isFree
                        ? Colors.green[700]
                        : isHighlighted
                        ? Colors.black
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _priceLabel,
                    style: TextStyle(
                        color: _isFree
                            ? Colors.white
                            : isHighlighted
                            ? const Color(0xffF3FF5A)
                            : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                if (event.featured)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('★ Featured',
                        style: TextStyle(
                            color: isHighlighted
                                ? Colors.black
                                : const Color(0xFFFFB800),
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                const Spacer(),
                if (event.attendeeSettings.maxAttendees > 0)
                  Text(
                    '${event.attendeeSettings.maxAttendees} seats',
                    style: TextStyle(fontSize: 11, color: fgMuted),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Thumbnail widget ───────────────────────────────────────────
class _Thumbnail extends StatelessWidget {
  final String bannerImage;
  final bool isHighlighted;
  const _Thumbnail(
      {required this.bannerImage, required this.isHighlighted});

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (bannerImage.isEmpty) {
      child = Container(
        color: isHighlighted
            ? Colors.black12
            : AppColors.cardcolor,
        child: Icon(Icons.event,
            color: isHighlighted
                ? Colors.black38
                : Colors.white24,
            size: 28),
      );
    } else {
      try {
        child = Image.memory(base64Decode(bannerImage),
            fit: BoxFit.cover);
      } catch (_) {
        if (bannerImage.startsWith('http')) {
          child = Image.network(bannerImage, fit: BoxFit.cover);
        } else {
          child = Image.asset(bannerImage, fit: BoxFit.cover);
        }
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(height: 64, width: 64, child: child),
    );
  }
}

// ── Small inline chip ──────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final bool highlighted;
  const _Chip({required this.label, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: highlighted
            ? Colors.black.withOpacity(0.12)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color:
              highlighted ? Colors.black87 : Colors.white60)),
    );
  }
}