import 'network_services.dart';

Future customerLoginService(Map req) async {
  return handleResponse(await postRequest("send_signin_otp", req));
}

Future customerOTPViaCall(Map req) async {
  return handleResponse(await postRequest("send_signin_otp_call", req));
}

Future verifyOtp(Map req) async {
  return handleResponse(await postRequest("verify_signin_otp", req));
}
