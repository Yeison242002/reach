import 'package:flutter/material.dart';
import 'package:reach/app/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reach',
      initialRoute: '/signin', // Puedes cambiar esto a '/home' si ya está logueado
      routes: appRoutes,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1F1B2E),
        primaryColor: const Color(0xFFB23399),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB23399),
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
