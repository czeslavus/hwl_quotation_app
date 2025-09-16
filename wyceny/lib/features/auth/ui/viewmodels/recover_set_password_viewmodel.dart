import 'package:flutter/material.dart';
import 'package:e_kierowca_app/core/exceptions/recover_set_password_exception.dart';
import 'package:e_kierowca_app/features/auth/domain/services/auth_service.dart';

class RecoverSetPasswordViewModel extends ChangeNotifier {

  final AuthService _authService;

  final formKey = GlobalKey<FormState>();
  final usernameCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final pass1Ctrl = TextEditingController();
  final pass2Ctrl = TextEditingController();

  bool loading = false;
  String? error;

  RecoverSetPasswordViewModel(this._authService);

  Future<bool> setPassword() async {
    if (!formKey.currentState!.validate()) return false;
    error = null;
    loading = true;
    notifyListeners();

    try {
      final ok = await _authService.recoverSetPassword(
        usernameCtrl.text.trim(),
        codeCtrl.text.trim(),
        pass1Ctrl.text,
      );
      loading = false;
      if (ok == true) {
        return true;
      } else {
        error = 'Nieprawidłowy kod lub hasło nie spełnia wymagań';
        notifyListeners();
        return false;
      }
    } on RecoverSetPasswordException catch (e) {
      loading = false;
      error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      loading = false;
      error = 'Wystąpił błąd. Spróbuj ponownie.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    codeCtrl.dispose();
    pass1Ctrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }
}
