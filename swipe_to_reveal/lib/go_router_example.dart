import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swipe_to_reveal/main.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => const NoTransitionPage(
        name: 'home',
        child: HomePage(),
      ),
      routes: [
        GoRoute(
          path: 'chat',
          name: 'chat',
          pageBuilder: (context, state) => CustomTransitionPage(
            name: 'chat',
            opaque: false,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0); // Start from the right
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              final tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );
              final opacityTween = Tween(begin: 0.0, end: 1.0);

              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: curve,
                reverseCurve: curve,
              );

              return Stack(
                children: [
                  FadeTransition(
                    opacity: curvedAnimation.drive(opacityTween),
                    child: secondaryAnimation.status == AnimationStatus.reverse ? const HomePage() : Container(),
                  ),
                  SlideTransition(
                    position: curvedAnimation.drive(tween),
                    child: child,
                  ),
                ],
              );
            },
            child: const ChatPage(),
          ),
        ),
      ],
    ),
  ],
);
