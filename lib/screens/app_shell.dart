import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/breakpoints.dart';
import '../widgets/floating_nav_bar.dart';
import 'collection_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'recipe_list_screen.dart';

/// Kerangka navigasi utama.
///
/// Compact : FloatingNavBar (pil melayang) di bawah.
/// Expanded: NavigationRail melayang di kiri (diperluas di layar wide).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // State lokal tampilan (tab aktif), bukan shared state aplikasi.
  int _index = 0;

  static const List<NavItem> _destinations = [
    NavItem('Beranda', Icons.home_outlined, Icons.home),
    NavItem('Cari', Icons.search, Icons.search),
    NavItem('Koleksi', Icons.bookmark_border, Icons.bookmark),
    NavItem('Profil', Icons.person_outline, Icons.person),
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
            bottomNavigationBar: FloatingNavBar(
              items: _destinations,
              selectedIndex: _index,
              onDestinationSelected: _select,
            ),
          );
        }

        final extended = width >= Breakpoints.wide;

        return Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: _select,
                    extended: extended,
                    labelType: extended ? null : NavigationRailLabelType.all,
                    leading: const _RailLogo(),
                    destinations: [
                      for (final item in _destinations)
                        NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.label),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}

/// Lencana ikon di bagian atas rail.
class _RailLogo extends StatelessWidget {
  const _RailLogo();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        child: Icon(Icons.restaurant_menu, color: AppTheme.primary),
      ),
    );
  }
}
