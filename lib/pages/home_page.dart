import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transist_tracker/pages/bus_details_page.dart';
import 'package:transist_tracker/pages/favourites_page.dart';
import 'package:transist_tracker/pages/find_bus_page.dart';
import 'package:transist_tracker/pages/profile_page.dart';
import 'package:transist_tracker/pages/time_table_page.dart';
import 'package:transist_tracker/utils/colors.dart';

import 'package:transist_tracker/providers/navigation_provider.dart';
export 'package:transist_tracker/providers/navigation_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    final screens = [
      const BusDetailsPage(),
      const FindBusPage(),
      const FavouritesPage(),
      const TimeTablePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: mainYellow,
        unselectedItemColor: Colors.grey,
        elevation: 8.0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
