import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/navtrip_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    this.redirectTo,
    super.key,
  });

  final String? redirectTo;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _redirectQueued = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
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
                          child: _LoginPanel(
                            formKey: _formKey,
                            auth: auth,
                            identifierController: _identifierController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            onTogglePassword: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            onSubmit: _submit,
                            onGoogle: _googleSignIn,
                            onSignUp: () =>
                                Navigator.of(context).pushReplacementNamed(
                              '/signup',
                              arguments: widget.redirectTo,
                            ),
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
                          _LoginPanel(
                            formKey: _formKey,
                            auth: auth,
                            identifierController: _identifierController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            onTogglePassword: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            onSubmit: _submit,
                            onGoogle: _googleSignIn,
                            onSignUp: () =>
                                Navigator.of(context).pushReplacementNamed(
                              '/signup',
                              arguments: widget.redirectTo,
                            ),
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

    await auth.signIn(
      identifier: _identifierController.text,
      password: _passwordController.text,
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

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.formKey,
    required this.auth,
    required this.identifierController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onGoogle,
    required this.onSignUp,
    required this.redirectTo,
  });

  final GlobalKey<FormState> formKey;
  final AuthProvider auth;
  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmit;
  final Future<void> Function() onGoogle;
  final VoidCallback onSignUp;
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
                'Sign in',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 42,
                      color: NavTripPalette.ink,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use your email and password to keep your trip planning session synced with Firebase.',
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
                      controller: identifierController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration:
                          const InputDecoration(labelText: 'Email address'),
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Enter your email address.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: onTogglePassword,
                          icon: Icon(obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                      ),
                      validator: (value) => (value?.isEmpty ?? true)
                          ? 'Enter your password.'
                          : null,
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
                          : const Text('Sign In'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: auth.isBusy ? null : onGoogle,
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Continue with Google'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onSignUp,
                child: const Text('Need an account? Sign Up'),
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
