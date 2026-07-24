import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/navtrip_theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    this.redirectTo,
    super.key,
  });

  final String? redirectTo;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _redirectQueued = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isAuthenticated &&
        auth.needsVerification == false &&
        !_redirectQueued) {
      _redirectQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(context)
            .pushReplacementNamed(widget.redirectTo ?? '/dashboard');
      });
    }

    return Scaffold(
      body: PaperTexture(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              final content = wide
                  ? Row(
                      children: [
                        Expanded(child: _StoryPanel(large: true)),
                        Expanded(
                          child: _SignUpPanel(
                            formKey: _formKey,
                            auth: auth,
                            emailController: _emailController,
                            usernameController: _usernameController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            obscurePassword: _obscurePassword,
                            obscureConfirmPassword: _obscureConfirmPassword,
                            onTogglePassword: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            onToggleConfirmPassword: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                            onSubmit: _submit,
                            onGoogle: _googleSignIn,
                            onLogin: () => Navigator.of(context)
                                .pushReplacementNamed('/login',
                                    arguments: widget.redirectTo),
                            redirectTo: widget.redirectTo,
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _StoryPanel(large: false),
                          const SizedBox(height: 20),
                          _SignUpPanel(
                            formKey: _formKey,
                            auth: auth,
                            emailController: _emailController,
                            usernameController: _usernameController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            obscurePassword: _obscurePassword,
                            obscureConfirmPassword: _obscureConfirmPassword,
                            onTogglePassword: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            onToggleConfirmPassword: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                            onSubmit: _submit,
                            onGoogle: _googleSignIn,
                            onLogin: () => Navigator.of(context)
                                .pushReplacementNamed('/login',
                                    arguments: widget.redirectTo),
                            redirectTo: widget.redirectTo,
                          ),
                        ],
                      ),
                    );

              return content;
            },
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    auth.clearMessages();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await auth.signUp(
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) {
      return;
    }

    if (context.read<AuthProvider>().isAuthenticated) {
      Navigator.of(context)
          .pushReplacementNamed(widget.redirectTo ?? '/dashboard');
    }
  }

  Future<void> _googleSignIn() async {
    final auth = context.read<AuthProvider>();
    auth.clearMessages();
    await auth.signInWithGoogle();

    if (!mounted) {
      return;
    }

    if (context.read<AuthProvider>().isAuthenticated) {
      Navigator.of(context)
          .pushReplacementNamed(widget.redirectTo ?? '/dashboard');
    }
  }
}

class _StoryPanel extends StatelessWidget {
  const _StoryPanel({required this.large});

  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(large ? 56 : 18),
      color: NavTripPalette.sand,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final imageHeight = large && availableHeight.isFinite
                  ? (availableHeight * 0.54).clamp(300.0, 460.0).toDouble()
                  : (large ? 460.0 : 240.0);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      decoration: NavTripStyles.polaroidCard(),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBF0XU3AL3w_e-ZuAMqI7naht3rDkZdQvuvPqu6bd9XrMhmQSQIMVZ8mg4mCcmtdJEbLljiiQr-ggnLSSnHGtKNqATWqyZ6mAZgn16MjURSw-9cwJmIcZ_lGdokYD5p6RlrxowTfj38oWvCpN7bMvOxgqTsVgoq17ZuoL0YQeQ2q88ntdXlwKYtsG2fPn8Q_8Oar3UVjsgG_s06EcKM3TbmEtH1mJBVehqXcpvhKvec4xjCtw0FsGYKc1egfIr-5brhv1fJN4PDxd5r',
                                height: imageHeight,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Capture the journey.',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: NavTripPalette.mutedInk,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Icon(Icons.travel_explore,
                      color: NavTripPalette.terracotta, size: 34),
                  const SizedBox(height: 8),
                  Text(
                    'Make planning feel like keeping a travel journal.',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SignUpPanel extends StatelessWidget {
  const _SignUpPanel({
    required this.formKey,
    required this.auth,
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
    required this.onGoogle,
    required this.onLogin,
    required this.redirectTo,
  });

  final GlobalKey<FormState> formKey;
  final AuthProvider auth;
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final Future<void> Function() onSubmit;
  final Future<void> Function() onGoogle;
  final VoidCallback onLogin;
  final String? redirectTo;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'NavTrip-AI',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: NavTripPalette.terracottaDeep,
                    ),
              ),
              const SizedBox(height: 18),
              Text(
                'Create account',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 42,
                      color: NavTripPalette.ink,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set up your traveler profile and keep planning under Firebase.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: NavTripPalette.mutedInk,
                    ),
              ),
              const SizedBox(height: 24),
              if (auth.errorMessage != null) ...[
                _MessageBanner(message: auth.errorMessage!, isError: true),
                const SizedBox(height: 12),
              ],
              if (auth.verificationMessage != null) ...[
                _MessageBanner(
                    message: auth.verificationMessage!, isError: false),
                const SizedBox(height: 12),
              ],
              Container(
                decoration: NavTripStyles.polaroidCard(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Enter your email.';
                        }
                        if (!text.contains('@')) {
                          return 'Enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Enter a username.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: onTogglePassword,
                          icon: Icon(obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'Enter a password.';
                        }
                        if ((value ?? '').length < 8) {
                          return 'Use at least 8 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        suffixIcon: IconButton(
                          onPressed: onToggleConfirmPassword,
                          icon: Icon(obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'Confirm your password.';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: auth.isBusy ? null : onSubmit,
                      child: auth.isBusy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Account'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: auth.isBusy ? null : onGoogle,
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Continue with Google'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If Firebase requires email verification, you will be prompted to verify before the app opens your dashboard.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: NavTripPalette.mutedInk),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onLogin,
                child: const Text('Already have an account? Sign In'),
              ),
              if (redirectTo != null) ...[
                const SizedBox(height: 8),
                Text(
                  'You will return to $redirectTo after authentication.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: NavTripPalette.mutedInk),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError ? const Color(0xffffe5e1) : const Color(0xfffff6d8),
        border: Border.all(
            color: isError ? NavTripPalette.error : const Color(0xffc8b26b)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: NavTripPalette.ink,
            ),
      ),
    );
  }
}
