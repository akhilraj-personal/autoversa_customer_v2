import 'network_services.dart';

Future getStateList(Map req) async {
  return handleResponse(
      await securedPostRequest("get_statelist_by_country_id", req));
}
