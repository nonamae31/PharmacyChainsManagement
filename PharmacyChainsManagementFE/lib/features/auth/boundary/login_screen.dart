import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../control/auth_bloc.dart';
import '../control/auth_event.dart';
import '../control/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  void _submit() {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter email and password.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    context.read<AuthBloc>().add(LoginRequested(email, password));
  }

  void _onGoogleLogin() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(GoogleLoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppColors.danger,
              textColor: Colors.white,
              fontSize: 16,
            );
          } else if (state is AuthAuthenticated) {
            final role = state.role.toLowerCase();
            switch (role) {
              case 'founder':
                context.go('/founder_home');
                break;
              case 'business_admin':
                context.go('/business_admin_home');
                break;
              case 'branch_manager':
                context.go('/branch_manager_home');
                break;
              case 'staff':
                context.go('/staff_home');
                break;
              case 'inventory_manager':
                context.go('/inventory_home');
                break;
              default:
                context.go('/login');
            }
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return Row(
              children: [
                if (isWide) const Expanded(child: _BrandPanel()),
                Expanded(
                  child: _LoginPane(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    emailFocus: _emailFocus,
                    passwordFocus: _passwordFocus,
                    obscurePassword: _obscurePassword,
                    onTogglePassword: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    onSubmit: _submit,
                    onGoogleLogin: _onGoogleLogin,
                    showCompactBrand: !isWide,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFFE9EEF2)),
        CustomPaint(painter: _PharmaWavePainter()),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.primary.withValues(alpha: 0.26),
                const Color(0xFF111827).withValues(alpha: 0.74),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PharmacyChain OS',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pharmacy Chain Management Portal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFFE5EDF2),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.sm,
                children: const [
                  _BrandFeature(
                    icon: Icons.verified_user,
                    text: 'Secure Access',
                  ),
                  _BrandFeature(
                    icon: Icons.cloud_done,
                    text: 'Cloud Synchronized',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrandFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BrandFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFE5EDF2)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: const Color(0xFFE5EDF2),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _LoginPane extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onGoogleLogin;
  final bool showCompactBrand;

  const _LoginPane({
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onGoogleLogin,
    required this.showCompactBrand,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showCompactBrand) ...[
                        const _CompactBrandMark(),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: const Color(0xFF111827),
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Please enter your credentials to securely access your workspace.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _LoginCard(
                        emailController: emailController,
                        passwordController: passwordController,
                        emailFocus: emailFocus,
                        passwordFocus: passwordFocus,
                        obscurePassword: obscurePassword,
                        isLoading: isLoading,
                        onTogglePassword: onTogglePassword,
                        onSubmit: onSubmit,
                        onGoogleLogin: onGoogleLogin,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactBrandMark extends StatelessWidget {
  const _CompactBrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.local_pharmacy, color: Colors.white),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          'PharmacyChain OS',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onGoogleLogin;

  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onGoogleLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('emailField'),
            controller: emailController,
            focusNode: emailFocus,
            decoration: const InputDecoration(
              labelText: 'Email or Username',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => passwordFocus.requestFocus(),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            key: const Key('passwordField'),
            controller: passwordController,
            focusNode: passwordFocus,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: obscurePassword ? 'Show password' : 'Hide password',
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: onTogglePassword,
              ),
            ),
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!isLoading) onSubmit();
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const Key('forgotPasswordButton'),
              onPressed: isLoading
                  ? null
                  : () => context.go('/forgot-password'),
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            key: const Key('loginButton'),
            onPressed: isLoading ? null : onSubmit,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.arrow_forward),
            label: const Text('Log In'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF44546A),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('OR'),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _GoogleLoginButton(isLoading: isLoading, onPressed: onGoogleLogin),
        ],
      ),
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleLoginButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF111827),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _GoogleMark(),
            SizedBox(width: AppSpacing.sm),
            Text('Continue with Google'),
          ],
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 16,
      child: CustomPaint(painter: _GoogleMarkPainter()),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.18;
    final rect = Rect.fromLTWH(
      strokeWidth,
      strokeWidth,
      size.width - strokeWidth * 2,
      size.height - strokeWidth * 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -0.08, 1.23, false, paint..color = _blue);
    canvas.drawArc(rect, 1.15, 1.08, false, paint..color = _green);
    canvas.drawArc(rect, 2.22, 0.94, false, paint..color = _yellow);
    canvas.drawArc(rect, 3.16, 1.62, false, paint..color = _red);

    final centerY = size.height * 0.52;
    final startX = size.width * 0.52;
    final endX = size.width * 0.86;
    canvas.drawLine(
      Offset(startX, centerY),
      Offset(endX, centerY),
      paint..color = _blue,
    );
    canvas.drawLine(
      Offset(endX, centerY),
      Offset(endX, size.height * 0.66),
      paint..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PharmaWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = AppColors.secondary.withValues(alpha: 0.18);
    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppColors.primary.withValues(alpha: 0.28);
    final bubblePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.secondary.withValues(alpha: 0.12);
    final capsulePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.34);

    for (var i = 0; i < 4; i++) {
      final path = Path();
      final y = size.height * (0.28 + i * 0.045);
      path.moveTo(-40, y);
      path.cubicTo(
        size.width * 0.24,
        y - 90,
        size.width * 0.46,
        y + 110,
        size.width + 40,
        y - 10,
      );
      canvas.drawPath(path, i.isEven ? wavePaint : accentPaint);
    }

    final moleculePath = Path()
      ..moveTo(size.width * 0.14, size.height * 0.34)
      ..lineTo(size.width * 0.28, size.height * 0.27)
      ..lineTo(size.width * 0.42, size.height * 0.36)
      ..lineTo(size.width * 0.58, size.height * 0.28);
    canvas.drawPath(moleculePath, accentPaint);

    final points = [
      Offset(size.width * 0.14, size.height * 0.34),
      Offset(size.width * 0.28, size.height * 0.27),
      Offset(size.width * 0.42, size.height * 0.36),
      Offset(size.width * 0.58, size.height * 0.28),
      Offset(size.width * 0.72, size.height * 0.34),
      Offset(size.width * 0.2, size.height * 0.48),
      Offset(size.width * 0.62, size.height * 0.46),
    ];
    for (final point in points) {
      canvas.drawCircle(point, 14, bubblePaint);
      canvas.drawCircle(point, 6, accentPaint);
    }

    for (var i = 0; i < 8; i++) {
      final left = size.width * (0.12 + (i % 4) * 0.22);
      final top = size.height * (0.18 + (i ~/ 4) * 0.22);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, 46, 16),
        const Radius.circular(12),
      );
      canvas.save();
      canvas.translate(left + 23, top + 8);
      canvas.rotate(i.isEven ? 0.72 : -0.54);
      canvas.translate(-(left + 23), -(top + 8));
      canvas.drawRRect(rect, capsulePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
