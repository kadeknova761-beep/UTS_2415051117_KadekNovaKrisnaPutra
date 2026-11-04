import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:resepku/core/exceptions.dart';
import 'package:resepku/repositories/meal_repository_impl.dart';
import 'package:resepku/services/meal_api_service.dart';

MealRepositoryImpl _repositoryReturning(String body, {int status = 200}) {
  final client = MockClient((_) async => http.Response(body, status));
  return MealRepositoryImpl(MealApiService(client: client));
}

const _oneMeal =
    '{"meals":[{"idMeal":"1","strMeal":"Corba","strMealThumb":"t.jpg"}]}';

void main() {
  group('MealRepositoryImpl', () {
    test('getCategories mengubah JSON menjadi model', () async {
      final repository = _repositoryReturning(
        '{"categories":[{"idCategory":"1","strCategory":"Beef",'
        '"strCategoryThumb":"b.png","strCategoryDescription":"d"}]}',
      );

      final categories = await repository.getCategories();

      expect(categories, hasLength(1));
      expect(categories.first.name, 'Beef');
    });

    test('getMealsByCategory mengisi category dari filter', () async {
      final repository = _repositoryReturning(_oneMeal);

      final meals = await repository.getMealsByCategory('Seafood');

      expect(meals.single.name, 'Corba');
      expect(meals.single.category, 'Seafood');
    });

    test('hasil null dianggap daftar kosong', () async {
      final repository = _repositoryReturning('{"meals":null}');

      final meals = await repository.searchMeals('xyz');

      expect(meals, isEmpty);
    });

    test('searchMeals memakai parameter s untuk kata kunci', () async {
      final requests = <Uri>[];
      final client = MockClient((request) async {
        requests.add(request.url);
        return http.Response(_oneMeal, 200);
      });
      final repository = MealRepositoryImpl(MealApiService(client: client));

      await repository.searchMeals('  corba ');

      expect(requests.single.path, endsWith('/search.php'));
      expect(requests.single.queryParameters['s'], 'corba');
    });

    test(
      'searchMeals kosong memuat huruf awal dan membuang duplikat',
      () async {
        final letters = <String?>[];
        final client = MockClient((request) async {
          letters.add(request.url.queryParameters['f']);
          return http.Response(_oneMeal, 200);
        });
        final repository = MealRepositoryImpl(MealApiService(client: client));

        final meals = await repository.searchMeals('');

        expect(letters, unorderedEquals(['b', 'c', 's']));
        expect(meals, hasLength(1));
      },
    );

    test('getRecommendations membuang resep duplikat', () async {
      final repository = _repositoryReturning(_oneMeal);

      final meals = await repository.getRecommendations();

      expect(meals, hasLength(1));
    });

    test('getMealDetail melempar AppException bila tidak ditemukan', () async {
      final repository = _repositoryReturning('{"meals":null}');

      await expectLater(
        repository.getMealDetail('0'),
        throwsA(isA<AppException>()),
      );
    });

    test('status bukan 200 menjadi AppException', () async {
      final repository = _repositoryReturning('{}', status: 500);

      await expectLater(
        repository.getCategories(),
        throwsA(isA<AppException>()),
      );
    });

    test('JSON rusak menjadi AppException', () async {
      final repository = _repositoryReturning('bukan json');

      await expectLater(
        repository.getCategories(),
        throwsA(isA<AppException>()),
      );
    });

    test('data tidak lengkap menjadi AppException', () async {
      final repository = _repositoryReturning('{"meals":[{"idMeal":"1"}]}');

      await expectLater(
        repository.searchMeals('x'),
        throwsA(isA<AppException>()),
      );
    });

    test('gangguan jaringan menjadi AppException', () async {
      final client = MockClient((_) async {
        throw http.ClientException('offline');
      });
      final repository = MealRepositoryImpl(MealApiService(client: client));

      await expectLater(
        repository.getCategories(),
        throwsA(isA<AppException>()),
      );
    });
  });
}
