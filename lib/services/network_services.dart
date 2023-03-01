import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/network_utils.dart';

Map buildHeader() {
  return {
    'Content-Type': 'application/json',
  };
}

Future<Response> postRequest(String endPoint, body) async {
  try {
    if (!await isNetworkAvailable()) {
      var temp = await isNetworkAvailable();
      if (Platform.isAndroid) {
        if (!temp) {
          throw "NETWORK_ERROR";
        }
      }
    }
    String url = dotenv.env['API_URL']! + endPoint;
    Response response = await post(Uri.parse(url), body: body).timeout(
        Duration(seconds: 30),
        onTimeout: (() => throw "SERVER_NOT_REACHABLE"));
    return response;
  } catch (e) {
    throw "INTERNAL_ERROR";
  }
}

Future<Response> securedPostRequest(String endPoint, body) async {
  try {
    if (!await isNetworkAvailable()) throw "NETWORK_ERROR";
    String url = dotenv.env['API_URL']! + endPoint;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    Response response = await post(Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: jsonEncode(body))
        .timeout(Duration(seconds: 30),
            onTimeout: (() => throw "SERVER_NOT_REACHABLE"));
    return response;
  } catch (e) {
    throw "INTERNAL_ERROR";
  }
}

Future<Response> getRequest(String endPoint) async {
  try {
    if (!await isNetworkAvailable()) throw "NETWORK_ERROR";
    String url = dotenv.env['API_URL']! + endPoint;
    Response response = await get(Uri.parse(url)).timeout(Duration(seconds: 30),
        onTimeout: (() => throw "SERVER_NOT_REACHABLE"));
    return response;
  } catch (e) {
    throw "INTERNAL_ERROR";
  }
}

Future<Response> securedGetRequest(String endPoint) async {
  try {
    if (!await isNetworkAvailable()) throw "NETWORK_ERROR";
    String url = dotenv.env['API_URL']! + endPoint;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    Response response = await get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    }).timeout(Duration(seconds: 30),
        onTimeout: (() => throw "SERVER_NOT_REACHABLE"));
    return response;
  } catch (e) {
    throw "INTERNAL_ERROR";
  }
}

Future handleResponse(Response response) async {
  if (response.statusCode >= 200 && response.statusCode <= 206) {
    return jsonDecode(response.body);
  } else {
    if (!response.body.isEmpty && response.body != 'null') {
      throw jsonDecode(response.body);
    } else {
      if (!await isNetworkAvailable()) {
        throw "NETWORK_ERROR";
      } else {
        throw "INTERNAL_SERVER_ERROR";
      }
    }
  }
}
