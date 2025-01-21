import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Screen/Login.dart';
import 'package:eshop/Screen/SignInUpAcc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../Helper/Color.dart';
import '../Provider/SettingProvider.dart';
import '../ui/widgets/AppBtn.dart';
import '../utils/blured_router.dart';

class IntroSlider extends StatefulWidget {
  const IntroSlider({Key? key}) : super(key: key);
  static route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const IntroSlider();
      },
    );
  }

  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<IntroSlider>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  late List slideList = [
    // Slide(
    //   imageUrl: 'assets/images/introimage_a.svg',
    //   title: getTranslated(context, 'TITLE1_LBL'),
    //   description: getTranslated(context, 'DISCRIPTION1'),
    // ),
    // Slide(
    //   imageUrl: 'assets/images/introimage_b.svg',
    //   title: getTranslated(context, 'TITLE2_LBL'),
    //   description: getTranslated(context, 'DISCRIPTION2'),
    // ),
    // Slide(
    //   imageUrl: 'assets/images/introimage_c.svg',
    //   title: getTranslated(context, 'TITLE3_LBL'),
    //   description: getTranslated(context, 'DISCRIPTION3'),
    // ),
  ];

  @override
  void initState() {
    super.initState();

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.9,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  void _goToNextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    buttonController!.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  // _onPageChanged(int index) {
  //   if (mounted) {
  //     setState(() {
  //       _currentPage = index;
  //     });
  //   }
  // }

  // List<T?> map<T>(List list, Function handler) {
  //   List<T?> result = [];
  //   for (var i = 0; i < list.length; i++) {
  //     result.add(handler(i, list[i]));
  //   }

  //   return result;
  // }

  // Widget _slider() {
  //   return Expanded(
  //     child: slideList.isNotEmpty
  //         ? PageView.builder(
  //             itemCount: slideList.length,
  //             scrollDirection: Axis.horizontal,
  //             controller: _pageController,
  //             onPageChanged: _onPageChanged,
  //             itemBuilder: (BuildContext context, int index) {
  //               return SingleChildScrollView(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.max,
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: <Widget>[
  //                     SizedBox(
  //                       height: MediaQuery.of(context).size.height * .5,
  //                       child: SvgPicture.asset(
  //                         slideList[index].imageUrl,
  //                       ),
  //                     ),
  //                     Container(
  //                         margin: const EdgeInsetsDirectional.only(top: 20),
  //                         child: Text(slideList[index].title,
  //                             style: Theme.of(context)
  //                                 .textTheme
  //                                 .headlineSmall!
  //                                 .copyWith(
  //                                     color: Theme.of(context)
  //                                         .colorScheme
  //                                         .fontColor,
  //                                     fontWeight: FontWeight.bold))),
  //                     Container(
  //                       padding: const EdgeInsetsDirectional.only(
  //                           top: 30.0, start: 15.0, end: 15.0),
  //                       child: Text(slideList[index].description,
  //                           textAlign: TextAlign.center,
  //                           style: Theme.of(context)
  //                               .textTheme
  //                               .titleMedium!
  //                               .copyWith(
  //                                   color:
  //                                       Theme.of(context).colorScheme.fontColor,
  //                                   fontWeight: FontWeight.normal)),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           )
  //         : const SizedBox.shrink(),
  //   );
  // }

  // _btn() {
  //   return Column(
  //     children: [
  //       Row(
  //           mainAxisSize: MainAxisSize.min,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: getList()),
  //       Center(
  //           child: Padding(
  //         padding: const EdgeInsetsDirectional.only(bottom: 18.0),
  //         child: AppBtn(
  //             title: _currentPage == 0 || _currentPage == 1
  //                 ? getTranslated(context, 'NEXT_LBL')
  //                 : getTranslated(context, 'GET_STARTED'),
  //             btnAnim: buttonSqueezeanimation,
  //             btnCntrl: buttonController,
  //             onBtnSelected: () {
  //               if (_currentPage == 2) {
  //                 SettingProvider settingProvider =
  //                     Provider.of<SettingProvider>(context, listen: false);
  //                 settingProvider.setPrefrenceBool(ISFIRSTTIME, true);
  //                 Navigator.pushReplacement(
  //                   context,
  //                   CupertinoPageRoute(
  //                       builder: (context) => const SignInUpAcc()),
  //                 );
  //               } else {
  //                 _currentPage = _currentPage + 1;
  //                 _pageController.animateToPage(_currentPage,
  //                     curve: Curves.decelerate,
  //                     duration: const Duration(milliseconds: 300));
  //               }
  //             }),
  //       )),
  //     ],
  //   );
  // }

  // List<Widget> getList() {
  //   List<Widget> childs = [];

  //   for (int i = 0; i < slideList.length; i++) {
  //     childs.add(AnimatedContainer(
  //         duration: const Duration(milliseconds: 500),
  //         width: _currentPage == i ? 25 : 8.0,
  //         height: 8.0,
  //         margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(5.0),
  //           color: _currentPage == i
  //               ? Theme.of(context).colorScheme.fontColor
  //               : Theme.of(context).colorScheme.lightBlack.withOpacity(0.7),
  //         )));
  //   }
  //   return childs;
  // }

  // skipBtn() {
  //   return _currentPage == 0 || _currentPage == 1
  //       ? Padding(
  //           padding: const EdgeInsetsDirectional.only(top: 20.0, end: 10.0),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: <Widget>[
  //               InkWell(
  //                 onTap: () {
  //                   SettingProvider settingProvider =
  //                       Provider.of<SettingProvider>(context, listen: false);
  //                   settingProvider.setPrefrenceBool(ISFIRSTTIME, true);
  //                   Navigator.pushReplacement(
  //                     context,
  //                     CupertinoPageRoute(
  //                         builder: (context) => const SignInUpAcc()),
  //                   );
  //                 },
  //                 child: Row(children: [
  //                   Text(getTranslated(context, 'SKIP')!,
  //                       style: Theme.of(context).textTheme.bodySmall!.copyWith(
  //                             color: Theme.of(context).colorScheme.fontColor,
  //                           )),
  //                   Icon(
  //                     Icons.arrow_forward_ios,
  //                     color: Theme.of(context).colorScheme.fontColor,
  //                     size: 12.0,
  //                   ),
  //                 ]),
  //               ),
  //             ],
  //           ))
  //       : Container(
  //           margin: const EdgeInsetsDirectional.only(top: 50.0),
  //           height: 15,
  //         );
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
          itemBuilder: (context, index) {
            // if (index == 0) {
            //   return _introPage(context);
            // } else {
            return _welcomePage(context);
            // }
          },
        ),
      ),
    );
  }

  Widget _introPage(BuildContext context) {
    return SizedBox(
      height: deviceHeight,
      width: deviceWidth,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Intro.jpg',
            fit: BoxFit.cover,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // skipBtn(),
              // _slider(),
              // _btn(),
              SizedBox(height: deviceHeight! * 0.1),
              Image.asset(
                'assets/images/Splash-Logo.png',
                width: 70,
                height: 70,
              ),
              SizedBox(height: deviceHeight! * 0.03),
              Text(
                "Get Your Groceries \nDelivered to Your Home",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: "Poppins",
                    ),
              ),
              SizedBox(height: deviceHeight! * 0.015),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: deviceWidth! * 0.17),
                child: Text(
                  "The best delivery app in town for delivering your daily fresh groceries",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: const Color(0XFF979899),
                        fontSize: 13,
                        fontFamily: "Poppins",
                      ),
                ),
              ),
              const SizedBox(height: 50),

              SizedBox(
                height: 53,
                width: 190,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: const WidgetStatePropertyAll(
                      Color(0xff025C00),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _goToNextPage();
                    });
                  },
                  child: Text(
                    'Enter Home',
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: "Poppins",
                        ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _welcomePage(BuildContext context) {
    return SizedBox(
      height: deviceHeight,
      width: deviceWidth,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Welcome.jpg',
            fit: BoxFit.cover,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                width: 70,
                height: 70,
                child: CircleAvatar(
                  child: ClipOval(
                    child: Image.asset(
                      "assets/images/Splash_Logo.png",
                    ),
                  ),
                ),
              ),
              SizedBox(height: deviceHeight! * 0.03),
              Text(
                "Welcome To \nOur Super Store",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      fontSize: 19,
                      fontFamily: "Poppins",
                    ),
              ),
              SizedBox(height: deviceHeight! * 0.015),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: deviceWidth! * 0.17),
                child: Text(
                  "The best delivery app in town for delivering your daily fresh groceries",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: "Poppins",
                      ),
                ),
              ),
              const SizedBox(height: 33),
              SizedBox(
                height: 53,
                width: 190,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: const WidgetStatePropertyAll(
                      colors.darkprimary,
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  onPressed: () {
                    SettingProvider settingProvider =
                        Provider.of<SettingProvider>(context, listen: false);
                    settingProvider.setPrefrenceBool(ISFIRSTTIME, true);
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (context) =>
                              const LoginScreen(isPop: false)),
                      // CupertinoPageRoute(
                      //     builder: (context) => const SignInUpAcc(
                      //           isPop: false,
                      //         )),
                    );
                  },
                  child: Text(
                    'Get Started',
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: colors.lightWhite2,
                          fontSize: 13,
                          fontFamily: "Poppins",
                        ),
                  ),
                ),
              ),
              SizedBox(height: deviceHeight! * 0.05),
            ],
          ),
        ],
      ),
    );
  }
}

// class Slide {
//   final String imageUrl;
//   final String? title;
//   final String? description;

//   Slide({
//     required this.imageUrl,
//     required this.title,
//     required this.description,
//   });
// }

// class IntroSlider extends StatefulWidget {
//   const IntroSlider({Key? key}) : super(key: key);
//   static route(RouteSettings settings) {
//     return BlurredRouter(
//       builder: (context) {
//         return const IntroSlider();
//       },
//     );
//   }

//   @override
//   _GettingStartedScreenState createState() => _GettingStartedScreenState();
// }

// class _GettingStartedScreenState extends State<IntroSlider>
//     with TickerProviderStateMixin {
//   int _currentPage = 0;
//   final PageController _pageController = PageController(initialPage: 0);
//   Animation? buttonSqueezeanimation;
//   AnimationController? buttonController;
//   late List slideList = [
//     Slide(
//       imageUrl: 'assets/images/introimage_a.svg',
//       title: getTranslated(context, 'TITLE1_LBL'),
//       description: getTranslated(context, 'DISCRIPTION1'),
//     ),
//     Slide(
//       imageUrl: 'assets/images/introimage_b.svg',
//       title: getTranslated(context, 'TITLE2_LBL'),
//       description: getTranslated(context, 'DISCRIPTION2'),
//     ),
//     Slide(
//       imageUrl: 'assets/images/introimage_c.svg',
//       title: getTranslated(context, 'TITLE3_LBL'),
//       description: getTranslated(context, 'DISCRIPTION3'),
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();

//     buttonController = AnimationController(
//         duration: const Duration(milliseconds: 2000), vsync: this);

//     buttonSqueezeanimation = Tween(
//       begin: deviceWidth! * 0.9,
//       end: 50.0,
//     ).animate(CurvedAnimation(
//       parent: buttonController!,
//       curve: const Interval(
//         0.0,
//         0.150,
//       ),
//     ));
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _pageController.dispose();
//     buttonController!.dispose();

//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: SystemUiOverlay.values);
//   }

//   _onPageChanged(int index) {
//     if (mounted) {
//       setState(() {
//         _currentPage = index;
//       });
//     }
//   }

//   List<T?> map<T>(List list, Function handler) {
//     List<T?> result = [];
//     for (var i = 0; i < list.length; i++) {
//       result.add(handler(i, list[i]));
//     }

//     return result;
//   }

//   Widget _slider() {
//     return Expanded(
//       child: slideList.isNotEmpty
//           ? PageView.builder(
//               itemCount: slideList.length,
//               scrollDirection: Axis.horizontal,
//               controller: _pageController,
//               onPageChanged: _onPageChanged,
//               itemBuilder: (BuildContext context, int index) {
//                 return SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.max,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * .5,
//                         child: SvgPicture.asset(
//                           slideList[index].imageUrl,
//                         ),
//                       ),
//                       Container(
//                           margin: const EdgeInsetsDirectional.only(top: 20),
//                           child: Text(slideList[index].title,
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .headlineSmall!
//                                   .copyWith(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .fontColor,
//                                       fontWeight: FontWeight.bold))),
//                       Container(
//                         padding: const EdgeInsetsDirectional.only(
//                             top: 30.0, start: 15.0, end: 15.0),
//                         child: Text(slideList[index].description,
//                             textAlign: TextAlign.center,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleMedium!
//                                 .copyWith(
//                                     color:
//                                         Theme.of(context).colorScheme.fontColor,
//                                     fontWeight: FontWeight.normal)),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             )
//           : const SizedBox.shrink(),
//     );
//   }

//   _btn() {
//     return Column(
//       children: [
//         Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: getList()),
//         Center(
//             child: Padding(
//           padding: const EdgeInsetsDirectional.only(bottom: 18.0),
//           child: AppBtn(
//               title: _currentPage == 0 || _currentPage == 1
//                   ? getTranslated(context, 'NEXT_LBL')
//                   : getTranslated(context, 'GET_STARTED'),
//               btnAnim: buttonSqueezeanimation,
//               btnCntrl: buttonController,
//               onBtnSelected: () {
//                 if (_currentPage == 2) {
                  // SettingProvider settingProvider =
                  //     Provider.of<SettingProvider>(context, listen: false);
                  // settingProvider.setPrefrenceBool(ISFIRSTTIME, true);
                  // Navigator.pushReplacement(
                  //   context,
                  //   CupertinoPageRoute(
                  //       builder: (context) => const SignInUpAcc()),
                  // );
//                 } else {
//                   _currentPage = _currentPage + 1;
//                   _pageController.animateToPage(_currentPage,
//                       curve: Curves.decelerate,
//                       duration: const Duration(milliseconds: 300));
//                 }
//               }),
//         )),
//       ],
//     );
//   }

//   List<Widget> getList() {
//     List<Widget> childs = [];

//     for (int i = 0; i < slideList.length; i++) {
//       childs.add(AnimatedContainer(
//           duration: const Duration(milliseconds: 500),
//           width: _currentPage == i ? 25 : 8.0,
//           height: 8.0,
//           margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5.0),
//             color: _currentPage == i
//                 ? Theme.of(context).colorScheme.fontColor
//                 : Theme.of(context).colorScheme.lightBlack.withOpacity(0.7),
//           )));
//     }
//     return childs;
//   }

//   skipBtn() {
//     return _currentPage == 0 || _currentPage == 1
//         ? Padding(
//             padding: const EdgeInsetsDirectional.only(top: 20.0, end: 10.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: <Widget>[
//                 InkWell(
//                   onTap: () {
//                     SettingProvider settingProvider =
//                         Provider.of<SettingProvider>(context, listen: false);
//                     settingProvider.setPrefrenceBool(ISFIRSTTIME, true);
//                     Navigator.pushReplacement(
//                       context,
//                       CupertinoPageRoute(
//                           builder: (context) => const SignInUpAcc()),
//                     );
//                   },
//                   child: Row(children: [
//                     Text(getTranslated(context, 'SKIP')!,
                        // style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        //       color: Theme.of(context).colorScheme.fontColor,
                        //     )),
//                     Icon(
//                       Icons.arrow_forward_ios,
//                       color: Theme.of(context).colorScheme.fontColor,
//                       size: 12.0,
//                     ),
//                   ]),
//                 ),
//               ],
//             ))
//         : Container(
//             margin: const EdgeInsetsDirectional.only(top: 50.0),
//             height: 15,
//           );
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
//     deviceHeight = MediaQuery.of(context).size.height;
//     deviceWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//         body: SafeArea(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           skipBtn(),
//           _slider(),
//           _btn(),
//         ],
//       ),
//     ));
//   }
// }

// class Slide {
//   final String imageUrl;
//   final String? title;
//   final String? description;

//   Slide({
//     required this.imageUrl,
//     required this.title,
//     required this.description,
//   });
// }
