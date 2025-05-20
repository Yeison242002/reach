import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:reach/presentation/screens/auth/signin/signin_screen.dart';
import 'package:reach/app/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(MyApp());
  } catch (e) {
    print("Error al inicializar Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App con Firebase',
      debugShowCheckedModeBanner: false,
      initialRoute: '/signin',
      routes: appRoutes,       
    );
  }
}


