import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/recipe_provider.dart';
import 'repositories/fake_meal_repository.dart';
import 'repositories/meal_repository.dart';
import 'screens/app_shell.dart';

void main() {
  runApp(const ResepKuApp());
}

class ResepKuApp extends StatelessWidget {
  /// Sumber data. Bisa diganti (misalnya saat pengujian).
  final MealRepository repository;

  const ResepKuApp({super.key, this.repository = const FakeMealRepository()});

  @override
  Widget build(BuildContext context) {
    // Provider ditaruh di atas MaterialApp agar semua route, termasuk
    // halaman yang dibuka lewat Navigator.push, bisa mengaksesnya.
    return ChangeNotifierProvider(
      create: (_) => RecipeProvider(repository)..init(),
      child: MaterialApp(
        title: 'ResepKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AppShell(),
      ),
    );
  }
}
