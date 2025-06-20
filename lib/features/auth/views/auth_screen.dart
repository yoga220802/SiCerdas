import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart';
import 'package:project_sicerdas/features/auth/views/forgot_password_screen.dart';
import 'package:project_sicerdas/features/auth/widgets/login_form.dart';
import 'package:project_sicerdas/features/auth/widgets/register_form.dart';
import 'package:project_sicerdas/features/home/views/home_screen.dart';
import 'package:project_sicerdas/features/main_screen.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final DraggableScrollableController _dragController = DraggableScrollableController();
  late AnimationController _fadeAnimController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  final TextEditingController _registerUsernameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _registerConfirmPasswordController = TextEditingController();

  final FocusNode _loginEmailFocus = FocusNode();
  final FocusNode _loginPasswordFocus = FocusNode();
  final FocusNode _registerUsernameFocus = FocusNode();
  final FocusNode _registerEmailFocus = FocusNode();
  final FocusNode _registerPasswordFocus = FocusNode();
  final FocusNode _registerConfirmPasswordFocus = FocusNode();

  bool _isRegisterSheetVisible = false;

  @override
  void initState() {
    super.initState();

    _fadeAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeAnimController, curve: Curves.easeInOut));
    _dragController.addListener(_onDragChanged);
  }

  void _onDragChanged() {
    final sheetPosition = _dragController.size;
    if (mounted) {
      bool shouldBeVisible = sheetPosition > 0.5;
      if (shouldBeVisible != _isRegisterSheetVisible) {
        setState(() => _isRegisterSheetVisible = shouldBeVisible);
        if (shouldBeVisible) {
          _fadeAnimController.forward();
        } else {
          _fadeAnimController.reverse();
        }
      }
    }
  }

  void _showRegisterSheet() {
    Future.delayed(Duration.zero, () {
      if (mounted) FocusScope.of(context).unfocus();
    });
    _dragController.animateTo(
      0.85,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _hideRegisterSheet() {
    Future.delayed(Duration.zero, () {
      if (mounted) FocusScope.of(context).unfocus();
    });
    _dragController.animateTo(
      0.05,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
  }

  Future<void> _handleLogin(AuthController authController) async {
    if (mounted) FocusScope.of(context).unfocus();

    bool loggedIn = await authController.loginUser(
      email: _loginEmailController.text,
      password: _loginPasswordController.text,
    );

    if (mounted) {
      if (loggedIn) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      } else if (authController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authController.errorMessage!), backgroundColor: AppColors.error),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal login. Periksa kembali email dan password Anda."),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleRegister(AuthController authController) async {
    if (mounted) FocusScope.of(context).unfocus();

    bool registered = await authController.registerUser(
      username: _registerUsernameController.text,
      email: _registerEmailController.text,
      password: _registerPasswordController.text,
    );
    if (mounted) {
      if (registered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi berhasil! Silakan login."),
            backgroundColor: AppColors.success,
          ),
        );
        _loginEmailController.text =
            _registerEmailController.text; // Isi email login dengan email register
        _loginPasswordController.clear(); // Kosongkan password
        _hideRegisterSheet();
      } else if (authController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authController.errorMessage!), backgroundColor: AppColors.error),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal melakukan registrasi. Coba lagi."),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _dragController.removeListener(_onDragChanged);
    _fadeAnimController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();

    _loginEmailFocus.dispose();
    _loginPasswordFocus.dispose();
    _registerUsernameFocus.dispose();
    _registerEmailFocus.dispose();
    _registerPasswordFocus.dispose();
    _registerConfirmPasswordFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: Consumer<AuthController>(
        builder: (context, authController, child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.secondary,
            body: SafeArea(
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder:
                        (context, child) => Opacity(opacity: _fadeAnimation.value, child: child),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: _isRegisterSheetVisible ? 0 : 80.0),
                      child: SizedBox(
                        height:
                            size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom,
                        child: Padding(
                          padding: AppSpacing.hPaddingLarge,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(flex: 1),
                              const Icon(
                                Icons.account_circle_outlined,
                                size: 50,
                                color: AppColors.textBlack,
                              ),
                              AppSpacing.vsMedium,
                              Text(
                                'Masuk Disini!',
                                style: AppTypography.headlineSmall.copyWith(
                                  color: AppColors.textBlack,
                                ),
                              ),
                              AppSpacing.vsSmall,
                              Text(
                                'Nikmati pengalaman membaca berita dengan login yang cepat dan terlindungi',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textGrey),
                              ),
                              AppSpacing.vsLarge,
                              LoginForm(
                                emailController: _loginEmailController,
                                passwordController: _loginPasswordController,
                                emailFocusNode: _loginEmailFocus,
                                passwordFocusNode: _loginPasswordFocus,
                                onLoginPressed:
                                    () => _handleLogin(authController), // Kirim authController
                                onForgotPasswordPressed: _navigateToForgotPassword,
                                isLoading: authController.isLoading,
                              ),
                              AppSpacing.vsMedium,
                              _buildRegisterLink(authController),
                              AppSpacing.vsLarge,
                              _buildSocialLoginButtons(authController),
                              const Spacer(flex: 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildRegisterSheet(authController),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegisterLink(AuthController authController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum mempunyai akun? ',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textBlack),
        ),
        GestureDetector(
          onTap: authController.isLoading ? null : _showRegisterSheet,
          child: Text(
            'Register',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white,
              fontWeight: AppTypography.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons(AuthController authController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSocialButton(Icons.g_mobiledata_outlined, 'Google', () {
          /* TODO: Google login */
        }, authController),
        _buildSocialButton(Icons.facebook_outlined, 'Facebook', () {
          /* TODO: Facebook login */
        }, authController),
        _buildSocialButton(Icons.apple_outlined, 'Apple', () {
          /* TODO: Apple login */
        }, authController),
      ],
    );
  }

  Widget _buildSocialButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
    dynamic authController, {
    bool isRegister = false,
  }) {
    return GestureDetector(
      onTap: authController.isLoading ? null : onPressed,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: isRegister ? AppColors.secondary : AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Icon(icon, size: 24, color: isRegister ? AppColors.white : AppColors.secondary),
      ),
    );
  }

  Widget _buildRegisterSheet(AuthController authController) {
    return DraggableScrollableSheet(
      initialChildSize: 0.08,
      minChildSize: 0.08,
      maxChildSize: 0.9,
      controller: _dragController,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: AppSpacing.vPaddingMedium,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _isRegisterSheetVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child:
                      _isRegisterSheetVisible
                          ? RegisterForm(
                            usernameController: _registerUsernameController,
                            emailController: _registerEmailController,
                            passwordController: _registerPasswordController,
                            confirmPasswordController: _registerConfirmPasswordController,
                            usernameFocusNode: _registerUsernameFocus,
                            emailFocusNode: _registerEmailFocus,
                            passwordFocusNode: _registerPasswordFocus,
                            confirmPasswordFocusNode: _registerConfirmPasswordFocus,
                            onRegisterPressed: () => _handleRegister(authController),
                            isLoading: authController.isLoading,
                          )
                          : const SizedBox(height: 200),
                ),
                ..._isRegisterSheetVisible
                    ? [
                      AppSpacing.vsMedium,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah mempunyai akun? ',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textGrey),
                          ),
                          GestureDetector(
                            onTap: authController.isLoading ? null : _hideRegisterSheet,
                            child: Text(
                              'Login',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.secondary,
                                fontWeight: AppTypography.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vsLarge,
                      _buildSocialLoginButtons(authController),
                      AppSpacing.vsXLarge,
                    ]
                    : (!_isRegisterSheetVisible &&
                        _dragController.isAttached &&
                        _dragController.size < 0.1)
                    ? [const SizedBox(height: 50)]
                    : [],
              ],
            ),
          ),
        );
      },
    );
  }
}
