import 'package:event_management/Screen/ticket_screen.dart';
import 'package:flutter/material.dart';

import '../utils/color.dart';

class FloatingBottomActions extends StatefulWidget {
  const FloatingBottomActions({super.key});

  @override
  State<FloatingBottomActions> createState() =>
      _FloatingBottomActionsState();
}

class _FloatingBottomActionsState extends State<FloatingBottomActions> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 20,
      child: Row(
        children: [
          // 👉 Slide to Book
          Expanded(
            child: _DarkSlideButton(
              onBooked: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TicketsScreen()));
              },
            ),
          ),

          const SizedBox(width: 14),

          // ❤️ Like Button (RIGHT)
          GestureDetector(
            onTap: () => setState(() => isLiked = !isLiked),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLiked
                    ? AppColors.primary
                    : AppColors.seccard,
                boxShadow: [
                  if (isLiked)
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 16,
                    ),
                ],
              ),
              child: Icon(
                isLiked
                    ? Icons.favorite
                    : Icons.favorite_border_rounded,
                color: isLiked
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _DarkSlideButton extends StatefulWidget {
  final VoidCallback onBooked;

  const _DarkSlideButton({required this.onBooked});

  @override
  State<_DarkSlideButton> createState() => _DarkSlideButtonState();
}

class _DarkSlideButtonState extends State<_DarkSlideButton> {
  double dragX = 0;
  bool booked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: booked ? AppColors.seccard : AppColors.primaryDark,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: booked ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Center(
            child: Text(
              booked ? "Booked ✔" : "Slide to Book",
              style: TextStyle(
                color: booked
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.4,
              ),
            ),
          ),

          Positioned(
            left: dragX,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (!booked) {
                  setState(() {
                    dragX += details.delta.dx;
                    dragX = dragX.clamp(0, 200);
                  });
                }
              },
              onHorizontalDragEnd: (_) {
                if (dragX > 190) {
                  setState(() {
                    dragX = 200;
                    booked = true;
                  });
                  widget.onBooked();
                } else {
                  setState(() => dragX = 0);
                }
              },
              child: Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: AppColors.primary.withOpacity(0.6),
                  //     blurRadius: 14,
                  //   ),
                  //
                  // ],
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
