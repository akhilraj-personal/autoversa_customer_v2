import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabNotifier extends ChangeNotifier {
  int currentIndex = 1;
  get getindex => currentIndex;
  set setindex(int val) {
    currentIndex = val;
    notifyListeners();
  }
}

class LanguageChangeProvider with ChangeNotifier {
  Locale _currentLocale = new Locale("en");
  Locale get currentLocale => _currentLocale;
  void changeLocale(String _locale) {
    this._currentLocale = new Locale(_locale);
    Get.updateLocale(this._currentLocale);
    notifyListeners();
  }
}
