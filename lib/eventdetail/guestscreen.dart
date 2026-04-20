import 'package:event_management/utils/color.dart';
import 'package:flutter/material.dart';

import 'model/guestmodel.dart';

class GuestSection extends StatelessWidget {
  final List<Guest> guests;

  const GuestSection({super.key, required this.guests});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardcolor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 10,),
              Icon(
                Icons.person_2_outlined,
                size: 22,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                "Guests",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.06),
          ),

          const SizedBox(height: 16),
          SizedBox(
            height:160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 1),
              itemCount: guests.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final guest = guests[index];
                return _GuestCard(guest: guest);
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _GuestCard extends StatelessWidget {
  final Guest guest;

  const _GuestCard({required this.guest});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.seccard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // 👤 Guest Image
          CircleAvatar(
            radius: 42,
            backgroundImage: NetworkImage(guest.image),
          ),
          const SizedBox(height: 12),

          // 👨 Name
          Text(
            guest.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // 🏷 Designation
          Text(
            guest.designation,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
