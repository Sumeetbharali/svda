import 'dart:convert';
import 'dart:developer';

import 'package:eshop/Provider/SettingProvider.dart';
import 'package:eshop/Provider/SmsServicesProvider.dart';
import 'package:eshop/settings.dart';
import 'package:eshop/ui/styles/DesignConfig.dart';
import 'package:eshop/utils/Hive/hive_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../Model/brands_model.dart';

class GetBrandsProvider extends ChangeNotifier {
  bool isLoading = false;

  bool isShowBrand = false;

  BrandModel? _brandModel;
  BrandModel? get brandModel => _brandModel;

  Future<void> getBrandId({required String brandId}) async {
    const String apiUrl = '${AppSettings.baseUrl}get_brands_data';

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(
          {"brand_id": brandId},
        ),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        _brandModel = BrandModel.fromJson(jsonResponse);
        log(response.body);
      }
    } catch (e) {
      log('An error occurred: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class LoginProvider extends ChangeNotifier {
  bool isLoading = false;

  dynamic _loginModel;
  dynamic get loginModel => _loginModel;

  Future<void> login(BuildContext context, {required String mobile}) async {
    const String apiUrl = '${AppSettings.baseUrl}get_brands_data';

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode({"mobile": mobile}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        _loginModel = jsonResponse;
      } else {
        setSnackbar("Failed to login", context);
      }
    } catch (e) {
      log('An error occurred: $e');
      setSnackbar("An error occurred", context);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

var otpResponse;

Future<void> getVerifyUser(context, String mobile) async {
  try {
    const String authorizationToken =
        "TUtCij4Zzvxd1khM7wyXrOPFalGR5KHSb2LQW0V8NnqD9EpAfszUuiR4bBjVJ8CGKgIfcZFepyntsXo0";
    final otp = (100000 +
            (999999 - 100000) *
                (DateTime.now().millisecondsSinceEpoch % 100000) ~/
                100000)
        .toString();
    otpResponse = otp;
    log(otp, name: "OTP");

    final url =
        "https://www.fast2sms.com/dev/bulkV2?authorization=$authorizationToken&route=otp&variables_values=$otp&flash=0&numbers=$mobile";
    final headers = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Connection': 'keep-alive',
      'auth-token': authorizationToken,
    };

    final response = await http.get(Uri.parse(url), headers: headers);
    final responseBody = json.decode(response.body);

    if (response.statusCode == 200 && responseBody['return'] == true) {
      // OTP sent successfully
      log("OTP sent successfully.", name: "API");
      otpResponse = otp;
      if (kDebugMode) {
        print("$otp :  Otp sendedl̥");
      }
      SmsServiceProvider smsServiceProvider =
          Provider.of<SmsServiceProvider>(context, listen: false);
      // smsServiceProvider.showNotification(otp);

      SettingProvider settingsProvider =
          Provider.of<SettingProvider>(context, listen: false);
    }
  } catch (error) {
    setSnackbar(error.toString(), context);
  } finally {}
}
