import 'package:flutter/material.dart';

import '../../../../core/ui/app_spacing.dart';
import '../controllers/auth_controller.dart';
import '../../../../services/di/service_locator.dart';
import 'register_screen.dart';

abstract class LoginAuthController implements Listenable {
  bool get isLoading;

  String? get errorMessage;

  Future<bool> login(String email, String password);
}

class _AuthControllerAdapter extends ChangeNotifier
    implements LoginAuthController {
  final AuthController _delegate;
  late final VoidCallback _listener;

  _AuthControllerAdapter(this._delegate) {
    _listener = notifyListeners;
    _delegate.addListener(_listener);
  }

  @override
  void dispose() {
    _delegate.removeListener(_listener);
    super.dispose();
  }

  @override
  bool get isLoading => _delegate.isLoading;

  @override
  String? get errorMessage => _delegate.errorMessage;

  @override
  Future<bool> login(String email, String password) {
    return _delegate.login(email, password);
  }
}

class LoginScreen extends StatefulWidget {
  final LoginAuthController? authController;

  const LoginScreen({
    super.key,
    this.authController,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final LoginAuthController authController;
  late final bool _ownsAuthController;

  bool _obscurePassword = true;
  String? _localErrorMessage;

  @override
  void initState() {
    super.initState();
    final injected = widget.authController;
    if (injected != null) {
      authController = injected;
      _ownsAuthController = false;
    } else {
      authController = _AuthControllerAdapter(ServiceLocator.I.authController);
      _ownsAuthController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsAuthController && authController is ChangeNotifier) {
      (authController as ChangeNotifier).dispose();
    }
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _localErrorMessage = 'Please enter your email and password.';
      });
      return;
    }

    setState(() {
      _localErrorMessage = null;
    });

    final success = await authController.login(
      email,
      password,
    );

    if (success && mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('Welcome Back'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.screenVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Log in to continue',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _LabeledField(
                              label: 'EMAIL',
                              child: TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'you@example.com',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'PASSWORD',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Forgot password coming soon'),
                                      ),
                                    );
                                  },
                                  child: const Text('Forgot?'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                            ),
                            if (_localErrorMessage != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _localErrorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                            if (authController.errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                authController.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                            if (authController.isLoading)
                              const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed:
                                  authController.isLoading ? null : _handleLogin,
                              child: const Text('Login'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Google login coming soon'),
                                ),
                              );
                            },
                            child: Image.asset(
                              'assets/images/google_logo.png',
                              height: 22,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.g_mobiledata);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Apple login coming soon'),
                                ),
                              );
                            },
                            child: Image.asset(
                              'assets/images/apple_logo.png',
                              height: 22,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.apple);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
