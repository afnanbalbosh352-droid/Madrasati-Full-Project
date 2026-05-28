import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  // اللغة الافتراضية للتطبيق هي الإنجليزية
  Locale _appLocale = const Locale('en');

  Locale get appLocale => _appLocale;

  void changeLanguage(Locale type) {
    if (_appLocale == type) return;
    _appLocale = type;
    
    notifyListeners(); 
  }
}