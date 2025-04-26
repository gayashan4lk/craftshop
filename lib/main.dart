import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_size/window_size.dart';
import 'package:craftshop/core/di/service_locator.dart';
import 'package:craftshop/data/data_sources/database_helper.dart';
import 'package:craftshop/presentation/screens/main_screen.dart';
import 'package:craftshop/presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseHelper.instance.database;
  
  // Initialize dependencies
  await initializeDependencies();
  
  // Set minimum window size for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1200, 800));
    setWindowTitle('CraftShop POS');
  }
  
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CraftShop POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}
