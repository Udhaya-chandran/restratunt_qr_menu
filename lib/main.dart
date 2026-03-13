import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  
  await Supabase.initialize(
    url: 'https://qmhkjcgppbabdcenokda.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFtaGtqY2dwcGJhYmRjZW5va2RhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMxMjY2NTIsImV4cCI6MjA4ODcwMjY1Mn0.LdP6Nq7p7Y-gGRqGKbfa53x5AyB3LyNvCbCRjI9LPbA',
  );

  runApp(const ProviderScope(child: RestaurantManagementApp()));
}
