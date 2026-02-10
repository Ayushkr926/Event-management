import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_provider.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Map<String, String>> categories = [
    {"title": "Live Shows", "image": "assets/images/live.jpeg"},
    {"title": "Tourism", "image": "assets/images/Tourism.jpeg"},
    {"title": "Sports", "image": "assets/images/Sports.jpeg"},
    {"title": "Concerts", "image": "assets/images/live.jpeg"},
    {"title": "Comedy", "image": "assets/images/comedy.png"},
    {"title": "Tech", "image": "assets/images/Tech.jpeg"},
  ];

  bool islike = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const SizedBox(height: 12),
                    _header(),
                    const SizedBox(height: 6),
                    _locationSelector(),
                    const SizedBox(height: 20),
                    _searchBar(),
                    const SizedBox(height: 26),
                    _sectionTitle("Categories"),
                    const SizedBox(height: 12),
                    _categoryChips(),
                    const SizedBox(height: 26),
                    _sectionTitle("Trending This Week"),
                    const SizedBox(height: 14),
                    _trendingCard(context,islike),
                    const SizedBox(height: 30),
                    _sectionTitle("Events Near You"),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // EVENTS LIST
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => eventCard(isFree: true,index:index),
                  childCount: 6,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundImage: AssetImage("assets/images/profile.jpg"),
        ),
        const Spacer(),
        Column(
          children: const [
            Text("Welcome Back",
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            Text("Ayush Kumar",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const Spacer(),
        _iconButton(Icons.card_giftcard),
      ],
    );
  }

  Widget _locationSelector() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.location_on, size: 16, color: Colors.white54),
          SizedBox(width: 4),
          Text("New Delhi, India",
              style: TextStyle(color: Colors.white54)),
          Icon(Icons.keyboard_arrow_down, color: Colors.white54),
        ],
      ),
    );
  }

  // ================= SEARCH =================

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xff1E1E2A),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: Colors.white54),
                SizedBox(width: 10),
                Text("Search events...",
                    style: TextStyle(color: Colors.white54)),
                Spacer(),
                Icon(Icons.mic, color: Colors.white38),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _iconButton(Icons.tune),
      ],
    );
  }

  // ================= CATEGORY =================

  Widget _categoryChips() {
    return SizedBox(
      height: 46,
      child: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final active = provider.selectedIndex == index;
              return GestureDetector(
                onTap: () => provider.selectCategory(index),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xffF2F862)
                        : const Color(0xff1E1E2A),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage:
                        AssetImage(categories[index]["image"]!),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        categories[index]["title"]!,
                        style: TextStyle(
                          color: active ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= TRENDING =================

  Widget _trendingCard(BuildContext context,bool islike) {
    return Container(
      height: 380,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff181818),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Image.asset("assets/images/home1.jpg",
                      width: double.infinity, fit: BoxFit.cover),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _badge("Trending"),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      height: 46,
                      width: 46,
                      decoration: const BoxDecoration(
                        color: Color(0xff1E1E2A),
                        shape: BoxShape.circle,
                      ),
                      child: Consumer<HomeProvider>(
                        builder: (context, provider, _) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: provider.toggleLike,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(scale: animation, child: child),
                              child: Icon(
                                provider.isLike
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey(provider.isLike),
                                color: provider.isLike
                                    ? Colors.red
                                    : Colors.white54,
                                size: 26,
                              ),
                            ),
                          );
                        },
                      ),

                    )
                  ),




                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "May",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "20",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),



                ],
              ),
            ),
          ),



          const SizedBox(height: 10,),

          Row(
            children: [
              Column(
                children: [
                  const Text(
                    "Blackpink Concert",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "📍 123 Main Street, New York",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Text(
                "\$40.23",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20,),
          Row(
            children: [
              SizedBox(
                height: 44,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
// 🟡 COUNT PILL
                    Container(
                      height: 40,
                      width: 40, // 🔥 same as height
                      decoration: const BoxDecoration(
                        color: Color(0xffF2F862),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "1.2K",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),


// 👤 AVATAR 1
                    Positioned(
                      left: 32,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage("assets/images/onboarding1.jpg"),
                        ),
                      ),
                    ),

// 👤 AVATAR 2
                    Positioned(
                      left: 50,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage("assets/images/onboarding3.jpg"),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 70,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage("assets/images/onboarding4.jpg"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: MediaQuery.sizeOf(context).width*0.4,
                padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xffF2F862),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: const Text(
                    "Join now",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),


        ],
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



  // ================= COMMON =================

  Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const Text("See all", style: TextStyle(color: Colors.white54)),
      ],
    );
  }

  Widget _badge(String text, {Color color = Colors.redAccent}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
      BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: const TextStyle(fontSize: 10, color: Colors.white)),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      height: 46,
      width: 46,
      decoration: const BoxDecoration(
        color: Color(0xff1E1E2A),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xffF2F862)),
    );
  }

  Widget _bottomNav() {
    return Container(
      height: 70,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1E1E2A),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(Icons.home, color: Colors.black),
          Icon(Icons.search, color: Colors.white54),
          Icon(Icons.confirmation_num, color: Colors.white54),
          Icon(Icons.person, color: Colors.white54),
        ],
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
