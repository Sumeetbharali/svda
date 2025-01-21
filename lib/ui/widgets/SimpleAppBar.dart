import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:eshop/Screen/cart/Cart.dart';
import 'package:eshop/app/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

getSimpleAppBar(
  String title,
  BuildContext context,
) {
  return AppBar(
    elevation: 0,
    titleSpacing: 0,
    centerTitle: true,
    backgroundColor: Theme.of(context).colorScheme.white,
    leading: Builder(builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.all(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: Theme.of(context).colorScheme.primarytheme,
            ),
          ),
        ),
      );
    }),
    title: Text(
      title,
      style: TextStyle(
          color: Theme.of(context).colorScheme.primarytheme,
          fontWeight: FontWeight.normal),
    ),
    actions: [
      // Row(
      // mainAxisAlignment: MainAxisAlignment.end,
      // crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisSize: MainAxisSize.min,
      // children: [
      Center(
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routers.favoriteScreen,
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                'assets/images/home/wishlist.png',
                width: 22,
                color: Theme.of(context).colorScheme.primarytheme,
              ),
              // Positioned(
              //   right: -7,
              //   top: -5,
              //   child: Container(
              //     height: 15,
              //     width: 15,
              //     decoration: const BoxDecoration(
              //       color: colors.red,
              //       shape: BoxShape.circle,
              //     ),
              //     child: Padding(
              //       padding: const EdgeInsets.all(0),
              //       child: Center(
              //         child: Text(
              //           data,
              //           maxLines: 1,
              //           overflow: TextOverflow.ellipsis,
              //           style: TextStyle(
              //             color: Theme.of(context).colorScheme.white,
              //             fontSize: 8,
              //             fontWeight: FontWeight.w500,
              //             fontFamily: "Poppins",
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 15),
      Center(
        child: Selector<UserProvider, String>(
          builder: (context, data, child) {
            return InkWell(
              onTap: () {
                if (title != "Cart")
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Cart(fromBottom: false),
                    ),
                  );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    "assets/images/home/cart.png",
                    color: Theme.of(context).colorScheme.primarytheme,
                    width: 18,
                    height: 20,
                  ),
                  (data.isNotEmpty && data != "0")
                      ? Positioned(
                          right: -5,
                          top: -5,
                          // textDirection: Directionality.of(context),
                          child: Container(
                            height: 15,
                            width: 15,
                            decoration: const BoxDecoration(
                              color: colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Center(
                                child: Text(
                                  data.toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink()
                ],
              ),
            );
          },
          selector: (_, homeProvider) => homeProvider.curCartCount,
        ),
      ),
      const SizedBox(width: 15),
      //   ],
      // ),
    ],
  );
}
