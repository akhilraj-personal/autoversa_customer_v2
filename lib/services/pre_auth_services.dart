import 'network_services.dart';

Future customerLoginService(Map req) async {
  return handleResponse(await postRequest("send_signin_otp", req));
}
