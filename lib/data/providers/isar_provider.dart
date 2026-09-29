import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

/// Overridden at app startup with the opened [Isar] instance (see main.dart).
/// Tests never need to touch this — they override [taskServiceProvider]
/// directly with a fake repository instead.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider must be overridden in main() before runApp.');
});
