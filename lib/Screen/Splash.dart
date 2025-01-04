import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:eshop/Provider/SettingProvider.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:eshop/Screen/HomePage.dart';
import 'package:eshop/app/routes.dart';
import 'package:eshop/utils/blured_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';

//splash screen of app
class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);
  static route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const Splash();
      },
    );
  }

  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {
  bool from = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    apiBaseHelper.postAPICall(getSettingApi, {}).then((value) {
      isCityWiseDelivery = (value['data'] as Map)['system_settings'][0]
              ['city_wise_deliverability'] ==
          "1";

      isFirebaseAuth = (value['data'] as Map)['authentication_settings'][0]
              ['authentication_method'] ==
          "firebase";
    });
    //setToken();
    startTime();
  }

  void setToken() async {
    FirebaseMessaging.instance.getToken().then(
      (token) async {
        SettingProvider settingsProvider =
            Provider.of<SettingProvider>(context, listen: false);

        String getToken = await settingsProvider.getPrefrence(FCMTOKEN) ?? '';
        log("fcm token****$token");
        if (token != getToken && token != null) {
          log("register token***$token");
          registerToken(token);
        }
      },
    );
  }

  void registerToken(String? token) async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);
    var parameter = {
      FCM_ID: token,
    };
    if (context.read<UserProvider>().userId != "") {
      parameter[USER_ID] = context.read<UserProvider>().userId;
    }

    Response response =
        await post(updateFcmApi, body: parameter, headers: headers)
            .timeout(const Duration(seconds: timeOut));

    var getdata = json.decode(response.body);

    log("param noti fcm***$parameter");

    log("value notification****$getdata");

    if (getdata['error'] == false) {
      log("fcm token****$token");
      settingsProvider.setPrefrence(FCMTOKEN, token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0XFF4FA403),
                  Color(0XFF2E9105),
                  Color(0XFF0A7C08),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 110,
              height: 110,
              child: CircleAvatar(
                child: ClipOval(
                  child: Image.asset(
                    "assets/images/Splash_Logo.png",
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  startTime() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, navigationPage);
  }

  Future<void> navigationPage() async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);

    bool isFirstTime = await settingsProvider.getPrefrenceBool(ISFIRSTTIME);

    if (isFirstTime) {
      setState(() {
        from = true;
      });

      // Navigator.of(context)
      //     .pushReplacement(MaterialPageRoute(builder: (context) {
      //   Dashboard.dashboardScreenKey = GlobalKey<HomePageState>();
      //   return Dashboard(
      //     key: Dashboard.dashboardScreenKey,
      //   );
      // }));
      Navigator.pushReplacementNamed(context, Routers.dashboardScreen);
      // Navigator.pushReplacementNamed(context, Routers.introSliderScreen);
    } else {
      setState(() {
        from = false;
      });
//
//       Navigator.pushReplacement(
//           context,
//           CupertinoPageRoute(
//             builder: (context) => const IntroSlider(),
//           ));
      Navigator.pushReplacementNamed(context, Routers.introSliderScreen);

      //
    }
  }

  @override
  void dispose() {
    if (from) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    }
    super.dispose();
  }
}
