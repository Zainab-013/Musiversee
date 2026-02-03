import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'dart:async';
import '../config/app_colors.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo placeholder - You can replace with your actual logo
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.neonGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.music_note,
                          size: 80,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'MUSIVERSE',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 48,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: AppColors.cyan.withOpacity(0.8),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Feel the music',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.cyan,
                              letterSpacing: 2,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}