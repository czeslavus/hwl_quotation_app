import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:e_kierowca_app/app/auth.dart';
import 'package:e_kierowca_app/features/auth/ui/viewmodels/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late final LoginViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = GetIt.instance<LoginViewModel>();
    _vm.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onLogin() async {
    FocusScope.of(context).unfocus();
    final auth = AuthScope.of(context);
    final ok = await auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
    if (ok && mounted) {
      context.go('/dist'); // lub inny główny ekran
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/hellmann256.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
        title: const Text(
          'eKierowca HWL',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Zaloguj się', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Użytkownik',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_vm.isLoading,
                  onChanged: (_) => _vm.clearError(),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordCtrl,
                  decoration: InputDecoration(
                    labelText: 'Hasło',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_vm.obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: _vm.togglePasswordVisibility,
                    ),
                  ),
                  obscureText: _vm.obscurePassword,
                  enabled: !_vm.isLoading,
                  onSubmitted: (_) => _onLogin(),
                ),
                const SizedBox(height: 12),
                if (_vm.error != null)
                  Text(
                    _vm.error!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                  ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _vm.isLoading ? null : _onLogin,
                  child: _vm.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Zaloguj'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _vm.isLoading
                      ? null
                      : () async {
                          final username = _usernameCtrl.text.trim();
                          if (username.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Podaj nazwę użytkownika.')),
                            );
                            return;
                          }
                          final ok = await _vm.recover(username: username);
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Wysłano instrukcje odzyskiwania hasła.')),
                            );
                          } else if (mounted && _vm.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_vm.error!)),
                            );
                          }
                        },
                  child: const Text('Nie pamiętasz hasła?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Rejestracja w get_it (dodaj do istniejącego DI):
// getIt.registerFactory<LoginViewModel>(() => LoginViewModel(getIt<AuthService>()));
