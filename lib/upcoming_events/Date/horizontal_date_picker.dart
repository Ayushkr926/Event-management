import 'package:event_management/eventdetail/event_detailscreen.dart';
import 'package:event_management/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Create_event/model/event_model.dart';
import '../event_provider.dart';
import 'date_provider.dart';



class HorizontalDatePicker extends StatefulWidget {
  const HorizontalDatePicker({super.key});

  @override
  State<HorizontalDatePicker> createState() => _HorizontalDatePickerState();
}

class _HorizontalDatePickerState extends State<HorizontalDatePicker> {
  final ScrollController _dateScrollController = ScrollController();

  void _scrollToSelected(DateProvider provider) {
    final index = provider.daysInMonth.indexWhere(
          (d) => DateUtils.isSameDay(d, provider.selectedDate),
    );

    if (index != -1) {
      _dateScrollController.animateTo(
        index * 76.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DateProvider>();

    return Scaffold(
      backgroundColor: Colors.black,

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: _BackButton(),
        title: const Text(
          "Events",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _HelpButton(),
          )
        ],
      ),

      /// ================= BODY =================
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            /// Date Picker Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Month Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy')
                              .format(provider.currentMonth),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            _navButton(
                              icon: Icons.chevron_left,
                              onTap: () {
                                provider.changeMonth(-1);
                                _scrollToSelected(provider);
                              },
                            ),
                            _navButton(
                              icon: Icons.chevron_right,
                              onTap: () {
                                provider.changeMonth(1);
                                _scrollToSelected(provider);
                              },
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// Horizontal Dates
                    SizedBox(
                      height: 96,
                      child: ListView.builder(
                        controller: _dateScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: provider.daysInMonth.length,
                        itemBuilder: (context, index) {
                          final date = provider.daysInMonth[index];
                          final isToday = DateUtils.isSameDay(
                              date, DateTime.now());
                          final isSelected = DateUtils.isSameDay(
                              date, provider.selectedDate);

                          return GestureDetector(
                            onTap: () {
                              provider.selectDate(date);
                              _scrollToSelected(provider);
                            },
                            child: AnimatedContainer(
                              duration:
                              const Duration(milliseconds: 250),
                              width: 68,
                              margin:
                              const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE7F44D)
                                    : Colors.transparent,
                                borderRadius:
                                BorderRadius.circular(40),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFE7F44D)
                                      : Colors.white24,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [


                                  Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat('EEE').format(date),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (isToday && !isSelected)
                                    const Padding(
                                      padding:
                                      EdgeInsets.only(top: 4),
                                      child: CircleAvatar(
                                        radius: 3,
                                        backgroundColor:
                                        Color(0xFFE7F44D),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// ================= EVENTS LIST =================
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: Consumer2<DateProvider, EventProvider>(
                builder: (context, dateProvider, eventProvider, _) {
                  final events = eventProvider.filteredEventsByDate(dateProvider.selectedDate);


                  if (events.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Center(
                          child: Text(
                            "No events on this date",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final event = events[index];
                        return eventCardFromModel(event, index);
                      },
                      childCount: events.length,
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  // ================= EVENT CARD =================

  Widget eventCard({bool isFree = true,required int index}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color : index==0?Color(0xffF3FF5A):Color(0xff181818),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      "assets/images/onboarding5.jpg",
                      height: 54,
                      width: 54,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 10,),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "Redsketch Academy",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: index!=0?Color(0xffc6c6c5):Color(0xff181818),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Video Editing",
                              style: TextStyle(
                                fontSize: 14,
                                color: index!=0?Color(0xffc6c6c5):Color(0xff181818),
                              ),
                            ),
                          ])),
                  const SizedBox(width: 10,),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(10),
                    decoration:  BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff222222),
                    ),
                    child: Icon(Icons.arrow_outward,color: Colors.white,),
                  ),

                ],
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  /// Left section (Time + Location)
                  Expanded(
                    child: Row(
                      children:  [
                        Icon(Icons.access_time, size: 16,color: index!=0?Color(0xffc6c6c5):Color(0xff181818),),
                        SizedBox(width: 6),
                        Text(
                          "08:00 AM",
                          style: TextStyle(fontSize: 13,color: index!=0?Color(0xffc6c6c5):Color(0xff181818),),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.location_on_outlined, size: 16,color: index!=0?Color(0xffc6c6c5):Color(0xff181818),),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Valencia, otra calle",
                            style: TextStyle(fontSize: 13,color: index!=0?Color(0xffc6c6c5):Color(0xff181818),),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// Right section (Avatars)
                  SizedBox(
                    height: 44,
                    width: 100,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: const [
                        _Avatar(left: 0, image: "assets/images/onboarding1.jpg"),
                        _Avatar(left: 18, image: "assets/images/onboarding3.jpg"),
                        Positioned(left: 36, child: _CountCircle()),
                      ],
                    ),
                  ),
                ],
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget eventCardFromModel(EventModel event, int index) {
    final isHighlighted = index == 0;

    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>EventDetail(event: event,)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xffF3FF5A)
              : const Color(0xff181818),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    event.bannerImage,
                    height: 54,
                    width: 54,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isHighlighted
                              ? Colors.black
                              : const Color(0xffc6c6c5),
                        ),
                      ),
                      Text(
                        event.category,
                        style: TextStyle(
                          fontSize: 14,
                          color: isHighlighted
                              ? Colors.black
                              : const Color(0xffc6c6c5),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_outward, color: Colors.white),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 16,
                    color: isHighlighted ? Colors.black : Colors.white70),
                const SizedBox(width: 6),
                Text(event.startDate,
                    style: TextStyle(
                        color:
                        isHighlighted ? Colors.black : Colors.white70)),
                const SizedBox(width: 12),
                Icon(Icons.location_on_outlined,
                    size: 16,
                    color: isHighlighted ? Colors.black : Colors.white70),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location as String,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color:
                        isHighlighted ? Colors.black : Colors.white70),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _navButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      splashRadius: 22,
      icon: Icon(icon, color: Colors.white),
      onPressed: onTap,
    );
  }
}


class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    );
  }
}

class _HelpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: AppColors.surface,
      child: Container(
        height: 26,
        width: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Icon(
          Icons.question_mark,
          size: 15,
          color: AppColors.primary,
        ),
      ),
    );
  }
}




///===========================Avatar========================

class _Avatar extends StatelessWidget {
  final double left;
  final String image;

  const _Avatar({required this.left, required this.image});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      child: CircleAvatar(
        radius: 15,
        backgroundColor: Colors.black,
        child: CircleAvatar(
          radius: 15,
          backgroundImage: AssetImage(image),
        ),
      ),
    );
  }
}



class _CountCircle extends StatelessWidget {
  const _CountCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      decoration:  BoxDecoration(
          color: Color(0xffF2F862),
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white
          )
      ),
      alignment: Alignment.center,
      child: const Text(
        "1.2K",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
