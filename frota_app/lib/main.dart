import 'package:flutter/material.dart';
import 'core/config/supabase_config.dart';
import 'core/services/realtime_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  RealtimeService().initialize();
  runApp(const FleetApp());
}


