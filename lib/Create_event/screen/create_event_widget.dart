// lib/widgets/create_event_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// THEME CONSTANTS
// ─────────────────────────────────────────────
class EventTheme {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFFEEECFF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color surface = Color(0xFFFAFAFF);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);



  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static InputDecoration inputDecoration(String label,
      {String? hint, Widget? prefix, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefix,
      suffixIcon: suffix,
      labelStyle: const TextStyle(
          color: EventTheme.textSecondary, fontWeight: FontWeight.w500),
      floatingLabelStyle:
      const TextStyle(color: EventTheme.primary, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: EventTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: EventTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: EventTheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP HEADER WIDGET
// ─────────────────────────────────────────────
class StepHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;

  const StepHeader({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: (iconColor ?? EventTheme.primary).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon,
                color: iconColor ?? EventTheme.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: EventTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 13.5,
                        color: EventTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STYLED TEXT FIELD
// ─────────────────────────────────────────────
class EventTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  const EventTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: inputFormatters,
      style: const TextStyle(
          color: EventTheme.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15),
      decoration: EventTheme.inputDecoration(label,
          hint: hint, prefix: prefixIcon, suffix: suffixIcon),
    );
  }
}

// ─────────────────────────────────────────────
// STYLED DROPDOWN
// ─────────────────────────────────────────────
class EventDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;

  const EventDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: EventTheme.primary),
      style: const TextStyle(
          color: EventTheme.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15),
      decoration: EventTheme.inputDecoration(label, prefix: prefixIcon),
    );
  }
}

// ─────────────────────────────────────────────
// TOGGLE CARD (Switch Row)
// ─────────────────────────────────────────────
class ToggleCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final Color? iconColor;

  const ToggleCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: value
            ? EventTheme.primary.withOpacity(0.05)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
          value ? EventTheme.primary.withOpacity(0.3) : EventTheme.border,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon,
                color: value
                    ? (iconColor ?? EventTheme.primary)
                    : EventTheme.textSecondary,
                size: 22),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: value
                            ? EventTheme.textPrimary
                            : EventTheme.textSecondary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 12.5,
                          color: EventTheme.textSecondary)),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: EventTheme.primary,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION CARD
// ─────────────────────────────────────────────
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const SectionCard({Key? key, required this.child, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: EventTheme.cardDecoration,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: EventTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAG INPUT WIDGET
// ─────────────────────────────────────────────
class TagInputWidget extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;
  final String label;
  final String hint;

  const TagInputWidget({
    Key? key,
    required this.tags,
    required this.onTagsChanged,
    this.label = 'Tags',
    this.hint = 'Type and press Enter',
  }) : super(key: key);

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  final _controller = TextEditingController();

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isNotEmpty && !widget.tags.contains(tag)) {
      final updated = [...widget.tags, tag];
      widget.onTagsChanged(updated);
      _controller.clear();
    }
  }

  void _removeTag(String tag) {
    final updated = widget.tags.where((t) => t != tag).toList();
    widget.onTagsChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          style: const TextStyle(
              color: EventTheme.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 15),
          decoration: EventTheme.inputDecoration(widget.label,
              hint: widget.hint,
              suffix: IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: EventTheme.primary),
                onPressed: () => _addTag(_controller.text),
              )),
          onFieldSubmitted: _addTag,
          textInputAction: TextInputAction.done,
        ),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags
                .map((tag) => _TagChip(
              label: tag,
              onDeleted: () => _removeTag(tag),
            ))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _TagChip({Key? key, required this.label, required this.onDeleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: EventTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EventTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  color: EventTheme.primary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(Icons.close,
                size: 15, color: EventTheme.primary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EVENT TYPE SELECTOR
// ─────────────────────────────────────────────
class EventTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const EventTypeSelector({
    Key? key,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  static const types = [
    {'value': 'in-person', 'label': 'In-Person', 'icon': Icons.location_on},
    {'value': 'online', 'label': 'Online', 'icon': Icons.videocam},
    {'value': 'hybrid', 'label': 'Hybrid', 'icon': Icons.device_hub},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: types.map((type) {
        final isSelected = selected == type['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(type['value'] as String),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? EventTheme.primary
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? EventTheme.primary
                      : EventTheme.border,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    type['icon'] as IconData,
                    color: isSelected ? Colors.white : EventTheme.textSecondary,
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type['label'] as String,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : EventTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// PRIVACY SELECTOR
// ─────────────────────────────────────────────
class PrivacySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const PrivacySelector({
    Key? key,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  static const options = [
    {
      'value': 'public',
      'label': 'Public',
      'desc': 'Visible to everyone',
      'icon': Icons.public
    },
    {
      'value': 'private',
      'label': 'Private',
      'desc': 'Hidden from search',
      'icon': Icons.lock_outline
    },
    {
      'value': 'invite-only',
      'label': 'Invite Only',
      'desc': 'By invitation only',
      'icon': Icons.mail_outline
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((opt) {
        final isSelected = selected == opt['value'];
        return GestureDetector(
          onTap: () => onChanged(opt['value'] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? EventTheme.primaryLight
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? EventTheme.primary
                    : EventTheme.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(opt['icon'] as IconData,
                    color: isSelected
                        ? EventTheme.primary
                        : EventTheme.textSecondary,
                    size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opt['label'] as String,
                          style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? EventTheme.primary
                                  : EventTheme.textPrimary)),
                      Text(opt['desc'] as String,
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: EventTheme.textSecondary)),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle,
                      color: EventTheme.primary, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// STEP PROGRESS INDICATOR
// ─────────────────────────────────────────────
class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressBar({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: const TextStyle(
                  fontSize: 12.5,
                  color: EventTheme.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              '${(progress * 100).round()}% complete',
              style: const TextStyle(
                  fontSize: 12.5,
                  color: EventTheme.primary,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor:
            const AlwaysStoppedAnimation<Color>(EventTheme.primary),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// IMAGE PICKER CARD
// ─────────────────────────────────────────────
class ImagePickerCard extends StatelessWidget {
  final String label;
  final String? imagePath;
  final VoidCallback onPickImage;
  final VoidCallback? onRemove;
  final double height;
  final String emptyIcon;

  const ImagePickerCard({
    Key? key,
    required this.label,
    this.imagePath,
    required this.onPickImage,
    this.onRemove,
    this.height = 180,
    this.emptyIcon = '🖼️',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: imagePath != null
                ? EventTheme.primary.withOpacity(0.4)
                : EventTheme.border,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: imagePath != null
            ? Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildEmpty(),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  _ActionButton(
                    icon: Icons.edit,
                    onTap: onPickImage,
                  ),
                  if (onRemove != null) ...[
                    const SizedBox(width: 6),
                    _ActionButton(
                      icon: Icons.delete_outline,
                      onTap: onRemove!,
                      color: Colors.red,
                    ),
                  ],
                ],
              ),
            ),
          ],
        )
            : _buildEmpty(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: EventTheme.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_photo_alternate_outlined,
              color: EventTheme.primary, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: EventTheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap to upload an image',
          style: TextStyle(fontSize: 12, color: EventTheme.textSecondary),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.color = EventTheme.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ADD MORE BUTTON
// ─────────────────────────────────────────────
class AddMoreButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AddMoreButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_circle_outline, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: EventTheme.primary,
        side: const BorderSide(color: EventTheme.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NAVIGATION BUTTONS
// ─────────────────────────────────────────────
class StepNavigationButtons extends StatelessWidget {
  final bool isFirstStep;
  final bool isLastStep;
  final bool isLoading;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback? onSaveDraft;

  const StepNavigationButtons({
    Key? key,
    required this.isFirstStep,
    required this.isLastStep,
    required this.isLoading,
    required this.onPrev,
    required this.onNext,
    this.onSaveDraft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onPrev,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: EventTheme.textSecondary,
                  side: const BorderSide(color: EventTheme.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: EventTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastStep ? 'Publish Event' : 'Continue',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastStep
                        ? Icons.rocket_launch_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}