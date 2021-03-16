import 'package:get/get.dart';
import 'package:telegramchatapp/Models/user.dart';

class UserController extends GetxController {
  Rx<List<User>> eachUser = Rx<List<User>>();

  List<User> get users => eachUser.value;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
}
