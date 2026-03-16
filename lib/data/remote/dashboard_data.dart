import 'package:get/get.dart';
import 'package:softel_control/core/class/crud.dart';


class DashboardData {
  Crud crud;

  DashboardData(this.crud);

  // Fetch overall sales data
  Future<Response> getDashboardSales() async {
    var response = await crud.post("AppLink.dashboardSales", {});
    return response;
  }

  // Fetch sales by payment method
  Future<Response> getSalesByPaymentMethod() async {
    var response = await crud.post("AppLink.sales ByPaymentMethod", {});
    return response;
  }

  // Fetch sales over time with optional date range
  Future<Response> getSalesOverTime({
    String? startDate,
    String? endDate,
  }) async {
    String url = "AppLink.salesOverTime";

    if (startDate != null && endDate != null) {
      url += "?start_date=$startDate&end_date=$endDate";
    }

    var response = await crud.post(url, {});
    return response;
  }
}
