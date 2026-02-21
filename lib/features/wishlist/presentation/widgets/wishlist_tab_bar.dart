import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/entities/wishlist_entity.dart';

class WishlistTabBar extends StatelessWidget {
  final List<WishlistEntity> wishlists;
  final TabController tabController;
  final Function(int) onTabChanged;

  const WishlistTabBar({
    super.key,
    required this.wishlists,
    required this.tabController,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      isScrollable: true,
      indicatorColor: const Color(0xFF0066CC),
      labelColor: const Color(0xFF0066CC),
      unselectedLabelColor: Colors.grey,
      onTap: onTabChanged,
      tabs:
          wishlists
              .map(
                (wishlist) => Tab(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          wishlist.name,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (wishlist.isDefault) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Color(0xFF0066CC),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}
