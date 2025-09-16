import 'package:flutter/material.dart';
import 'package:e_kierowca_app/features/auth/domain/services/auth_service.dart';

class RecoverSetPasswordScreen extends StatefulWidget {
  final AuthService authService;
  const RecoverSetPasswordScreen({super.key, required this.authService});

  @override
  State<RecoverSetPasswordScreen> createState() =>
      _RecoverSetPasswordScreenState();
}

class _RecoverSetPasswordScreenState extends State<RecoverSetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _pass1Ctrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  bool _loadingCode = false;
  bool _loadingSet = false;
  String? _codeInfo;
  String? _setError;
  String? _codeError;

  Future<void> _sendCode() async {
    setState(() {
      _loadingCode = true;
      _codeError = null;
      _codeInfo = null;
    });
    try {
      final ok = await widget.authService.recoverRequest(_userCtrl.text.trim());
      if (ok) {
        setState(() {
          _codeInfo = 'Kod został wysłany SMS-em';
        });
      } else {
        setState(() {
          _codeError = 'Nieprawidłowy login lub brak numeru telefonu';
        });
      }
    } catch (_) {
      setState(() {
        _codeError = 'Wystąpił błąd. Spróbuj ponownie.';
      });
    } finally {
      setState(() {
        _loadingCode = false;
      });
    }
  }

  Future<void> _setPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loadingSet = true;
      _setError = null;
    });
    try {
      final ok = await widget.authService.recoverSetPassword(
        _userCtrl.text.trim(),
        _codeCtrl.text.trim(),
        _pass1Ctrl.text,
      );
      if (ok && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hasło zostało zmienione. Możesz się zalogować.'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _setError = e is Exception
            ? e.toString()
            : 'Wystąpił błąd. Spróbuj ponownie.';
      });
    } finally {
      setState(() {
        _loadingSet = false;
      });
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _codeCtrl.dispose();
    _pass1Ctrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Odzyskiwanie hasła')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // GÓRNA CZĘŚĆ: wysyłanie kodu
                  TextFormField(
                    controller: _userCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nazwa użytkownika',
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loadingCode ? null : _sendCode,
                      child: _loadingCode
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Wyślij kod'),
                    ),
                  ),
                  if (_codeInfo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _codeInfo!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  if (_codeError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _codeError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const Divider(height: 32),
                  // DOLNA CZĘŚĆ: ustawianie nowego hasła
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _codeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Kod z SMS',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Podaj kod' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _pass1Ctrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Nowe hasło',
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Podaj hasło' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _pass2Ctrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Powtórz hasło',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Powtórz hasło';
                            if (v != _pass1Ctrl.text) {
                              return 'Hasła się nie zgadzają';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_setError != null)
                          Text(
                            _setError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loadingSet ? null : _setPassword,
                            child: _loadingSet
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Ustaw nowe hasło'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
