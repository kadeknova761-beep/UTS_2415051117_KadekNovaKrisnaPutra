import 'package:flutter_test/flutter_test.dart';
import 'package:resepku/main.dart';

void main() {
  testWidgets('menampilkan Home ResepKu', (tester) async {
    await tester.pumpWidget(const ResepKuApp());

    expect(find.text('ResepKu'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
  });
}
