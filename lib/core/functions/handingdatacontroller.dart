import 'package:softel_control/core/class/statusrequest.dart';

StatusRequest handlingData(response) {
  if (response is StatusRequest) {
    return response;
  } else {
    return StatusRequest.success;
  }
}
