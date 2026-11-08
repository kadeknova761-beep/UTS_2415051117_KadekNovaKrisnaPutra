import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_theme.dart';
import 'core/supabase_config.dart';
import 'providers/profile_provider.dart';
import 'providers/recipe_detail_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/saved_recipe_provider.dart';
import 'repositories/fake_profile_repository.dart';
import 'repositories/fake_saved_recipe_repository.dart';
import 'repositories/meal_repository.dart';
import 'repositories/meal_repository_impl.dart';
import 'repositories/profile_repository.dart';
import 'repositories/profile_repository_impl.dart';
import 'repositories/saved_recipe_repository.dart';
import 'repositories/saved_recipe_repository_impl.dart';
import 'screens/profile_gate.dart';
import 'services/meal_api_service.dart';
import 'services/profile_service.dart';
import 'services/saved_recipe_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(
    ResepKuApp(
      savedRecipeRepository: SavedRecipeRepositoryImpl(
        SavedRecipeService(Supabase.instance.client),
      ),
      profileRepository: ProfileRepositoryImpl(ProfileService()),
    ),
  );
}

class ResepKuApp extends StatelessWidget {
  /// Sumber data katalog. Bila null, aplikasi memakai REST API TheMealDB.
  /// Diisi repository lain saat pengujian (misalnya FakeMealRepository).
  final MealRepository? repository;

  /// Sumber data koleksi. Bila null (misalnya di tes), dipakai versi
  /// in-memory sehingga tes tidak butuh Supabase.
  final SavedRecipeRepository? savedRecipeRepository;

  /// Sumber data profil. Bila null (misalnya di tes), dipakai versi
  /// in-memory yang sudah berisi profil contoh sehingga tes langsung
  /// masuk ke aplikasi.
  final ProfileRepository? profileRepository;

  const ResepKuApp({
    super.key,
    this.repository,
    this.savedRecipeRepository,
    this.profileRepository,
  });

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
        ChangeNotifierProvider(
          create: (_) => SavedRecipeProvider(
            savedRecipeRepository ?? FakeSavedRecipeRepository(),
          )..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            profileRepository ??
                FakeProfileRepository(initial: FakeProfileRepository.sample),
          )..load(),
        ),
      ],
      child: MaterialApp(
        title: 'ResepKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const ProfileGate(),
      ),
    );
  }
}
