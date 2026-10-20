import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'models/user_model.dart';
import 'providers/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/warga/warga_main_screen.dart';
import 'screens/operator/operator_main_screen.dart';
import 'screens/pengawas/pengawas_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const GasKeunApp(),
    ),
  );
}

class GasKeunApp extends StatelessWidget {
  const GasKeunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GasKeun Warga — Komunitas Biodigester',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.isLoggedIn) {
            return const AuthScreen();
          }
          return const WargaMainScreen();
        },
      ),
    );
  }
}
