import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:wyceny/features/auth/ui/viewmodels/recover_set_password_viewmodel.dart';
import 'package:wyceny/l10n/app_localizations.dart';

class RecoverSetPasswordScreen extends StatefulWidget {
  const RecoverSetPasswordScreen({super.key});

  @override
  State<RecoverSetPasswordScreen> createState() => _RecoverSetPasswordScreenState();
}

class _RecoverSetPasswordScreenState extends State<RecoverSetPasswordScreen> {
  late final RecoverSetPasswordViewModel _vm = GetIt.I<RecoverSetPasswordViewModel>();

  @override
  void dispose() {
    _vm.dispose(); // VM zwalnia swoje kontrolery
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      // brak AppBar — layout jak na ekranie logowania
      body: Stack(
        fit: StackFit.expand,
        children: [
          // TŁO
          Image.asset('assets/portal-background-2_0.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.35)), // scrim

          // KARTA POŚRODKU
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListenableBuilder(
                listenable: _vm,
                builder: (context, _) {
                  return Card(
                    elevation: 8,
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                      child: Theme(
                        // ten sam InputDecorationTheme co na loginie
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
                            Align(
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 64,
                                child: Image.asset('assets/hellmannblue.png', height: 64, fit: BoxFit.contain),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // TYTUŁ
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                t.recover_title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── GÓRA: wysyłanie kodu ───────────────────────
                            TextFormField(
                              controller: _vm.usernameCtrl,
                              decoration: InputDecoration(labelText: t.auth_usernameLabel),
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.username, AutofillHints.email],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 44,
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: _vm.loadingCode ? null : _vm.sendCode,
                                child: _vm.loadingCode
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : Text(t.recover_sendCode),
                              ),
                            ),
                            if (_vm.codeInfo != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(_codeInfoToText(_vm.codeInfo!, t), style: const TextStyle(color: Colors.green)),
                              ),
                            if (_vm.codeError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(_codeErrorToText(_vm.codeError!, t), style: TextStyle(color: scheme.error)),
                              ),

                            const Divider(height: 32),

                            // ── DÓŁ: ustawianie nowego hasła ───────────────
                            Form(
                              key: _vm.formKey,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _vm.codeCtrl,
                                    decoration: InputDecoration(labelText: t.recover_codeLabel),
                                    validator: (v) => (v == null || v.isEmpty) ? t.recover_codeRequired : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _vm.pass1Ctrl,
                                    obscureText: _vm.obscure1,
                                    decoration: InputDecoration(
                                      labelText: t.recover_newPasswordLabel,
                                      suffixIcon: IconButton(
                                        splashRadius: 20,
                                        icon: Icon(_vm.obscure1 ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF64748B)),
                                        tooltip: _vm.obscure1 ? t.auth_showPassword : t.auth_hidePassword,
                                        onPressed: _vm.toggleObscure1,
                                      ),
                                    ),
                                    validator: (v) => (v == null || v.isEmpty) ? t.auth_passwordRequired : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _vm.pass2Ctrl,
                                    obscureText: _vm.obscure2,
                                    decoration: InputDecoration(
                                      labelText: t.recover_repeatPasswordLabel,
                                      suffixIcon: IconButton(
                                        splashRadius: 20,
                                        icon: Icon(_vm.obscure2 ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF64748B)),
                                        tooltip: _vm.obscure2 ? t.auth_showPassword : t.auth_hidePassword,
                                        onPressed: _vm.toggleObscure2,
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return t.recover_repeatPasswordRequired;
                                      if (v != _vm.pass1Ctrl.text) return t.recover_passwordsMismatch;
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  if (_vm.setError != null)
                                    Text(_setErrorToText(_vm.setError!, t), style: TextStyle(color: scheme.error)),

                                  SizedBox(
                                    height: 44,
                                    width: double.infinity,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: _vm.loadingSet
                                          ? null
                                          : () async {
                                        final ok = await _vm.setPassword();
                                        if (!mounted) return;
                                        if (ok) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(t.recover_passwordChangedSnack)),
                                          );
                                        }
                                      },
                                      child: _vm.loadingSet
                                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                          : Text(t.recover_setPassword),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // mapowanie enumów → teksty z lokalizacji
  String _codeInfoToText(RecoverCodeInfo info, AppLocalizations t) {
    switch (info) {
      case RecoverCodeInfo.sentSms:
        return t.recover_codeSentInfo;
    }
  }

  String _codeErrorToText(RecoverCodeError err, AppLocalizations t) {
    switch (err) {
      case RecoverCodeError.invalidLoginOrPhone:
        return t.recover_invalidLoginOrPhone;
      case RecoverCodeError.network:
        return t.common_networkError;
      case RecoverCodeError.unknown:
        return t.common_unknownError;
    }
  }

  String _setErrorToText(RecoverSetError err, AppLocalizations t) {
    switch (err) {
      case RecoverSetError.invalidCodeOrPolicy:
        return t.recover_invalidCodeOrPolicy;
      case RecoverSetError.network:
        return t.common_networkError;
      case RecoverSetError.unknown:
        return t.common_unknownError;
    }
  }
}
