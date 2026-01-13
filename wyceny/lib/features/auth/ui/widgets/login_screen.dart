import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:wyceny/features/auth/ui/viewmodels/login_view_model.dart';
import 'package:wyceny/features/common/language_flag_toggle.dart';
import 'package:wyceny/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late final LoginViewModel _vm = GetIt.instance<LoginViewModel>();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final t = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      if (_usernameCtrl.text.trim().isEmpty) {
        _usernameFocus.requestFocus();
      } else {
        _passwordFocus.requestFocus();
      }
      return;
    }

    final ok = await _vm.login(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    if (ok) {
      context.go('/quote');
    } else if (_vm.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorToText(_vm.error!, t))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      // bez AppBar – tło pełnoekranowe jak w mocku
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // TŁO: zdjęcie
          Image.asset(
            'assets/portal-background-2_0.jpg',
            fit: BoxFit.cover,
          ),
          // lekki niebiesko-ciemny scrim dla czytelności
          Container(color: Colors.black.withOpacity(0.35)),

          // ZAWARTOŚĆ: karta logowania na środku
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: ListenableBuilder(
                listenable: _vm,
                builder: (context, _) {
                  return Card(
                    elevation: 8,
                    surfaceTintColor: Colors.white,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Theme(
                            // delikatnie dopasowane pola jak w mocku
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme: InputDecorationTheme(
                                isDense: true,
                                filled: true,
                                fillColor: const Color(0xFFF5F7FA),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                                ),
                                labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // LOGO
                                // TYTUŁ
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    t.appTitle,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.center,
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0x00ffffff),
                                    radius: 64,
                                    child: Image.asset(
                                      'assets/hellmannblue.png',
                                      height: 64,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // TYTUŁ
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    t.auth_loginTitle,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // USERNAME
                                TextFormField(
                                  controller: _usernameCtrl,
                                  focusNode: _usernameFocus,
                                  decoration: InputDecoration(
                                    labelText: t.auth_usernameLabel,
                                  ),
                                  enabled: !_vm.isLoading,
                                  autofillHints: const [AutofillHints.username, AutofillHints.email],
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) => _vm.clearError(),
                                  validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? t.auth_usernameRequired : null,
                                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                                ),
                                const SizedBox(height: 12),

                                // PASSWORD
                                TextFormField(
                                  controller: _passwordCtrl,
                                  focusNode: _passwordFocus,
                                  decoration: InputDecoration(
                                    labelText: t.auth_passwordLabel,
                                    suffixIcon: IconButton(
                                      splashRadius: 20,
                                      icon: Icon(
                                        _vm.obscurePassword ? Icons.visibility : Icons.visibility_off,
                                        color: const Color(0xFF64748B),
                                      ),
                                      tooltip: _vm.obscurePassword ? t.auth_showPassword : t.auth_hidePassword,
                                      onPressed: _vm.togglePasswordVisibility,
                                    ),
                                  ),
                                  enabled: !_vm.isLoading,
                                  obscureText: _vm.obscurePassword,
                                  autofillHints: const [AutofillHints.password],
                                  textInputAction: TextInputAction.done,
                                  onChanged: (_) => _vm.clearError(),
                                  validator: (v) =>
                                  (v == null || v.isEmpty) ? t.auth_passwordRequired : null,
                                  onFieldSubmitted: (_) => _onLogin(),
                                ),

                                const SizedBox(height: 12),

                                // BŁĄD INLINE (opcjonalnie)
                                if (_vm.error != null)
                                  Text(
                                    _errorToText(_vm.error!, t),
                                    style: TextStyle(color: scheme.error),
                                  ),

                                const SizedBox(height: 12),

                                // PRZYCISK LOGOWANIA – pełna szerokość
                                SizedBox(
                                  height: 44,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _vm.isLoading ? null : _onLogin,
                                    child: _vm.isLoading
                                        ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                        : Text(t.auth_loginButton),
                                  ),
                                ),

                                // LINK „Nie pamiętasz hasła?”
                                TextButton(
                                  onPressed: _vm.isLoading ? null : () => context.go('/recover'),
                                  child: Text(
                                    t.auth_forgotPassword,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Positioned(
            top: 8,
            right: 12,
            child: SafeArea(
              child: LanguageFlagToggle(),
            ),
          ),
        ],
      ),
    );
  }

  String _errorToText(LoginError error, AppLocalizations t) {
    switch (error) {
      case LoginError.invalidCredentials:
        return t.login_invalidCredentials;
      case LoginError.network:
        return t.login_network;
      case LoginError.unknown:
        return t.login_unknown;
    }
  }
}
