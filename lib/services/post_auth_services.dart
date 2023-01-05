import 'package:autoversa/utils/app_validations.dart';

import 'network_services.dart';

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
      'system/NotificationController/read_notification', req));
}

Future getCustomerNotificationList() async {
  return handleResponse(
      await securedGetRequest('system/NotificationController/'));
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
