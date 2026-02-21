import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/home_tab_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/categories_tab_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/account_tab_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/presentation/widgets/wishlist_icon_widget.dart';

class MainHomeScreen extends ConsumerStatefulWidget {
  const MainHomeScreen({super.key});

  @override
  ConsumerState<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends ConsumerState<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTabScreen(),
    const CategoriesTabScreen(),
    const WishlistScreen(),
    const AccountTabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).cardColor,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(
            context,
          ).colorScheme.onSurface.withOpacity(0.6),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: WishlistIconWidget(
                iconColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.6),
                activeColor: Theme.of(context).colorScheme.primary,
                iconSize: 24,
              ),
              activeIcon: WishlistIconWidget(
                iconColor: Theme.of(context).colorScheme.primary,
                activeColor: Theme.of(context).colorScheme.primary,
                iconSize: 24,
              ),
              label: 'Lists',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
