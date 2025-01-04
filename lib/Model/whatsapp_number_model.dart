class WhatsAppNumberModel {
  WhatsAppNumberModel({
    required this.error,
    required this.message,
    required this.data,
  });
  late final bool error;
  late final String message;
  late final Data data;

  WhatsAppNumberModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['error'] = error;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.systemSettings,
  });
  late final List<SystemSettings> systemSettings;

  Data.fromJson(Map<String, dynamic> json) {
    systemSettings = List.from(json['system_settings'])
        .map((e) => SystemSettings.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['system_settings'] = systemSettings.map((e) => e.toJson()).toList();
    return _data;
  }
}

class SystemSettings {
  SystemSettings({
    required this.systemConfigurations,
    required this.systemTimezoneGmt,
    required this.systemConfigurationsId,
    required this.appName,
    required this.supportNumber,
    required this.supportEmail,
    required this.copyrightDetails,
    required this.currentVersion,
    required this.currentVersionIos,
    required this.isVersionSystemOn,
    required this.areaWiseDeliveryCharge,
    required this.currency,
    required this.deliveryCharge,
    required this.minAmount,
    required this.systemTimezone,
    required this.isReferEarnOn,
    required this.minReferEarnOrderAmount,
    required this.referEarnBonus,
    required this.referEarnMethod,
    required this.maxReferEarnAmount,
    required this.referEarnBonusTimes,
    required this.welcomeWalletBalanceOn,
    required this.walletBalanceAmount,
    required this.minimumCartAmt,
    required this.lowStockLimit,
    required this.maxItemsCart,
    required this.deliveryBoyBonusPercentage,
    required this.maxProductReturnDays,
    required this.isDeliveryBoyOtpSettingOn,
    required this.cartBtnOnList,
    required this.expandProductImages,
    required this.taxName,
    required this.taxNumber,
    required this.companyName,
    required this.companyUrl,
    required this.supportedLocals,
    required this.isCustomerAppUnderMaintenance,
    required this.isAdminAppUnderMaintenance,
    required this.isWebUnderMaintenance,
    required this.isDeliveryBoyAppUnderMaintenance,
    required this.messageForCustomerApp,
    required this.messageForAdminApp,
    required this.messageForWeb,
    required this.messageForDeliveryBoyApp,
    required this.isOfferPopupOn,
    required this.googleLogin,
    required this.appleLogin,
    required this.facebookLogin,
    required this.whatsappStatus,
    required this.whatsappNumber,
    required this.offerPopupMethod,
    required this.localPickup,
    required this.address,
    required this.adminStoreState,
    required this.latitude,
    required this.longitude,
    required this.pincodeWiseDeliverability,
    required this.cityWiseDeliverability,
    required this.androidAppStoreLink,
    required this.iosAppStoreLink,
    required this.scheme,
    required this.host,
  });
  late final String systemConfigurations;
  late final String systemTimezoneGmt;
  late final String systemConfigurationsId;
  late final String appName;
  late final String supportNumber;
  late final String supportEmail;
  late final String copyrightDetails;
  late final String currentVersion;
  late final String currentVersionIos;
  late final String isVersionSystemOn;
  late final String areaWiseDeliveryCharge;
  late final String currency;
  late final String deliveryCharge;
  late final String minAmount;
  late final String systemTimezone;
  late final String isReferEarnOn;
  late final String minReferEarnOrderAmount;
  late final String referEarnBonus;
  late final String referEarnMethod;
  late final String maxReferEarnAmount;
  late final String referEarnBonusTimes;
  late final String welcomeWalletBalanceOn;
  late final String walletBalanceAmount;
  late final String minimumCartAmt;
  late final String lowStockLimit;
  late final String maxItemsCart;
  late final String deliveryBoyBonusPercentage;
  late final String maxProductReturnDays;
  late final String isDeliveryBoyOtpSettingOn;
  late final String cartBtnOnList;
  late final String expandProductImages;
  late final String taxName;
  late final String taxNumber;
  late final String companyName;
  late final String companyUrl;
  late final String supportedLocals;
  late final String isCustomerAppUnderMaintenance;
  late final String isAdminAppUnderMaintenance;
  late final String isWebUnderMaintenance;
  late final String isDeliveryBoyAppUnderMaintenance;
  late final String messageForCustomerApp;
  late final String messageForAdminApp;
  late final String messageForWeb;
  late final String messageForDeliveryBoyApp;
  late final int isOfferPopupOn;
  late final int googleLogin;
  late final int appleLogin;
  late final int facebookLogin;
  late final int whatsappStatus;
  late final String whatsappNumber;
  late final String offerPopupMethod;
  late final String localPickup;
  late final String address;
  late final String adminStoreState;
  late final String latitude;
  late final String longitude;
  late final String pincodeWiseDeliverability;
  late final String cityWiseDeliverability;
  late final String androidAppStoreLink;
  late final String iosAppStoreLink;
  late final String scheme;
  late final String host;

  SystemSettings.fromJson(Map<String, dynamic> json) {
    systemConfigurations = json['system_configurations'];
    systemTimezoneGmt = json['system_timezone_gmt'];
    systemConfigurationsId = json['system_configurations_id'];
    appName = json['app_name'];
    supportNumber = json['support_number'];
    supportEmail = json['support_email'];
    copyrightDetails = json['copyright_details'];
    currentVersion = json['current_version'];
    currentVersionIos = json['current_version_ios'];
    isVersionSystemOn = json['is_version_system_on'];
    areaWiseDeliveryCharge = json['area_wise_delivery_charge'];
    currency = json['currency'];
    deliveryCharge = json['delivery_charge'];
    minAmount = json['min_amount'];
    systemTimezone = json['system_timezone'];
    isReferEarnOn = json['is_refer_earn_on'];
    minReferEarnOrderAmount = json['min_refer_earn_order_amount'];
    referEarnBonus = json['refer_earn_bonus'];
    referEarnMethod = json['refer_earn_method'];
    maxReferEarnAmount = json['max_refer_earn_amount'];
    referEarnBonusTimes = json['refer_earn_bonus_times'];
    welcomeWalletBalanceOn = json['welcome_wallet_balance_on'];
    walletBalanceAmount = json['wallet_balance_amount'];
    minimumCartAmt = json['minimum_cart_amt'];
    lowStockLimit = json['low_stock_limit'];
    maxItemsCart = json['max_items_cart'];
    deliveryBoyBonusPercentage = json['delivery_boy_bonus_percentage'];
    maxProductReturnDays = json['max_product_return_days'];
    isDeliveryBoyOtpSettingOn = json['is_delivery_boy_otp_setting_on'];
    cartBtnOnList = json['cart_btn_on_list'];
    expandProductImages = json['expand_product_images'];
    taxName = json['tax_name'];
    taxNumber = json['tax_number'];
    companyName = json['company_name'];
    companyUrl = json['company_url'];
    supportedLocals = json['supported_locals'];
    isCustomerAppUnderMaintenance = json['is_customer_app_under_maintenance'];
    isAdminAppUnderMaintenance = json['is_admin_app_under_maintenance'];
    isWebUnderMaintenance = json['is_web_under_maintenance'];
    isDeliveryBoyAppUnderMaintenance =
        json['is_delivery_boy_app_under_maintenance'];
    messageForCustomerApp = json['message_for_customer_app'];
    messageForAdminApp = json['message_for_admin_app'];
    messageForWeb = json['message_for_web'];
    messageForDeliveryBoyApp = json['message_for_delivery_boy_app'];
    isOfferPopupOn = json['is_offer_popup_on'];
    googleLogin = json['google_login'];
    appleLogin = json['apple_login'];
    facebookLogin = json['facebook_login'];
    whatsappStatus = json['whatsapp_status'];
    whatsappNumber = json['whatsapp_number'];
    offerPopupMethod = json['offer_popup_method'];
    localPickup = json['local_pickup'];
    address = json['address'];
    adminStoreState = json['admin_store_state'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    pincodeWiseDeliverability = json['pincode_wise_deliverability'];
    cityWiseDeliverability = json['city_wise_deliverability'];
    androidAppStoreLink = json['android_app_store_link'];
    iosAppStoreLink = json['ios_app_store_link'];
    scheme = json['scheme'];
    host = json['host'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['system_configurations'] = systemConfigurations;
    _data['system_timezone_gmt'] = systemTimezoneGmt;
    _data['system_configurations_id'] = systemConfigurationsId;
    _data['app_name'] = appName;
    _data['support_number'] = supportNumber;
    _data['support_email'] = supportEmail;
    _data['copyright_details'] = copyrightDetails;
    _data['current_version'] = currentVersion;
    _data['current_version_ios'] = currentVersionIos;
    _data['is_version_system_on'] = isVersionSystemOn;
    _data['area_wise_delivery_charge'] = areaWiseDeliveryCharge;
    _data['currency'] = currency;
    _data['delivery_charge'] = deliveryCharge;
    _data['min_amount'] = minAmount;
    _data['system_timezone'] = systemTimezone;
    _data['is_refer_earn_on'] = isReferEarnOn;
    _data['min_refer_earn_order_amount'] = minReferEarnOrderAmount;
    _data['refer_earn_bonus'] = referEarnBonus;
    _data['refer_earn_method'] = referEarnMethod;
    _data['max_refer_earn_amount'] = maxReferEarnAmount;
    _data['refer_earn_bonus_times'] = referEarnBonusTimes;
    _data['welcome_wallet_balance_on'] = welcomeWalletBalanceOn;
    _data['wallet_balance_amount'] = walletBalanceAmount;
    _data['minimum_cart_amt'] = minimumCartAmt;
    _data['low_stock_limit'] = lowStockLimit;
    _data['max_items_cart'] = maxItemsCart;
    _data['delivery_boy_bonus_percentage'] = deliveryBoyBonusPercentage;
    _data['max_product_return_days'] = maxProductReturnDays;
    _data['is_delivery_boy_otp_setting_on'] = isDeliveryBoyOtpSettingOn;
    _data['cart_btn_on_list'] = cartBtnOnList;
    _data['expand_product_images'] = expandProductImages;
    _data['tax_name'] = taxName;
    _data['tax_number'] = taxNumber;
    _data['company_name'] = companyName;
    _data['company_url'] = companyUrl;
    _data['supported_locals'] = supportedLocals;
    _data['is_customer_app_under_maintenance'] = isCustomerAppUnderMaintenance;
    _data['is_admin_app_under_maintenance'] = isAdminAppUnderMaintenance;
    _data['is_web_under_maintenance'] = isWebUnderMaintenance;
    _data['is_delivery_boy_app_under_maintenance'] =
        isDeliveryBoyAppUnderMaintenance;
    _data['message_for_customer_app'] = messageForCustomerApp;
    _data['message_for_admin_app'] = messageForAdminApp;
    _data['message_for_web'] = messageForWeb;
    _data['message_for_delivery_boy_app'] = messageForDeliveryBoyApp;
    _data['is_offer_popup_on'] = isOfferPopupOn;
    _data['google_login'] = googleLogin;
    _data['apple_login'] = appleLogin;
    _data['facebook_login'] = facebookLogin;
    _data['whatsapp_status'] = whatsappStatus;
    _data['whatsapp_number'] = whatsappNumber;
    _data['offer_popup_method'] = offerPopupMethod;
    _data['local_pickup'] = localPickup;
    _data['address'] = address;
    _data['admin_store_state'] = adminStoreState;
    _data['latitude'] = latitude;
    _data['longitude'] = longitude;
    _data['pincode_wise_deliverability'] = pincodeWiseDeliverability;
    _data['city_wise_deliverability'] = cityWiseDeliverability;
    _data['android_app_store_link'] = androidAppStoreLink;
    _data['ios_app_store_link'] = iosAppStoreLink;
    _data['scheme'] = scheme;
    _data['host'] = host;
    return _data;
  }
}
