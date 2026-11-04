import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/recipe_detail_provider.dart';
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
    // Repository didaftarkan sekali lalu dibagi ke semua provider data.
    return MultiProvider(
      providers: [
        Provider<MealRepository>(
          create: (_) => repository ?? MealRepositoryImpl(MealApiService()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RecipeProvider(context.read<MealRepository>())..init(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RecipeDetailProvider(context.read<MealRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'ResepKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AppShell(),
      ),
    );
  }
}
