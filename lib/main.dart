import 'dart:developer';
import 'dart:io';

import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/PushNotificationService.dart';
import 'package:eshop/Provider/CartProvider.dart';
import 'package:eshop/Provider/CategoryProvider.dart';
import 'package:eshop/Provider/FavoriteProvider.dart';
import 'package:eshop/Provider/FlashSaleProvider.dart';
import 'package:eshop/Provider/HomeProvider.dart';
import 'package:eshop/Provider/OfferImagesProvider.dart';
import 'package:eshop/Provider/ProductDetailProvider.dart';
import 'package:eshop/Provider/ProductProvider.dart';
import 'package:eshop/Provider/SmsServicesProvider.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:eshop/Provider/WhatsAppNumberProvider.dart';
import 'package:eshop/Provider/get_brands.dart';
import 'package:eshop/Provider/pushNotificationProvider.dart';
import 'package:eshop/app/languages.dart';
import 'package:eshop/cubits/brandsListCubit.dart';
import 'package:eshop/cubits/fetch_citites.dart';
import 'package:eshop/cubits/fetch_featured_sections_cubit.dart';
import 'package:eshop/cubits/personalConverstationsCubit.dart';
import 'package:eshop/repository/brandsRepository.dart';
import 'package:eshop/repository/chatRepository.dart';
import 'package:eshop/ui/styles/themedata.dart';
import 'package:eshop/utils/Hive/hive_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Provider/MyFatoraahPaymentProvider.dart';
import 'Provider/SettingProvider.dart';
import 'Provider/Theme.dart';
import 'Provider/order_provider.dart';
import 'app/app_Localization.dart';
import 'app/routes.dart';
import 'firebase_options.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

///4.2.0
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveUtils.initBoxes();
  if (Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // const IOSInitializationSettings initializationSettingsIOS =
  //     IOSInitializationSettings(
  //         requestAlertPermission: true,
  //         requestBadgePermission: true,
  //         requestSoundPermission: true);

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    // iOS: initializationSettingsIOS,
  );
// Initialize the notification plugin

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle when the user taps on a notification
      // You can extract the payload here
      String? payload = response.payload;
      if (payload != null) {
        // Handle the payload, navigate or perform actions based on the notification
        log("Notification payload: $payload");
      }
    },
  );

  // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
  //     onSelectNotification: (String? payload) async {
  //   // Handle notification tap
  //   if (payload != null) {
  //     print('Notification payload: $payload');
  //     // You can navigate to a different screen or show a dialog
  //   }
  // });
  //await Firebase.initializeApp();
  initializedDownload();
  HttpOverrides.global = MyHttpOverrides();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // status bar color
  ));
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(
          create: (BuildContext context) {
            if (disableDarkTheme == false) {
              String? theme = prefs.getString(APP_THEME);

              if (theme == DARK) {
                ISDARK = "true";
              } else if (theme == LIGHT) {
                ISDARK = "false";
              }

              if (theme == null || theme == "" || theme == DEFAULT_SYSTEM) {
                prefs.setString(APP_THEME, DEFAULT_SYSTEM);
                var brightness = SchedulerBinding
                    .instance.platformDispatcher.platformBrightness;
                ISDARK = (brightness == Brightness.dark).toString();

                return ThemeNotifier(ThemeMode.system);
              }

              return ThemeNotifier(
                theme == LIGHT ? ThemeMode.light : ThemeMode.dark,
              );
            } else {
              return ThemeNotifier(ThemeMode.light);
            }
          },
        ),
        Provider<SettingProvider>(
          create: (context) => SettingProvider(prefs),
        ),
        Provider<WhatsAppNumberProvider>(
          create: (context) => WhatsAppNumberProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
            create: (context) => UserProvider()),
        ChangeNotifierProvider<LoginProvider>(
            create: (context) => LoginProvider()),
        ChangeNotifierProvider<GetBrandsProvider>(
            create: (context) => GetBrandsProvider()),
        ChangeNotifierProvider<HomeProvider>(
            create: (context) => HomeProvider()),
        ChangeNotifierProvider<CategoryProvider>(
            create: (context) => CategoryProvider()),
        ChangeNotifierProvider<ProductDetailProvider>(
            create: (context) => ProductDetailProvider()),
        ChangeNotifierProvider<FavoriteProvider>(
            create: (context) => FavoriteProvider()),
        ChangeNotifierProvider<OrderProvider>(
            create: (context) => OrderProvider()),
        ChangeNotifierProvider<CartProvider>(
            create: (context) => CartProvider()),
        ChangeNotifierProvider<ProductProvider>(
            create: (context) => ProductProvider()),
        ChangeNotifierProvider<FlashSaleProvider>(
            create: (context) => FlashSaleProvider()),
        ChangeNotifierProvider<OfferImagesProvider>(
            create: (context) => OfferImagesProvider()),
        ChangeNotifierProvider<PaymentIdProvider>(
            create: (context) => PaymentIdProvider()),
        ChangeNotifierProvider<PushNotificationProvider>(
            create: (context) => PushNotificationProvider()),
        ChangeNotifierProvider<SmsServiceProvider>(
            create: (context) =>
                SmsServiceProvider(flutterLocalNotificationsPlugin)),
        BlocProvider<PersonalConverstationsCubit>(
            create: (context) => PersonalConverstationsCubit(ChatRepository())),
        //cubit to get brand details on home page
        BlocProvider<BrandsListCubit>(
            create: (context) =>
                BrandsListCubit(brandsRepository: BrandsRepository())),
        BlocProvider<FetchCitiesCubit>(create: (context) => FetchCitiesCubit()),
        BlocProvider<FetchFeaturedSectionsCubit>(
            create: (context) => FetchFeaturedSectionsCubit())
      ],
      child: MyApp(sharedPreferences: prefs),
    ),
  );
}

Future<void> initializedDownload() async {
  await FlutterDownloader.initialize(debug: false);
}

class MyApp extends StatefulWidget {
  late SharedPreferences sharedPreferences;

  MyApp({Key? key, required this.sharedPreferences}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      if (mounted) {
        setState(() {
          _locale = locale;
        });
      }
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    if (_locale == null) {
      return Center(
        child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primarytheme,
            valueColor: AlwaysStoppedAnimation<Color?>(
                Theme.of(context).colorScheme.primarytheme)),
      );
    } else {
      return MaterialApp(
        locale: _locale,
        supportedLocales: [...Languages().codes()],
        onGenerateRoute: Routers.onGenerateRouted,
        initialRoute: Routers.splash,
        //scaffoldMessengerKey: scaffoldMessageKey,
        localizationsDelegates: const [
          AppLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale!.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        navigatorKey: navigatorKey,
        title: appName,
        theme: lightTheme,
        debugShowCheckedModeBanner: false,

        darkTheme: lightTheme,
        // darkTheme: darkTheme,

        themeMode: themeNotifier.getThemeMode(),
      );
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
