import 'dart:async';

import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/SqliteData.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Model/Section_Model.dart';
import 'package:eshop/Provider/CartProvider.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:eshop/Screen/HomePage.dart';
import 'package:eshop/Screen/Login.dart';
import 'package:eshop/Screen/cart/Cart.dart';
import 'package:eshop/app/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Helper/Session.dart';
import '../../../ui/styles/DesignConfig.dart';

class FeaturedProductItem extends StatefulWidget {
  const FeaturedProductItem({
    super.key,
    required this.price,
    required this.offerPersontage,
    required this.product,
    required this.sectionPosition,
    required this.index,
  });

  final double price;
  final String? offerPersontage;
  final Product product;
  final int sectionPosition;
  final int index;

  @override
  State<FeaturedProductItem> createState() => _FeaturedProductItemState();
}

class _FeaturedProductItemState extends State<FeaturedProductItem> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.5;

    return Card(
      elevation: 0.0,
      color: const Color.fromARGB(255, 233, 233, 233).withOpacity(0.5),
      margin: const EdgeInsetsDirectional.only(bottom: 2, end: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 15),
            Expanded(
              child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    clipBehavior: Clip.none,
                    children: [
                      networkImageCommon(widget.product.image!, width, false,
                          height: double.maxFinite, width: double.maxFinite),
                      widget.product.availability == "0"
                          ? Container(
                              constraints: const BoxConstraints.expand(),
                              color: Theme.of(context).colorScheme.white70,
                              width: double.maxFinite,
                              padding: const EdgeInsets.all(2),
                              child: Center(
                                child: Text(
                                  getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  start: 10.0, top: 5, end: 5.0),
              child: Text(
                widget.product.name!,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Theme.of(context).colorScheme.lightBlack),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 10.0, top: 2),
              child: Text(
                widget.product.isSalesOn == "1"
                    ? getPriceFormat(
                        context,
                        safeParseDouble(
                            widget.product.prVarientList![0].saleFinalPrice ??
                                "0.0"))!
                    : '${getPriceFormat(context, widget.price)!} ',
                style: const TextStyle(
                    fontSize: 11.0,
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  start: 10.0, bottom: 8, top: 2),
              child: widget.offerPersontage != "0.00"
                  ? safeParseDouble(
                              widget.product.prVarientList![0].disPrice!) !=
                          0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              safeParseDouble(widget.product.prVarientList![0]
                                          .disPrice!) !=
                                      0
                                  ? getPriceFormat(
                                      context,
                                      safeParseDouble(widget
                                          .product.prVarientList![0].price!))!
                                  : "",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      letterSpacing: 0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor
                                          .withOpacity(0.6)),
                            ),
                          ],
                        )
                      : Container(
                          height: 5,
                        )
                  : const SizedBox.shrink(),
            ),
            const Divider(
              color: Colors.grey,
            ),
            SizedBox(
              height: 35,
              child: TextButton.icon(
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.zero),
                ),
                onPressed: () {
                  addToCart(
                    widget.product.name ?? "",
                    false,
                    true,
                    widget.product,
                  ).then((val) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const Cart(fromBottom: false),
                      ),
                    );
                  });
                },
                label: Text(
                  "Add to cart",
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                ),
                icon: Image.asset(
                  'assets/images/home/cart.png',
                  color: Colors.green,
                  width: 10,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Product model = widget.product;
          Navigator.pushNamed(context, Routers.productDetails, arguments: {
            "secPos": widget.sectionPosition,
            "index": widget.index,
            "list": false,
            "id": model.id!,
          });
        },
      ),
    );
  }

  bool _isNetworkAvail = true;
  bool qtyChange = false;
  int _oldSelVarient = 0;
  var db = DatabaseHelper();

  // Safe parsing methods
  double safeParseDouble(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      return 0.0; // Default value
    }
  }

  int safeParseInt(String value) {
    try {
      return int.parse(value);
    } catch (e) {
      return 0; // Default value
    }
  }

  Future<void> addToCart(
      String qty, bool intent, bool from, Product product) async {
    try {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        Product model1 = product;
        setState(() {
          qtyChange = true;
        });
        if (context.read<UserProvider>().userId != "") {
          try {
            if (mounted) {
              setState(() {
                context.read<CartProvider>().setProgress(true);
              });
            }
            if (safeParseInt(qty) < model1.minOrderQuntity!) {
              qty = model1.minOrderQuntity.toString();
              // setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
            }

            var parameter = {
              USER_ID: context.read<UserProvider>().userId,
              PRODUCT_VARIENT_ID: model1.prVarientList![_oldSelVarient].id,
              QTY: qty,
            };
            apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
              bool error = getdata["error"];
              String? msg = getdata["message"];
              if (!error) {
                var data = getdata["data"];

                model1.prVarientList![_oldSelVarient].cartCount =
                    qty.toString();
                if (from) {
                  context.read<UserProvider>().setCartCount(data['cart_count']);
                  var cart = getdata["cart"];
                  List<SectionModel> cartList = [];
                  cartList = (cart as List)
                      .map((cart) => SectionModel.fromCart(cart))
                      .toList();

                  context.read<CartProvider>().setCartlist(cartList);

                  if (intent) {
                    cartTotalClear();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const Cart(
                          fromBottom: false,
                        ),
                      ),
                    );
                  } else {
                    setSnackbar(getTranslated(context, 'PRO_ADD_TO_CART_LBL')!,
                        context);
                  }
                }
              } else {
                setSnackbar(msg!, context);
              }
              if (mounted) {
                setState(() {
                  context.read<CartProvider>().setProgress(false);
                });
              }
            }, onError: (error) {
              setSnackbar(error.toString(), context);
            });
          } on TimeoutException catch (_) {
            setSnackbar(getTranslated(context, 'somethingMSg')!, context);
            if (mounted) {
              setState(() {
                context.read<CartProvider>().setProgress(false);
              });
            }
          }
        } else {
          // Navigate to Login Screen
          setSnackbar(
            getTranslated(context, 'You have to login first.')!,
            context,
          );

          Future.delayed(const Duration(microseconds: 2), () {
            intent = false;
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(
                builder: (context) => const LoginScreen(isPop: false),
              ),
              (route) => true,
            );
          });
        }
      } else {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } catch (e) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }
}
