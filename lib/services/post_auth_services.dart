import 'network_services.dart';

Future getStateList(Map req) async {
  return handleResponse(
      await securedPostRequest("get_statelist_by_country_id", req));
}

Future customerSignup(Map req) async {
  return handleResponse(await securedPostRequest("cust_signup", req));
}
