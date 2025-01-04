import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Model/Section_Model.dart';
import 'package:eshop/Provider/HomeProvider.dart';
import 'package:eshop/Screen/All_Category.dart';
import 'package:eshop/Screen/HomePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../app/routes.dart';
import '../ui/styles/DesignConfig.dart';
import '../ui/widgets/AppBarWidget.dart';
import '../utils/blured_router.dart';

class SubCategoryScreen extends StatelessWidget {
  final List<Product>? subList;
  final String title;
  final String? maxDis;
  final String? minDis;
  static route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return SubCategoryScreen(
          title: arguments?['title'],
          minDis: arguments?['minDis'],
          maxDis: arguments?['maxDis'],
          subList: arguments?['subList'],
        );
      },
    );
  }

  const SubCategoryScreen({
    Key? key,
    this.subList,
    required this.title,
    this.maxDis,
    this.minDis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollControllerOnCategory = ScrollController();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.white,
      appBar: getAppBar(title, context),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        controller: _scrollControllerOnCategory,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Other Categories",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllCategory(),
                        ),
                      );
                    },
                    child: Text(
                      "See all",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: const Color(0Xff23AA49),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            searchBar(context),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    subList!.length,
                    (index) {
                      return subCatItem(index, context);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // cookingProducts(context),
            // const SizedBox(height: 20),
            // _cookingProducts(context),
          ],
        ),
      ),
      // body: GridView.count(
      //     padding: const EdgeInsets.all(20),
      //     crossAxisCount: 5,
      //     shrinkWrap: true,
      //     childAspectRatio: .75,
      //     children: List.generate(
      //       subList!.length,
      //       (index) {
      //         return subCatItem(index, context);
      //       },
      //     )),
    );
  }

  cookingProducts(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22),
      child: Text(
        "Cooking Products",
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  GridView _cookingProducts(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      // controller:
      //     _scrollControllerOnSubCategory,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: .6,
      children: List.generate(
        4,
        (index) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 233, 233, 233).withOpacity(0.5),
                  // shape: BoxShape.circle,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.042),
                      spreadRadius: 2,
                      blurRadius: 13,
                      offset: const Offset(0, 0), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/images/categories/Product Image.png',
                      height: 90,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      // "${capitalize(subList[index].name!.toLowerCase())}\n",
                      "Orange",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                    ),
                    Text(
                      // "${capitalize(subList[index].name!.toLowerCase())}\n",
                      "1kg, 45\u{20B9}",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                    ),
                    Text(
                      "45\u{20B9}",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .fontColor
                                .withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),
                    const SizedBox(height: 3),
                    const Divider(),
                    TextButton.icon(
                      style: const ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.zero),
                      ),
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/images/home/cart.png',
                        width: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(
                        " Add to cart",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 18,
                top: 0,
                child: Container(
                  height: 38,
                  width: 35,
                  decoration: BoxDecoration(
                    color: index == 0 || index == 2 ? Colors.green : Colors.red,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Center(
                      child: Text(
                        breakTextIntoLines(
                          sellingDiscount[index],
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Padding searchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: InkWell(
        onTap: () async {
          await Navigator.pushNamed(context, Routers.searchScreen);
        },
        child: Row(
          children: [
            Expanded(
              child: TextField(
                enabled: false,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                  hintText: getTranslated(context, 'Search products'),
                  // hintText: getTranslated(context, 'searchHint'),
                  hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.3),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: SvgPicture.asset(
                        'assets/images/search.svg',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primarytheme,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  // fillColor: const Color(0XFFF3F5F7),
                  fillColor:
                      const Color.fromARGB(255, 224, 224, 224).withOpacity(0.3),
                  filled: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: const Color(0XffE6FFD2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/images/categories/Vector (20).png',
                cacheWidth: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String breakTextIntoLines(String text) {
    return text.split(' ').join('\n');
  }

  subCatItem(int index, BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    color: const Color.fromARGB(255, 233, 233, 233)
                        .withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                      child: Center(
                        child: networkImageCommon(
                            subList![index].image!, 50, false),
                      ),
                    ),
                  )
                  /*CachedNetworkImage(
                    imageUrl: subList![index].image!,
                    fadeInDuration: const Duration(milliseconds: 150),
                    errorWidget: (context, error, stackTrace) => erroWidget(50),
                    placeholder: (context, url) {
                      return placeHolder(50);
                    },
                  )*/
                  ),
            ),
            Text(
              breakTextIntoLines(
                "${capitalize(subList![index].name!.toLowerCase())}\n",
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor, fontSize: 14),
            )
          ],
        ),
      ),
      onTap: () {
        if (subList![index].subList == null ||
            subList![index].subList!.isEmpty) {
          // Navigator.push(
          //     context,
          //     CupertinoPageRoute(
          //       builder: (context) => ProductListScreen(
          //
          //       ),
          //     ));

          Navigator.pushNamed(context, Routers.productListScreen, arguments: {
            "name": subList![index].name,
            "id": subList![index].id,
            "tag": false,
            "fromSeller": false,
            "maxDis": maxDis,
            "minDis": minDis,
          });
        } else {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => SubCategoryScreen(
                  subList: subList![index].subList,
                  title: subList![index].name!.toUpperCase(),
                  maxDis: maxDis,
                  minDis: minDis,
                ),
              ));
        }
      },
    );
  }
}
