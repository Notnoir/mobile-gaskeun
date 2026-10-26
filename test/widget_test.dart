import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gaskeun/main.dart';
import 'package:gaskeun/providers/app_state.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('GasKeunApp renders AuthScreen with Google auth and actions by default',
      (WidgetTester tester) async {
    final state = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const GasKeunApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AuthScreen elements
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk ke akun GasKeun Anda'), findsOneWidget);
    expect(find.text('Lanjut dengan Google'), findsOneWidget);
    expect(find.text('Masuk dengan Email'), findsOneWidget);
    expect(find.text('Daftar Sekarang'), findsOneWidget);
    expect(find.text('GasKeun Warga'), findsOneWidget);

    // Switch to Register Mode
    await tester.tap(find.text('Daftar Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Akun Warga'), findsOneWidget);
    expect(find.text('Daftar dengan Google'), findsOneWidget);
    expect(find.text('Lanjut Daftar Akun'), findsOneWidget);

    // Switch back to Login Mode
    await tester.ensureVisible(find.text('Masuk Sekarang'));
    await tester.tap(find.text('Masuk Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat Datang'), findsOneWidget);

    // Expand Email Login Form
    await tester.tap(find.text('Masuk dengan Email'));
    await tester.pumpAndSettle();
    expect(find.text('Masuk Sekarang'), findsOneWidget);

    state.dispose();
  });

  testWidgets('GasKeunApp renders Warga portal when logged in with Google account',
      (WidgetTester tester) async {
    final state = AppState();
    // Log in with Google Account
    state.loginWithGoogleAccount(
      email: 'warga.google@gmail.com',
      displayName: 'Warga Google',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const GasKeunApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Warga portal elements
    expect(find.text('GasKeun Warga'), findsWidgets);
    expect(find.text('Saldo Poin Tersedia'), findsOneWidget);
    expect(find.text('pts'), findsOneWidget);
    expect(find.text('Setor'), findsOneWidget);

    state.dispose();
  });

  testWidgets('Logging out returns user to AuthScreen for account switching',
      (WidgetTester tester) async {
    final state = AppState();
    state.login('warga@gaskeun.id', 'password123');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const GasKeunApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Logout
    state.logout();
    await tester.pumpAndSettle();

    // Verify user is back at AuthScreen
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Lanjut dengan Google'), findsOneWidget);
    expect(find.text('Masuk dengan Email'), findsOneWidget);

    state.dispose();
  });

  test('AppState registerCitizen creates new profile with welcome bonus', () {
    final state = AppState();
    final success = state.registerCitizen(
      name: 'Warga Baru',
      email: 'baru@gaskeun.id',
      phone: '08123456789',
      rt: 'RT 03',
      password: 'password123',
    );

    expect(success, true);
    expect(state.isLoggedIn, true);
    expect(state.activeProfile.name, 'Warga Baru');
    expect(state.activeProfile.points, 100);

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
