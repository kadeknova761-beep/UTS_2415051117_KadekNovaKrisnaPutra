import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/main.dart';
import 'package:resepku/repositories/fake_meal_repository.dart';

void main() {
  testWidgets('menampilkan Home ResepKu', (tester) async {
    await tester.pumpWidget(
      const ResepKuApp(repository: FakeMealRepository(delay: Duration.zero)),
    );
    await tester.pumpAndSettle();

    expect(find.text('ResepKu'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Beef'), findsOneWidget);
  });
}
