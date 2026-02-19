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
    // Start
    Get.put(Crud());

    Get.put(AuthController());

    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<ClientController>(() => ClientController(), fenix: true);
    Get.lazyPut<ApplicationController>(
      () => ApplicationController(),
      fenix: true,
    );
    Get.lazyPut<SubscriptionController>(
      () => SubscriptionController(),
      fenix: true,
    );
  }
}
