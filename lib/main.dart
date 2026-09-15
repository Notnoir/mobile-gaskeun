import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'models/user_model.dart';
import 'providers/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/warga/warga_main_screen.dart';
import 'screens/operator/operator_main_screen.dart';
import 'screens/pengawas/pengawas_main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const GasKeunApp(),
    ),
  );
}

class GasKeunApp extends StatefulWidget {
  const GasKeunApp({super.key});

  @override
  State<GasKeunApp> createState() => _GasKeunAppState();
}

class _GasKeunAppState extends State<GasKeunApp> {
  bool _isLoggedIn = true; // default true for immediate interactive evaluation

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GasKeun — Manajemen Biodigester',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isLoggedIn
          ? Consumer<AppState>(
              builder: (context, state, _) {
                switch (state.currentRole) {
                  case UserRole.warga:
                    return const WargaMainScreen();
                  case UserRole.operator:
                    return const OperatorMainScreen();
                  case UserRole.pengawas:
                    return const PengawasMainScreen();
                }
              },
            )
          : AuthScreen(
              onLoginSuccess: () {
                setState(() => _isLoggedIn = true);
              },
            ),
    );
  }
}
