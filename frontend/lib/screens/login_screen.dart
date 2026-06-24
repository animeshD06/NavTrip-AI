import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/clerk_auth_config.dart';
import '../theme/navtrip_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _launchingClerk = false;

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
        Expanded(
          child: _ClerkPanel(
            isBusy: _launchingClerk,
            hasClerkUrl: ClerkAuthConfig.hasSignInUrl,
            onContinue: _openClerkAuth,
            onLearnMore: _openClerkDocs,
          ),
        ),
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
          _ClerkPanel(
            isBusy: _launchingClerk,
            hasClerkUrl: ClerkAuthConfig.hasSignInUrl,
            onContinue: _openClerkAuth,
            onLearnMore: _openClerkDocs,
          ),
        ],
      ),
    );
  }

  Future<void> _openClerkAuth() async {
    final signInUrl = ClerkAuthConfig.signInUrl;
    if (signInUrl.isEmpty) {
      _showSnackBar(
        'Set CLERK_SIGN_IN_URL to your Clerk sign-in page before using /login.',
      );
      return;
    }

    final uri = Uri.tryParse(signInUrl);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      _showSnackBar('CLERK_SIGN_IN_URL must be a valid http or https URL.');
      return;
    }

    setState(() {
      _launchingClerk = true;
    });

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        _showSnackBar('Unable to open the Clerk sign-in page.');
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('Unable to open the Clerk sign-in page.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _launchingClerk = false;
        });
      }
    }
  }

  Future<void> _openClerkDocs() async {
    await launchUrl(
      Uri.parse('https://clerk.com/docs'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

class _ClerkPanel extends StatelessWidget {
  const _ClerkPanel({
    required this.isBusy,
    required this.hasClerkUrl,
    required this.onContinue,
    required this.onLearnMore,
  });

  final bool isBusy;
  final bool hasClerkUrl;
  final VoidCallback onContinue;
  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
              'Welcome Back',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 42,
                    color: NavTripPalette.ink,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in or create your account with Clerk from the existing /login route.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: NavTripPalette.mutedInk,
                  ),
            ),
            const SizedBox(height: 28),
            Container(
              decoration: NavTripStyles.polaroidCard(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BenefitRow(
                    icon: Icons.verified_user_outlined,
                    text: 'Clerk handles sign in and sign up in one flow.',
                  ),
                  const SizedBox(height: 14),
                  const _BenefitRow(
                    icon: Icons.lock_outline,
                    text: 'The UI stays on your existing /login route and keeps the travel journal look.',
                  ),
                  const SizedBox(height: 14),
                  const _BenefitRow(
                    icon: Icons.public_outlined,
                    text: 'Configure the Clerk sign-in URL with a Dart define when you run the app.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: isBusy || !hasClerkUrl ? null : onContinue,
              icon: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.open_in_new),
              label: Text(
                isBusy ? 'Opening Clerk...' : 'Continue with Clerk',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasClerkUrl
                  ? 'If you choose sign up inside Clerk, the same flow returns to the app after authentication.'
                  : 'Set CLERK_SIGN_IN_URL to enable Clerk auth from this screen.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: NavTripPalette.mutedInk,
                  ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onLearnMore,
              child: const Text('Read Clerk docs'),
            ),
            const SizedBox(height: 12),
            Text(
              'Don\'t have an account? Clerk sign-up is available from the same entry point.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: NavTripPalette.mutedInk,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: NavTripPalette.terracottaDeep),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: NavTripPalette.ink,
                ),
          ),
        ),
      ],
    );
  }
}

