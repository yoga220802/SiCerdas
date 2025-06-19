import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/app/widgets/custom_button.dart';
import 'package:project_sicerdas/features/auth/views/auth_screen.dart';

class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({required this.image, required this.title, required this.description});
}

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      image: 'assets/images/Image 1.png',
      title: 'Informasi Berita Terkini',
      description: 'Menyediakan berita terbaru dari berbagai kategori secara real-time dan akurat.',
    ),
    OnboardingData(
      image: 'assets/images/Image 2.png',
      title: 'Cepat dan Tepat Waktu',
      description:
          'Aplikasi Berita menyajikan informasi dengan pembaruan waktu nyata, memastikan pengguna tidak ketinggalan peristiwa penting.',
    ),
    OnboardingData(
      image: 'assets/images/Image 3.png',
      title: 'Mudah Digunakan oleh Semua',
      description:
          'Dirancang dengan antarmuka sederhana dan mudah digunakan oleh semua kalangan pengguna.',
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToNext() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Padding(
                    padding: AppSpacing.aPaddingLarge,
                    child: Image.asset(
                      _onboardingData[index].image,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, size: 100, color: AppColors.grey),
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 2, // Bagian untuk teks dan tombol
            child: Container(
              width: double.infinity,
              padding: AppSpacing.aPaddingLarge.copyWith(top: 16.0),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Column(
                        key: ValueKey<int>(_currentPage),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _onboardingData[_currentPage].title,
                            style: AppTypography.headlineSmall.copyWith(color: AppColors.white),
                            textAlign: TextAlign.center,
                          ),
                          AppSpacing.vsMedium,
                          Text(
                            _onboardingData[_currentPage].description,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.vsLarge,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: AppSpacing.aPaddingTiny,
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? AppColors.white
                                  : AppColors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.vsLarge,
                  CustomButton(
                    text: _currentPage == _onboardingData.length - 1 ? 'Mulai Sekarang' : 'Lanjut',
                    onPressed: _navigateToNext,
                    type: ButtonType.outline,
                    customBackgroundColor: AppColors.secondary,
                    customOutlineColor: AppColors.white,
                    customTextColor: AppColors.textWhite,
                    width: double.infinity,
                  ),
                  AppSpacing.vsMedium,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
