import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/recipe_provider.dart';
import 'repositories/meal_repository.dart';
import 'repositories/meal_repository_impl.dart';
import 'screens/app_shell.dart';
import 'services/meal_api_service.dart';

void main() {
  runApp(const ResepKuApp());
}

class ResepKuApp extends StatelessWidget {
  /// Sumber data. Bila null, aplikasi memakai REST API TheMealDB.
  /// Diisi repository lain saat pengujian (misalnya FakeMealRepository).
  final MealRepository? repository;

  const ResepKuApp({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    // Provider ditaruh di atas MaterialApp agar semua route, termasuk
    // halaman yang dibuka lewat Navigator.push, bisa mengaksesnya.
    return ChangeNotifierProvider(
      create: (_) =>
          RecipeProvider(repository ?? MealRepositoryImpl(MealApiService()))
            ..init(),
      child: MaterialApp(
        title: 'ResepKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AppShell(),
      ),
    );
  }
}
