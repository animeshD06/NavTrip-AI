import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/navtrip_theme.dart';

class AuthGuard extends StatefulWidget {
  const AuthGuard({
    required this.child,
    required this.protectedRoute,
    super.key,
  });

  final Widget child;
  final String protectedRoute;

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _redirectScheduled = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isReady) {
      return const _AuthLoadingView();
    }

    if (auth.isAuthenticated) {
      _redirectScheduled = false;
      return widget.child;
    }

    if (!_redirectScheduled) {
      _redirectScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacementNamed(
          '/login',
          arguments: widget.protectedRoute,
        );
      });
    }

    return const _AuthLoadingView();
  }
}

class _AuthLoadingView extends StatelessWidget {
  const _AuthLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperTexture(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Restoring your session...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
