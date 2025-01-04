import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SmsServiceProvider with ChangeNotifier {
  final String apiUrl = "https://www.fast2sms.com/dev/bulkV2";
  final String authorizationToken =
      "TUtCij4Zzvxd1khM7wyXrOPFalGR5KHSb2LQW0V8NnqD9EpAfszUuiR4bBjVJ8CGKgIfcZFepyntsXo0";
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// https://www.fast2sms.com/dev/bulkV2?authorization=TUtCij4Zzvxd1khM7wyXrOPFalGR5KHSb2LQW0V8NnqD9EpAfszUuiR4bBjVJ8CGKgIfcZFepyntsXo0&route=otp&variables_values=123456&flash=0&numbers=6203002599
  SmsServiceProvider(this.flutterLocalNotificationsPlugin);

  Future<void> sendOtp(String phoneNumber) async {
    final otp = (100000 +
            (999999 - 100000) *
                (DateTime.now().millisecondsSinceEpoch % 100000) ~/
                100000)
        .toString();
    log(otp, name: "OTP");
    final url =
        "https://www.fast2sms.com/dev/bulkV2?authorization=$authorizationToken&route=otp&variables_values=$otp&flash=0&numbers=$phoneNumber"; // final url =
    //     "$apiUrl?authorization=$authorizationToken&route=otp&variables_values=$otp&flash=0&numbers=$phoneNumber";
    final headers = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Connection': 'keep-alive',
      'auth-token': authorizationToken,
    };
    try {
      final response = await http.get(
        headers: headers,
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        // showNotification(otp);
        log(response.body);
      } else {
        log(response.body);

        log("Failed to send OTP: ${response.statusCode}");
      }
    } catch (e) {
      log("Error: $e");
    }
  }

  // void showNotification(String otp) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails('otp_channel', 'OTP Notifications',
  //           channelDescription: 'Channel for OTP notifications',
  //           importance: Importance.max,
  //           priority: Priority.high);
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Your OTP',
  //     'Your OTP is: $otp',
  //     platformChannelSpecifics,
  //     payload: 'item x',
  //   );
  // }
}
