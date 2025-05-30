import 'package:flutter/material.dart';
import 'dart:async';

import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/features/onboarding/view/get_started_screen.dart';
import 'package:project_sicerdas/app/widgets/floating_circle.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late List<AnimationController> _circleAnimControllers;
  late List<Animation<double>> _circleAnimations;
  final int _numCircles = 8;

  late AnimationController _dotsAnimController;
  int _currentDot = 0;
  final int _totalDots = 6;

  @override
  void initState() {
    super.initState();

    _circleAnimControllers = List.generate(
      _numCircles,
      (index) =>
          AnimationController(duration: Duration(milliseconds: 1500 + (index * 200)), vsync: this),
    );

    _circleAnimations = List.generate(
      _numCircles,
      (index) => Tween<double>(
        begin: -10.0,
        end: 10.0,
      ).animate(CurvedAnimation(parent: _circleAnimControllers[index], curve: Curves.easeInOut)),
    );

    for (var controller in _circleAnimControllers) {
      controller.repeat(reverse: true);
    }

    _dotsAnimController = AnimationController(
      duration: const Duration(milliseconds: 500), // Sedikit diperlambat
      vsync: this,
    );

    _dotsAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _dotsAnimController.reset();
        if (mounted) {
          // Pastikan widget masih ada di tree
          setState(() {
            _currentDot = (_currentDot + 1) % _totalDots;
          });
        }
        _dotsAnimController.forward();
      }
    });
    _dotsAnimController.forward();

    Timer(const Duration(seconds: 3), () {
      // Dipercepat sedikit
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GetStartedScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _circleAnimControllers) {
      controller.dispose();
    }
    _dotsAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.white, // Menggunakan warna dari theme
      body: Stack(
        children: [
          // Ornamen lingkaran animasi
          FloatingCircle(
            left: -size.width * 0.2,
            top: -size.width * 0.1,
            size: size.width * 0.5,
            color: AppColors.splashCircleBlue.withValues(alpha: .7),
            animation: _circleAnimations[0],
          ),
          FloatingCircle(
            right: -size.width * 0.1,
            top: size.height * 0.05,
            size: size.width * 0.3,
            color: AppColors.splashCircleBlue.withValues(alpha: .7),
            animation: _circleAnimations[1],
          ),
          FloatingCircle(
            right: -size.width * 0.25,
            top: size.height * 0.2,
            size: size.width * 0.5,
            color: AppColors.lightGrey.withValues(alpha: .7),
            animation: _circleAnimations[2],
          ),
          FloatingCircle(
            left: size.width * 0.05,
            bottom: size.height * 0.3,
            size: size.width * 0.1,
            color: AppColors.lightGrey.withValues(alpha: .7),
            animation: _circleAnimations[3],
          ),
          FloatingCircle(
            left: size.width * 0.05,
            bottom: size.height * 0.25,
            size: size.width * 0.02,
            color: AppColors.splashCircleBlue.withValues(alpha: .3),
            animation: _circleAnimations[4],
          ),
          FloatingCircle(
            left: size.width * 0.1,
            bottom: size.height * 0.25,
            size: size.width * 0.05,
            color: AppColors.splashCircleBlue.withValues(alpha: .7),
            animation: _circleAnimations[5],
          ),
          FloatingCircle(
            right: -size.width * 0.2,
            bottom: -size.width * 0.2,
            size: size.width * 0.6,
            color: AppColors.splashCircleBlue.withValues(alpha: .7),
            animation: _circleAnimations[6],
          ),
          FloatingCircle(
            right: size.width * 0.05,
            bottom: size.height * 0.15,
            size: size.width * 0.2,
            color: AppColors.splashCircleBlue.withValues(alpha: .7),
            animation: _circleAnimations[7],
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png', // Pastikan path logo benar
                  width: size.width * 0.4, // Ukuran disesuaikan
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 80),
                ),
                AppSpacing.vsLarge,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _totalDots,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6), // Spasi antar dot
                      width: 10, // Ukuran dot
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentDot == index
                                ? AppColors
                                    .splashLoadingDot // Warna dot aktif
                                : AppColors.splashLoadingDot.withValues(
                                  alpha: 0.3,
                                ), // Warna dot non-aktif
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
