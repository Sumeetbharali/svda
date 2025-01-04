import 'dart:convert';
import 'dart:developer';

import 'package:eshop/Helper/ApiBaseHelper.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Model/whatsapp_number_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class WhatsAppNumberProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  WhatsAppNumberModel? _whatsAppNumberModel;
  WhatsAppNumberModel? get whatsAppNumberModel => _whatsAppNumberModel;

  Future<void> getWhatsAppNumber() async {
    _isLoading = true;
    try {
      final response = await http.post(Uri.parse(
          "https://suvidhasupermarket.xyz/app/v1/api/get_system_settings"));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        _whatsAppNumberModel = WhatsAppNumberModel.fromJson(responseData);
        log(responseData.toString(), name: "Whatsapp number");
      }
    } catch (e) {
      log("Error : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
