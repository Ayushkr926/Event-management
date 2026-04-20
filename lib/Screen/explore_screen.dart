import 'dart:async';
import 'package:event_management/Screen/search-screen.dart';
import 'package:event_management/eventdetail/floatingbookbuttom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../floatingbottomnav.dart';
import '../utils/color.dart';




class CategoryModel {
  final String title;
  final String imagePath;

  const CategoryModel({required this.title, required this.imagePath});
}

// ────────────────────────────────────────────────
// Providers

final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
  CategoriesNotifier.new,
);

class CategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  Future<List<CategoryModel>> build() async {
    await Future.delayed(const Duration(seconds: 2));

    return [
      CategoryModel(title: "Tourism", imagePath: "assets/images/Tourism.jpeg"),
      CategoryModel(title: "Sports", imagePath: "assets/images/Sports.jpeg"),
      CategoryModel(title: "Concerts", imagePath: "assets/images/live.jpeg"),
      CategoryModel(title: "Tech", imagePath: "assets/images/Tech.jpeg"),
      CategoryModel(title: "Festivals", imagePath: "assets/images/festivals.jpg"),
      CategoryModel(title: "Art", imagePath: "assets/images/art.jpg"),
    ];
  }

  Future<void> refresh() async {
    // Easy refresh support
    ref.invalidateSelf();
  }
}

// Simple in-memory selected filter/popular (can be persisted later with shared_preferences/hive)
final selectedFilterProvider = StateProvider<String>((ref) => "Discover");
final selectedPopularProvider = StateProvider<String?>((ref) => null);

// ────────────────────────────────────────────────
// Main Screen
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => ref.read(categoriesProvider.notifier).refresh(),
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate.fixed([
                        const SizedBox(height: 8),
                        const _Header(),
                        const SizedBox(height: 24),
                        const _SearchBar(),
                        const SizedBox(height: 20),
                        const _Filters(),
                        const SizedBox(height: 32),
                        const _PopularSearches(),
                        const SizedBox(height: 32),
                        const _CategoriesTitle(),
                        const SizedBox(height: 16),
                      ]),
                    ),
                  ),
                  const SliverToBoxAdapter(child: _CategoriesCarousel()),
                  const SliverToBoxAdapter(child: SizedBox(height: 48)),
                ],
              ),
            ),
          ),

          const FloatingBottomNav(),
        ],
      )
    );
  }
}

// ────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionCircleButton(
          icon: Icons.arrow_back_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.maybePop(context);
          },
        ),
        const Spacer(),
        Text(
          "Explore",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        _ActionCircleButton(
          icon: Icons.share_rounded,
          active: true,
          onTap: () {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Share coming soon")),
            );
          },
        ),
      ],
    );
  }
}

class _ActionCircleButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  const _ActionCircleButton({
    required this.icon,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.seccard,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: AppColors.primary.withOpacity(0.3),
        onTap: onTap,
        child: SizedBox.square(
          dimension: 44,
          child: Icon(icon, color: active ? AppColors.primary : Colors.white70),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, SearchScreen.route());
        // OR if using go_router: context.push('/search');
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Colors.white70, size: 26),
            const SizedBox(width: 12),
            Text(
              "Discover events, places...",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────

class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _FilterChip(
            icon: Icons.explore_rounded,
            label: "Discover",
            active: selected == "Discover",
            onTap: () {
              ref.read(selectedFilterProvider.notifier).state = "Discover";
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(width: 12),
          _FilterChip(
            icon: Icons.grid_view_rounded,
            label: "Category",
            active: selected == "Category",
            onTap: () {
              ref.read(selectedFilterProvider.notifier).state = "Category";
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(width: 12),
          _FilterChip(
            icon: Icons.swap_vert_rounded,
            label: "Sort",
            active: selected == "Sort",
            onTap: () {
              ref.read(selectedFilterProvider.notifier).state = "Sort";
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.seccard,
          borderRadius: BorderRadius.circular(32),
          boxShadow: active
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: active ? AppColors.primaryDark : Colors.white70),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.primaryDark : Colors.white,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────

class _PopularSearches extends ConsumerWidget {
  const _PopularSearches();

  static const List<String> items = [
    "Concerts",
    "Candlelight",
    "Rooftops",
    "Exhibitions",
    "Restaurants",
    "Cinema",
    "Festivals",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPopularProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Popular Searches",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((label) {
            final isSelected = selected == label;
            return GestureDetector(
              onTap: () {
                ref.read(selectedPopularProvider.notifier).state = label;
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.seccard,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 10)]
                      : null,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryDark : Colors.white,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────

class _CategoriesTitle extends StatelessWidget {
  const _CategoriesTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Categories",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // TODO: GoRouter.go('/categories')
          },
          child: const Text("See All", style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}

class _CategoriesCarousel extends ConsumerWidget {
  const _CategoriesCarousel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategories = ref.watch(categoriesProvider);

    return SizedBox(
      height: 360,
      child: asyncCategories.when(
        data: (categories) => PageView.builder(
          physics: const BouncingScrollPhysics(),
          controller: PageController(viewportFraction: 0.82, initialPage: 1),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _AnimatedCategoryCard(category: categories[index]);
          },
        ),
        loading: () => ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 4,
          itemBuilder: (context, index) => const _ShimmerCategoryCard(),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text("Failed to load categories", style: TextStyle(color: Colors.red[300])),
              TextButton(
                onPressed: () => ref.invalidate(categoriesProvider),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedCategoryCard extends StatelessWidget {
  final CategoryModel category;

  const _AnimatedCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PageController(), // In real use → listen to actual controller
      builder: (context, child) {
        // Simplified — you can make value dynamic per index if needed
        final value = 0.0; // placeholder — enhance with real page value
        final scale = 1.0 - (value.abs() * 0.15);
        final rotation = value * 0.05;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(rotation)
            ..scale(scale),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              // TODO: context.go('/category/${category.title}', extra: category);
              // Hero(tag: 'category-${category.title}', child: ...)
            },
            child: Hero(
              tag: 'category-${category.title}',
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        category.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.85),
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                category.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  shadows: [Shadow(blurRadius: 12, color: Colors.black87)],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerCategoryCard extends StatelessWidget {
  const _ShimmerCategoryCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.seccard,
      highlightColor: AppColors.surface,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 140,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}