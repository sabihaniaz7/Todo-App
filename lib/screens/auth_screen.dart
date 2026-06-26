import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/services/auth_service.dart';
import 'package:flutter_firebase/theme/app_colors.dart';
import 'package:flutter_firebase/theme/app_sizes.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          margin: const EdgeInsets.all(AppSizes.md),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<void> _handleAuth(
    Future<UserCredential?> Function() authFunction,
  ) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }
    if (!_isLogin && name.isEmpty) {
      _showError("Please enter your name.");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await authFunction();
    } on FirebaseAuthException catch (e) {
      String msg = "A connection error occurred (${e.code}: ${e.message}).";
      if (e.code == 'user-not-found') {
        msg = "No account found with this email.";
      } else if (e.code == 'wrong-password') {
        msg = "Incorrect password.";
      } else if (e.code == 'invalid-credential') {
        msg = "Incorrect email or password.";
      } else if (e.code == 'email-already-in-use') {
        msg = "This email is already in use by another account.";
      } else if (e.code == 'weak-password') {
        msg = "The password is too weak.";
      } else if (e.code == 'operation-not-allowed') {
        msg = "Email/Password sign-in is not enabled in the Firebase Console.";
      } else if (e.code == 'invalid-email') {
        msg = "Please enter a valid email address.";
      }
      _showError(msg);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        _showError("Google sign-in was cancelled or failed.");
      }
    } on FirebaseAuthException catch (e) {
      _showError("Google sign-in failed (${e.code}: ${e.message}).");
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final textColor = AppColors.darkTextPrimary;

    final secondaryTextColor = AppColors.darkTextSecondary;

    final fieldColor = Colors.black;
    final fieldTextColor = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                  maxWidth: 420,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Todo App',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppSizes.fontDisplay,
                            fontWeight: FontWeight.w900,
                            // color: AppColors.primary,
                            color: Color(
                              0xFFB19FFB,
                            ), // Matched gorgeous signature light purple tone
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xxl),
                    Text(
                      _isLogin ? 'Welcome Back' : 'Create Account',

                      style: TextStyle(
                        fontSize: AppSizes.fontXxl,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                    if (!_isLogin) ...[
                      _AuthTextField(
                        controller: _nameController,
                        hintText: 'User Name',
                        fillColor: fieldColor,
                        textColor: fieldTextColor,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: AppSizes.md),
                    ],
                    _AuthTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      fillColor: fieldColor,
                      textColor: fieldTextColor,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppSizes.md),
                    _AuthTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      fillColor: fieldColor,
                      textColor: fieldTextColor,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: secondaryTextColor,
                          size: AppSizes.iconMd,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                      // Disable the action button completely if any auth process is currently loading
                      onPressed: _isLoading
                          ? null
                          : () => _handleAuth(
                              _isLogin
                                  ? () => _authService.loginWithEmail(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    )
                                  : () => _authService.signUpWithEmail(
                                      _nameController.text.trim(),
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    ),
                            ),
                      child:
                          _isLoading &&
                              _isLogin // If loading email-auth, you could show a spinner here, or just keep the text disabled
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isLogin ? 'Log in' : 'Sign up'),
                    ),
                    const SizedBox(height: AppSizes.md),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        foregroundColor: textColor,
                        side: BorderSide(color: AppColors.darkBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              Icons.g_mobiledata,
                              color: Colors.red,
                              size: 30,
                            ),
                      label: Text(
                        _isLoading ? 'Connecting...' : 'Sign in with Google',
                      ),
                      // Disable button if loading
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                    ),
                    const SizedBox(height: AppSizes.xl),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isLogin = !_isLogin;
                                // Clean input caches instantly during structural tree context swaps
                                _emailController.clear();
                                _passwordController.clear();
                                _nameController.clear();
                              });
                            },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                          children: [
                            TextSpan(
                              text: _isLogin
                                  ? "Don't have an account? "
                                  : "Have an account? ",
                              style: const TextStyle(fontSize: AppSizes.fontMd),
                            ),
                            TextSpan(
                              text: _isLogin ? 'Sign Up' : 'Log in',
                              style: const TextStyle(
                                color: Color(0xFFB19FFB),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.fillColor,
    required this.textColor,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final Color fillColor;
  final Color textColor;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(
        color: textColor,
        fontSize: AppSizes.fontMd,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: TextStyle(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
