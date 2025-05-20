import 'package:flutter/material.dart';
import 'package:reach/presentation/screens/auth/signin/signin_screen.dart';
import 'package:reach/presentation/screens/auth/signup/signup_screen.dart';
import 'package:reach/presentation/screens/main_navigation/main_navigation_screen.dart';
import 'package:reach/presentation/screens/consumption_history/consumption_history_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/signin': (_) => const SignInScreen(),
  '/signup': (_) => const SignUpScreen(),
  '/main': (_) => const MainNavigationScreen(), // Nuevo
  '/consumption-history': (context) => const ConsumptionHistoryScreen(),
};
