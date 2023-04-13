import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'network_services.dart';
import 'package:http/http.dart' as http;

Future<http.Response> getLocationData(String text) async {
  http.Response response;

  response = await http.get(
    Uri.parse(dotenv.env['API_URL']! +
        "/CommonController/testLocationList?search_text=$text"),
    headers: {"Content-Type": "application/json"},
  );
  return response;
}

// Future getLocationData(String text) async {
//   return handleResponse(
//       await securedPostRequest("CommonController/testLocationList", text));
// }

Future getStateList(Map req) async {
  return handleResponse(
      await securedPostRequest("get_statelist_by_country_id", req));
}

Future customerSignup(Map req) async {
  return handleResponse(await securedPostRequest("cust_signup", req));
}

Future getCustomerVehicles(Map req) async {
  return handleResponse(await securedPostRequest('customer_vehicle_list', req));
}

Future getCustomerBookingList(Map req) async {
  return handleResponse(await securedPostRequest(
      'Booking/BookingController/getCustomerBookings', req));
}

Future getPackages(Map req) async {
  return handleResponse(
      await securedPostRequest('Package/PackageController/packageList', req));
}

Future getVehicleModels(Map req) async {
  return handleResponse(await securedPostRequest("get_vehicle_models", req));
}

Future getVehicleVariants(Map req) async {
  return handleResponse(await securedPostRequest("get_vehicle_variants", req));
}

Future getVehicleModelYears(Map req) async {
  return handleResponse(await securedPostRequest("get_vehicle_years", req));
}

Future getVehicleModelVariantYears(Map req) async {
  return handleResponse(
      await securedPostRequest("get_vehicle_varient_years", req));
}

Future addCustomerVehicle(Map req) async {
  return handleResponse(
      await securedPostRequest("Customer/CustomerVehicleController", req));
}

Future getVehicleBrands() async {
  return handleResponse(await securedGetRequest('get_vehicle_brands'));
}

Future getbookingjobs_forcustomer(Map req) async {
  return handleResponse(await securedPostRequest(
      'Booking/BookingController/getbookingjobs_forcustomer', req));
}

Future getbookingdetails(Map req) async {
  return handleResponse(await securedPostRequest(
      'Booking/BookingController/getbookingdetails_forcustomer', req));
}

Future booking_unhold(Map req) async {
  return handleResponse(
      await securedPostRequest('Booking/BookingController/Update_status', req));
}

Future booking_cancel(Map req) async {
  return handleResponse(
      await securedPostRequest('Booking/BookingController/hold_booking', req));
}

Future getPackageDetails(Map req) async {
  return handleResponse(
      await securedPostRequest('Package/GetVehiclePackage', req));
}

Future read_notification(Map req) async {
  return handleResponse(await securedPostRequest(
      'System/NotificationController/read_notification', req));
}

Future getCustomerNotificationList(Map req) async {
  return handleResponse(await securedPostRequest(
      'System/NotificationController/get_customer_notifications', req));
}

Future getCustomerAddresses(Map req) async {
  return handleResponse(await securedPostRequest(
      'Customer/CustomerAddressController/index', req));
}

Future getPickupOptions() async {
  return handleResponse(await securedGetRequest('System/PickupTypeController'));
}

Future getTimeSlotsForBooking(Map req) async {
  return handleResponse(
      await securedPostRequest('Get_availabletimeslotby_id', req));
}

Future getCityList(Map req) async {
  return handleResponse(
      await securedPostRequest("get_citylist_by_state_id", req));
}

Future getprofiledetails(Map req) async {
  return handleResponse(await securedPostRequest('get_customer_by_id', req));
}

Future profile_update(Map req) async {
  return handleResponse(await securedPostRequest('customer_update', req));
}

Future deleteCustomerVehicle(Map req) async {
  return handleResponse(await securedPostRequest(
      'Customer/CustomerVehicleController/delete', req));
}

Future saveCustomerMessage(Map req) async {
  return handleResponse(
      await securedPostRequest('Customer/SupportChatController', req));
}

Future getCustomerMessages(data) async {
  return handleResponse(
      await securedGetRequest('Customer/SupportChatController/' + data));
}

Future get_service_history(Map req) async {
  return handleResponse(await securedPostRequest(
      'Booking/BookingController/getCustomerBookinghistory', req));
}

Future getInspectionDetails(Map req) async {
  return handleResponse(await securedPostRequest(
      'Booking/BookingController/Get_inspection_by_bookid', req));
}

Future create_workcard_payment(Map req) async {
  return handleResponse(await securedPostRequest(
      'Booking/BookingController/create_jobpayment_booking', req));
}

Future withoutpayment(Map req) async {
  return handleResponse(await securedPostRequest(
      'Booking/BookingController/Job_status_update_bycust', req));
}

Future getcardjobdetails(Map req) async {
  return handleResponse(await securedPostRequest(
      'Booking/BookingController/Get_jobdetails_bybkid', req));
}

Future confirmbookingpayment(Map req) async {
  return handleResponse(await securedPostRequest(
      'Booking/BookingController/confirm_booking_payment', req));
}

Future create_payment_for_job_workcard(Map req) async {
  return handleResponse(await securedPostRequest(
      'Booking/BookingController/create_payment_for_job', req));
}

Future getServicePackageDetails(Map req) async {
  return handleResponse(await securedPostRequest('getDynamicPackgeDatas', req));
}

Future saveCustomerAddress(Map req) async {
  return handleResponse(
      await securedPostRequest('Customer/CustomerAddressController', req));
}

Future createRescheduleBooking(Map req) async {
  return handleResponse(await securedPostRequest('createawaitingbooking', req));
}

Future submitdeliverydrop(Map req) async {
  return handleResponse(await securedPostRequest(
      'Booking/BookingController/save_droplocationforbooking', req));
}

Future booking_reschedule(Map req) async {
  return handleResponse(await securedPostRequest(
      'Booking/BookingController/reschedule_booking', req));
}

Future clear_notification(Map req) async {
  return handleResponse(await securedPostRequest(
      'System/NotificationController/clear_customer_notifications', req));
}

Future deleteCustomerAddress(Map req) async {
  return handleResponse(await securedPostRequest(
      'Customer/CustomerAddressController/delete', req));
}

Future getCustomerAddressDetails(req) async {
  return handleResponse(await securedGetRequest(
      'Customer/CustomerAddressController/' + base64.encode(utf8.encode(req))));
}

Future updateCustomerAddress(Map req) async {
  return handleResponse(await securedPostRequest(
      'Customer/CustomerAddressController/update', req));
}

Future getCustomerVehicleDetails(req) async {
  return handleResponse(await securedGetRequest(
      'Customer/CustomerVehicleController/' + base64.encode(utf8.encode(req))));
}

Future updateCustomerVehicle(Map req) async {
  return handleResponse(await securedPostRequest(
      'Customer/CustomerVehicleController/update', req));
}
