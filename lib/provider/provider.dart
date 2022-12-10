import 'package:flutter/material.dart';

class TabNotifier extends ChangeNotifier {
  int currentIndex = 1;
  get getindex => currentIndex;
  set setindex(int val) {
    currentIndex = val;
    notifyListeners();
  }
}
