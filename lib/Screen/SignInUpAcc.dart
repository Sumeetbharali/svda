import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:eshop/Helper/PushNotificationService.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/SqliteData.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Model/Section_Model.dart';
import 'package:eshop/Provider/CartProvider.dart';
import 'package:eshop/Provider/FavoriteProvider.dart';
import 'package:eshop/Provider/SettingProvider.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:eshop/Screen/Dashboard.dart';
import 'package:eshop/Screen/HomePage.dart';
import 'package:eshop/Screen/Login.dart';
import 'package:eshop/settings.dart';
import 'package:eshop/ui/styles/DesignConfig.dart';
import 'package:eshop/ui/styles/Validators.dart';
import 'package:eshop/ui/widgets/ApiException.dart';
import 'package:eshop/ui/widgets/AppBtn.dart';
import 'package:eshop/utils/Hive/hive_utils.dart';
import 'package:eshop/utils/blured_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../Helper/Color.dart';
import '../app/routes.dart';
import 'SendOtp.dart';

class SignInUpAcc extends StatefulWidget {
  final String? mobileController;
  final Widget? classType;
  final bool isPop;
  final bool? isRefresh;
  static route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return LoginScreen(
          isPop: arguments?['isPop'],
          isRefresh: arguments?['isRefresh'],
          classType: arguments?['classType'],
          mobileController: arguments?['mobileController'],
        );
      },
    );
  }

  const SignInUpAcc({
    super.key,
    required this.isPop,
    this.mobileController,
    this.classType,
    this.isRefresh,
  });

  @override
  _SignInUpAccState createState() => _SignInUpAccState();
}

class _SignInUpAccState extends State<SignInUpAcc> {
  final mobileController = TextEditingController();
  String defaultCountryCode = AppSettings.defaultCountryCode;
  String? mobile, id, countrycode, countryName, mobileno;
  bool? googleLogin, appleLogin;
  bool _isNetworkAvail = true;
  bool acceptTnC = true;
  var db = DatabaseHelper();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? password,
      username,
      email,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      image,
      loginType;
  bool socialLoginLoading = false;
  AnimationController? buttonController;
  _subLogo() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 35),
      child: SizedBox(
        width: 65,
        height: 65,
        child: CircleAvatar(
          child: ClipOval(
            child: Image.asset(
              "assets/images/Splash_Logo.png",
            ),
          ),
        ),
      ),
    );
  }

  welcomeEshopTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 20.0),
      child: Text(
        getTranslated(context, 'Welcome Back')!,
        // getTranslated(context, 'WELCOME_ESHOP')!,

        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: 21,
              fontFamily: "Poppins",
            ),
      ),
    );
  }

  eCommerceforBusinessTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 30.0,
        vertical: 5.0,
      ),
      child: Text(
        getTranslated(
          context,
          'Login to your account with using your registered number',
        )!,
        textAlign: TextAlign.center,
        // getTranslated(context, 'ECOMMERCE_APP_FOR_ALL_BUSINESS')!,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  // signInyourAccTxt() {
  //   return Padding(
  //     padding: const EdgeInsetsDirectional.only(top: 80.0, bottom: 40),
  //     child: Text(
  //       getTranslated(context, 'SIGNIN_ACC_LBL')!,
  //       style: Theme.of(context).textTheme.titleMedium!.copyWith(
  //           color: Theme.of(context).colorScheme.fontColor,
  //           fontWeight: FontWeight.bold),
  //     ),
  //   );
  // }

  signInBtn() {
    return CupertinoButton(
      child: Container(
          width: deviceWidth! * 0.8,
          height: 45,
          alignment: FractionalOffset.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primarytheme,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Text(getTranslated(context, 'SIGNIN_LBL')!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: colors.whiteTemp, fontWeight: FontWeight.normal))),
      onPressed: () {
        Navigator.pushNamed(context, Routers.loginScreen,
            arguments: {"isPop": false});
      },
    );
  }

  Widget socialLoginBtn() {
    ///DEBUG
    return Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 0),
        child: Column(
          children: [
            // if (googleLogin == true)
            InkWell(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                width: deviceWidth! * 0.8,
                decoration: BoxDecoration(
                  // color: Colors.green,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  // border: Border.all(
                  //     color: Theme.of(context)
                  //         .colorScheme
                  //         .primarytheme), /* color: Theme.of(context).colorScheme.lightWhite*/
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/google_button.svg',
                      height: 22,
                      width: 22,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 15),
                      child: Text(
                          getTranslated(context, 'CONTINUE_WITH_GOOGLE')!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontWeight: FontWeight.normal)),
                    )
                  ],
                ),
              ),
              onTap: () async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  setState(() {
                    socialLoginLoading = true;
                  });
                  onTapSocialLogin(type: GOOGLE_TYPE);
                } else {
                  Future.delayed(const Duration(seconds: 2)).then((_) async {
                    await buttonController!.reverse();
                    if (mounted) {
                      setState(() {
                        _isNetworkAvail = false;
                      });
                    }
                  });
                }
              },
            ),
            if (appleLogin == true)
              if (Platform.isIOS)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: InkWell(
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      width: deviceWidth! * 0.7,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  Theme.of(context).colorScheme.primarytheme)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/apple_logo.svg',
                            height: 22,
                            width: 22,
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(start: 8),
                            child: Text(
                                getTranslated(context, 'CONTINUE_WITH_APPLE')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.normal)),
                          )
                        ],
                      ),
                    ),
                    onTap: () async {
                      if (acceptTnC) {
                        _isNetworkAvail = await isNetworkAvailable();
                        if (_isNetworkAvail) {
                          setState(() {
                            socialLoginLoading = true;
                          });
                          onTapSocialLogin(type: APPLE_TYPE);
                        } else {
                          Future.delayed(const Duration(seconds: 2))
                              .then((_) async {
                            await buttonController!.reverse();
                            if (mounted) {
                              setState(() {
                                _isNetworkAvail = false;
                              });
                            }
                          });
                        }
                      } else {
                        setSnackbar(
                            getTranslated(context, 'agreeTCFirst')!, context);
                      }
                    },
                  ),
                )
          ],
        ));
  }

  Future<Map<String, dynamic>> onTapSocialLogin({
    required String type,
  }) async {
    try {
      final result = await socialSignInUser(type: type);
      final user = result['user'] as User;

      Map<String, dynamic> userDataTest = await loginAuth(
          mobile: user.providerData[0].phoneNumber ?? "",
          email: user.providerData[0].email ?? "",
          firebaseId: user.providerData[0].uid ?? "",
          name: user.providerData[0].displayName ??
              (type == APPLE_TYPE ? "Apple User" : ""),
          type: type);
      bool error = userDataTest["error"];
      String? msg = userDataTest["message"];
      print(":TOKENM ISS ${userDataTest}");
      await HiveUtils.setJWT(userDataTest['token']);
      setState(() {
        socialLoginLoading = false;
      });
      if (!error) {
        setSnackbar(msg!, context);

        var i = userDataTest["data"];
        id = i[ID];
        username = i[USERNAME];
        email = i[EMAIL];
        mobile = i[MOBILE];
        city = i[CITY];
        area = i[AREA];
        address = i[ADDRESS];
        pincode = i[pinCodeOrCityNameKey];
        latitude = i[LATITUDE];
        longitude = i[LONGITUDE];
        image = i[IMAGE];
        loginType = i[TYPE];

        SettingProvider settingProvider =
            Provider.of<SettingProvider>(context, listen: false);

        settingProvider.setPrefrenceBool(ISFIRSTTIME, true);

        settingProvider.saveUserDetail(id!, username, email, mobile, city, area,
            address, pincode, latitude, longitude, image, loginType, context);
        Future.delayed(Duration.zero, () {
          PushNotificationService(context: context).setDeviceToken(
              clearSesssionToken: true, settingProvider: settingProvider);
        });
        /* setToken(); */
        offFavAdd().then((value) {
          db.clearFav();
          context.read<FavoriteProvider>().setFavlist([]);
          offCartAdd().then((value) {
            db.clearCart();
            offSaveAdd().then((value) {
              db.clearSaveForLater();
              if (widget.isPop) {
                if (widget.isRefresh != null) {
                  Navigator.pop(context, 'refresh');
                } else {
                  _getFav(context).whenComplete(() {
                    _getCart("0", context).whenComplete(() {
                      Future.delayed(const Duration(seconds: 2))
                          .whenComplete(() {
                        Navigator.of(context).pop();
                      });
                    });
                  });
                }
              } else {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  Dashboard.dashboardScreenKey = GlobalKey<HomePageState>();
                  return widget.classType ??
                      Dashboard(
                        key: Dashboard.dashboardScreenKey,
                      );
                }), (route) => false);
              }
            });
          });
        });
      } else {
        setSnackbar(msg!, context);
      }

      return userDataTest;
    } catch (e) {
      setState(() {
        socialLoginLoading = false;
      });
      print("login error*****${e.toString()}");
      signOut(type);
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<void> signOut(String type) async {
    _firebaseAuth.signOut();
    if (type == GOOGLE_TYPE) {
      _googleSignIn.signOut();
    } else {
      _firebaseAuth.signOut();
    }
  }

  Future<void> offFavAdd() async {
    List favOffList = await db.getOffFav();

    if (favOffList.isNotEmpty) {
      for (int i = 0; i < favOffList.length; i++) {
        _setFav(favOffList[i]["PID"]);
      }
    }
  }

  _setFav(String pid) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: context.read<UserProvider>().userId,
          PRODUCT_ID: pid
        };
        apiBaseHelper.postAPICall(setFavoriteApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
          } else {
            setSnackbar(msg!, context);
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Future<void> addToCartCheckout(String varId, String qty) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: varId,
          USER_ID: context.read<UserProvider>().userId,
          QTY: qty,
        };
        apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];
          } else {}
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) _isNetworkAvail = false;

      setState(() {});
    }
  }

  Future<void> offCartAdd() async {
    List cartOffList = await db.getOffCart();

    if (cartOffList.isNotEmpty) {
      for (int i = 0; i < cartOffList.length; i++) {
        addToCartCheckout(cartOffList[i]["VID"], cartOffList[i]["QTY"]);
      }
    }
  }

  Future<void> offSaveAdd() async {
    List saveOffList = await db.getOffSaveLater();

    if (saveOffList.isNotEmpty) {
      for (int i = 0; i < saveOffList.length; i++) {
        saveForLater(saveOffList[i]["VID"], saveOffList[i]["QTY"]);
      }
    }
  }

  saveForLater(String vid, String qty) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: vid,
          USER_ID: context.read<UserProvider>().userId,
          QTY: qty,
          SAVE_LATER: "1"
        };
        apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];
          } else {
            setSnackbar(msg!, context);
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Future _getFav(BuildContext context) async {
    try {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        if (context.read<UserProvider>().userId != "") {
          Map parameter = {
            USER_ID: context.read<UserProvider>().userId,
          };

          apiBaseHelper.postAPICall(getFavApi, parameter).then((getdata) {
            bool error = getdata["error"];
            String? msg = getdata["message"];
            if (!error) {
              var data = getdata["data"];

              List<Product> tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<FavoriteProvider>().setFavlist(tempList);
              });
            } else {
              if (msg != 'No Favourite(s) Product Are Added') {
                setSnackbar(msg!, context);
              }
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<FavoriteProvider>().setLoading(false);
            });
          }, onError: (error) {
            setSnackbar(error.toString(), context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<FavoriteProvider>().setLoading(false);
            });
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<FavoriteProvider>().setLoading(false);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  Future<void> _getCart(String save, BuildContext context) async {
    try {
      _isNetworkAvail = await isNetworkAvailable();

      if (_isNetworkAvail) {
        if (context.read<UserProvider>().userId != "") {
          try {
            var parameter = {
              USER_ID: context.read<UserProvider>().userId,
              SAVE_LATER: save,
              "only_delivery_charge": "0",
            };
            apiBaseHelper.postAPICall(getCartApi, parameter).then((getdata) {
              bool error = getdata["error"];
              String? msg = getdata["message"];
              if (!error) {
                var data = getdata["data"];

                List<SectionModel> cartList = (data as List)
                    .map((data) => SectionModel.fromCart(data))
                    .toList();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  print("inner widget:${cartList.length}");
                  context
                      .read<UserProvider>()
                      .setCartCount(cartList.length.toString());
                  print(
                      "cart count login****${context.read<UserProvider>().cartCount}");
                  context.read<CartProvider>().setCartlist(cartList);
                });
              }
            }, onError: (error) {
              setSnackbar(error.toString(), context);
            });
          } on TimeoutException catch (_) {}
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  Future<Map<String, dynamic>> socialSignInUser({required String type}) async {
    Map<String, dynamic> result = {};
    try {
      print("Calling google signin ${type}");

      if (type == GOOGLE_TYPE) {
        UserCredential? userCredential = await signInWithGoogle(context);
        print("Calling google signin ${userCredential}");

        if (userCredential != null) {
          result['user'] = userCredential.user!;
        } else {
          throw ApiMessageAndCodeException(
              errorMessage: getTranslated(context, 'somethingMSg')!);
        }
      } else if (type == APPLE_TYPE) {
        UserCredential? userCredential = await signInWithApple(context);
        if (userCredential != null) {
          result['user'] = userCredential.user!;
        } else {
          throw ApiMessageAndCodeException(
              errorMessage: getTranslated(context, 'somethingMSg')!);
        }
      }
      print("user result***$result");
      return result;
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(
          errorMessage: getTranslated(context, 'somethingMSg')!);
    } on FirebaseAuthException catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    } on PlatformException catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);

      return null;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    return userCredential;
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential?> signInWithApple(BuildContext context) async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      print('**********apple id:******$authResult');

      return authResult;
    } on FirebaseAuthException catch (authError) {
      print('**********errror id:******$authError');
      setSnackbar(authError.message!, context);

      return null;
    } on FirebaseException catch (e) {
      setSnackbar(e.toString(), context);

      return null;
    } catch (e) {
      String errorMessage = e.toString();

      if (errorMessage == "Null check operator used on a null value") {
        //if user goes back from selecting Account
        //in case of User gmail not selected & back to Login screen
        setSnackbar(getTranslated(context, 'CANCEL_USER_MSG')!, context);

        return null;
      } else {
        setSnackbar(errorMessage, context);

        return null;
      }
    }
  }

  Future<dynamic> loginAuth(
      {required String firebaseId,
      required String name,
      required String email,
      required String type,
      required String mobile}) async {
    try {
      final body = {
        NAME: name,
        TYPE: type,
      };

      if (mobile != "") {
        body[MOBILE] = mobile;
      }

      if (email != "") {
        body[EMAIL] = email;
      }
      if (firebaseId != "") {
        body[FCM_ID] = firebaseId;
      }
      print("login param****$body");
      var getData = apiBaseHelper.postAPICall(signUpUserApi, body);
      print("getdata******$getData");
      return getData;
    } catch (e) {
      print("auth error");
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  verifyOtp() {
    return CupertinoButton(
      child: Container(
        width: deviceWidth! * 0.8,
        height: 45,
        alignment: FractionalOffset.center,
        decoration: const BoxDecoration(
          color: Color(0Xff4BA203),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Text(
          getTranslated(context, 'SEND_OTP_TITLE')!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: colors.whiteTemp,
                fontWeight: FontWeight.normal,
                fontSize: 16,
                fontFamily: "Poppins",
              ),
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(
          context,
          Routers.loginScreen,
          arguments: {
            "isPop": false,
            "mobileController": mobileController.text
          },
        );
      },
    );
  }

  createAccBtn() {
    return CupertinoButton(
      child: Container(
        width: deviceWidth! * 0.8,
        height: 45,
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
          // color: colors.darkGreen,
          color: Theme.of(context).colorScheme.primarytheme,
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Text(
          getTranslated(context, 'CREATE_ACC_LBL')!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: colors.whiteTemp,
                fontWeight: FontWeight.normal,
                fontSize: 16,
                fontFamily: "Poppins",
              ),
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, Routers.sendOTPScreen,
            arguments: {"title": getTranslated(context, 'SEND_OTP_TITLE')});
      },
    );
  }

  skipSignInBtn() {
    return CupertinoButton(
      child: Container(
          width: deviceWidth! * 0.8,
          height: 45,
          alignment: FractionalOffset.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primarytheme,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Text(getTranslated(context, 'SKIP_SIGNIN_LBL')!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: colors.whiteTemp, fontWeight: FontWeight.normal))),
      onPressed: () {
        Dashboard.dashboardScreenKey = GlobalKey<HomePageState>();

        Navigator.pushReplacementNamed(
          context,
          Routers.dashboardScreen,
        );
      },
    );
  }

  // backBtn() {
  //   return Container(
  //     padding: const EdgeInsetsDirectional.only(top: 34.0, start: 5.0),
  //     alignment: Alignment.topLeft,
  //     width: 60,
  //     child: Material(
  //         color: Colors.transparent,
  //         child: Container(
  //           margin: const EdgeInsets.all(10),
  //           decoration: shadow(),
  //           child: Card(
  //             elevation: 0,
  //             child: InkWell(
  //               borderRadius: BorderRadius.circular(4),
  //               onTap: () => Navigator.of(context).pop(),
  //               child: Center(
  //                 child: Icon(
  //                   Icons.keyboard_arrow_left,
  //                   color: Theme.of(context).colorScheme.primarytheme,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         )),
  //   );
  // }

  // setCodeWithMono() {
  // return Padding(
  //   padding: const EdgeInsetsDirectional.only(start: 15, end: 15),
  //   child: IntlPhoneField(
  //       style: Theme.of(context).textTheme.titleSmall!.copyWith(
  //           color: Theme.of(context).colorScheme.fontColor,
  //           fontWeight: FontWeight.normal),
  //       controller: mobileController,
  //       decoration: InputDecoration(
  // prefixIcon: Text(
  //   "+91-",
  //   style: Theme.of(context).textTheme.titleSmall!.copyWith(
  //         color: Theme.of(context).colorScheme.fontColor,
  //         fontSize: 20,
  //         fontWeight: FontWeight.bold,
  //       ),
  // ),
  //         hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
  //             color: Theme.of(context).colorScheme.fontColor.withOpacity(0.6),
  //             fontWeight: FontWeight.normal),
  //         hintText: getTranslated(context, 'MOBILEHINT_LBL'),
  //         border: OutlineInputBorder(
  //             borderSide: BorderSide.none,
  //             borderRadius: BorderRadius.circular(10)),
  //         fillColor: Theme.of(context).colorScheme.lightWhite,
  //         filled: true,
  //         contentPadding:
  //             const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
  //       ),
  //       initialCountryCode: defaultCountryCode,
  // onSaved: (phoneNumber) {
  //   setState(() {
  //     countrycode =
  //         phoneNumber!.countryCode.toString().replaceFirst('+', '');
  //     mobile = phoneNumber.number;
  //   });
  // },
  // // onCountryChanged: (country) {
  // //   setState(() {
  // //     // countrycode = country.dialCode;
  // //     countrycode = "+91";
  // //   });
  // // },
  // autovalidateMode: AutovalidateMode.onUserInteraction,
  // autofocus: true,
  // disableLengthCheck: false,
  // validator: (val) => validateMobIntl(
  //     val!,
  //     getTranslated(context, 'MOB_REQUIRED'),
  //     getTranslated(context, 'VALID_MOB')),
  // onChanged: (phone) {},
  //       showDropdownIcon: false,
  //       //invalidNumberMessage: getTranslated(context, 'VALID_MOB'),
  //       keyboardType: TextInputType.number,
  //       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  //       flagsButtonMargin: const EdgeInsets.only(left: 20, right: 20),
  //       showCountryFlag: false,
  //       pickerDialogStyle: PickerDialogStyle(
  //         countryNameStyle:
  //             TextStyle(color: Theme.of(context).colorScheme.fontColor),
  //         padding: const EdgeInsets.only(left: 10, right: 10),
  //       ),
  //     ),
  //   );
  // }

  setCodeWithMono() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: MediaQuery.of(context).size.width * 0.2,
            top: 20,
          ),
          child: TextFormField(
            controller: mobileController,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              prefixIcon: Text(
                "+91 - ",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Poppins",
                    ),
              ),
              hintText: "00000-00000",
              hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .fontColor
                        .withOpacity(0.11),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                  ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            onSaved: (phoneNumber) {
              setState(() {
                countrycode = "91".toString().replaceFirst('+', '');
                mobile = phoneNumber;
              });
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            autofocus: true,
            validator: (val) {
              if (val == null || val.replaceAll('-', '').length < 10) {
                // return getTranslated(context, 'MOB_REQUIRED');
                return getTranslated(context, 'VALID_MOB');
              }
              return null;
            },
            onChanged: (phone) {},
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
              _PhoneNumberInputFormatter(),
            ],
          ),
        ),
      ],
    );
  }

  Widget orText(BuildContext context) {
    return Text(
      "OR",
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: "Poppins",
          ),
    );
  }

  Widget termsAndUse() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: "By clicking on “Continue” you are agreeing\n to our ",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
          ),
          TextSpan(
            text: "terms of use",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  decoration: TextDecoration.underline,
                  color: Theme.of(context).colorScheme.primarytheme,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        leading: IconButton(
          onPressed: () {
            SystemNavigator.pop();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.primarytheme,
            size: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _subLogo(),
            welcomeEshopTxt(),
            eCommerceforBusinessTxt(),
            setCodeWithMono(),
            verifyOtp(),
            // signInyourAccTxt(),
            orText(context),
            // continueWithGoogle(),
            socialLoginBtn(),
            createAccBtn(),
            // skipSignInBtn(),
            SizedBox(height: deviceHeight! * 0.13),
            Align(
              alignment: Alignment.bottomCenter,
              child: termsAndUse(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any existing dashes
    String newText = newValue.text.replaceAll('-', '');

    if (newText.length > 5) {
      // Add a dash after the 5th digit
      newText = '${newText.substring(0, 5)}-${newText.substring(5)}';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
// class SignInUpAcc extends StatefulWidget {
//   const SignInUpAcc({Key? key}) : super(key: key);

//   @override
//   _SignInUpAccState createState() => _SignInUpAccState();
// }

// class _SignInUpAccState extends State<SignInUpAcc> {
//   _subLogo() {
//     return Padding(
//         padding: const EdgeInsetsDirectional.only(top: 30.0),
//         child: SvgPicture.asset(
//           'assets/images/homelogo.svg',
//           colorFilter: ColorFilter.mode(
//               Theme.of(context).colorScheme.primarytheme, BlendMode.srcIn),
//         ));
//   }

//   welcomeEshopTxt() {
//     return Padding(
//       padding: const EdgeInsetsDirectional.only(top: 30.0),
//       child: Text(
//         getTranslated(context, 'WELCOME_ESHOP')!,
//         style: Theme.of(context).textTheme.titleMedium!.copyWith(
//             color: Theme.of(context).colorScheme.fontColor,
//             fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   eCommerceforBusinessTxt() {
//     return Padding(
//       padding: const EdgeInsetsDirectional.only(
//         top: 5.0,
//       ),
//       child: Text(
//         getTranslated(context, 'ECOMMERCE_APP_FOR_ALL_BUSINESS')!,
//         style: Theme.of(context).textTheme.titleSmall!.copyWith(
//             color: Theme.of(context).colorScheme.fontColor,
//             fontWeight: FontWeight.normal),
//       ),
//     );
//   }

//   signInyourAccTxt() {
//     return Padding(
//       padding: const EdgeInsetsDirectional.only(top: 80.0, bottom: 40),
//       child: Text(
//         getTranslated(context, 'SIGNIN_ACC_LBL')!,
//         style: Theme.of(context).textTheme.titleMedium!.copyWith(
//             color: Theme.of(context).colorScheme.fontColor,
//             fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   signInBtn() {
//     return CupertinoButton(
//       child: Container(
//           width: deviceWidth! * 0.8,
//           height: 45,
//           alignment: FractionalOffset.center,
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.primarytheme,
//             borderRadius: const BorderRadius.all(Radius.circular(10.0)),
//           ),
//           child: Text(getTranslated(context, 'SIGNIN_LBL')!,
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                   color: colors.whiteTemp, fontWeight: FontWeight.normal))),
//       onPressed: () {
//         Navigator.pushNamed(context, Routers.loginScreen,
//             arguments: {"isPop": false});
//       },
//     );
//   }

//   createAccBtn() {
//     return CupertinoButton(
//       child: Container(
//           width: deviceWidth! * 0.8,
//           height: 45,
//           alignment: FractionalOffset.center,
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.primarytheme,
//             borderRadius: const BorderRadius.all(Radius.circular(10.0)),
//           ),
//           child: Text(getTranslated(context, 'CREATE_ACC_LBL')!,
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                   color: colors.whiteTemp, fontWeight: FontWeight.normal))),
//       onPressed: () {
//         Navigator.pushNamed(context, Routers.sendOTPScreen,
//             arguments: {"title": getTranslated(context, 'SEND_OTP_TITLE')});
//       },
//     );
//   }

//   skipSignInBtn() {
//     return CupertinoButton(
//       child: Container(
//           width: deviceWidth! * 0.8,
//           height: 45,
//           alignment: FractionalOffset.center,
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.primarytheme,
//             borderRadius: const BorderRadius.all(Radius.circular(10.0)),
//           ),
//           child: Text(getTranslated(context, 'SKIP_SIGNIN_LBL')!,
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                   color: colors.whiteTemp, fontWeight: FontWeight.normal))),
//       onPressed: () {
//         Dashboard.dashboardScreenKey = GlobalKey<HomePageState>();

//         Navigator.pushReplacementNamed(
//           context,
//           Routers.dashboardScreen,
//         );
//       },
//     );
//   }

//   // backBtn() {
//   //   return Container(
//   //     padding: const EdgeInsetsDirectional.only(top: 34.0, start: 5.0),
//   //     alignment: Alignment.topLeft,
//   //     width: 60,
//   //     child: Material(
//   //         color: Colors.transparent,
//   //         child: Container(
//   //           margin: const EdgeInsets.all(10),
//   //           decoration: shadow(),
//   //           child: Card(
//   //             elevation: 0,
//   //             child: InkWell(
//   //               borderRadius: BorderRadius.circular(4),
//   //               onTap: () => Navigator.of(context).pop(),
//   //               child: const Center(
//   //                 child: Icon(
//   //                   Icons.keyboard_arrow_left,
//   //                   color: Theme.of(context).colorScheme.primarytheme,
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //         )),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     deviceHeight = MediaQuery.of(context).size.height;
//     deviceWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       body: Container(
//         color: Theme.of(context).colorScheme.lightWhite,
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _subLogo(),
//                 welcomeEshopTxt(),
//                 eCommerceforBusinessTxt(),
//                 signInyourAccTxt(),
//                 signInBtn(),
//                 createAccBtn(),
//                 skipSignInBtn(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
