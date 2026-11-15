import 'package:flutter/material.dart';

import 'screens/conferencia_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const StrataConferenciaApp());
}

class StrataConferenciaApp extends StatelessWidget {
  const StrataConferenciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strata Conferência',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.temaClaro,
      home: const ConferenciaScreen(),
    );
  }
}