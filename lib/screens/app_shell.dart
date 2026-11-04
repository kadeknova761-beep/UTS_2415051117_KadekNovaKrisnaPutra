import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import 'collection_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'recipe_list_screen.dart';

/// Kerangka navigasi utama.
///
/// Compact : NavigationBar di bawah.
/// Expanded: NavigationRail di kiri (diperluas di layar wide).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // State lokal tampilan (tab aktif), bukan shared state aplikasi.
  int _index = 0;

  static const List<_Destination> _destinations = [
    _Destination('Beranda', Icons.home_outlined, Icons.home),
    _Destination('Cari', Icons.search, Icons.search),
    _Destination('Koleksi', Icons.bookmark_border, Icons.bookmark),
    _Destination('Profil', Icons.person_outline, Icons.person),
  ];

  static const List<Widget> _pages = [
    HomeScreen(),
    RecipeListScreen(title: 'Cari resep'),
    CollectionScreen(),
    ProfileScreen(),
  ];

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // IndexedStack menjaga posisi scroll tiap tab saat berpindah.
        final body = IndexedStack(index: _index, children: _pages);

        if (!Breakpoints.isExpanded(width)) {
          return Scaffold(
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: [
                for (final item in _destinations)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
              ],
            ),
          );
        }

        final extended = width >= Breakpoints.wide;

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _select,
                extended: extended,
                labelType: extended ? null : NavigationRailLabelType.all,
                destinations: [
                  for (final item in _destinations)
                    NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(item.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}

class _Destination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _Destination(this.label, this.icon, this.selectedIcon);
}
