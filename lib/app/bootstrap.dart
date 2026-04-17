import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_session_initializer.dart';
import '../core/config/env.dart';
import 'app.dart';

Future<void> bootstrap() async {
  if (Env.isSupabaseConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    await AppSessionInitializer.restore();
  }

  runApp(const App());
}
