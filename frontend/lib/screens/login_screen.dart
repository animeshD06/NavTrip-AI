import 'package:flutter/material.dart';

import '../theme/navtrip_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;

    return Scaffold(
      body: PaperTexture(
        child: SafeArea(
          child: isDesktop ? _desktopLayout(context) : _mobileLayout(context),
        ),
      ),
    );
  }

  Widget _desktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StoryPanel(large: true)),
        Expanded(child: _FormPanel(formKey: _formKey, emailController: _emailController, passwordController: _passwordController, obscurePassword: _obscurePassword, onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword), onSubmit: _submit, onGoogle: _socialTap, onApple: _socialTap)),
      ],
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _StoryPanel(large: false),
          const SizedBox(height: 24),
          _FormPanel(formKey: _formKey, emailController: _emailController, passwordController: _passwordController, obscurePassword: _obscurePassword, onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword), onSubmit: _submit, onGoogle: _socialTap, onApple: _socialTap),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  void _socialTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Social login preview tapped')),
    );
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: NavTripStyles.polaroidCard(),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBF0XU3AL3w_e-ZuAMqI7naht3rDkZdQvuvPqu6bd9XrMhmQSQIMVZ8mg4mCcmtdJEbLljiiQr-ggnLSSnHGtKNqATWqyZ6mAZgn16MjURSw-9cwJmIcZ_lGdokYD5p6RlrxowTfj38oWvCpN7bMvOxgqTsVgoq17ZuoL0YQeQ2q88ntdXlwKYtsG2fPn8Q_8Oar3UVjsgG_s06EcKM3TbmEtH1mJBVehqXcpvhKvec4xjCtw0FsGYKc1egfIr-5brhv1fJN4PDxd5r',
                        height: large ? 480 : 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Capture the journey.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: NavTripPalette.mutedInk,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Icon(Icons.travel_explore, color: NavTripPalette.terracotta, size: 34),
              const SizedBox(height: 8),
              Text(
                'Make planning feel like keeping a travel journal.',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onGoogle,
    required this.onApple,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('NavTrip-AI', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: NavTripPalette.terracottaDeep)),
            const SizedBox(height: 18),
            Text('Welcome Back', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 42, color: NavTripPalette.ink)),
            const SizedBox(height: 8),
            Text('Your memories are waiting for you.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: NavTripPalette.mutedInk)),
            const SizedBox(height: 28),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email Address', hintText: 'traveler@voyage.com'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Enter your email';
                      if (!value.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        onPressed: onTogglePassword,
                        icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter your password';
                      if (value.length < 6) return 'Use at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: onSubmit,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Sign In'),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or continue with', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: NavTripPalette.mutedInk)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(child: _SocialButton(label: 'Google', icon: Icons.g_mobiledata, onTap: onGoogle)),
                      const SizedBox(width: 12),
                      Expanded(child: _SocialButton(label: 'Apple', icon: Icons.apple, onTap: onApple)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Forgot your password?'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Don\'t have an account? Start your journal.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: NavTripPalette.mutedInk),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

