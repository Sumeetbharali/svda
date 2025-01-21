// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eshop/Screen/homeWidgets/sections/featured_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Provider/CategoryProvider.dart';
import 'package:eshop/Provider/HomeProvider.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:eshop/Screen/Dashboard.dart';
import 'package:shimmer/shimmer.dart';

import '../Helper/Session.dart';
import '../Model/Section_Model.dart';
import '../app/routes.dart';
import '../ui/styles/DesignConfig.dart';
import 'HomePage.dart';

class AllCategory extends StatefulWidget {
  bool? isSeeAll;
  AllCategory({
    super.key,
    this.isSeeAll,
  });

  @override
  AllCategoryState createState() => AllCategoryState();
}

class AllCategoryState extends State<AllCategory> {
  final ScrollController _scrollControllerOnCategory = ScrollController();
  final ScrollController _scrollControllerOnSubCategory = ScrollController();
  List<SectionModel> featuredSectionList = [];

  @override
  void initState() {
    _section();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _section();
  }

  @override
  Widget build(BuildContext context) {
    hideAppbarAndBottomBarOnScroll(_scrollControllerOnCategory, context);
    hideAppbarAndBottomBarOnScroll(_scrollControllerOnSubCategory, context);
    return Scaffold(
      appBar: widget.isSeeAll == true
          ? AppBar(
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).colorScheme.black,
                  size: 16,
                ),
              ),
              title: Text(
                "Categories",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 21,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.lightWhite,
            )
          : null,
      body: SingleChildScrollView(
        controller: _scrollControllerOnSubCategory,
        child: Column(
          children: [
            Consumer<HomeProvider>(builder: (context, homeProvider, _) {
              if (homeProvider.catLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primarytheme,
                  ),
                );
              }

              // Row(
              //   children: [
              //     Expanded(
              //         flex: 1,
              //         child: Container(
              //             color: Theme.of(context).colorScheme.lightWhite,
              //             child: ListView.builder(
              //               physics: const BouncingScrollPhysics(
              //                   parent: AlwaysScrollableScrollPhysics()),
              //               controller: _scrollControllerOnCategory,
              //               shrinkWrap: true,
              //               scrollDirection: Axis.vertical,
              //               padding: const EdgeInsetsDirectional.only(top: 10.0),
              //               itemCount: catList.length,
              //               itemBuilder: (context, index) {
              //                 return catItem(index, context);
              //               },
              //             ))),
              //     Expanded(
              //       flex: 3,
              //       child: catList.isNotEmpty
              //           ? Column(
              //               children: [
              //                 Selector<CategoryProvider, int>(
              //                   builder: (context, data, child) {
              //                     return Padding(
              //                       padding: const EdgeInsets.all(8.0),
              //                       child: Column(
              //                         crossAxisAlignment: CrossAxisAlignment.start,
              //                         mainAxisSize: MainAxisSize.min,
              //                         children: [
              //                           Row(
              //                             children: [
              //                               Text(
              //                                   "${capitalize(catList[data].name!.toLowerCase())} "),
              //                               const Expanded(
              //                                   child: Divider(
              //                                 thickness: 2,
              //                               ))
              //                             ],
              //                           ),
              //                           Padding(
              //                               padding: const EdgeInsets.symmetric(
              //                                   vertical: 8.0),
              //                               child: Text(
              //                                 "${getTranslated(context, 'All')!} ${capitalize(catList[data].name!.toLowerCase())} ",
              //                                 style: Theme.of(context)
              //                                     .textTheme
              //                                     .titleMedium!
              //                                     .copyWith(
              //                                       color: Theme.of(context)
              //                                           .colorScheme
              //                                           .fontColor,
              //                                     ),
              //                               ))
              //                         ],
              //                       ),
              //                     );
              //                   },
              //                   selector: (_, cat) => cat.curCat,
              //                 ),
              //                 Expanded(
              //                     child: Selector<CategoryProvider, List<Product>>(
              //                   builder: (context, data, child) {
              //                     return data.isNotEmpty
              //                         ? GridView.count(
              //                             physics: const BouncingScrollPhysics(
              //                                 parent:
              //                                     AlwaysScrollableScrollPhysics()),
              //                             controller:
              //                                 _scrollControllerOnSubCategory,
              //                             padding: const EdgeInsets.symmetric(
              //                                 horizontal: 20),
              //                             crossAxisCount: 3,
              //                             shrinkWrap: true,
              //                             childAspectRatio: .6,
              //                             children: List.generate(
              //                               data.length,
              //                               (index) {
              //                                 return subCatItem(
              //                                     data, index, context);
              //                               },
              //                             ))
              //                         : Center(
              //                             child: Text(
              //                                 getTranslated(context, 'noItem')!));
              //                   },
              //                   selector: (_, categoryProvider) =>
              //                       categoryProvider.subList,
              //                 )),
              //               ],
              //             )
              //           : const SizedBox.shrink(),
              //     ),
              //   ],
              // );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchBar(context),
                  const SizedBox(height: 10),
                  findTHeBEst(context),
                  const SizedBox(height: 10),
                  _catList(),
                  const SizedBox(height: 20),
                  _section(),

                  // recentViews(context),
                  // const SizedBox(height: 20),
                  // _recentviewItem(context),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  GridView _recentviewItem(BuildContext context) {
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
                      const Color.fromARGB(255, 233, 233, 233).withOpacity(0.9),
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

  Padding findTHeBEst(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Text(
        "Find The Best",
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Padding recentViews(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Text(
        "Recent Views",
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Padding searchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: InkWell(
        onTap: () async {
          await Navigator.pushNamed(context, Routers.searchScreen);

          if (mounted) setState(() {});
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
            // const SizedBox(width: 10),
            // Container(
            //   height: 50,
            //   width: 50,
            //   decoration: BoxDecoration(
            //     color: const Color(0XffE6FFD2),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Image.asset(
            //     'assets/images/categories/Vector (20).png',
            //     cacheWidth: 20,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  _section() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? SizedBox(
                width: double.infinity,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.simmerBase,
                    highlightColor: Theme.of(context).colorScheme.simmerHigh,
                    child: sectionLoading()))
            :
            // Container(
            //     height: 200,
            //     color: Colors.red,
            //     child: Column(
            //       children: [
            //         Text(featuredSectionList.length),
            //       ],
            //     ),
            ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: featuredSectionList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  setState(() {});
                  return _singleFeaturedSection(index);
                  // return Column(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: <Widget>[
                  //     _getHeading(
                  //         featuredSectionList[index].title ?? "", index, 1, []),
                  //     // _getFeaturedSection(index),
                  //   ],
                  // );
                },
                // ),
              );
      },
      selector: (_, homeProvider) => homeProvider.secLoading,
    );
  }

  sectionLoading() {
    return Column(
        children: [0, 1, 2, 3, 4]
            .map((_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                                margin: const EdgeInsets.only(bottom: 40),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.white,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20)))),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                width: double.infinity,
                                height: 18.0,
                                color: Theme.of(context).colorScheme.white,
                              ),
                              GridView.count(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  childAspectRatio: 1.0,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                  children: List.generate(
                                    4,
                                    (index) {
                                      return Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color:
                                            Theme.of(context).colorScheme.white,
                                      );
                                    },
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    sliderLoading()
                    //offerImages.length > index ? _getOfferImage(index) : SizedBox.shrink(),
                  ],
                ))
            .toList());
  }

  Widget sliderLoading() {
    double width = deviceWidth!;
    double height = width / 2;
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          height: height,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  _singleFeaturedSection(int index) {
    Color back;
    int pos = index % 5;
    if (pos == 0) {
      back = Theme.of(context).colorScheme.back1;
    } else if (pos == 1) {
      back = Theme.of(context).colorScheme.back2;
    } else if (pos == 2) {
      back = Theme.of(context).colorScheme.back3;
    } else if (pos == 3) {
      back = Theme.of(context).colorScheme.back4;
    } else {
      back = Theme.of(context).colorScheme.back5;
    }

    return featuredSectionList[index].productList!.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Stack(
                  children: [
                    // Positioned.fill(
                    //   child: Container(
                    //     margin: const EdgeInsets.only(bottom: 40),
                    //     decoration: BoxDecoration(
                    //       color: back,
                    //       borderRadius: const BorderRadius.only(
                    //           topLeft: Radius.circular(20),
                    //           topRight: Radius.circular(20)),
                    //     ),
                    //   ),
                    // ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _getHeading(featuredSectionList[index].title ?? "",
                            index, 1, []),
                        _getFeaturedSection(index),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  _getFeaturedSection(int index) {
    var orient = MediaQuery.of(context).orientation;
    SectionModel featuredSection = featuredSectionList[index];
    List<Product>? featuredSectionProductList = featuredSection.productList;

    return FeaturedSectionGet()
        .get(featuredSection.style!,
            index: index, products: featuredSectionProductList!)
        .render(context);
  }

  _getHeading(
    String title,
    int index,
    int from,
    List<Product> productList,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(90, 214, 255, 214),
            Color.fromARGB(44, 198, 236, 198),
            Color.fromARGB(20, 198, 236, 198),
            // Color.fromARGB(0, 255, 255, 255),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.2, 0.5, 0.9],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (from == 1)
            Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 5, left: 8),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerRight,
                children: <Widget>[
                  // Container(
                  //   decoration: BoxDecoration(
                  //     borderRadius: const BorderRadius.only(
                  //         topLeft: Radius.circular(20),
                  //         topRight: Radius.circular(20)),
                  //     color: Colors.grey.shade200,
                  //   ),
                  //   padding: const EdgeInsetsDirectional.only(
                  //       start: 12, bottom: 3, top: 3, end: 12),
                  //   child: Text(
                  //     from == 2
                  //         ? title
                  //         : featuredSectionList[index].shortDesc ?? "",
                  //     style: Theme.of(context)
                  //         .textTheme
                  //         .titleSmall!
                  //         .copyWith(color: colors.blackTemp),
                  //     maxLines: 1,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      from == 2
                          ? featuredSectionList[index].shortDesc ?? ""
                          : featuredSectionList[index].shortDesc ?? "",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
              padding: const EdgeInsetsDirectional.only(start: 20.0, end: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      from == 2
                          ? title
                          : featuredSectionList[index].title ?? "",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                          minimumSize: Size.zero, //
                          // backgroundColor: (Theme.of(context).colorScheme.white),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5)),
                      child: Text(
                        getTranslated(context, 'See all')!,
                        // getTranslated(context, 'SHOP_NOW')!,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      onPressed: () {
                        SectionModel model = featuredSectionList[index];

                        Navigator.pushNamed(context, Routers.sectionListScreen,
                            arguments: {
                              "index": index,
                              "section_model": model,
                              "from": from,
                              "productList": productList,
                            });
                      }),
                ],
              )),
        ],
      ),
    );
  }

  Widget catLoading() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    .map((_) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            shape: BoxShape.circle,
                          ),
                          width: 50.0,
                          height: 50.0,
                        ))
                    .toList()),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
  }

  // searchBar() {
  //   return InkWell(
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 18),
  //       child: SizedBox(
  //         height: 50,
  //         child:
  //       ),
  //     ),
  //     onTap: () async {
  //       // await Navigator.push(
  //       //     context,
  //       //     CupertinoPageRoute(
  //       //       builder: (context) => const SearchScreen(),
  //       //     ));

  //       await Navigator.pushNamed(context, Routers.searchScreen);

  //       if (mounted) setState(() {});
  //     },
  //   );
  // }

  _catList() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? SizedBox(
                width: double.infinity,
                child: Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.simmerBase,
                  highlightColor: Theme.of(context).colorScheme.simmerHigh,
                  child: catLoading(),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 3 items per row
                    crossAxisSpacing: 5.0, // Spacing between columns
                    mainAxisSpacing: 5.0, // Spacing between rows
                    childAspectRatio: 0.65, // Adjust width/height ratio
                  ),
                  itemCount: catList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        if (catList[index].subList == null ||
                            catList[index].subList!.isEmpty) {
                          await Navigator.pushNamed(
                            context,
                            Routers.productListScreen,
                            arguments: {
                              "name": catList[index].name,
                              "id": catList[index].id,
                              "tag": false,
                              "fromSeller": false,
                            },
                          );
                        } else {
                          await Navigator.pushNamed(
                            context,
                            Routers.subCategoryScreen,
                            arguments: {
                              "title": catList[index].name!,
                              "subList": catList[index].subList,
                            },
                          );
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 65,
                            width: 75,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .black
                                      .withOpacity(0.048),
                                  spreadRadius: 2,
                                  blurRadius: 13,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                              color: const Color.fromARGB(255, 224, 224, 224)
                                  .withOpacity(0.7),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Center(
                              child: networkImageCommon(
                                catList[index].image!,
                                30,
                                width: 50,
                                height: 50,
                                false,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            (formatText(catList[index].name!)),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
      },
      selector: (_, homeProvider) => homeProvider.catLoading,
    );
  }

  String formatText(String input) {
    // Split the input text into words
    List<String> words = input.split(' ');

    // Group words into chunks of 2 per line
    List<String> lines = [];
    for (int i = 0; i < words.length; i += 2) {
      lines.add(words
          .sublist(i, i + 2 > words.length ? words.length : i + 2)
          .join(' '));
    }

    // Combine chunks into a string with line breaks
    return lines.take(2).join('\n'); // Limit to 2 lines
  }

  String breakTextIntoLines(String text) {
    return text.split(' ').join('\n');
  }

  Widget catItem(int index, BuildContext context1) {
    return Selector<CategoryProvider, int>(
      builder: (context, data, child) {
        if (index == 0 && (popularList.isNotEmpty)) {
          return InkWell(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: data == index
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).colorScheme.white,
                  border: data == index
                      ? Border(
                          bottom: BorderSide(
                              width: 0.5,
                              color:
                                  Theme.of(context).colorScheme.primarytheme),
                          top: BorderSide(
                              width: 0.5,
                              color:
                                  Theme.of(context).colorScheme.primarytheme),
                          left: BorderSide(
                              width: 5.0,
                              color:
                                  Theme.of(context).colorScheme.primarytheme),
                        )
                      : null),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: SvgPicture.asset(
                          data == index
                              ? "${imagePath}popular_sel.svg"
                              : "${imagePath}popular.svg",
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.primarytheme,
                              BlendMode.srcIn),
                        )),
                  ),
                  Text(
                    "${capitalize(catList[index].name!.toLowerCase())}\n",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context1).textTheme.bodySmall!.copyWith(
                        color: data == index
                            ? Theme.of(context).colorScheme.primarytheme
                            : Theme.of(context).colorScheme.fontColor),
                  )
                ],
              ),
            ),
            onTap: () {
              context1.read<CategoryProvider>().setCurSelected(index);
              context1.read<CategoryProvider>().setSubList(popularList);
            },
          );
        } else {
          return InkWell(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: data == index
                      ? Theme.of(context).canvasColor
                      : Theme.of(context).colorScheme.white,
                  border: data == index
                      ? Border(
                          left: BorderSide(
                              width: 5.0,
                              color:
                                  Theme.of(context).colorScheme.primarytheme),
                        )
                      : null),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: deviceWidth! / 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .fontColor
                                .withOpacity(0.042),
                            spreadRadius: 2,
                            blurRadius: 13,
                            offset: const Offset(
                                0, 0), // changes position of shadow
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                          radius: 45.0,
                          backgroundColor: Theme.of(context).colorScheme.white,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child: networkImageCommon(
                                catList[index].image!,
                                50,
                                width: deviceWidth! / 7.8,
                                height: double.maxFinite,
                                false),
                          )
                          /*CachedNetworkImage(
                            imageUrl: catList[index].image!,
                            fadeInDuration: const Duration(milliseconds: 150),
                            fit: BoxFit.fill,
                            errorWidget: (context, error, stackTrace) =>
                                erroWidget(50),
                            placeholder: (context,url) { return placeHolder(50);}
                          )*/
                          ),
                    ),
                  )),
                  Text(
                    "${capitalize(catList[index].name!.toLowerCase())}\n",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context1).textTheme.bodySmall!.copyWith(
                        color: data == index
                            ? Theme.of(context).colorScheme.primarytheme
                            : Theme.of(context).colorScheme.fontColor),
                  )
                ],
              ),
            ),
            onTap: () {
              context1.read<CategoryProvider>().setCurSelected(index);
              if (catList[index].subList == null ||
                  catList[index].subList!.isEmpty) {
                context1.read<CategoryProvider>().setSubList([]);
                // Navigator.push(
                //     context1,
                //     CupertinoPageRoute(
                //       builder: (context) => ProductListScreen(
                //         name: catList[index].name,
                //         id: catList[index].id,
                //         tag: false,
                //         fromSeller: false,
                //       ),
                //     )).then((value) {
                //   context.read<CategoryProvider>().setCurSelected(0);
                // });

                Navigator.pushNamed(context1, Routers.productListScreen,
                    arguments: {
                      "name": catList[index].name,
                      "id": catList[index].id,
                      "tag": false,
                      "fromSeller": false,
                    }).then((value) {
                  context.read<CategoryProvider>().setCurSelected(0);
                });
                ;
              } else {
                context1
                    .read<CategoryProvider>()
                    .setSubList(catList[index].subList);
              }
            },
          );
        }
      },
      selector: (_, cat) => cat.curCat,
    );
  }

  subCatItem(List<Product> subList, int index, BuildContext context) {
    return InkWell(
      child: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.042),
                        spreadRadius: 2,
                        blurRadius: 13,
                        offset:
                            const Offset(0, 0), // changes position of shadow
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                      radius: 45.0,
                      backgroundColor: Theme.of(context).colorScheme.white,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: networkImageCommon(
                              subList[index].image!, 50, false))
                      /*CachedNetworkImage(
                      imageUrl: subList[index].image!,
                      fadeInDuration: const Duration(milliseconds: 150),
                      fit: BoxFit.fill,
                      errorWidget: (context, error, stackTrace) =>
                          erroWidget(50),
                      placeholder: (context,url) {return placeHolder(50);}
                    ),*/
                      ))),
          Text(
            "${capitalize(subList[index].name!.toLowerCase())}\n",
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
          )
        ],
      ),
      onTap: () {
        if (context.read<CategoryProvider>().curCat == 0 &&
            popularList.isNotEmpty) {
          if (popularList[index].subList == null ||
              popularList[index].subList!.isEmpty) {
            // Navigator.push(
            //     context,
            //     CupertinoPageRoute(
            //       builder: (context) => ProductListScreen(
            //
            //       ),
            //     ));

            Navigator.pushNamed(context, Routers.productListScreen, arguments: {
              "name": popularList[index].name,
              "id": popularList[index].id,
              "tag": false,
              "fromSeller": false,
            });
          } else {
            // Navigator.push(
            //     context,
            //     CupertinoPageRoute(
            //       builder: (context) => SubCategoryScreen(),
            //     ));

            Navigator.pushNamed(context, Routers.subCategoryScreen, arguments: {
              "subList": popularList[index].subList,
              "title": popularList[index].name!.toUpperCase(),
            });
          }
        } else if (subList[index].subList == null ||
            subList[index].subList!.isEmpty) {
          Navigator.pushNamed(context, Routers.productListScreen, arguments: {
            "name": subList[index].name,
            "id": subList[index].id,
            "tag": false,
            "fromSeller": false,
          });
        } else {
          // Navigator.push(
          //     context,
          //     CupertinoPageRoute(
          //       builder: (context) => SubCategoryScreen(
          //
          //       ),
          //     ));

          Navigator.pushNamed(context, Routers.subCategoryScreen, arguments: {
            "subList": subList[index].subList,
            "title": subList[index].name!.toUpperCase(),
          });
        }
      },
    );
  }
}
