import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_advisor/core/theme/app_themes/themes.dart';
import 'package:trading_advisor/ui/homepage.dart';
import 'package:trading_advisor/ui/homepage_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => HomeViewModel())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trading Advisor',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Homepage(),
    );
  }
}
