// lib/screens/create_event_screen.dart
// Main multi-step Create Event screen

import 'dart:io';
import 'package:flutter/material.dart';

import '../model/event_model.dart';
import '../service/firebase_event_service.dart';
import 'create_event_widget.dart';
import 'event_steps.dart';


class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  // ── State ──────────────────────────────────
  final PageController _pageController = PageController();
  final List<GlobalKey<FormState>> _formKeys =
  List.generate(12, (_) => GlobalKey<FormState>());
  int _currentStep = 0;
  bool _isLoading = false;

  // ── Data ───────────────────────────────────
  final EventModel _event = EventModel();
  final FirebaseEventService _service = FirebaseEventService();

  // Media files
  File? _bannerFile;
  File? _organizerPhotoFile;
  final Map<String, File> _speakerPhotos = {};
  final List<File> _galleryFiles = [];

  // ── Step Config ────────────────────────────
  static const _stepTitles = [
    'Basic Info',
    'Date & Time',
    'Location',
    'Organizer',
    'Attendees',
    'Tickets',
    'Agenda',
    'Speakers',
    'Media',
    'Rules',
    'Notifications',
    'Publish',
  ];

  static const _stepIcons = [
    Icons.info_outline_rounded,
    Icons.calendar_month_outlined,
    Icons.place_outlined,
    Icons.person_outline_rounded,
    Icons.people_outline_rounded,
    Icons.confirmation_number_outlined,
    Icons.view_timeline_outlined,
    Icons.record_voice_over_outlined,
    Icons.photo_library_outlined,
    Icons.gavel_rounded,
    Icons.notifications_outlined,
    Icons.rocket_launch_rounded,
  ];

  // ── Navigation ─────────────────────────────
  void _nextStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? true) {
      if (_currentStep < 11) {
        setState(() => _currentStep++);
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _publishEvent();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  // ── Submit ─────────────────────────────────
  Future<void> _publishEvent() async {
    setState(() => _isLoading = true);
    try {
      final docId = await _service.createEventWithMedia(
        event: _event,
        bannerImageFile: _bannerFile,
        organizerPhotoFile: _organizerPhotoFile,
        speakerPhotos: _speakerPhotos,
        galleryFiles: _galleryFiles,
      );
      if (mounted) {
        _showSuccessDialog(docId);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String eventId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: EventTheme.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: EventTheme.success, size: 44),
              ),
              const SizedBox(height: 20),
              const Text('Event Created! 🎉',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                _event.status == 'published'
                    ? 'Your event is now live and visible to attendees.'
                    : 'Your event has been saved as a draft.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: EventTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: EventTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('ID: $eventId',
                    style: const TextStyle(
                        fontSize: 11,
                        color: EventTheme.primary,
                        fontFamily: 'monospace')),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.of(context).pop(); // back to prev screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EventTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text('Back to Dashboard',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ─────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EventTheme.surface,
      body: Column(
        children: [
          _buildAppBar(),
          _buildStepChips(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _buildPages(),
            ),
          ),
          StepNavigationButtons(
            isFirstStep: _currentStep == 0,
            isLastStep: _currentStep == 11,
            isLoading: _isLoading,
            onPrev: _prevStep,
            onNext: _nextStep,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: EventTheme.textPrimary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Create Event',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: EventTheme.textPrimary),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      setState(() => _event.status = 'draft');
                      await _publishEvent();
                    },
                    icon: const Icon(Icons.save_outlined, size: 16),
                    label: const Text('Save Draft'),
                    style: TextButton.styleFrom(
                        foregroundColor: EventTheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StepProgressBar(
                    currentStep: _currentStep, totalSteps: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepChips() {
    return Container(
      height: 52,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _stepTitles.length,
        itemBuilder: (_, i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return GestureDetector(
            onTap: () {
              if (i <= _currentStep) {
                setState(() => _currentStep = i);
                _pageController.jumpToPage(i);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? EventTheme.primary
                    : isDone
                    ? EventTheme.primaryLight
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? EventTheme.primary
                      : isDone
                      ? EventTheme.primary.withOpacity(0.3)
                      : EventTheme.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDone)
                    const Icon(Icons.check_rounded,
                        color: EventTheme.primary, size: 13)
                  else
                    Icon(_stepIcons[i],
                        size: 13,
                        color: isActive
                            ? Colors.white
                            : EventTheme.textSecondary),
                  const SizedBox(width: 5),
                  Text(
                    _stepTitles[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.white
                          : isDone
                          ? EventTheme.primary
                          : EventTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPages() {
    return [
      _buildPage(0, Step1BasicInfo(event: _event, bannerFile: _bannerFile, onBannerChanged: (f) => setState(() => _bannerFile = f))),
      _buildPage(1, Step2DateTime(event: _event)),
      _buildPage(2, Step3Location(event: _event)),
      _buildPage(3, Step4Organizer(event: _event, organizerPhotoFile: _organizerPhotoFile, onPhotoChanged: (f) => setState(() => _organizerPhotoFile = f))),
      _buildPage(4, Step5AttendeeSettings(event: _event)),
      _buildPage(5, Step6Tickets(event: _event)),
      _buildPage(6, Step7Agenda(event: _event)),
      _buildPage(7, Step8Speakers(event: _event, speakerPhotos: _speakerPhotos, onSpeakerPhotoChanged: (id, f) => setState(() => _speakerPhotos[id] = f))),
      _buildPage(8, Step9Media(event: _event, galleryFiles: _galleryFiles, onGalleryChanged: (files) => setState(() { _galleryFiles.clear(); _galleryFiles.addAll(files); }))),
      _buildPage(9, Step10Rules(event: _event)),
      _buildPage(10, Step11Notifications(event: _event)),
      _buildPage(11, Step12Publish(event: _event)),
    ];
  }

  Widget _buildPage(int index, Widget child) {
    return Form(
      key: _formKeys[index],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}