// lib/screens/steps/event_steps.dart
// All 12 step widgets for the Create Event multi-step form

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../model/event_model.dart';
import 'create_event_widget.dart';


final _imagePicker = ImagePicker();

Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
  final picked = await _imagePicker.pickImage(
      source: source, imageQuality: 85, maxWidth: 1920);
  if (picked != null) return File(picked.path);
  return null;
}

// ════════════════════════════════════════════
// STEP 1 — BASIC INFO
// ════════════════════════════════════════════
class Step1BasicInfo extends StatefulWidget {
  final EventModel event;
  final File? bannerFile;
  final ValueChanged<File?> onBannerChanged;

  const Step1BasicInfo({
    Key? key,
    required this.event,
    required this.bannerFile,
    required this.onBannerChanged,
  }) : super(key: key);

  @override
  State<Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<Step1BasicInfo> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;

  static const categories = [
    'Technology', 'Business', 'Arts & Culture', 'Health & Wellness',
    'Education', 'Music', 'Sports & Fitness', 'Food & Drink',
    'Community', 'Networking', 'Entertainment', 'Government & Politics',
    'Science', 'Travel', 'Fashion', 'Film & Media',
  ];

  static const languages = [
    'English', 'Spanish', 'French', 'German', 'Hindi',
    'Mandarin', 'Arabic', 'Portuguese', 'Japanese', 'Korean',
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.event.title);
    _descCtrl = TextEditingController(text: widget.event.description);
    _titleCtrl.addListener(() => widget.event.title = _titleCtrl.text);
    _descCtrl.addListener(() => widget.event.description = _descCtrl.text);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          icon: Icons.auto_awesome,
          title: 'Basic Information',
          subtitle: 'Start with the essentials of your event',
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('EVENT TITLE *'),
              EventTextField(
                label: 'Event Title',
                hint: 'Give your event a catchy name',
                controller: _titleCtrl,
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Title is required' : null,
                prefixIcon: const Icon(Icons.title_rounded,
                    color: EventTheme.textSecondary, size: 20),
              ),
              const SizedBox(height: 18),
              const SectionLabel('EVENT CATEGORY *'),
              EventDropdown<String>(
                label: 'Category',
                value: widget.event.category.isEmpty
                    ? null
                    : widget.event.category,
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => widget.event.category = v ?? ''),
                validator: (v) =>
                v == null || v.isEmpty ? 'Please select a category' : null,
                prefixIcon: const Icon(Icons.category_outlined,
                    color: EventTheme.textSecondary, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('EVENT COVER IMAGE *'),
              ImagePickerCard(
                label: 'Upload Event Banner',
                imagePath: widget.bannerFile?.path,
                height: 200,
                onPickImage: () async {
                  final file = await pickImage();
                  if (file != null) widget.onBannerChanged(file);
                },
                onRemove: widget.bannerFile != null
                    ? () => widget.onBannerChanged(null)
                    : null,
              ),
              const SizedBox(height: 8),
              const Text(
                'Recommended: 1920×1080px, max 5MB (JPG/PNG)',
                style: TextStyle(
                    fontSize: 12, color: EventTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('DESCRIPTION *'),
              EventTextField(
                label: 'Event Description',
                hint: 'Tell attendees what your event is about...',
                controller: _descCtrl,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 18),
              const SectionLabel('TAGS'),
              TagInputWidget(
                tags: widget.event.tags,
                onTagsChanged: (tags) =>
                    setState(() => widget.event.tags = tags),
                label: 'Add Tags',
                hint: 'e.g. flutter, mobile, tech',
              ),
              const SizedBox(height: 18),
              const SectionLabel('EVENT LANGUAGE'),
              EventDropdown<String>(
                label: 'Language',
                value: widget.event.language,
                items: languages
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => widget.event.language = v ?? 'English'),
                prefixIcon: const Icon(Icons.language_outlined,
                    color: EventTheme.textSecondary, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════
// STEP 2 — DATE & TIME
// ════════════════════════════════════════════
class Step2DateTime extends StatefulWidget {
  final EventModel event;
  const Step2DateTime({Key? key, required this.event}) : super(key: key);

  @override
  State<Step2DateTime> createState() => _Step2DateTimeState();
}

class _Step2DateTimeState extends State<Step2DateTime> {
  late TextEditingController _startDateCtrl;
  late TextEditingController _endDateCtrl;
  late TextEditingController _timezoneCtrl;

  static const timezones = [
    'UTC', 'America/New_York', 'America/Chicago', 'America/Denver',
    'America/Los_Angeles', 'Europe/London', 'Europe/Paris', 'Asia/Dubai',
    'Asia/Kolkata', 'Asia/Tokyo', 'Asia/Singapore', 'Australia/Sydney',
    'Pacific/Auckland',
  ];

  @override
  void initState() {
    super.initState();
    _startDateCtrl = TextEditingController(text: widget.event.startDate);
    _endDateCtrl = TextEditingController(text: widget.event.endDate);
    _timezoneCtrl = TextEditingController(text: widget.event.timezone);
  }

  @override
  void dispose() {
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _timezoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: EventTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: EventTheme.primary),
        ),
        child: child!,
      ),
    );
    if (time == null) return;
    final formatted =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')} ${time.format(context)}';
    ctrl.text = formatted;
    setState(() {
      if (isStart) {
        widget.event.startDate = formatted;
      } else {
        widget.event.endDate = formatted;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          icon: Icons.calendar_month_rounded,
          title: 'Date & Time',
          subtitle: 'When is your event happening?',
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('START DATE & TIME *'),
              EventTextField(
                label: 'Start Date & Time',
                hint: 'Select start date and time',
                controller: _startDateCtrl,
                readOnly: true,
                onTap: () => _pickDate(_startDateCtrl, true),
                validator: (v) => v == null || v.isEmpty
                    ? 'Start date is required'
                    : null,
                prefixIcon: const Icon(Icons.event_available_outlined,
                    color: EventTheme.textSecondary, size: 20),
                suffixIcon: const Icon(Icons.arrow_drop_down_rounded,
                    color: EventTheme.primary),
              ),
              const SizedBox(height: 18),
              const SectionLabel('END DATE & TIME *'),
              EventTextField(
                label: 'End Date & Time',
                hint: 'Select end date and time',
                controller: _endDateCtrl,
                readOnly: true,
                onTap: () => _pickDate(_endDateCtrl, false),
                validator: (v) => v == null || v.isEmpty
                    ? 'End date is required'
                    : null,
                prefixIcon: const Icon(Icons.event_busy_outlined,
                    color: EventTheme.textSecondary, size: 20),
                suffixIcon: const Icon(Icons.arrow_drop_down_rounded,
                    color: EventTheme.primary),
              ),
              const SizedBox(height: 18),
              const SectionLabel('TIMEZONE'),
              EventDropdown<String>(
                label: 'Timezone',
                value: widget.event.timezone,
                items: timezones
                    .map((tz) =>
                    DropdownMenuItem(value: tz, child: Text(tz)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => widget.event.timezone = v ?? 'UTC'),
                prefixIcon: const Icon(Icons.schedule_outlined,
                    color: EventTheme.textSecondary, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: ToggleCard(
            title: 'Recurring Event',
            subtitle: 'This event repeats on a schedule',
            value: widget.event.isRecurring,
            onChanged: (v) =>
                setState(() => widget.event.isRecurring = v),
            icon: Icons.repeat_rounded,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════
// STEP 3 — LOCATION
// ════════════════════════════════════════════
class Step3Location extends StatefulWidget {
  final EventModel event;
  const Step3Location({Key? key, required this.event}) : super(key: key);

  @override
  State<Step3Location> createState() => _Step3LocationState();
}

class _Step3LocationState extends State<Step3Location> {
  late Map<String, TextEditingController> _ctrls;

  @override
  void initState() {
    super.initState();
    final loc = widget.event.location;
    final online = widget.event.onlineDetails;
    _ctrls = {
      'venueName': TextEditingController(text: loc.venueName),
      'address': TextEditingController(text: loc.address),
      'city': TextEditingController(text: loc.city),
      'state': TextEditingController(text: loc.state),
      'country': TextEditingController(text: loc.country),
      'postalCode': TextEditingController(text: loc.postalCode),
      'mapsLink': TextEditingController(text: loc.googleMapsLink),
      'landmark': TextEditingController(text: loc.landmark),
      'platform': TextEditingController(text: online.platform),
      'meetingLink': TextEditingController(text: online.meetingLink),
      'meetingId': TextEditingController(text: online.meetingId),
      'passcode': TextEditingController(text: online.passcode),
    };
    _ctrls.forEach((key, ctrl) {
      ctrl.addListener(() {
        final loc = widget.event.location;
        final online = widget.event.onlineDetails;
        switch (key) {
          case 'venueName': loc.venueName = ctrl.text; break;
          case 'address': loc.address = ctrl.text; break;
          case 'city': loc.city = ctrl.text; break;
          case 'state': loc.state = ctrl.text; break;
          case 'country': loc.country = ctrl.text; break;
          case 'postalCode': loc.postalCode = ctrl.text; break;
          case 'mapsLink': loc.googleMapsLink = ctrl.text; break;
          case 'landmark': loc.landmark = ctrl.text; break;
          case 'platform': online.platform = ctrl.text; break;
          case 'meetingLink': online.meetingLink = ctrl.text; break;
          case 'meetingId': online.meetingId = ctrl.text; break;
          case 'passcode': online.passcode = ctrl.text; break;
        }
      });
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.event.eventType;
    final showInPerson = type == 'in-person' || type == 'hybrid';
    final showOnline = type == 'online' || type == 'hybrid';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          icon: Icons.place_outlined,
          title: 'Location',
          subtitle: 'Where is your event taking place?',
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('EVENT TYPE *'),
              EventTypeSelector(
                selected: widget.event.eventType,
                onChanged: (v) => setState(() => widget.event.eventType = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (showInPerson) ...[
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_on_outlined,
                          color: Color(0xFFFF8F00), size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text('Venue Details',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: EventTheme.textPrimary)),
                  ],
                ),
                const SizedBox(height: 18),
                EventTextField(
                  label: 'Venue Name',
                  hint: 'e.g. Convention Center',
                  controller: _ctrls['venueName']!,
                  prefixIcon: const Icon(Icons.business_outlined,
                      color: EventTheme.textSecondary, size: 20),
                ),
                const SizedBox(height: 14),
                EventTextField(
                  label: 'Street Address',
                  hint: '123 Main Street',
                  controller: _ctrls['address']!,
                  prefixIcon: const Icon(Icons.home_outlined,
                      color: EventTheme.textSecondary, size: 20),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                        child: EventTextField(
                            label: 'City',
                            controller: _ctrls['city']!)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: EventTextField(
                            label: 'State',
                            controller: _ctrls['state']!)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                        child: EventTextField(
                            label: 'Country',
                            controller: _ctrls['country']!)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: EventTextField(
                            label: 'Postal Code',
                            controller: _ctrls['postalCode']!,
                            keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 14),
                EventTextField(
                  label: 'Google Maps Link',
                  hint: 'https://maps.google.com/...',
                  controller: _ctrls['mapsLink']!,
                  prefixIcon: const Icon(Icons.map_outlined,
                      color: EventTheme.textSecondary, size: 20),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 14),
                EventTextField(
                  label: 'Landmark / Directions',
                  hint: 'Near the Central Park entrance',
                  controller: _ctrls['landmark']!,
                ),
                const SizedBox(height: 14),
                ToggleCard(
                  title: 'Parking Available',
                  subtitle: 'Parking is available at this venue',
                  value: widget.event.location.parkingAvailable,
                  onChanged: (v) => setState(
                          () => widget.event.location.parkingAvailable = v),
                  icon: Icons.local_parking_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (showOnline)
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: EventTheme.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.videocam_outlined,
                          color: EventTheme.primary, size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text('Online Event Details',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: EventTheme.textPrimary)),
                  ],
                ),
                const SizedBox(height: 18),
                EventTextField(
                  label: 'Platform',
                  hint: 'e.g. Zoom, Google Meet, Teams',
                  controller: _ctrls['platform']!,
                  prefixIcon: const Icon(Icons.desktop_windows_outlined,
                      color: EventTheme.textSecondary, size: 20),
                ),
                const SizedBox(height: 14),
                EventTextField(
                  label: 'Meeting Link',
                  hint: 'https://zoom.us/j/...',
                  controller: _ctrls['meetingLink']!,
                  prefixIcon: const Icon(Icons.link_rounded,
                      color: EventTheme.textSecondary, size: 20),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                        child: EventTextField(
                            label: 'Meeting ID',
                            controller: _ctrls['meetingId']!)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: EventTextField(
                            label: 'Passcode',
                            controller: _ctrls['passcode']!)),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════
// STEP 4 — ORGANIZER DETAILS
// ════════════════════════════════════════════
class Step4Organizer extends StatefulWidget {
  final EventModel event;
  final File? organizerPhotoFile;
  final ValueChanged<File?> onPhotoChanged;

  const Step4Organizer({
    Key? key,
    required this.event,
    required this.organizerPhotoFile,
    required this.onPhotoChanged,
  }) : super(key: key);

  @override
  State<Step4Organizer> createState() => _Step4OrganizerState();
}

class _Step4OrganizerState extends State<Step4Organizer> {
  late Map<String, TextEditingController> _ctrls;

  @override
  void initState() {
    super.initState();
    final org = widget.event.organizer;
    _ctrls = {
      'name': TextEditingController(text: org.name),
      'organization': TextEditingController(text: org.organization),
      'bio': TextEditingController(text: org.bio),
      'email': TextEditingController(text: org.email),
      'phone': TextEditingController(text: org.phone),
      'website': TextEditingController(text: org.website),
    };
    _ctrls.forEach((key, ctrl) {
      ctrl.addListener(() {
        final org = widget.event.organizer;
        switch (key) {
          case 'name': org.name = ctrl.text; break;
          case 'organization': org.organization = ctrl.text; break;
          case 'bio': org.bio = ctrl.text; break;
          case 'email': org.email = ctrl.text; break;
          case 'phone': org.phone = ctrl.text; break;
          case 'website': org.website = ctrl.text; break;
        }
      });
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          icon: Icons.person_outline_rounded,
          title: 'Organizer Details',
          subtitle: 'Tell attendees who is hosting this event',
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('ORGANIZER PHOTO'),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final file = await pickImage();
                      if (file != null) widget.onPhotoChanged(file);
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: EventTheme.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: EventTheme.primary.withOpacity(0.3),
                            width: 2),
                        image: widget.organizerPhotoFile != null
                            ? DecorationImage(
                            image: FileImage(widget.organizerPhotoFile!),
                            fit: BoxFit.cover)
                            : null,
                      ),
                      child: widget.organizerPhotoFile == null
                          ? const Icon(Icons.add_a_photo_outlined,
                          color: EventTheme.primary, size: 28)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Profile Photo',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: EventTheme.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Upload a clear headshot or logo',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: EventTheme.textSecondary)),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final file = await pickImage();
                            if (file != null) widget.onPhotoChanged(file);
                          },
                          icon: const Icon(Icons.upload_rounded, size: 16),
                          label: const Text('Choose Photo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: EventTheme.primary,
                            side: const BorderSide(
                                color: EventTheme.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              EventTextField(
                label: 'Organizer Name *',
                hint: 'Your full name',
                controller: _ctrls['name']!,
                validator: (v) =>
                v == null || v.isEmpty ? 'Name is required' : null,
                prefixIcon: const Icon(Icons.person_outline,
                    color: EventTheme.textSecondary, size: 20),
              ),
              const SizedBox(height: 14),
              EventTextField(
                label: 'Organization / Company',
                hint: 'e.g. Acme Corp, Self-employed',
                controller: _ctrls['organization']!,
                prefixIcon: const Icon(Icons.business_center_outlined,
                    color: EventTheme.textSecondary, size: 20),
              ),
              const SizedBox(height: 14),
              EventTextField(
                label: 'Bio',
                hint: 'Brief introduction about yourself or your organization',
                controller: _ctrls['bio']!,
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('CONTACT INFORMATION'),
              EventTextField(
                label: 'Contact Email *',
                hint: 'contact@example.com',
                controller: _ctrls['email']!,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@')
                    ? 'Valid email required'
                    : null,
                prefixIcon: const Icon(Icons.email_outlined,
                    color: EventTheme.textSecondary, size: 20),
              ),
              const SizedBox(height: 14),
              EventTextField(
                label: 'Phone Number',
                hint: '+1 (555) 000-0000',
                controller: _ctrls['phone']!,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined,
                    color: EventTheme.textSecondary, size: 20),
              ),
              const SizedBox(height: 14),
              EventTextField(
                label: 'Website',
                hint: 'https://yourwebsite.com',
                controller: _ctrls['website']!,
                keyboardType: TextInputType.url,
                prefixIcon: const Icon(Icons.language_outlined,
                    color: EventTheme.textSecondary, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════
// STEP 5 — ATTENDEE SETTINGS
// ════════════════════════════════════════════
class Step5AttendeeSettings extends StatefulWidget {
  final EventModel event;
  const Step5AttendeeSettings({Key? key, required this.event}) : super(key: key);

  @override
  State<Step5AttendeeSettings> createState() => _Step5AttendeeSettingsState();
}

class _Step5AttendeeSettingsState extends State<Step5AttendeeSettings> {
  late TextEditingController _maxCtrl;
  late TextEditingController _minCtrl;

  @override
  void initState() {
    super.initState();
    _maxCtrl = TextEditingController(
        text: widget.event.attendeeSettings.maxAttendees.toString());
    _minCtrl = TextEditingController(
        text: widget.event.attendeeSettings.minAttendees.toString());
    _maxCtrl.addListener(() {
      widget.event.attendeeSettings.maxAttendees =
          int.tryParse(_maxCtrl.text) ?? 0;
    });
    _minCtrl.addListener(() {
      widget.event.attendeeSettings.minAttendees =
          int.tryParse(_minCtrl.text) ?? 0;
    });
  }

  @override
  void dispose() {
    _maxCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.event.attendeeSettings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          icon: Icons.people_outline_rounded,
          title: 'Attendee Settings',
          subtitle: 'Control who can join your event',
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('CAPACITY'),
              Row(
                children: [
                  Expanded(
                    child: EventTextField(
                      label: 'Max Attendees',
                      hint: '500',
                      controller: _maxCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      prefixIcon: const Icon(Icons.group_add_outlined,
                          color: EventTheme.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: EventTextField(
                      label: 'Min Attendees',
                      hint: '10',
                      controller: _minCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      prefixIcon: const Icon(Icons.group_outlined,
                          color: EventTheme.textSecondary, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ToggleCard(
                title: 'Approval Required',
                subtitle: 'Manually approve attendee registrations',
                value: settings.approvalRequired,
                onChanged: (v) =>
                    setState(() => settings.approvalRequired = v),
                icon: Icons.how_to_reg_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('PRIVACY SETTINGS'),
              PrivacySelector(
                selected: settings.privacy,
                onChanged: (v) => setState(() => settings.privacy = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════
// STEP 6 — TICKETS
// ════════════════════════════════════════════
class Step6Tickets extends StatefulWidget {
  final EventModel event;
  const Step6Tickets({Key? key, required this.event}) : super(key: key);

  @override
  State<Step6Tickets> createState() => _Step6TicketsState();
}

class _Step6TicketsState extends State<Step6Tickets> {
  void _addTicket() {
    setState(() {
      widget.event.tickets.add(TicketType(
          id: DateTime.now().millisecondsSinceEpoch.toString()));
    });
  }

  void _removeTicket(int index) {
    setState(() => widget.event.tickets.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          icon: Icons.confirmation_number_outlined,
          title: 'Tickets',
          subtitle: 'Set up ticketing for your event',
        ),
        SectionCard(
          child: ToggleCard(
            title: 'Paid Event',
            subtitle: 'Charge attendees for tickets',
            value: widget.event.isPaidEvent,
            onChanged: (v) => setState(() => widget.event.isPaidEvent = v),
            icon: Icons.attach_money_rounded,
            iconColor: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(height: 16),
        ...widget.event.tickets.asMap().entries.map((entry) {
          final idx = entry.key;
          final ticket = entry.value;
          return _TicketCard(
            key: ValueKey(ticket.id),
            ticket: ticket,
            index: idx,
            isPaid: widget.event.isPaidEvent,
            onRemove: () => _removeTicket(idx),
            onChanged: () => setState(() {}),
          );
        }).toList(),
        const SizedBox(height: 12),
        Center(
          child: AddMoreButton(
            label: 'Add Ticket Type',
            onPressed: _addTicket,
          ),
        ),
      ],
    );
  }
}

class _TicketCard extends StatefulWidget {
  final TicketType ticket;
  final int index;
  final bool isPaid;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _TicketCard({
    Key? key,
    required this.ticket,
    required this.index,
    required this.isPaid,
    required this.onRemove,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<_TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<_TicketCard> {
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _qtyCtrl;
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.ticket.name);
    _priceCtrl = TextEditingController(
        text: widget.ticket.price > 0 ? widget.ticket.price.toString() : '');
    _qtyCtrl = TextEditingController(
        text: widget.ticket.quantity > 0
            ? widget.ticket.quantity.toString()
            : '');
    _startCtrl = TextEditingController(text: widget.ticket.salesStartDate);
    _endCtrl = TextEditingController(text: widget.ticket.salesEndDate);
    _nameCtrl.addListener(() => widget.ticket.name = _nameCtrl.text);
    _priceCtrl.addListener(() =>
    widget.ticket.price = double.tryParse(_priceCtrl.text) ?? 0);
    _qtyCtrl.addListener(
            () => widget.ticket.quantity = int.tryParse(_qtyCtrl.text) ?? 0);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EventTheme.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: EventTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Ticket ${widget.index + 1}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: EventTheme.primary)),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Color(0xFFEF4444), size: 20),
                onPressed: widget.onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          EventTextField(
            label: 'Ticket Name',
            hint: 'e.g. General Admission, VIP',
            controller: _nameCtrl,
            prefixIcon: const Icon(Icons.confirmation_number_outlined,
                color: EventTheme.textSecondary, size: 20),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (widget.isPaid)
                Expanded(
                  child: EventTextField(
                    label: 'Price (\$)',
                    hint: '25.00',
                    controller: _priceCtrl,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(Icons.attach_money_rounded,
                        color: EventTheme.textSecondary, size: 20),
                  ),
                ),
              if (widget.isPaid) const SizedBox(width: 12),
              Expanded(
                child: EventTextField(
                  label: 'Quantity',
                  hint: '100',
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(Icons.numbers_rounded,
                      color: EventTheme.textSecondary, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
// STEP 7 — AGENDA
// ════════════════════════════════════════════
class Step7Agenda extends StatefulWidget {
  final EventModel event;
  const Step7Agenda({Key? key, required this.event}) : super(key: key);

  @override
  State<Step7Agenda> createState() => _Step7AgendaState();
}

class _Step7AgendaState extends State<Step7Agenda> {
  void _addItem() {
    setState(() {
      widget.event.agenda.add(
          AgendaItem(id: DateTime.now().millisecondsSinceEpoch.toString()));
    });
  }

  void _remove(int i) => setState(() => widget.event.agenda.removeAt(i));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          icon: Icons.view_timeline_outlined,
          title: 'Agenda',
          subtitle: 'Plan your event schedule',
        ),
        if (widget.event.agenda.isEmpty)
          SectionCard(
            child: Column(
              children: [
                const Icon(Icons.schedule_outlined,
                    color: EventTheme.textSecondary, size: 48),
                const SizedBox(height: 12),
                const Text('No agenda items yet',
                    style: TextStyle(
                        color: EventTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                const SizedBox(height: 4),
                const Text('Add sessions, breaks, and activities',
                    style: TextStyle(
                        color: EventTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                AddMoreButton(label: 'Add Agenda Item', onPressed: _addItem),
              ],
            ),
          ),
        ...widget.event.agenda.asMap().entries.map((e) => _AgendaCard(
          key: ValueKey(e.value.id),
          item: e.value,
          index: e.key,
          onRemove: () => _remove(e.key),
        )),
        if (widget.event.agenda.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Center(
              child: AddMoreButton(
                  label: 'Add Agenda Item', onPressed: _addItem),
            ),
          ),
      ],
    );
  }
}

class _AgendaCard extends StatefulWidget {
  final AgendaItem item;
  final int index;
  final VoidCallback onRemove;

  const _AgendaCard(
      {Key? key,
        required this.item,
        required this.index,
        required this.onRemove})
      : super(key: key);

  @override
  State<_AgendaCard> createState() => _AgendaCardState();
}

class _AgendaCardState extends State<_AgendaCard> {
  late TextEditingController _titleCtrl, _speakerCtrl, _startCtrl, _endCtrl, _descCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item.title);
    _speakerCtrl = TextEditingController(text: widget.item.speakerName);
    _startCtrl = TextEditingController(text: widget.item.startTime);
    _endCtrl = TextEditingController(text: widget.item.endTime);
    _descCtrl = TextEditingController(text: widget.item.description);
    _titleCtrl.addListener(() => widget.item.title = _titleCtrl.text);
    _speakerCtrl.addListener(() => widget.item.speakerName = _speakerCtrl.text);
    _startCtrl.addListener(() => widget.item.startTime = _startCtrl.text);
    _endCtrl.addListener(() => widget.item.endTime = _endCtrl.text);
    _descCtrl.addListener(() => widget.item.description = _descCtrl.text);
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl, _speakerCtrl, _startCtrl, _endCtrl, _descCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EventTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: EventTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('${widget.index + 1}',
                      style: const TextStyle(
                          color: EventTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Agenda Item', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                onPressed: widget.onRemove,
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EventTextField(label: 'Session Title', controller: _titleCtrl, hint: 'e.g. Opening Keynote'),
          const SizedBox(height: 10),
          EventTextField(label: 'Speaker Name', controller: _speakerCtrl, hint: 'Optional'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: EventTextField(label: 'Start Time', controller: _startCtrl, hint: '9:00 AM')),
            const SizedBox(width: 10),
            Expanded(child: EventTextField(label: 'End Time', controller: _endCtrl, hint: '10:00 AM')),
          ]),
          const SizedBox(height: 10),
          EventTextField(label: 'Description', controller: _descCtrl, maxLines: 3, hint: 'Brief description of this session'),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
// STEP 8 — SPEAKERS
// ════════════════════════════════════════════
class Step8Speakers extends StatefulWidget {
  final EventModel event;
  final Map<String, File> speakerPhotos;
  final Function(String id, File file) onSpeakerPhotoChanged;

  const Step8Speakers({
    Key? key,
    required this.event,
    required this.speakerPhotos,
    required this.onSpeakerPhotoChanged,
  }) : super(key: key);

  @override
  State<Step8Speakers> createState() => _Step8SpeakersState();
}

class _Step8SpeakersState extends State<Step8Speakers> {
  void _add() {
    setState(() {
      widget.event.speakers.add(Speaker(id: DateTime.now().millisecondsSinceEpoch.toString()));
    });
  }
  void _remove(int i) => setState(() => widget.event.speakers.removeAt(i));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          icon: Icons.record_voice_over_outlined,
          title: 'Speakers',
          subtitle: 'Introduce the people speaking at your event',
        ),
        if (widget.event.speakers.isEmpty)
          SectionCard(
            child: Column(
              children: [
                const Icon(Icons.mic_none_outlined, color: EventTheme.textSecondary, size: 48),
                const SizedBox(height: 12),
                const Text('No speakers added', style: TextStyle(color: EventTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                const Text('Add featured speakers for your event', style: TextStyle(color: EventTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                AddMoreButton(label: 'Add Speaker', onPressed: _add),
              ],
            ),
          ),
        ...widget.event.speakers.asMap().entries.map((e) => _SpeakerCard(
          key: ValueKey(e.value.id),
          speaker: e.value,
          index: e.key,
          photoFile: widget.speakerPhotos[e.value.id],
          onRemove: () => _remove(e.key),
          onPhotoChanged: (file) => widget.onSpeakerPhotoChanged(e.value.id, file),
        )),
        if (widget.event.speakers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Center(child: AddMoreButton(label: 'Add Speaker', onPressed: _add)),
          ),
      ],
    );
  }
}

class _SpeakerCard extends StatefulWidget {
  final Speaker speaker;
  final int index;
  final File? photoFile;
  final VoidCallback onRemove;
  final ValueChanged<File> onPhotoChanged;

  const _SpeakerCard({Key? key, required this.speaker, required this.index, this.photoFile, required this.onRemove, required this.onPhotoChanged}) : super(key: key);

  @override
  State<_SpeakerCard> createState() => _SpeakerCardState();
}

class _SpeakerCardState extends State<_SpeakerCard> {
  late TextEditingController _nameCtrl, _titleCtrl, _companyCtrl, _bioCtrl, _liCtrl, _twCtrl, _websiteCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.speaker;
    _nameCtrl = TextEditingController(text: s.name);
    _titleCtrl = TextEditingController(text: s.title);
    _companyCtrl = TextEditingController(text: s.company);
    _bioCtrl = TextEditingController(text: s.bio);
    _liCtrl = TextEditingController(text: s.linkedin);
    _twCtrl = TextEditingController(text: s.twitter);
    _websiteCtrl = TextEditingController(text: s.website);
    _nameCtrl.addListener(() => s.name = _nameCtrl.text);
    _titleCtrl.addListener(() => s.title = _titleCtrl.text);
    _companyCtrl.addListener(() => s.company = _companyCtrl.text);
    _bioCtrl.addListener(() => s.bio = _bioCtrl.text);
    _liCtrl.addListener(() => s.linkedin = _liCtrl.text);
    _twCtrl.addListener(() => s.twitter = _twCtrl.text);
    _websiteCtrl.addListener(() => s.website = _websiteCtrl.text);
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _titleCtrl, _companyCtrl, _bioCtrl, _liCtrl, _twCtrl, _websiteCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EventTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final f = await pickImage();
                  if (f != null) widget.onPhotoChanged(f);
                },
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: EventTheme.primaryLight,
                    shape: BoxShape.circle,
                    image: widget.photoFile != null
                        ? DecorationImage(image: FileImage(widget.photoFile!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: widget.photoFile == null
                      ? const Icon(Icons.add_a_photo_outlined, color: EventTheme.primary, size: 24)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Speaker ${widget.index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: EventTheme.textPrimary)),
                    const Text('Tap the circle to add photo',
                        style: TextStyle(fontSize: 12, color: EventTheme.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                onPressed: widget.onRemove,
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          EventTextField(label: 'Name *', controller: _nameCtrl, hint: 'Speaker full name'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: EventTextField(label: 'Title', controller: _titleCtrl, hint: 'CEO, Engineer...')),
            const SizedBox(width: 10),
            Expanded(child: EventTextField(label: 'Company', controller: _companyCtrl, hint: 'Company name')),
          ]),
          const SizedBox(height: 10),
          EventTextField(label: 'Bio', controller: _bioCtrl, maxLines: 3, hint: 'Brief speaker bio'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: EventTextField(label: 'LinkedIn', controller: _liCtrl, hint: 'linkedin.com/in/...')),
            const SizedBox(width: 10),
            Expanded(child: EventTextField(label: 'Twitter / X', controller: _twCtrl, hint: '@handle')),
          ]),
          const SizedBox(height: 10),
          EventTextField(label: 'Website', controller: _websiteCtrl, hint: 'https://...', keyboardType: TextInputType.url),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
// STEP 9 — MEDIA
// ════════════════════════════════════════════
class Step9Media extends StatefulWidget {
  final EventModel event;
  final List<File> galleryFiles;
  final ValueChanged<List<File>> onGalleryChanged;

  const Step9Media({
    Key? key,
    required this.event,
    required this.galleryFiles,
    required this.onGalleryChanged,
  }) : super(key: key);

  @override
  State<Step9Media> createState() => _Step9MediaState();
}

class _Step9MediaState extends State<Step9Media> {
  late TextEditingController _promoCtrl;

  @override
  void initState() {
    super.initState();
    _promoCtrl = TextEditingController(text: widget.event.promoVideo);
    _promoCtrl.addListener(() => widget.event.promoVideo = _promoCtrl.text);
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _addGalleryImage() async {
    final file = await pickImage();
    if (file != null) {
      widget.onGalleryChanged([...widget.galleryFiles, file]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          icon: Icons.photo_library_outlined,
          title: 'Media',
          subtitle: 'Add photos and videos to attract attendees',
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('EVENT GALLERY'),
              if (widget.galleryFiles.isNotEmpty)
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...widget.galleryFiles.asMap().entries.map((e) => Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(e.value, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4, right: 4,
                          child: GestureDetector(
                            onTap: () {
                              final updated = [...widget.galleryFiles];
                              updated.removeAt(e.key);
                              widget.onGalleryChanged(updated);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                              ),
                              child: const Icon(Icons.close, size: 14, color: Color(0xFFEF4444)),
                            ),
                          ),
                        ),
                      ],
                    )),
                    _AddGalleryTile(onTap: _addGalleryImage),
                  ],
                )
              else
                GestureDetector(
                  onTap: _addGalleryImage,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: EventTheme.border, width: 2),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: EventTheme.primary, size: 32),
                        SizedBox(height: 8),
                        Text('Add Gallery Images', style: TextStyle(color: EventTheme.primary, fontWeight: FontWeight.w600)),
                        Text('Tap to upload multiple photos', style: TextStyle(color: EventTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('PROMO VIDEO'),
              EventTextField(
                label: 'YouTube / Vimeo URL',
                hint: 'https://youtube.com/watch?v=...',
                controller: _promoCtrl,
                keyboardType: TextInputType.url,
                prefixIcon: const Icon(Icons.play_circle_outline, color: EventTheme.textSecondary, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('HASHTAGS'),
              TagInputWidget(
                tags: widget.event.hashtags,
                onTagsChanged: (tags) => setState(() => widget.event.hashtags = tags),
                label: 'Add Hashtags',
                hint: 'e.g. TechConf2024',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddGalleryTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddGalleryTile({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: EventTheme.primaryLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: EventTheme.primary.withOpacity(0.3)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: EventTheme.primary, size: 28),
            SizedBox(height: 4),
            Text('Add', style: TextStyle(fontSize: 11, color: EventTheme.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// STEP 10 — RULES & POLICIES
// ════════════════════════════════════════════
class Step10Rules extends StatefulWidget {
  final EventModel event;
  const Step10Rules({Key? key, required this.event}) : super(key: key);

  @override
  State<Step10Rules> createState() => _Step10RulesState();
}

class _Step10RulesState extends State<Step10Rules> {
  late Map<String, TextEditingController> _ctrls;

  static const ageOptions = ['All Ages', '13+', '16+', '18+', '21+'];
  static const dressCodes = ['No Dress Code', 'Smart Casual', 'Business Casual', 'Business Formal', 'Formal / Black Tie', 'Costume / Theme'];

  @override
  void initState() {
    super.initState();
    _ctrls = {
      'rules': TextEditingController(text: widget.event.rules),
      'whatToBring': TextEditingController(text: widget.event.whatToBring),
      'codeOfConduct': TextEditingController(text: widget.event.codeOfConduct),
    };
    _ctrls['rules']!.addListener(() => widget.event.rules = _ctrls['rules']!.text);
    _ctrls['whatToBring']!.addListener(() => widget.event.whatToBring = _ctrls['whatToBring']!.text);
    _ctrls['codeOfConduct']!.addListener(() => widget.event.codeOfConduct = _ctrls['codeOfConduct']!.text);
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          icon: Icons.gavel_rounded,
          title: 'Rules & Policies',
          subtitle: 'Set expectations for your attendees',
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('EVENT RULES'),
              EventTextField(label: 'Event Rules', hint: 'List the rules attendees must follow...', controller: _ctrls['rules']!, maxLines: 5),
              const SizedBox(height: 18),
              const SectionLabel('AGE RESTRICTION'),
              EventDropdown<String>(
                label: 'Age Restriction',
                value: widget.event.ageRestriction.isEmpty ? 'All Ages' : widget.event.ageRestriction,
                items: ageOptions.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                onChanged: (v) => setState(() => widget.event.ageRestriction = v ?? ''),
                prefixIcon: const Icon(Icons.person_outlined, color: EventTheme.textSecondary, size: 20),
              ),
              const SizedBox(height: 18),
              const SectionLabel('DRESS CODE'),
              EventDropdown<String>(
                label: 'Dress Code',
                value: widget.event.dressCode.isEmpty ? 'No Dress Code' : widget.event.dressCode,
                items: dressCodes.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => widget.event.dressCode = v ?? ''),
                prefixIcon: const Icon(Icons.checkroom_outlined, color: EventTheme.textSecondary, size: 20),
              ),
              const SizedBox(height: 18),
              const SectionLabel('WHAT TO BRING'),
              EventTextField(label: 'What to Bring', hint: 'Items attendees should bring...', controller: _ctrls['whatToBring']!, maxLines: 3),
              const SizedBox(height: 18),
              const SectionLabel('CODE OF CONDUCT'),
              EventTextField(label: 'Code of Conduct', hint: 'Expected behavior at your event...', controller: _ctrls['codeOfConduct']!, maxLines: 4),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════
// STEP 11 — NOTIFICATIONS
// ════════════════════════════════════════════
class Step11Notifications extends StatefulWidget {
  final EventModel event;
  const Step11Notifications({Key? key, required this.event}) : super(key: key);

  @override
  State<Step11Notifications> createState() => _Step11NotificationsState();
}

class _Step11NotificationsState extends State<Step11Notifications> {
  @override
  Widget build(BuildContext context) {
    final n = widget.event.notifications;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Keep your attendees informed',
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('REMINDER NOTIFICATIONS'),
              ToggleCard(
                title: '24-Hour Reminder',
                subtitle: 'Send reminder 24 hours before event',
                value: n.reminder24h,
                onChanged: (v) => setState(() => n.reminder24h = v),
                icon: Icons.alarm_outlined,
              ),
              const SizedBox(height: 10),
              ToggleCard(
                title: '1-Hour Reminder',
                subtitle: 'Send reminder 1 hour before event',
                value: n.reminder1h,
                onChanged: (v) => setState(() => n.reminder1h = v),
                icon: Icons.alarm_on_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('NOTIFICATION CHANNELS'),
              ToggleCard(
                title: 'Email Notifications',
                subtitle: 'Send event updates via email',
                value: n.email,
                onChanged: (v) => setState(() => n.email = v),
                icon: Icons.email_outlined,
                iconColor: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 10),
              ToggleCard(
                title: 'Push Notifications',
                subtitle: 'Send push notifications to mobile',
                value: n.push,
                onChanged: (v) => setState(() => n.push = v),
                icon: Icons.phone_android_outlined,
                iconColor: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════
// STEP 12 — PUBLISH
// ════════════════════════════════════════════
class Step12Publish extends StatefulWidget {
  final EventModel event;
  const Step12Publish({Key? key, required this.event}) : super(key: key);

  @override
  State<Step12Publish> createState() => _Step12PublishState();
}

class _Step12PublishState extends State<Step12Publish> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          icon: Icons.rocket_launch_rounded,
          title: 'Publish Event',
          subtitle: "You're almost there! Review and publish your event",
          iconColor: Color(0xFFFF6584),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Almost Ready to Launch! 🚀",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    SizedBox(height: 4),
                    Text("Review your settings below before publishing.",
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('EVENT VISIBILITY'),
              PrivacySelector(
                selected: widget.event.visibility,
                onChanged: (v) => setState(() => widget.event.visibility = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('PUBLISH STATUS'),
              _StatusOption(
                title: 'Save as Draft',
                subtitle: 'Not visible publicly, edit anytime',
                icon: Icons.edit_note_rounded,
                isSelected: widget.event.status == 'draft',
                color: const Color(0xFFF59E0B),
                onTap: () => setState(() => widget.event.status = 'draft'),
              ),
              const SizedBox(height: 10),
              _StatusOption(
                title: 'Publish Now',
                subtitle: 'Make this event live immediately',
                icon: Icons.public_rounded,
                isSelected: widget.event.status == 'published',
                color: EventTheme.success,
                onTap: () => setState(() => widget.event.status = 'published'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: ToggleCard(
            title: 'Featured Event',
            subtitle: 'Request to feature this event on the homepage',
            value: widget.event.featured,
            onChanged: (v) => setState(() => widget.event.featured = v),
            icon: Icons.star_border_rounded,
            iconColor: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }
}

class _StatusOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _StatusOption({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : EventTheme.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : EventTheme.textSecondary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: isSelected ? color : EventTheme.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 12.5, color: EventTheme.textSecondary)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}