import 'package:softel_control/controller/subscription_controller.dart';
import 'package:softel_control/controller/dashboard_controller.dart';
import 'package:softel_control/controller/client_controller.dart';
import 'package:softel_control/controller/application_controller.dart';
import 'package:softel_control/core/class/crud.dart';
import 'package:softel_control/controller/auth_controller.dart';
import 'package:get/get.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Crud(), permanent: true);
    Get.put(AuthController(), permanent: true);

    // Dashboard first so others can find its searchQuery
    Get.put<DashboardController>(DashboardController(), permanent: true);

    // Register dependencies
    Get.put<ClientController>(ClientController(), permanent: true);
    Get.put<ApplicationController>(ApplicationController(), permanent: true);
    Get.put<SubscriptionController>(SubscriptionController(), permanent: true);
  }
}
