import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ads.dart';
import 'screens.dart';
import 'state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.init();
  final state = AppState();
  await state.load();
  runApp(ChangeNotifierProvider.value(value: state, child: const RewardsApp()));
}

class RewardsApp extends StatelessWidget {
  const RewardsApp({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return MaterialApp(
      title: s.t('app'),
      debugShowCheckedModeBanner: false,
      locale: Locale(s.lang),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1B8A5A),
      ),
      builder: (context, child) => Directionality(
        textDirection: s.rtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: const HomeShell(),
    );
  }
}
