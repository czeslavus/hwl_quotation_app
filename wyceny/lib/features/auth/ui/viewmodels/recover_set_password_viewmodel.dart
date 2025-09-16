import 'package:flutter/material.dart';
import 'package:wyceny/features/auth/domain/services/auth_service.dart';
import 'package:dio/dio.dart';

enum RecoverCodeInfo { sentSms }
enum RecoverCodeError { invalidLoginOrPhone, network, unknown }
enum RecoverSetError { invalidCodeOrPolicy, network, unknown }

class RecoverSetPasswordViewModel extends ChangeNotifier {
  final AuthService _auth;

  // Form + kontrolery
  final formKey = GlobalKey<FormState>();
  final usernameCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final pass1Ctrl = TextEditingController();
  final pass2Ctrl = TextEditingController();

  // UI state
  bool loadingCode = false;
  bool loadingSet = false;
  bool obscure1 = true;
  bool obscure2 = true;

  RecoverCodeInfo? codeInfo;
  RecoverCodeError? codeError;
  RecoverSetError? setError;

  RecoverSetPasswordViewModel(this._auth);

  void toggleObscure1() {
    obscure1 = !obscure1;
    notifyListeners();
  }

  void toggleObscure2() {
    obscure2 = !obscure2;
    notifyListeners();
  }

  Future<void> sendCode() async {
    loadingCode = true;
    codeInfo = null;
    codeError = null;
    notifyListeners();
    try {
      final ok = await _auth.recoverRequest(usernameCtrl.text.trim());
      if (ok) {
        codeInfo = RecoverCodeInfo.sentSms;
      } else {
        codeError = RecoverCodeError.invalidLoginOrPhone;
      }
    } on DioError {
      codeError = RecoverCodeError.network;
    } catch (_) {
      codeError = RecoverCodeError.unknown;
    } finally {
      loadingCode = false;
      notifyListeners();
    }
  }

  Future<bool> setPassword() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    loadingSet = true;
    setError = null;
    notifyListeners();

    try {
      final ok = await _auth.recoverSetPassword(
        usernameCtrl.text.trim(),
        codeCtrl.text.trim(),
        pass1Ctrl.text,
      );
      loadingSet = false;
      if (ok) {
        notifyListeners();
        return true;
      } else {
        setError = RecoverSetError.invalidCodeOrPolicy;
        notifyListeners();
        return false;
      }
    } on DioError {
      loadingSet = false;
      setError = RecoverSetError.network;
      notifyListeners();
      return false;
    } catch (_) {
      loadingSet = false;
      setError = RecoverSetError.unknown;
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
