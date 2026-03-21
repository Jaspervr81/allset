import 'package:allset/app_theme.dart';
import 'package:allset/main_screen.dart';
import 'package:allset/providers/dark_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData(false),
      darkTheme: AppTheme.themeData(true),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: const MainScreen(),
    );
  }
}
