import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  final url = normalizeSupabaseUrl(dotenv.env['SUPABASE_URL'] ?? '');
  final anonKey = (dotenv.env['SUPABASE_ANON_KEY'] ?? '').trim();

  if (url.isEmpty || anonKey.isEmpty) {
    runApp(const MissingConfigApp());
    return;
  }

  // The anon (or publishable) key is safe to ship in the client; RLS protects data.
  await Supabase.initialize(url: url, publishableKey: anonKey);

  try {
    await ReminderService.instance.init();
  } catch (error) {
    // Reminders are optional; the app still works without them.
    debugPrint('Reminders unavailable: $error');
  }

  runApp(const ProviderScope(child: LifeFlowApp()));
}

/// Accepts common copy/paste mistakes (spaces, quotes, trailing slash,
/// `/rest/v1` or `/auth/v1` suffix) and returns the bare project URL.
String normalizeSupabaseUrl(String raw) {
  var url = raw.trim().replaceAll(RegExp(r'''^["']|["']$'''), '');
  url = url.replaceFirst(RegExp(r'/+(rest|auth)/v1/?$'), '');
  return url.replaceFirst(RegExp(r'/+$'), '');
}
