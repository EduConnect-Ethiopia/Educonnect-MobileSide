import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/offline_banner.dart';
import 'browse_screen.dart';
import 'cart/cart_screen.dart';
import 'home_screen.dart';
import 'my_courses/my_courses_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationControllerProvider.notifier).loadNotifications();
    });
  }

  static const List<Widget> _screens = [
    HomeScreen(),
    MyCoursesScreen(),
    BrowseScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isAmharic = ref.watch(settingsProvider).language == 'am';

    return Scaffold(
      body: OfflineBanner(
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: isAmharic ? 'ቤት' : 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: isAmharic ? 'የእኔ ኮርሶች' : 'My Courses',
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            label: isAmharic ? 'ይፈልጉ' : 'Browse',
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_cart_outlined),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: isAmharic ? 'ካርት' : 'Cart',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: isAmharic ? 'መገለጫ' : 'Profile',
          ),
        ],
      ),
    );
  }
}
