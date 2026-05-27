import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_screen.dart';
import '../features/student/student_home.dart';
import '../features/parent/parent_home.dart';
import '../features/admin/admin_home.dart';

CustomTransitionPage<void> _buildTransitionPage(
    GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.03, 0),
            end: Offset.zero,
          ).animate(curved),
          child: pageChild,
        ),
      );
    },
  );
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (c, s) => _buildTransitionPage(s, const LoginScreen()),
    ),
    GoRoute(
      path: '/student',
      pageBuilder: (c, s) => _buildTransitionPage(s, const StudentHome()),
    ),
    GoRoute(
      path: '/parent',
      pageBuilder: (c, s) => _buildTransitionPage(s, const ParentHome()),
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (c, s) => _buildTransitionPage(s, const AdminHome()),
    ),
  ],
);
