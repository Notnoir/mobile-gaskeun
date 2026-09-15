import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gaskeun/main.dart';
import 'package:gaskeun/providers/app_state.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('GasKeunApp renders Warga portal with points balance', (WidgetTester tester) async {
    final state = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const GasKeunApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify brand name & points balance indicator
    expect(find.text('GasKeun'), findsOneWidget);
    expect(find.text('Saldo Poin Tersedia'), findsOneWidget);
    expect(find.text('pts'), findsOneWidget);

    state.dispose();
  });

  test('AppState point calculation & submission flow', () {
    final state = AppState();
    final initialPoints = state.wargaProfile.points;

    // Submit waste: 3 kg
    final sub = state.submitWaste(weightKg: 3.0, category: 'Sisa Sayur');
    expect(sub.points, 300);
    expect(sub.status.name, 'menunggu');

    // Operator verifies submission
    state.verifySubmission(sub.id, true);
    expect(state.wargaProfile.points, initialPoints + 300);

    state.dispose();
  });
}
