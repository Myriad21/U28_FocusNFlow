import 'package:flutter/material.dart';

class AppNavigation {
  static final ValueNotifier<int> selectedTab = ValueNotifier<int>(0);

  static void goTo(int index) {
    selectedTab.value = index;
  }
}
