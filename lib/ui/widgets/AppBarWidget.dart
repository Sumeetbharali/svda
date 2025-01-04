import 'package:eshop/Helper/Color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../Helper/Session.dart';
import '../../Provider/UserProvider.dart';
import '../../Screen/cart/Cart.dart';
import '../../app/routes.dart';
import '../styles/DesignConfig.dart';

getAppBar(String title, BuildContext context, {int? from, bool? fromBottom}) {
  return AppBar(
    centerTitle: true,
    elevation: 0,
    titleSpacing: 0,
    backgroundColor: Theme.of(context).colorScheme.white,
    leading: Builder(builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.all(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => Navigator.of(context).pop(),
          child: fromBottom == true
              ? const SizedBox()
              : const Center(
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.black,
                    // color: Theme.of(context).colorScheme.primarytheme,
                  ),
                ),
        ),
      );
    }),
    title: Text(title,
        style: const TextStyle(
          color: Colors.black,
          // color: Theme.of(context).colorScheme.primarytheme,
          fontWeight: FontWeight.w600,
        )
        // const TextStyle(color: Theme.of(context).colorScheme.primarytheme, fontWeight: FontWeight.normal),
        ),
    actions: <Widget>[
      from == 1 || title == "Profile"
          ? const SizedBox()
          // : InkWell(
          //     onTap: () {
          //       if (title != "WishList") {
          //         Navigator.pushNamed(
          //           context,
          //           Routers.favoriteScreen,
          //         );
          //       }
          //     },
          //     child: Padding(
          //       padding: const EdgeInsets.only(right: 10.0),
          //       child: Image.asset(
          //         'assets/images/home/wishlist.png',
          //         width: 20,
          //         color: Theme.of(context).colorScheme.primarytheme,
          //       ),
          //     ),
          //   ),
          : IconButton(
              icon: SvgPicture.asset(
                "${imagePath}search.svg",
                height: 20,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.blackInverseInDarkTheme,
                    BlendMode.srcIn),
              ),
              onPressed: () {
                // Navigator.push(
                //     context,
                //     CupertinoPageRoute(
                //       builder: (context) =>  SearchScreen(),
                //     ));

                Navigator.pushNamed(
                  context,
                  Routers.searchScreen,
                );
              }),
      from == 1
          ? const SizedBox()
          : title == getTranslated(context, 'FAVORITE')!
              ? const SizedBox.shrink()
              : IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: SvgPicture.asset(
                    "${imagePath}desel_fav.svg",
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.blackInverseInDarkTheme,
                        BlendMode.srcIn),
                  ),
                  onPressed: () {
                    // Navigator.push(
                    //     context,
                    //     CupertinoPageRoute(
                    //       builder: (context) => const Favorite(),
                    //     ));

                    Navigator.pushNamed(
                      context,
                      Routers.favoriteScreen,
                    );

                    ///
                    ///
                    ///
                    ///
                    ///
                    ///
                  },
                ),
      from == 1
          ? const SizedBox()
          : Selector<UserProvider, String>(
              builder: (context, data, child) {
                return IconButton(
                  icon: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Center(
                            child: Image.asset(
                          "assets/images/home/cart.png",
                          color: Colors.black,
                          width: 18,
                        )),
                      ),
                      // Center(
                      //     child: SvgPicture.asset(
                      //   "${imagePath}appbarCart.svg",
                      //   colorFilter: ColorFilter.mode(
                      //       Theme.of(context)
                      //           .colorScheme
                      //           .blackInverseInDarkTheme,
                      //       BlendMode.srcIn),
                      // )),
                      (data.isNotEmpty && data != "0")
                          ? Positioned(
                              top: 2,
                              right: 8,
                              child: Container(
                                  //  height: 20,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  // color: Theme.of(context)
                                  //     .colorScheme
                                  //     .primarytheme),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                        data,
                                        style: TextStyle(
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .white),
                                      ),
                                    ),
                                  )),
                            )
                          : const SizedBox.shrink()
                    ],
                  ),
                  onPressed: () {
                    cartTotalClear();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const Cart(
                          fromBottom: false,
                        ),
                      ),
                    );
                  },
                );
              },
              selector: (_, homeProvider) => homeProvider.curCartCount,
            )
    ],
  );
}
