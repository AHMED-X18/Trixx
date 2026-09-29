import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trixx/data/isar/task_entity.dart';
import 'package:trixx/data/providers/isar_provider.dart';
import 'package:trixx/ui/shell/app_shell.dart';
import 'package:trixx/ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');

  final directory = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([TaskEntitySchema], directory: directory.path);

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const TrixxApp(),
    ),
  );
}

class TrixxApp extends StatelessWidget {
  const TrixxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRiXX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const AppShell(),
    );
  }
}
