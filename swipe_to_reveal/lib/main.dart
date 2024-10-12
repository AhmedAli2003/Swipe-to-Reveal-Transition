import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swipe_to_reveal/go_router_example.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    /// Without GoRouter
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: 'Swipe to Reveal Transition',
    //   theme: ThemeData(
    //     useMaterial3: true,
    //     colorScheme: ColorScheme.fromSeed(
    //       seedColor: const Color(
    //         0xFF192531,
    //       ),
    //     ),
    //   ),
    //   home: const HomePage(),
    // );

    // With GoRouter
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Swipe to Reveal Transition',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(
            0xFF192531,
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}

// This provider is used to provider the opacity value for the home page
final opacityValueProvider = StateProvider<double>((ref) => 1.0);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 100),
      opacity: ref.watch(opacityValueProvider),
      child: const HomePageScaffold(),
    );
  }
}

class HomePageScaffold extends StatelessWidget {
  const HomePageScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        backgroundColor: const Color(0xFF242328),
        leadingWidth: 32,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Icon(Icons.menu_rounded, color: Colors.white),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 16),
            Text(
              'Telegram Clone',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: const [
          Icon(
            Icons.search_rounded,
            color: Colors.white,
          ),
          SizedBox(width: 12),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              radius: 36,
            ),
            title: Row(
              children: [
                Text(
                  'Channel $index',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                getRandomIcon(),
                const Spacer(),
                const Text(
                  '10:34 AM',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'Channel $index last updates...',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            onTap: () {
              // GoRouter Navigation
              GoRouter.of(context).goNamed('chat');
              // Navigator.of(context).push(buildSwipeToRevealRoute()); // Navigator 1.0
            },
          );
        },
        itemCount: 16,
      ),
    );
  }

  Icon getRandomIcon() {
    final r = Random().nextInt(2);
    final iconData = r == 0 ? Icons.volume_up_rounded : Icons.volume_off_rounded;
    return Icon(iconData, size: 18);
  }
}

// Only for Navigator 1.0
Route buildSwipeToRevealRoute() {
  return PageRouteBuilder(
    opaque: false,
    pageBuilder: (context, animation, secondaryAnimation) => const ChatPage(),
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
  );
}

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double dragStart = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(opacityValueProvider.notifier).state = 1.0;
      },
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          dragStart = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          double dragDistance = details.globalPosition.dx - dragStart;
          _controller.value = dragDistance / MediaQuery.sizeOf(context).width;
          ref.read(opacityValueProvider.notifier).state = 1 - (0.5 * (1 - _controller.value));
        },
        onHorizontalDragEnd: (details) {
          if (_controller.value > 0.25) {
            ref.read(opacityValueProvider.notifier).state = 1.0;
            Navigator.of(context).pop(); // Pop when swipe is more than halfway
          } else {
            _controller.reverse(); // Snap back if the swipe is less than halfway
          }
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(MediaQuery.of(context).size.width * _controller.value, 0),
              child: Scaffold(
                backgroundColor: const Color(0xFF181818),
                appBar: AppBar(
                  leading: IconButton(
                    onPressed: () {
                      GoRouter.of(context).pop();
                      // Navigator.pop(context); // Nabigation 1.0
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                  title: const Text(
                    'Chat',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF181818),
                ),
                body: const Center(
                  child: Text(
                    'Chat Screen',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
