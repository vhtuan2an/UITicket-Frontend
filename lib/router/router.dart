import 'package:uiticket_fe/router/routes.dart';
import 'package:uiticket_fe/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uiticket_fe/screens/auth/login_screen.dart';
import 'package:uiticket_fe/screens/admin/admin_screen.dart';
import 'package:uiticket_fe/screens/home/creator_home_screen.dart';
import 'package:uiticket_fe/screens/home/buyer_home_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.login,
  routes: [
    // Auth routes
    GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.register,
      builder: (context, state) => const RegisterScreen(),
    ),



      GoRoute(
        path: Routes.adminPage,
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: Routes.eventCreatorPage,
        builder: (context, state) => const InstructorScreen(),
      ),
      GoRoute(
        path: Routes.ticketBuyerPage,
        builder: (context, state) => const LearnerScreen(),
      ),
  ],
);