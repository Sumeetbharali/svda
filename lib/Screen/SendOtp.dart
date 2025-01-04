import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/PushNotificationService.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Provider/SettingProvider.dart';
import 'package:eshop/Provider/SmsServicesProvider.dart';
import 'package:eshop/Screen/Privacy_Policy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../Helper/Color.dart';
import '../Helper/Session.dart';
import '../ui/styles/DesignConfig.dart';
import '../ui/styles/Validators.dart';
import '../ui/widgets/AppBtn.dart';
import '../ui/widgets/BehaviorWidget.dart';
import '../utils/Hive/hive_utils.dart';
import '../utils/blured_router.dart';
import 'HomePage.dart';
import 'Verify_Otp.dart';

class SendOtp extends StatefulWidget {
  String? title;
  static route(RouteSettings settings) {
    Map? arguments = settings?.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return SendOtp(
          title: arguments?['title'],
        );
      },
    );
  }

  SendOtp({Key? key, this.title}) : super(key: key);

  @override
  _SendOtpState createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> with TickerProviderStateMixin {
  bool visible = false;
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? mobile, id, countrycode, countryName, mobileno;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool acceptTnC = true;
  bool _obsecureText = true;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      if (widget.title != getTranslated(context, 'SEND_OTP_TITLE')) {
        _playAnimation();
        checkNetwork();
      } else {
        if (acceptTnC) {
          _playAnimation();
          checkNetwork();
        } else {
          setSnackbar(getTranslated(context, 'TnCNOTACCEPTED')!, context);
        }
      }
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getVerifyUser();
    } else {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
        await buttonController!.reverse();
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      if (mobileController.text.trim().isEmpty) {
        setSnackbar(getTranslated(context, 'MOB_REQUIRED')!, context);
        return false;
      }
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Widget noInternet(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: kToolbarHeight),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        noIntImage(),
        noIntText(context),
        noIntDec(context),
        AppBtn(
          title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            _playAnimation();

            Future.delayed(const Duration(seconds: 2)).then((_) async {
              _isNetworkAvail = await isNetworkAvailable();
              if (_isNetworkAvail) {
                Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                        builder: (BuildContext context) => super.widget));
              } else {
                await buttonController!.reverse();
                if (mounted) setState(() {});
              }
            });
          },
        )
      ]),
    );
  }

  Future<void> getVerifyUser() async {
    try {
      const String authorizationToken =
          "TUtCij4Zzvxd1khM7wyXrOPFalGR5KHSb2LQW0V8NnqD9EpAfszUuiR4bBjVJ8CGKgIfcZFepyntsXo0";
      final otp = (100000 +
              (999999 - 100000) *
                  (DateTime.now().millisecondsSinceEpoch % 100000) ~/
                  100000)
          .toString();

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
        SmsServiceProvider smsServiceProvider =
            Provider.of<SmsServiceProvider>(context, listen: false);
        // smsServiceProvider.showNotification(otp);

        SettingProvider settingsProvider =
            Provider.of<SettingProvider>(context, listen: false);
        await buttonController!.reverse();

        if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
          setSnackbar(responseBody['message'][0], context);
          Future.delayed(const Duration(seconds: 1)).then((_) {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => VerifyOtp(
                  generatedOtp: otp,
                  mobileNumber: mobile!,
                  countryCode: countrycode,
                  title: getTranslated(context, 'SEND_OTP_TITLE'),
                ),
              ),
            );
          });
        } else if (widget.title ==
            getTranslated(context, 'FORGOT_PASS_TITLE')) {
          Future.delayed(const Duration(seconds: 1)).then((_) {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => VerifyOtp(
                  mobileNumber: mobile!,
                  countryCode: countrycode,
                  title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                ),
              ),
            );
          });
        }
      } else {
        if (responseBody['message'][0] == "OTP sent successfully.") {
          setSnackbar(responseBody['message'][0], context);
        } else {
          setSnackbar("OTP sending failed", context);
        }
      }
    } catch (error) {
      setSnackbar(error.toString(), context);
    } finally {
      await buttonController!.reverse();
    }
  }

  // void _showNotification(String otp) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'otp_channel',
  //     'OTP Notifications',
  //     channelDescription: 'Channel for OTP notifications',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );

  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Your OTP',
  //     'Your OTP is: $otp',
  //     platformChannelSpecifics,
  //     payload: 'OTP Payload',
  //   );
  // }
  // Future<void> getVerifyUser() async {
  //   try {
  //     var data = {
  //       MOBILE: mobile,
  //       "is_forgot_password":
  //           (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')
  //                   ? 1
  //                   : 0)
  //               .toString()
  //     };

  //     apiBaseHelper.postAPICall(getVerifyUserApi, data).then((getdata) async {
  //       bool? error = getdata["error"];
  //       String? msg = getdata["message"];
  //       await buttonController!.reverse();

  //       SettingProvider settingsProvider =
  //           Provider.of<SettingProvider>(context, listen: false);

  //       if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
  //         if (!error!) {
  //           setSnackbar(msg!, context);

  //           Future.delayed(const Duration(seconds: 1)).then((_) {
  //             Navigator.push(
  //                 context,
  //                 CupertinoPageRoute(
  //                     builder: (context) => VerifyOtp(
  //                           mobileNumber: mobile!,
  //                           countryCode: countrycode,
  //                           title: getTranslated(context, 'SEND_OTP_TITLE'),
  //                         )));
  //           });
  //         } else {
  //           setSnackbar(msg!, context);
  //         }
  //       }
  //       if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')) {
  //         if (!error!) {
  //           Future.delayed(const Duration(seconds: 1)).then((_) {
  //             Navigator.push(
  //                 context,
  //                 CupertinoPageRoute(
  //                     builder: (context) => VerifyOtp(
  //                           mobileNumber: mobile!,
  //                           countryCode: countrycode,
  //                           title: getTranslated(context, 'FORGOT_PASS_TITLE'),
  //                         )));
  //           });
  //         } else {
  //           setSnackbar(getTranslated(context, 'FIRSTSIGNUP_MSG')!, context);
  //         }
  //       }
  //     }, onError: (error) {
  //       setSnackbar(error.toString(), context);
  //     });
  //   } on TimeoutException catch (_) {
  //     setSnackbar(getTranslated(context, 'somethingMSg')!, context);
  //     await buttonController!.reverse();
  //   }

  //   return;
  // }

  createAccTxt() {
    return Padding(
        padding: const EdgeInsets.only(
          top: 30.0,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            widget.title == getTranslated(context, 'SEND_OTP_TITLE')
                ? getTranslated(context, 'CREATE_ACC_LBL')!
                : getTranslated(context, 'FORGOT_PASSWORDTITILE')!,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold),
          ),
        ));
  }

  Widget verifyCodeTxt() {
    return Padding(
        padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            getTranslated(context, 'SEND_VERIFY_CODE_LBL')!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal,
                ),
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            maxLines: 1,
          ),
        ));
  }

  setCodeWithMono() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 15, end: 15),
      child: IntlPhoneField(
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        controller: mobileController,
        decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.fontColor.withOpacity(0.6),
                fontWeight: FontWeight.normal),
            hintText: getTranslated(context, 'MOBILEHINT_LBL'),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10)),
            fillColor: Theme.of(context).colorScheme.white,
            // fillColor: Theme.of(context).colorScheme.lightWhite,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            prefixIcon: const Icon(Icons.call)),
        initialCountryCode: defaultCountryCode,
        onSaved: (phoneNumber) {
          setState(() {
            countrycode =
                phoneNumber!.countryCode.toString().replaceFirst('+', '');
            mobile = phoneNumber.number;
          });
        },
        onCountryChanged: (country) {
          setState(() {
            countrycode = country.dialCode;
          });
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        autofocus: true,
        disableLengthCheck: false,
        validator: (val) => validateMobIntl(
            val!,
            getTranslated(context, 'MOB_REQUIRED'),
            getTranslated(context, 'VALID_MOB')),
        onChanged: (phone) {},
        showDropdownIcon: false,
        //invalidNumberMessage: getTranslated(context, 'VALID_MOB'),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        flagsButtonMargin: const EdgeInsets.only(left: 20, right: 20),
        pickerDialogStyle: PickerDialogStyle(
          countryNameStyle:
              TextStyle(color: Theme.of(context).colorScheme.fontColor),
          padding: const EdgeInsets.only(left: 10, right: 10),
        ),
      ),
    );
  }

  Widget passwordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          controller: passwordController,
          obscureText: _obsecureText,
          style: TextStyle(
            letterSpacing: 2,
            color: Theme.of(context).colorScheme.fontColor,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            fillColor: Theme.of(context).colorScheme.white,
            filled: true,
            hintText: '••••••••',
            hintStyle: TextStyle(
              letterSpacing: 2,
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.35),
            ),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.25),
            ),
            suffixIcon: IconButton(
              icon: _obsecureText
                  ? const Icon(Icons.visibility_off)
                  : const Icon(Icons.visibility),
              onPressed: () {
                setState(() {
                  _obsecureText = !_obsecureText;
                });
              },
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.25),
            ),
          ),
        ),
      ),
    );
  }

  Widget emailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          obscureText: _obsecureText,
          style: TextStyle(
            letterSpacing: 2,
            color: Theme.of(context).colorScheme.fontColor,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            fillColor: Theme.of(context).colorScheme.white,
            filled: true,
            hintText: 'Email address',
            hintStyle: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.35),
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.25),
            ),
          ),
        ),
      ),
    );
  }

  Widget setMono() {
    return TextFormField(
        keyboardType: TextInputType.number,
        controller: mobileController,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) => validateMob(
            val!,
            getTranslated(context, 'MOB_REQUIRED'),
            getTranslated(context, 'VALID_MOB')),
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'MOBILEHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primarytheme),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ));
  }

  Widget verifyBtn() {
    return AppBtn(
        // title: getTranslated(context, 'SIGN_UP_LBL'),
        // ? getTranslated(context, 'SEND_OTP')
        // : getTranslated(context, 'CONTINUE'),
        title: widget.title == getTranslated(context, 'SEND_OTP_TITLE')
            ? getTranslated(context, 'SEND_OTP')
            : getTranslated(context, 'CONTINUE'),
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          FocusScope.of(context).requestFocus(FocusNode());

          validateAndSubmit();
        });
    // return CupertinoButton(
    //   child: Container(
    //     width: buttonSqueezeanimation!.value,
    //     height: 45,
    //     alignment: FractionalOffset.center,
    //     decoration: const BoxDecoration(
    //       color: Color(0XFF4BA203),
    //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
    //     ),
    //     child: buttonSqueezeanimation!.value > 75.0
    //         ? Text(
    //             getTranslated(context, 'SIGN_UP_LBL') ?? 'Sign Up',
    //             textAlign: TextAlign.center,
    //             style: Theme.of(context).textTheme.titleLarge!.copyWith(
    //                   color: colors.whiteTemp,
    //                   fontWeight: FontWeight.normal,
    //                 ),
    //           )
    //         : CircularProgressIndicator(
    //             color: Theme.of(context).colorScheme.primarytheme,
    //             valueColor:
    //                 const AlwaysStoppedAnimation<Color>(colors.whiteTemp),
    //           ),
    //   ),
    //   onPressed: () {
    //     //if it's not loading do the thing
    //     if (buttonSqueezeanimation!.value == 15) {
    //       () async {
    //         FocusScope.of(context).requestFocus(FocusNode());
    //         validateAndSubmit();
    //       };
    //     }
    //   },
    // );
  }

  Widget termAndPolicyTxt() {
    return widget.title == getTranslated(context, 'SEND_OTP_TITLE')
        ? Padding(
            padding:
                const EdgeInsets.only(bottom: 0.0, left: 25.0, right: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.center,
                        softWrap: true,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  getTranslated(context, 'CONTINUE_AGREE_LBL')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            const WidgetSpan(
                              child: SizedBox(width: 5.0),
                            ),
                            WidgetSpan(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) {
                                        return PrivacyPolicy(
                                          title: getTranslated(context, 'TERM'),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                  getTranslated(context, 'TERMS_SERVICE_LBL')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ),
                            ),
                            const WidgetSpan(
                              child: SizedBox(width: 5.0),
                            ),
                            TextSpan(
                              text: getTranslated(context, 'AND_LBL')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            const WidgetSpan(
                              child: SizedBox(width: 5.0),
                            ),
                            WidgetSpan(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => PrivacyPolicy(
                                        title:
                                            getTranslated(context, 'PRIVACY'),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  getTranslated(context, 'PRIVACY')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  backBtn() {
    return Platform.isIOS
        ? Positioned(
            top: 34.0,
            left: 5.0,
            child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: shadow(),
                  child: Card(
                    elevation: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () => Navigator.of(context).pop(),
                      child: Center(
                        child: Icon(
                          Icons.keyboard_arrow_left,
                          color: Theme.of(context).colorScheme.primarytheme,
                        ),
                      ),
                    ),
                  ),
                )),
          )
        : const SizedBox.shrink();
  }

  @override
  void initState() {
    super.initState();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 15,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: _isNetworkAvail
          ? Stack(
              children: [
                // Image.asset(
                //   'assets/images/doodle.png',
                //   fit: BoxFit.fill,
                //   width: double.infinity,
                //   height: double.infinity,
                //   color: Theme.of(context).colorScheme.primarytheme,
                // ),
                getLoginContainer(),
                getLogo(),
                Positioned(
                  bottom: 20,
                  left: 10,
                  right: 10,
                  child: termAndPolicyTxt(),
                ),
              ],
            )
          : noInternet(context),
    );
  }

  getLoginContainer() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * 0.9,
        width: MediaQuery.of(context).size.width * 0.95,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Form(
          key: _formkey,
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 15),
                  //   child: Align(
                  //     alignment: Alignment.topLeft,
                  //     child: Text(
                  //       widget.title == getTranslated(context, 'SEND_OTP_TITLE')
                  //           ? getTranslated(context, 'SIGN_UP_LBL')!
                  //           : getTranslated(context, 'FORGOT_PASSWORDTITILE')!,
                  // style: TextStyle(
                  //   color: Theme.of(context).colorScheme.primarytheme,
                  //   fontSize: 30,
                  //   fontWeight: FontWeight.bold,
                  // ),
                  //     ),
                  //   ),
                  // ),
                  Text(
                    widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')
                        ? getTranslated(context, 'Forgot Password')!
                        : "Create Account",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')
                        ? "Almost there ! Put your valid details \nbelow and forgot password "
                        : "Almost there ! Put your valid details \nbelow and create an account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.3),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // verifyCodeTxt(),
                  setCodeWithMono(),
                  // passwordField(),
                  const SizedBox(
                    height: 70,
                  ),
                  // emailField(),
                  // const SizedBox(
                  //   height: 30,
                  // ),
                  verifyBtn(),

                  // termAndPolicyTxt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Positioned(
      // left: (MediaQuery.of(context).size.width / 2) - (150 / 2),
      left: 0,
      right: 0,
      top: 50,
      child: SizedBox(
          width: 90,
          height: 90,
          child: Image.asset(
            "assets/images/Splash-Logo.png",
            // color: Theme.of(context).colorScheme.primarytheme,
          )
          // child: SvgPicture.asset(
          //   "assets/images/homelogo.svg",
          //   colorFilter: ColorFilter.mode(
          //       Theme.of(context).colorScheme.primarytheme, BlendMode.srcIn),
          // ),
          ),
    );
  }
}

String getToken() {
  // final claimSet = JwtClaim(
  //     issuer: issuerName,
  //     // maxAge: const Duration(minutes: 1),
  //     maxAge: const Duration(days: tokenExpireTime),
  //     issuedAt: DateTime.now().toUtc());
  //
  // String token = issueJwtHS256(claimSet, Hive);
  // print("token is $token");
  return HiveUtils.getJWT() ?? "";
}

Map<String, String> get headers => {
      "Authorization": 'Bearer ${getToken()}',
    };
