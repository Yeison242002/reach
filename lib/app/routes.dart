import 'package:flutter/material.dart';
import 'package:reach/presentation/screens/auth/signin/signin_screen.dart';
import 'package:reach/presentation/screens/auth/signup/signup_screen.dart';
import 'package:reach/presentation/screens/home/home_screen.dart';
import 'package:reach/presentation/screens/main_navigation/main_navigation_screen.dart';
import 'package:reach/presentation/screens/consumption_history/consumption_history_screen.dart';
import 'package:reach/presentation/screens/profile/user_profile_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/signin': (_) => const SignInScreen(),
  '/signup': (_) => const SignUpScreen(),
  '/home': (_) => const MainNavigationScreen(),
  '/hi': (_) => const MainNavigationScreen(),
  '/main': (_) => const MainNavigationScreen(), // Nuevo
  '/consumption-history': (context) => ConsumptionHistoryScreen(),
  '/profile': (context) => const UserProfileScreen(),
};
