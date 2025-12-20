import 'package:get/get.dart';

class DashboardController extends GetxController {
  final currentIndex = 0.obs;

  void setTab(int index) {
    if (currentIndex.value == index) return;
    currentIndex.value = index;
  }
}
