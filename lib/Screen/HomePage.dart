// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
// import 'dart:math';

import 'package:eshop/Helper/ApiBaseHelper.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/SqliteData.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Model/Model.dart';
import 'package:eshop/Model/OfferImages.dart';
import 'package:eshop/Model/Section_Model.dart';
import 'package:eshop/Model/User.dart';
import 'package:eshop/Provider/CartProvider.dart';
import 'package:eshop/Provider/CategoryProvider.dart';
import 'package:eshop/Provider/FavoriteProvider.dart';
import 'package:eshop/Provider/HomeProvider.dart';
import 'package:eshop/Provider/SettingProvider.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:eshop/Provider/WhatsAppNumberProvider.dart';
import 'package:eshop/Screen/Add_Address.dart';
import 'package:eshop/Screen/All_Category.dart';
import 'package:eshop/Screen/Profile/MyProfile.dart';
import 'package:eshop/Screen/cart/Cart.dart';
import 'package:eshop/Screen/homeWidgets/popupOfferDialoge.dart';
import 'package:eshop/cubits/brandsListCubit.dart';
import 'package:eshop/cubits/fetch_citites.dart';
import 'package:eshop/cubits/fetch_featured_sections_cubit.dart';
import 'package:eshop/ui/widgets/AppBtn.dart';
import 'package:eshop/ui/widgets/ProductListView.dart';
import 'package:eshop/ui/widgets/SimBtn.dart';
import 'package:eshop/ui/widgets/setTitleWidget.dart';
import 'package:eshop/ui/widgets/user_custom_radio.dart';
import 'package:eshop/utils/Extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

import '../Provider/ProductProvider.dart';
import '../app/routes.dart';
import '../ui/styles/DesignConfig.dart';
import '../ui/styles/Validators.dart';
import 'homeWidgets/sections/featured_section.dart';
import 'homeWidgets/sections/styles/style_1.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

List<Product> catList = [];
List<Product> popularList = [];
ApiBaseHelper apiBaseHelper = ApiBaseHelper();
List<String> tagList = [];
List<Product> sellerList = [];
List<Model> homeSliderList = [];
List<Widget> pages = [];
int count = 1;
bool _isProgress = false;
int _oldSelVarient = 0;
final List<TextEditingController> _controller = [];
List<Product> productList = [];

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  final _controller = PageController();
  List<TextEditingController> _controllers = [];

  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<SectionModel> featuredSectionList = [];

  final ScrollController _scrollBottomBarController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  double beginAnim = 0.0;

  double endAnim = 1.0;
  var db = DatabaseHelper();
  List<String> proIds = [];
  List<Product> mostLikeProList = [];
  List<String> proIds1 = [];
  List<Product> mostFavProList = [];
  PopUpOfferImage popUpOffer = PopUpOfferImage();
  Map? selectedCity;
  int? selectedAddress = 0;
  List<User> addressList = [];
  String? selAddress, paymentMethod = '', selTime, selDate, promocode;
  bool _isLoading = false;

  String? pincodeOrCityName;
  String? slectedCityId = "";
  StateSetter? checkoutState; //39
  bool deliverable = false; //10

  String whatsAppNumber = "";

  ///2
  updateProgress(bool progress) {
    if (mounted) {
      checkoutState?.call(() {
        context.read<CartProvider>().setProgress(progress);
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initCityOrPinCodeWiseDelivery();
    callApi();
    selectedAddress;
    _getAddress();
    _section();
    _refresh();
    addressList;
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
    // WidgetsBinding.instance.addPostFrameCallback((_) {

    // whatsAppNumber = context
    //         .read<WhatsAppNumberProvider>()
    //         .whatsAppNumberModel
    //         ?.data
    //         .systemSettings
    //         .first
    //         .whatsappNumber
    //         .toString() ??
    //     "";
    // });
  }

  initCityOrPinCodeWiseDelivery() async {
    bool isCity = await context
        .read<SettingProvider>()
        .getPrefrenceBool("is_city_wise_delivery");

    if (isCity != isCityWiseDelivery) {
      await context.read<SettingProvider>().removeKey(pinCodeOrCityNameKey);
    }
  }

  updateCheckout() {
    if (mounted) checkoutState?.call(() {});
  }

  @override
  void didChangeDependencies() {
    selectedAddress;
    addressList;
    _section();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WhatsAppNumberProvider>(context, listen: false)
          .getWhatsAppNumber();
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    _controller.dispose();
    buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);
    featuredSectionList =
        context.watch<FetchFeaturedSectionsCubit>().getFeaturedSections();
    hideAppbarAndBottomBarOnScroll(_scrollBottomBarController, context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        body: _isNetworkAvail
            ? RefreshIndicator(
                color: Theme.of(context).colorScheme.primarytheme,
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: BlocListener<FetchFeaturedSectionsCubit,
                    FetchFeaturedSectionsState>(
                  listener: (context, state) {
                    if (state is FetchFeaturedSectionsSuccess) {
                      setState(() {});
                      if (pincodeOrCityName != null &&
                          pincodeOrCityName.toString().isNotEmpty) {
                        context.read<SettingProvider>().setPrefrence(
                            pinCodeOrCityNameKey, pincodeOrCityName!);

                        context.read<SettingProvider>().setPrefrenceBool(
                            "is_city_wise_delivery", isCityWiseDelivery!);
                      }
                      context.read<HomeProvider>().setSecLoading(false);
                    }

                    if (state is FetchFeaturedSectionsFail) {
                      if (pincodeOrCityName != null) {
                        setState(() {
                          pincodeOrCityName = null;
                        });
                        context.read<HomeProvider>().setSecLoading(false);
                      }
                      setSnackbar(state.error!.toString(), context);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    controller: _scrollBottomBarController,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _topbarContainer(),
                            const SizedBox(height: 75),
                            // _deliverPincode(),
                            // _getSearchBar(),
                            _categoriesAndSeeAllBtn(context),
                            _catList(),
                            const SizedBox(height: 5),
                            _section(),
                            const SizedBox(height: 0),

                            // _bestSellingBtn(context),
                            // popularItems(0, context),
                            // _bestSellingProductsDetails(),

                            // _mostLike(),
                            // const SizedBox(height: 5),

                            // oneStopPantryShop(context),
                            // _mostFav(),
                            // oneStopPantryProductList(context),
                            // _slider(),
                            // const BrandsListWidget(),

                            // _section(),
                            // _mostLike(),
                          ],
                        ),
                        Column(
                          children: [
                            _appBar(context),
                            const SizedBox(height: 2),
                            searchBar(),
                            const SizedBox(height: 20),
                            _slider(),

                            // carouselSlider(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : noInternet(context),
        floatingActionButton: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0.0, left: 15),
            child: FloatingActionButton(
              backgroundColor: const Color(0XFF23AA49),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              onPressed: () {
                // context.read<WhatsAppNumberProvider>().getWhatsAppNumber();
                openWhatsApp(context
                        .read<WhatsAppNumberProvider>()
                        .whatsAppNumberModel
                        ?.data
                        .systemSettings
                        .first
                        .whatsappNumber ??
                    "");
                // if (whatsAppNumber.isNotEmpty) openWhatsApp(whatsAppNumber);
                debugPrint(
                    "Whatsapp Number: ${context.read<WhatsAppNumberProvider>().whatsAppNumberModel?.data.systemSettings.first.whatsappNumber ?? ""}");
              },
              child: Image.asset(
                'assets/images/home/WhatsApp_icon 1.png',
                width: 34,
                height: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openWhatsApp(String phoneNumber) async {
    final whatsappUrl = "https://wa.me/$phoneNumber";

    launchUrl(
      Uri.parse(whatsappUrl),
    );
  }

  Selector<CategoryProvider, List<Product>> _bestSellingProductsDetails() {
    return Selector<CategoryProvider, List<Product>>(
      builder: (context, data, child) {
        return data.isNotEmpty
            ? GridView.count(
                physics: const NeverScrollableScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                // controller:
                //     _scrollControllerOnSubCategory,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                crossAxisCount: 2,
                shrinkWrap: true,
                childAspectRatio: .55,
                children: List.generate(
                  4,
                  (index) {
                    return bestSelling(
                      data,
                      index,
                      context,
                      Colors.white,
                      sellingDiscount[index],
                      index == 0 ? Colors.green : const Color(0XFFE40400),
                    );
                  },
                ))
            : Center(child: Text(getTranslated(context, 'noItem')!));
      },
      selector: (_, categoryProvider) => categoryProvider.subList,
    );
  }

  GridView oneStopPantryProductList(BuildContext context) {
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
                      'assets/images/home/Product.png',
                      height: 90,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      // "${capitalize(subList[index].name!.toLowerCase())}\n",
                      "Fortune Oil",
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

  _mostFav() {
    return mostFavProList.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // setHeadTitle(
                //     getTranslated(context, 'YOU_ARE_LOOKING_FOR_LBL')!,
                //     context),
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      return _productItemView(
                        index,
                        mostFavProList,
                        context,
                        detail1Hero,
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  Widget _productItemView(
    int index,
    List<Product> productList,
    BuildContext context,
    String from,
  ) {
    if (index < productList.length) {
      String? offPer;
      double price =
          double.parse(productList[index].prVarientList![0].disPrice!);
      if (price == 0) {
        price = double.parse(productList[index].prVarientList![0].price!);
      } else {
        double off =
            double.parse(productList[index].prVarientList![0].price!) - price;
        offPer = ((off * 100) /
                double.parse(productList[index].prVarientList![0].price!))
            .toStringAsFixed(2);
      }

      double width = deviceWidth! * 0.45;

      return SizedBox(
          // height: 255,
          width: width,
          child: Card(
            elevation: 0.2,
            color: const Color.fromARGB(255, 235, 235, 235),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsetsDirectional.only(bottom: 5, end: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                            padding: const EdgeInsetsDirectional.only(top: 8.0),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5)),
                              child: Hero(
                                  tag: "$from$index${productList[index].id}0",
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: networkImageCommon(
                                      productList[index].image!,
                                      double.maxFinite,
                                      false,
                                      height: double.maxFinite,
                                      width: double.maxFinite,
                                    ),
                                  )

                                  /*CachedNetworkImage(
                                imageUrl:
                                productList[index].image!,
                                height: double.maxFinite,
                                width: double.maxFinite,
                                fit: extendImg ? BoxFit.fill : BoxFit.contain,
                                errorWidget:
                                    (context, error, stackTrace) =>
                                    erroWidget(
                                      double.maxFinite,
                                    ),
                                placeholder: (context,url) {
                                  return placeHolder(
                                    double.maxFinite,
                                  );}
                              ),*/
                                  ),
                            )),
                        offPer != null
                            ? Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0XFFE40400),
                                      borderRadius: BorderRadius.circular(10)),
                                  margin: const EdgeInsets.all(5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      "OFF\n$offPer%",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: colors.whiteTemp,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9),
                                    ),
                                  ),
                                ),
                              )
                            : Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(5),
                                      bottomLeft: Radius.circular(5),
                                    ),
                                  ),
                                  margin: const EdgeInsets.all(5),
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(5, 5, 5, 8),
                                    child: Text(
                                      "BEST \nSELLERS",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: colors.whiteTemp,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 6),
                                    ),
                                  ),
                                ),
                              ),
                        const Divider(
                          height: 1,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 5.0, top: 5, bottom: 5),
                    child: Text(
                      productList[index].name!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${getPriceFormat(context, price)!} ',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      )),
                  Text(
                    double.parse(productList[index]
                                .prVarientList![0]
                                .disPrice!) !=
                            0
                        ? getPriceFormat(
                            context,
                            double.parse(
                                productList[index].prVarientList![0].price!))!
                        : "",
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          decoration: TextDecoration.lineThrough,
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                  ),
                  const SizedBox(height: 1, child: Divider()),
                  SizedBox(
                    height: 50,
                    child: TextButton.icon(
                      style: const ButtonStyle(
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.only(top: 5, bottom: 5),
                        ),
                      ),
                      onPressed: () async {
                        if (index < productList.length &&
                            index < _controllers.length) {
                          Product model = productList[index];

                          // Ensure model.qtyStepSize is not null before parsing
                          String qtyStepSize = model.qtyStepSize ??
                              '1'; // Use '1' as a default if it's null

                          // Check if the text field is empty or contains valid text
                          String currentQuantity = _controllers[index]
                                  .text
                                  .isNotEmpty
                              ? _controllers[index].text
                              : '0'; // Default to '0' if the text field is empty

                          // Add to cart logic
                          addToCart(
                            index,
                            (int.parse(currentQuantity) +
                                    int.parse(qtyStepSize))
                                .toString(),
                            2,
                          );
                        } else {
                          print('Index out of range or invalid data');
                          Product model = productList[index];
                          currentHero = from;
                          Navigator.pushNamed(context, Routers.productDetails,
                              arguments: {
                                "id": model.id!,
                                "secPos": 0,
                                "index": index,
                                "list": true
                              });
                        }
                      },
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
                  ),
                ],
              ),
              onTap: () {
                Product model = productList[index];
                currentHero = from;
                Navigator.pushNamed(context, Routers.productDetails,
                    arguments: {
                      "id": model.id!,
                      "secPos": 0,
                      "index": index,
                      "list": true
                    });

                // Navigator.push(
                //   context,
                //   PageRouteBuilder(pageBuilder: (_, __, ___) => ProductDetail()),
                // );
              },
            ),
          ));
    } else {
      return const SizedBox.shrink();
    }
  }

  Container oneStopPantryShop(BuildContext context) {
    return Container(
      // height: 217,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(173, 214, 255, 214),
            Color.fromARGB(64, 198, 236, 198),
            Color.fromARGB(0, 255, 255, 255),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.2, 0.5, 0.9],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Text(
              "One Stop Pantry Shop",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
            ),
            Text(
              "Find Exclusive",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Products",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    "See all",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: const Color(0xFF23AA49),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  bestSelling(
    List<Product> subList,
    int index,
    BuildContext context,
    Color color,
    String discountTxt,
    Color bgClr,
  ) {
    return Stack(
      children: [
        InkWell(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 233, 233, 233)
                        .withOpacity(0.7),
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
                        offset:
                            const Offset(0, 0), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 45, bottom: 10),
                        child: Center(
                          child: networkImageCommon(
                            subList[index].image!,
                            50,
                            false,
                            height: 80,
                          ),
                        ),
                      ),
                      Text(
                        "${capitalize(subList[index].name!.toLowerCase())}\n",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.fontColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
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
                        onPressed: () {
                          Navigator.pushNamed(
                              context, Routers.productListScreen,
                              arguments: {
                                "name": popularList[index].name,
                                "id": popularList[index].id,
                                "tag": false,
                                "fromSeller": false,
                              });
                        },
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
                  // child: CircleAvatar(
                  //     radius: 45.0,
                  //     backgroundColor: Colors.transparent,
                  //     child: ClipRRect(
                  //         borderRadius: BorderRadius.circular(50),
                  //         child: networkImageCommon(
                  //             subList[index].image!, 50, false))
                  //     /*CachedNetworkImage(
                  //     imageUrl: subList[index].image!,
                  //     fadeInDuration: const Duration(milliseconds: 150),
                  //     fit: BoxFit.fill,
                  //     errorWidget: (context, error, stackTrace) =>
                  //         erroWidget(50),
                  //     placeholder: (context,url) {return placeHolder(50);}
                  //   ),*/
                  //     )
                ),
              ),
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

                Navigator.pushNamed(context, Routers.productListScreen,
                    arguments: {
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

                Navigator.pushNamed(context, Routers.subCategoryScreen,
                    arguments: {
                      "subList": popularList[index].subList,
                      "title": popularList[index].name!.toUpperCase(),
                    });
              }
            } else if (subList[index].subList == null ||
                subList[index].subList!.isEmpty) {
              Navigator.pushNamed(context, Routers.productListScreen,
                  arguments: {
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

              Navigator.pushNamed(context, Routers.subCategoryScreen,
                  arguments: {
                    "subList": subList[index].subList,
                    "title": subList[index].name!.toUpperCase(),
                  });
            }
          },
        ),
        Positioned(
          right: 20,
          top: 0,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: bgClr,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Center(
                child: Text(
                  breakTextIntoLines(discountTxt),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
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
  }

  Padding _categoriesAndSeeAllBtn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Shop by Category",
            style: TextStyle(
              color: Theme.of(context).colorScheme.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          TextButton(
            style: const ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.zero)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllCategory(
                    isSeeAll: true,
                  ),
                ),
              );
              debugPrint("AllCategory button pressed");
            },
            child: Text(
              "See all",
              style: TextStyle(
                color: Theme.of(context).colorScheme.lightGreen,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding _bestSellingBtn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Best Selling",
            style: TextStyle(
              color: Theme.of(context).colorScheme.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          TextButton(
            style: const ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.zero)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllCategory(
                    isSeeAll: true,
                  ),
                ),
              );
              debugPrint("AllCategory button pressed");
            },
            child: Text(
              "See all",
              style: TextStyle(
                color: Theme.of(context).colorScheme.lightGreen,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  CarouselSlider carouselSlider() {
    return CarouselSlider(
      items: imgList,
      options: CarouselOptions(
        // height: 168,
        aspectRatio: 16 / 9,
        viewportFraction: 0.9,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 2),
        autoPlayAnimationDuration: const Duration(seconds: 1),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0.1,
        // onPageChanged: callbackFunction,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  CarouselSlider carouselSlider2() {
    return CarouselSlider(
      items: [
        carouselSliderItems(
          "Limited Offer",
          "45%",
          "Best Products",
          "See Details",
          'assets/images/home/Products.png',
          210,
          -35,
          5,
          [
            const Color(0xFF3F5394),
            const Color(0xFF697DBD),
          ],
          const Color(0xFF3F5394).withOpacity(0.3),
          const Color(0xFF3F5394),
        ),
        carouselSliderItems(
          "Limited Offer",
          "45%",
          "All House Products",
          "See Details",
          'assets/images/home/kisspng-organic-food-vegetarian-cuisine-vegetable-raw-food-vegetables-fruits-and-vegetables-transparent-fruit-5a7aa799513cd2 1.png',
          330,
          -130,
          -20,
          [
            const Color(0xFF7A3343),
            const Color(0xFF7A3343).withOpacity(0.5),
          ],
          const Color(0xFF7A3343).withOpacity(0.5),
          const Color(0xFF7A3343),
        ),
      ],
      options: CarouselOptions(
        // height: 168,
        // aspectRatio: 16 / 9,
        viewportFraction: 0.88,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 2),
        autoPlayAnimationDuration: const Duration(seconds: 1),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0,
        // onPageChanged: callbackFunction,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget carouselSliderItems(
    final String title,
    final String disPer,
    String subtitle,
    String btnName,
    String image,
    double imageWidth,
    double positionedRight,
    double positionedBottom,
    List<Color> lineargraClr,
    Color bgCircleClr,
    Color topCircleCle,
  ) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: deviceWidth! * 0.85,
          height: 175,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: lineargraClr,
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.2), // Shadow color
            //     spreadRadius: 1, // Spread radius of the shadow
            //     blurRadius: 10, // Blur radius of the shadow
            //     offset: Offset(0, 5), // Offset of the shadow
            //   ),
            // ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -35,
                child: Container(
                  width: 198, // Diameter of the circular shape
                  height: 198,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bgCircleClr,
                  ),
                ),
              ),
              Positioned(
                right: -50,
                top: -18,
                child: Container(
                  width: 198, // Diameter of the circular shape
                  height: 198,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: topCircleCle,
                  ),
                ),
              ),
              Positioned(
                left: 25,
                top: 15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Text(
                      disPer,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.white,
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      width: 100,
                      height: 35,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(10),
                          backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.white),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          btnName,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                // left: 20,
                right: positionedRight,
                bottom: positionedBottom,
                child: Image.asset(
                  image,
                  width: imageWidth,
                  // height: 150,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container _topbarContainer() {
    return Container(
      height: 265,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD5FFD4),
            Color(0xFFE9FFBB),
          ],
          // colors: [Color(0xFF039900), Color(0xFF80BC00)],
        ),
      ),
      // child: Image.asset(
      //   'assets/images/home/BG 1.png',
      //   fit: BoxFit.cover,
      // ),

      // child: Image.asset(
      //   'assets/images/BG 1.jpg',
      //   // color: Colors.transparent.withOpacity(0.3),
      // ),
    );
  }

//  Selector<UserProvider, String>(
//                       selector: (_, provider) => provider.curUserName,
//                       builder: (context, userName, child) {
//                         nameController = TextEditingController(text: userName);
//                         return Text(
//                           userName == ""
//                               ? getTranslated(context, 'GUEST')!
//                               : userName,
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleMedium!
//                               .copyWith(
//                                 color: Theme.of(context).colorScheme.fontColor,
//                               ),
//                         );
//                       }),
  _appBar(BuildContext context) {
    return Selector<UserProvider, String>(
        selector: (_, provider) => provider.curUserName,
        builder: (context, userName, child) {
          // nameController = TextEditingController(text: userName);
          return ListTile(
            contentPadding: const EdgeInsets.only(top: 0, left: 18, right: 18),
            leading: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProfile(),
                  ),
                );
              },
              child: CircleAvatar(
                  maxRadius: 20,
                  backgroundColor: Colors.white.withOpacity(0.7),
                  // backgroundColor: colors.primary.withOpacity(0.5),
                  child: Image.asset(
                    'assets/images/home/Menu_Icon.png',
                    width: 20,
                    height: 15,
                  )
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(50),
                  //   child: Consumer<UserProvider>(
                  //       builder: (context, userProvider, _) {
                  //     return userProvider.profilePic != ''
                  //         ? Image.network(
                  //             userProvider.profilePic,
                  //             fit: BoxFit.fill,
                  //           )
                  //         /*CachedNetworkImage(
                  //             fadeInDuration: const Duration(milliseconds: 150),
                  //             imageUrl: userProvider.profilePic,
                  //             height: 64.0,
                  //             width: 64.0,
                  //             fit: BoxFit.cover,
                  //             errorWidget: (context, error, stackTrace) =>
                  //                 erroWidget(64),
                  //             placeholder: (context, url) {
                  //               return placeHolder(64);
                  //             })*/
                  //         : imagePlaceHolder(40, context);
                  //   }),
                  // ),
                  ),
            ),
            title: Text(
              'Welcome ${userName == "" ? getTranslated(context, 'GUEST')! : userName}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: "Poppins",
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: _isLoading
                ? const Text("Loading.....")
                : addressList.isNotEmpty
                    ? ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              // setState(() {
                              //   selectedAddress = index;
                              //   selAddress = addressList[index].id;
                              // });
                            },
                            child: Text(
                              addressList[selectedAddress!].area.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => AddAddress(
                                      update: false,
                                      index: addressList.length,
                                      //updateState: widget.update!,
                                    )),
                          );
                        },
                        child: const Text('Set your location'),
                      ),
            //       _isLoading
            // ? Center(child: CircularProgressIndicator())
            // : _isNetworkAvail
            //     ? ListView.builder(
            //         itemCount: addressList.length,
            //         itemBuilder: (context, index) {
            //           return ListTile(
            //             title: Text(addressList[index].address),
            //             subtitle: Text("Delivery Charge: ${addressList[index].deliveryCharge}"),
            //             trailing: addressList[index].isDefault == "1"
            //                 ? Icon(Icons.check, color: Colors.green)
            //                 : null,
            // onTap: () {
            //   setState(() {
            //     selectedAddress = index;
            //     selAddress = addressList[index].id;
            //   });
            //             },
            //           );
            //         },
            //       )
            //     : Center(child: Text("No network available")),
            // subtitle: Text(
            //   userName == "" ? getTranslated(context, 'GUEST')! : userName,
            //   style: const TextStyle(
            //     color: Colors.black,
            //     fontSize: 16,
            //     fontWeight: FontWeight.w500,
            //     fontFamily: "Poppins",
            //   ),
            //   maxLines: 1,
            //   overflow: TextOverflow.ellipsis,
            // ),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
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
                        width: 20,
                        color: Colors.black,
                      ),
                      // Positioned(
                      //   right: -7,
                      //   top: -5,
                      //   child: notificationCircle(context, ''),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // InkWell(
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => const Cart(
                //             fromBottom: false,
                //           ),
                //         ));
                //   },
                //   child: Stack(
                //     clipBehavior: Clip.none,
                //     children: [
                //       Image.asset(
                //         'assets/images/home/Bag.png',
                //         width: 20,
                //       ),
                //       Positioned(
                //         right: -7,
                //         top: -5,
                //         child: notificationCircle(context),
                //       ),
                //     ],
                //   ),
                // ),
                Selector<UserProvider, String>(
                  builder: (context, data, child) {
                    return InkWell(
                      onTap: () {
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
                            // "${imagePath}sel_home.svg",
                            color: Colors.black,

                            width: 18,
                            height: 20,
                          ),
                          (data.isNotEmpty && data != "0")
                              ? Positioned(
                                  right: -7,
                                  top: -5,
                                  // textDirection: Directionality.of(context),
                                  child: notificationCircle(context, data),
                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                    );
                  },
                  selector: (_, homeProvider) => homeProvider.curCartCount,
                ),
                const SizedBox(width: 10),
              ],
            ),
          );
          // return Text(
          //   userName == "" ? getTranslated(context, 'GUEST')! : userName,
          //   style: Theme.of(context).textTheme.titleMedium!.copyWith(
          //         color: Theme.of(context).colorScheme.fontColor,
          //       ),
          // );
        });
  }

  // address() {
  //   return Card(
  //     elevation: 1,
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Row(
  //             children: [
  //               const Icon(Icons.location_on),
  //               Padding(
  //                   padding: const EdgeInsetsDirectional.only(start: 8.0),
  //                   child: Text(
  //                     getTranslated(context, 'SHIPPING_DETAIL') ?? '',
  //                     style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         color: Theme.of(context).colorScheme.fontColor),
  //                   )),
  //             ],
  //           ),
  //           const Divider(),
  //           addressList.isNotEmpty
  //               ? Padding(
  //                   padding: const EdgeInsetsDirectional.only(start: 8.0),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           Expanded(
  //                               child:
  //                                   Text(addressList[selectedAddress!].name!)),
  //                           InkWell(
  //                             child: Padding(
  //                               padding:
  //                                   const EdgeInsets.symmetric(horizontal: 8.0),
  //                               child: Text(
  //                                 getTranslated(context, 'CHANGE')!,
  //                                 style: TextStyle(
  //                                   color: Theme.of(context)
  //                                       .colorScheme
  //                                       .primarytheme,
  //                                 ),
  //                               ),
  //                             ),
  //                             onTap: () async {
  //                               await Navigator.pushNamed(
  //                                   context, Routers.manageAddressScreen,
  //                                   arguments: {
  //                                     "home": false,
  //                                     "update": updateCheckout,
  //                                     "updateProgress": updateProgress
  //                                   }).then((value) {
  //                                 checkoutState?.call(() {
  //                                   deliverable = false;
  //                                 });
  //                               });
  //                             },
  //                           ),
  //                         ],
  //                       ),
  //                       Text(
  //                         "${addressList[selectedAddress!].address!}, ${addressList[selectedAddress!].area!}, ${addressList[selectedAddress!].city!}, ${addressList[selectedAddress!].state!}, ${addressList[selectedAddress!].country!}, ${addressList[selectedAddress!].pincode!}",
  //                         style: Theme.of(context)
  //                             .textTheme
  //                             .bodySmall!
  //                             .copyWith(
  //                                 color:
  //                                     Theme.of(context).colorScheme.lightBlack),
  //                       ),
  //                       Padding(
  //                         padding: const EdgeInsets.symmetric(vertical: 5.0),
  //                         child: Row(
  //                           children: [
  //                             Text(
  //                               addressList[selectedAddress!].mobile!,
  //                               style: Theme.of(context)
  //                                   .textTheme
  //                                   .bodySmall!
  //                                   .copyWith(
  //                                       color: Theme.of(context)
  //                                           .colorScheme
  //                                           .lightBlack),
  //                             ),
  //                           ],
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 )
  //               : Padding(
  //                   padding: const EdgeInsetsDirectional.only(start: 8.0),
  //                   child: InkWell(
  //                     child: Text(
  //                       getTranslated(context, 'ADDADDRESSs')!,
  //                       style: TextStyle(
  //                         color: Theme.of(context).colorScheme.fontColor,
  //                       ),
  //                     ),
  //                     onTap: () async {
  //                       ScaffoldMessenger.of(context).removeCurrentSnackBar();
  //                       Navigator.push(
  //                         context,
  //                         CupertinoPageRoute(
  //                             builder: (context) => AddAddress(
  //                                   update: false,
  //                                   index: addressList.length,
  //                                   updateState: updateCheckout,
  //                                 )),
  //                       ).then((value) async {
  //                         //await getShipRocketDeliveryCharge();
  //                       });
  //                       if (mounted) setState(() {});
  //                     },
  //                   ),
  //                 )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // _getAddress() async {
  //   _isNetworkAvail = await isNetworkAvailable();
  //   if (_isNetworkAvail) {
  //     try {
  //       Map parameter = {
  //         // USER_ID: context.read<UserProvider>().userId,
  //       };

  //       apiBaseHelper.postAPICall(getAddressApi, parameter).then((getdata) {
  //         bool error = getdata["error"];
  //         if (!error) {
  //           var data = getdata["data"];
  //           setState(() {});

  //           addressList =
  //               (data as List).map((data) => User.fromAddress(data)).toList();

  //           for (int i = 0; i < addressList.length; i++) {
  //             if (addressList[i].isDefault == "1") {
  //               selectedAddress = i;
  //               selAddress = addressList[i].id;
  //               setState(() {});
  //               //   if (IS_SHIPROCKET_ON == "0") {
  //               //     if (!ISFLAT_DEL) {
  //               //       if (totalPrice < double.parse(addressList[i].freeAmt!)) {
  //               //         deliveryCharge =
  //               //             double.parse(addressList[i].deliveryCharge!);
  //               //       } else {
  //               //         deliveryCharge = 0;
  //               //       }
  //               //     }
  //               //   }
  //             }
  //           }

  //           // addAddressModel();
  //         } else {}
  //         if (mounted) {
  //           setState(() {
  //             _isLoading = false;
  //           });
  //         }
  //       }, onError: (error) {
  //         setSnackbar(error.toString(), context);
  //       });
  //     } on TimeoutException catch (_) {}
  //   } else {
  //     if (mounted) {
  //       setState(() {
  //         _isNetworkAvail = false;
  //       });
  //     }
  //   }
  //   return;
  // }

  _getAddress() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        Map<String, dynamic> parameter = {
          // Replace with actual user ID if necessary
          // 'user_id': context.read<UserProvider>().userId,
        };

        // Call the API to get the address data
        var getdata = await apiBaseHelper.postAPICall(getAddressApi, parameter);

        // Check if there was no error in the response
        bool error = getdata["error"];
        if (!error) {
          var data = getdata["data"];
          // Update the address list and UI
          setState(() {
            addressList =
                (data as List).map((data) => User.fromAddress(data)).toList();
          });

          // Find the default address and update the UI
          for (int i = 0; i < addressList.length; i++) {
            if (addressList[i].isDefault == "1") {
              setState(() {
                selectedAddress = i;
                selAddress = addressList[i].id;
              });

              // Add any additional logic for shipping here
            }
          }
        } else {
          // Handle the case where there's an error in the API response
          setSnackbar("Error fetching address", context);
        }

        // Update loading state after fetching data
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } on TimeoutException catch (_) {
        setSnackbar("Request timed out", context);
      } catch (e) {
        debugPrint("Error address : $e");
        // setSnackbar(e.toString(), context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  // void addAddressModel() {
  //   for (int i = 0; i < addressList.length; i++) {
  //     addModel.add(RadioModel(
  //         isSelected: i == selectedAddress ? true : false,
  //         name: "${addressList[i].name!}, ${addressList[i].mobile!}",
  //         add:
  //             "${addressList[i].address!}, ${addressList[i].area!}, ${addressList[i].city!}, ${addressList[i].state!}, ${addressList[i].country!}, ${addressList[i].pincode!}",
  //         addItem: addressList[i],
  //         show: !widget.home!,
  //         onSetDefault: () {
  //           if (mounted) {
  //             setState(() {
  //               _isProgress = true;
  //             });
  //           }
  //           setAsDefault(i);
  //         },
  //         onDeleteSelected: () {
  //           if (mounted) {
  //             setState(() {
  //               _isProgress = true;
  //             });
  //           }
  //           deleteAddress(i);
  //         },
  //         onEditSelected: () async {
  //           await Navigator.push(
  //               context,
  //               CupertinoPageRoute(
  //                 builder: (context) => AddAddress(
  //                   update: true,
  //                   index: i,
  //                   updateState: widget.update,
  //                 ),
  //               )).then((value) {
  //             if (mounted) {
  //               setState(() {
  //                 addModel.clear();

  //                 addAddressModel();
  //               });
  //             }
  //           });
  //         }));
  //   }
  // }

  Container notificationCircle(BuildContext context, String text) {
    return Container(
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
            text,
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
    );
  }

  Future<void> _refresh() {
    context.read<HomeProvider>().setCatLoading(true);
    context.read<HomeProvider>().setSecLoading(true);
    context.read<HomeProvider>().setOfferLoading(true);
    context.read<HomeProvider>().setMostLikeLoading(true);
    context.read<HomeProvider>().setSliderLoading(true);
    context.read<CategoryProvider>().setCurSelected(0);
    proIds.clear();
    _section();
    _getAddress();
    return callApi();
  }

  Widget _slider() {
    // double height = 500;
    double height = deviceWidth! / 2.2;

    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? sliderLoading()
            : Stack(
                children: [
                  SizedBox(
                    height: height,
                    width: double.infinity,
                    child: PageView.builder(
                      itemCount: homeSliderList.length,
                      scrollDirection: Axis.horizontal,
                      controller: _controller,
                      physics: const AlwaysScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          context.read<HomeProvider>().setCurSlider(index);
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: pages[index],
                          ),
                        );
                      },
                    ),
                  ),
                  // Positioned(
                  //   bottom: 0,
                  //   height: 35,
                  //   left: 0,
                  //   width: deviceWidth,
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.max,
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: map<Widget>(
                  //       homeSliderList,
                  //       (index, url) {
                  //         return AnimatedContainer(
                  //             duration: const Duration(milliseconds: 500),
                  //             width: context.read<HomeProvider>().curSlider ==
                  //                     index
                  //                 ? 25
                  //                 : 8.0,
                  //             height: 8.0,
                  //             margin: const EdgeInsets.symmetric(
                  //                 vertical: 10.0, horizontal: 2.0),
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(5.0),
                  //               color: context.read<HomeProvider>().curSlider ==
                  //                       index
                  //                   ? Theme.of(context).colorScheme.fontColor
                  //                   : Theme.of(context)
                  //                       .colorScheme
                  //                       .lightBlack
                  //                       .withOpacity(0.7),
                  //             ));
                  //       },
                  //     ),
                  //   ),
                  // ),

                  // Text(homeSliderList.first.date.toString()),
                ],
              );
      },
      selector: (_, homeProvider) => homeProvider.sliderLoading,
    );
  }

  void _animateSlider() {
    Future.delayed(const Duration(seconds: 10)).then((_) {
      if (mounted) {
        int nextPage = _controller.hasClients
            ? _controller.page!.round() + 1
            : _controller.initialPage;

        if (nextPage == homeSliderList.length) {
          nextPage = 0;
        }
        if (_controller.hasClients) {
          _controller
              .animateToPage(nextPage,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.linear)
              .then((_) {
            _animateSlider();
          });
        }
      }
    });
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
                            fontSize: 18,
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
                            fontSize: 22,
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

  _getFeaturedSection(int index) {
    var orient = MediaQuery.of(context).orientation;
    SectionModel featuredSection = featuredSectionList[index];
    List<Product>? featuredSectionProductList = featuredSection.productList;

    return FeaturedSectionGet()
        .get(featuredSection.style!,
            index: index, products: featuredSectionProductList!)
        .render(context);
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

  _mostLike() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Stack(children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    decoration: const BoxDecoration(
                      // color: const Color.fromARGB(255, 233, 233, 233)
                      //     .withOpacity(0.5),
                      // shape: BoxShape.circle,

                      // color: Theme.of(context).colorScheme.back3,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                Selector<ProductProvider, List<Product>>(
                  builder: (context, data1, child) {
                    return data1.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // _getHeading(
                                  //     getTranslated(
                                  //         context, 'YOU_MIGHT_ALSO_LIKE')!,
                                  //     0,
                                  //     2,
                                  //     data1),
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: GridView.count(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                top: 0),
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 15,
                                        crossAxisSpacing: 15,
                                        shrinkWrap: true,
                                        childAspectRatio: 0.8,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children: List.generate(
                                          data1.length < 4 ? data1.length : 4,
                                          (index) {
                                            return productItem(
                                                0,
                                                index,
                                                index % 2 == 0 ? true : false,
                                                data1[index],
                                                2,
                                                data1.length);
                                          },
                                        )),
                                  ),
                                  //  setHeadTitle("You might also like",context),
                                  /*Container(
                            height: 230,
                           // padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child:  ListView.builder(
                                      physics:
                                      const AlwaysScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                       itemCount:  data1.length,
                                      itemBuilder: (context, index) {
                                        return productItemView(index, data1,context);
                                      },
                                    ),
                            ),
                          ),*/
                                ]))
                        : const SizedBox();
                  },
                  selector: (_, provider) => provider.productList,
                )
              ]))
        ]);
      },
      selector: (_, homeProvider) => homeProvider.mostLikeLoading,
    );
  }

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
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 3 items per row
                    crossAxisSpacing: 5, // Spacing between columns
                    mainAxisSpacing: 5, // Spacing between rows
                    childAspectRatio: 0.7, // Adjust for item width/height ratio
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 75,
                            width: 70,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor
                                      .withOpacity(0.048),
                                  spreadRadius: 2,
                                  blurRadius: 13,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                              color: const Color.fromARGB(255, 232, 232, 232)
                                  .withOpacity(0.6),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Center(
                              child: networkImageCommon(
                                catList[index].image!,
                                10,
                                width: 60,
                                height: 60,
                                false,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            (formatText(catList[index].name!)),
                            maxLines: 2,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
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

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Future<void> callApi() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UserProvider user = Provider.of<UserProvider>(context, listen: false);
      SettingProvider setting =
          Provider.of<SettingProvider>(context, listen: false);

      pincodeOrCityName = await setting.getPrefrence(pinCodeOrCityNameKey);
      user.setUserId(setting.userId);
      user.setMobile(setting.mobile);
      user.setName(setting.userName);
      user.setEmail(setting.email);
      user.setProfilePic(setting.profileUrl);
      user.setType(setting.loginType);
    });

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getSetting();

      //
      var cityId = await context.read<SettingProvider>().getPrefrence("cityId");
      context.read<FetchFeaturedSectionsCubit>().fetchSections(context,
          userId: context.read<UserProvider>().userId,
          pincodeOrCityName: isCityWiseDelivery! ? cityId : pincodeOrCityName,
          isCityWiseDelivery: isCityWiseDelivery!);
      context.read<BrandsListCubit>().getBrandsList();
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }

    return;
  }

  Future _getFav() async {
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

              context.read<FavoriteProvider>().setFavlist(tempList);
            } else {
              if (msg != 'No Favourite(s) Product Are Added') {
                setSnackbar(msg!, context);
              }
            }

            context.read<FavoriteProvider>().setLoading(false);
          }, onError: (error) {
            setSnackbar(error.toString(), context);
            context.read<FavoriteProvider>().setLoading(false);
          });
        } else {
          context.read<FavoriteProvider>().setLoading(false);
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      }
    } on FormatException catch (e) {
      // setSnackbar(e.message, context);
    }
  }

  /* void getOfferImages() {
    try {
      Map parameter = {};

      apiBaseHelper.postAPICall(getOfferImageApi, parameter).then((getdata) {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          offerImages.clear();
          offerImages =
              (data as List).map((data) => Model.fromSlider(data)).toList();
        } else {
          setSnackbar(msg!, context);
        }

        context.read<HomeProvider>().setOfferLoading(false);
      }, onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setOfferLoading(false);
      });
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }*/

  void getFeaturedSection({String? pincode}) {
    // return;
    try {
      Map parameter = {PRODUCT_LIMIT: "6", PRODUCT_OFFSET: "0"};

      if (context.read<UserProvider>().userId != "") {
        parameter[USER_ID] = context.read<UserProvider>().userId;
      }
      //String curPin = context.read<UserProvider>().curPincode;
      if (pincode != null) parameter[ZIPCODE] = pincode;

      apiBaseHelper.postAPICall(getSectionApi, parameter).then((getdata) {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        featuredSectionList.clear();
        if (!error) {
          var data = getdata["data"];

          print('section pincode*******$pincode');
          ////TODOOOOOO
          if (pincode != null) {
            context
                .read<SettingProvider>()
                .setPrefrence(pinCodeOrCityNameKey, pincode!);
          }

          featuredSectionList = (data as List)
              .map((data) => SectionModel.fromJson(data))
              .toList();
        } else {
          if (pincode != null) {
            setState(() {
              pincode = null;
            });
          }
          setSnackbar(msg!, context);
        }

        context.read<HomeProvider>().setSecLoading(false);
      }, onError: (error) {
        print("SECTION ERROR");
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setSecLoading(false);
      });
    } on FormatException catch (e) {
      // setSnackbar(e.message, context);
    }
  }

  void getSetting() {
    try {
      //CUR_USERID = context.read<SettingProvider>().userId;

      Map parameter = {};
      if (context.read<UserProvider>().userId != "") {
        parameter = {USER_ID: context.read<UserProvider>().userId};
      }

      apiBaseHelper.postAPICall(getSettingApi, parameter).then((getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          var data = getdata["data"]["system_settings"][0];
          SUPPORTED_LOCALES = data["supported_locals"];
          if (data.toString().contains(MAINTAINANCE_MODE)) {
            Is_APP_IN_MAINTANCE = data[MAINTAINANCE_MODE];
          }
          if (Is_APP_IN_MAINTANCE != "1") {
            getSlider();
            getCat();
            getFeaturedSection();

            context.read<FetchFeaturedSectionsCubit>().fetchSections(context,
                userId: context.read<UserProvider>().userId,
                isCityWiseDelivery: isCityWiseDelivery!);
            // getOfferImages();

            proIds = (await db.getMostLike())!;
            getMostLikePro();
            proIds1 = (await db.getMostFav())!;
            getMostFavPro();
          }

          if (data.toString().contains(MAINTAINANCE_MESSAGE)) {
            IS_APP_MAINTENANCE_MESSAGE = data[MAINTAINANCE_MESSAGE];
          }

          cartBtnList = data["cart_btn_on_list"] == "1" ? true : false;
          refer = data["is_refer_earn_on"] == "1" ? true : false;
          CUR_CURRENCY = data["currency"];
          RETURN_DAYS = data['max_product_return_days'];
          MAX_ITEMS = data["max_items_cart"];
          MIN_AMT = data['min_amount'];
          CUR_DEL_CHR = data['delivery_charge'];
          String? isVerion = data['is_version_system_on'];
          extendImg = data["expand_product_images"] == "1" ? true : false;
          String? del = data["area_wise_delivery_charge"];
          MIN_ALLOW_CART_AMT = data[MIN_CART_AMT];
          IS_LOCAL_PICKUP = data[LOCAL_PICKUP];
          ADMIN_ADDRESS = data[ADDRESS];
          ADMIN_LAT = data[LATITUDE];
          ADMIN_LONG = data[LONGITUDE];
          ADMIN_MOB = data[SUPPORT_NUM];
          IS_SHIPROCKET_ON = getdata["data"]["shipping_method"][0]
              ["shiprocket_shipping_method"];
          IS_LOCAL_ON =
              getdata["data"]["shipping_method"][0]["local_shipping_method"];
          ALLOW_ATT_MEDIA = data[ALLOW_ATTACH];

          whatsappOrderingOn = data['whatsapp_status'].toString() == "1";
          if (whatsappOrderingOn) {
            whatsappOrderingPhoneNumber = data['whatsapp_number'] ?? "";
          }

          try {
            //pop up offer
            popUpOffer =
                PopUpOfferImage.fromJson(getdata["data"]["popup_offer"][0]);
            SharedPreferences sharedData =
                await SharedPreferences.getInstance();
            String storedOfferPopUpID =
                sharedData.getString("offerPopUpID") ?? "";

            /*   if (popUpOffer.isActive == "1") {
              if (popUpOffer.showMultipleTime == "1") {
                showPopUpOfferDialog();
              } else if (storedOfferPopUpID != popUpOffer.id) {
                showPopUpOfferDialog();
              }
            }*/
            popUpOffer.isActive == "1" &&
                    (popUpOffer.showMultipleTime == "1" ||
                        storedOfferPopUpID != popUpOffer.id)
                ? showPopUpOfferDialog()
                : null;
          } catch (e) {
            print("error is ${e.toString()}");
          }

          if (data.toString().contains(UPLOAD_LIMIT)) {
            UP_MEDIA_LIMIT = data[UPLOAD_LIMIT];
          }

          if (Is_APP_IN_MAINTANCE == "1") {
            appMaintenanceDialog();
          }

          if (del == "0") {
            ISFLAT_DEL = true;
          } else {
            ISFLAT_DEL = false;
          }

          if (context.read<UserProvider>().userId != "") {
            REFER_CODE = getdata['data']['user_data'][0]['referral_code'];

            context.read<UserProvider>().setPincode(
                  getdata["data"]["user_data"][0][pinCodeOrCityNameKey],
                );

            if (REFER_CODE == null || REFER_CODE == '' || REFER_CODE!.isEmpty) {
              generateReferral();
            }

            context.read<UserProvider>().setCartCount(
                getdata["data"]["user_data"][0]["cart_total_items"].toString());
            context
                .read<UserProvider>()
                .setBalance(getdata["data"]["user_data"][0]["balance"]);
            if (Is_APP_IN_MAINTANCE != "1") {
              _getFav();
              _getCart("0");
            }
          } else {
            if (Is_APP_IN_MAINTANCE != "1") {
              _getOffFav();
              _getOffCart();
            }
          }

          Map<String, dynamic> tempData = getdata["data"];
          if (tempData.containsKey(TAG)) {
            tagList = List<String>.from(getdata["data"][TAG]);
          }

          if (isVerion == "1") {
            String? verionAnd = data['current_version'];
            String? verionIOS = data['current_version_ios'];

            PackageInfo packageInfo = await PackageInfo.fromPlatform();

            String version = packageInfo.version;

            final Version currentVersion = Version.parse(version);
            final Version latestVersionAnd = Version.parse(verionAnd!);

            final Version latestVersionIos = Version.parse(verionIOS!);

            if ((Platform.isAndroid && latestVersionAnd > currentVersion) ||
                (Platform.isIOS && latestVersionIos > currentVersion)) {
              updateDailog();
            }
          }
        } else {
          setSnackbar(msg!, context);
        }
      }, onError: (error) {
        setSnackbar(error.toString(), context);
      });
    } on FormatException catch (e) {
      // setSnackbar(e.message, context);
    }
  }

  Future<void> getMostLikePro() async {
    if (proIds.isNotEmpty) {
      _isNetworkAvail = await isNetworkAvailable();

      if (_isNetworkAvail) {
        try {
          var parameter = {"product_ids": proIds.join(',')};

          apiBaseHelper.postAPICall(getProductApi, parameter).then(
              (getdata) async {
            bool error = getdata["error"];
            if (!error) {
              var data = getdata["data"];

              List<Product> tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();
              mostLikeProList.clear();
              mostLikeProList.addAll(tempList);

              context.read<ProductProvider>().setProductList(mostLikeProList);
            }
            if (mounted) {
              setState(() {
                context.read<HomeProvider>().setMostLikeLoading(false);
              });
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          context.read<HomeProvider>().setMostLikeLoading(false);
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
            context.read<HomeProvider>().setMostLikeLoading(false);
          });
        }
      }
    } else {
      context.read<ProductProvider>().setProductList([]);
      setState(() {
        context.read<HomeProvider>().setMostLikeLoading(false);
      });
    }
  }

  Future<void> getMostFavPro() async {
    if (proIds1.isNotEmpty) {
      _isNetworkAvail = await isNetworkAvailable();

      if (_isNetworkAvail) {
        try {
          var parameter = {"product_ids": proIds1.join(',')};

          apiBaseHelper.postAPICall(getProductApi, parameter).then(
              (getdata) async {
            bool error = getdata["error"];
            if (!error) {
              var data = getdata["data"];

              List<Product> tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();
              mostFavProList.clear();
              mostFavProList.addAll(tempList);
            }
            if (mounted) {
              setState(() {
                context.read<HomeProvider>().setMostLikeLoading(false);
              });
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          context.read<HomeProvider>().setMostLikeLoading(false);
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
            context.read<HomeProvider>().setMostLikeLoading(false);
          });
        }
      }
    } else {
      context.read<CartProvider>().setCartlist([]);
      setState(() {
        context.read<HomeProvider>().setMostLikeLoading(false);
      });
    }
  }

  Future<void> _getOffCart() async {
    if (context.read<UserProvider>().userId == "") {
      List<String>? proIds = (await db.getCart())!;

      if (proIds.isNotEmpty) {
        _isNetworkAvail = await isNetworkAvailable();

        if (_isNetworkAvail) {
          try {
            var parameter = {"product_variant_ids": proIds.join(',')};
            apiBaseHelper.postAPICall(getProductApi, parameter).then(
                (getdata) async {
              bool error = getdata["error"];
              String? msg = getdata["message"];
              if (!error) {
                var data = getdata["data"];

                List<Product> tempList = (data as List)
                    .map((data) => Product.fromJson(data))
                    .toList();
                List<SectionModel> cartSecList = [];
                for (int i = 0; i < tempList.length; i++) {
                  for (int j = 0; j < tempList[i].prVarientList!.length; j++) {
                    if (proIds.contains(tempList[i].prVarientList![j].id)) {
                      String qty = (await db.checkCartItemExists(
                          tempList[i].id!, tempList[i].prVarientList![j].id!))!;
                      List<Product>? prList = [];
                      prList.add(tempList[i]);
                      cartSecList.add(SectionModel(
                        id: tempList[i].id,
                        varientId: tempList[i].prVarientList![j].id,
                        qty: qty,
                        productList: prList,
                      ));
                    }
                  }
                }

                context.read<CartProvider>().setCartlist(cartSecList);
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
            context.read<CartProvider>().setProgress(false);
          }
        } else {
          if (mounted) {
            setState(() {
              _isNetworkAvail = false;
              context.read<CartProvider>().setProgress(false);
            });
          }
        }
      } else {
        context.read<CartProvider>().setCartlist([]);
        setState(() {
          context.read<CartProvider>().setProgress(false);
        });
      }
    }
  }

  Future<void> _getOffFav() async {
    if (context.read<UserProvider>().userId == "") {
      List<String>? proIds = (await db.getFav())!;
      if (proIds.isNotEmpty) {
        _isNetworkAvail = await isNetworkAvailable();

        if (_isNetworkAvail) {
          try {
            var parameter = {"product_ids": proIds.join(',')};
            apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
              bool error = getdata["error"];
              String? msg = getdata["message"];
              if (!error) {
                var data = getdata["data"];

                List<Product> tempList = (data as List)
                    .map((data) => Product.fromJson(data))
                    .toList();

                context.read<FavoriteProvider>().setFavlist(tempList);
              }
              if (mounted) {
                setState(() {
                  context.read<FavoriteProvider>().setLoading(false);
                });
              }
            }, onError: (error) {
              setSnackbar(error.toString(), context);
            });
          } on TimeoutException catch (_) {
            setSnackbar(getTranslated(context, 'somethingMSg')!, context);
            context.read<FavoriteProvider>().setLoading(false);
          }
        } else {
          if (mounted) {
            setState(() {
              _isNetworkAvail = false;
              context.read<FavoriteProvider>().setLoading(false);
            });
          }
        }
      } else {
        context.read<FavoriteProvider>().setFavlist([]);
        setState(() {
          context.read<FavoriteProvider>().setLoading(false);
        });
      }
    }
  }

  Future<void> _getCart(String save) async {
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
                context.read<CartProvider>().setCartlist(cartList);
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
      // setSnackbar(e.message, context);
    }
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> generateReferral() async {
    try {
      String refer = getRandomString(8);

      //////

      Map parameter = {
        REFERCODE: refer,
      };

      apiBaseHelper.postAPICall(validateReferalApi, parameter).then((getdata) {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          REFER_CODE = refer;

          context.read<SettingProvider>().setPrefrence(REFERCODE, REFER_CODE!);

          Map parameter = {
            USER_ID: context.read<UserProvider>().userId,
            REFERCODE: refer,
          };

          apiBaseHelper.postAPICall(getUpdateUserApi, parameter);
        } else {
          if (count < 5) generateReferral();
          count++;
        }

        context.read<HomeProvider>().setSecLoading(false);
      }, onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setSecLoading(false);
      });
    } on FormatException catch (e) {
      // setSnackbar(e.message, context);
    }
  }

  updateDailog() async {
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        title: Text(getTranslated(context, 'UPDATE_APP')!),
        content: Text(
          getTranslated(context, 'UPDATE_AVAIL')!,
          style: Theme.of(this.context)
              .textTheme
              .titleMedium!
              .copyWith(color: Theme.of(context).colorScheme.fontColor),
        ),
        actions: <Widget>[
          TextButton(
              child: Text(
                getTranslated(context, 'NO')!,
                style: Theme.of(this.context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.lightBlack,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              }),
          TextButton(
              child: Text(
                getTranslated(context, 'YES')!,
                style: Theme.of(this.context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                Navigator.of(context).pop(false);

                String url = '';
                if (Platform.isAndroid) {
                  url = androidLink + packageName;
                } else if (Platform.isIOS) {
                  url = iosLink;
                }

                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              })
        ],
      );
    }));
  }

  Widget homeShimmer() {
    return SizedBox(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: SingleChildScrollView(
            child: Column(
          children: [
            catLoading(),
            sliderLoading(),
            sectionLoading(),
          ],
        )),
      ),
    );
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

  Widget _buildImagePageItem(Model slider) {
    double height = deviceWidth! / 0.5;
    return InkWell(
      child: networkImageCommon(
        boxFit: BoxFit.fill,
        slider.image!,
        height,
        false,
        height: height,
        width: double.maxFinite,
      ),
      onTap: () async {
        int curSlider = context.read<HomeProvider>().curSlider;
        print("values ${homeSliderList[curSlider].type}");
        if (homeSliderList[curSlider].type == "products") {
          Product? item = homeSliderList[curSlider].list;
          currentHero = homeHero;

          Navigator.pushNamed(context, Routers.productDetails, arguments: {
            "secPos": 0,
            "index": 0,
            "list": true,
            "id": item!.id!,
          });
        } else if (homeSliderList[curSlider].type == "categories") {
          Product item = homeSliderList[curSlider].list;
          if (item.subList!.isEmpty) {
            Navigator.pushNamed(context, Routers.productListScreen, arguments: {
              "name": item.name,
              "id": item.id,
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
              "title": item.name!,
              "subList": item.subList,
            });
          }
        } else if (homeSliderList[curSlider].type == "slider_url") {
          String url = homeSliderList[curSlider].urlLink.toString();
          try {
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication);
            } else {
              throw 'Could not launch $url';
            }
          } catch (e) {
            throw 'Something went wrong';
          }
        }
      },
    );
  }

  Widget deliverLoading() {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ));
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

  Widget noInternet(BuildContext context) {
    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        noIntImage(),
        noIntText(context),
        noIntDec(context),
        AppBtn(
          title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            context.read<HomeProvider>().setCatLoading(true);
            context.read<HomeProvider>().setSecLoading(true);
            context.read<HomeProvider>().setOfferLoading(true);
            context.read<HomeProvider>().setMostLikeLoading(true);
            context.read<HomeProvider>().setSliderLoading(true);
            _playAnimation();

            Future.delayed(const Duration(seconds: 2)).then((_) async {
              _isNetworkAvail = await isNetworkAvailable();
              if (_isNetworkAvail) {
                if (mounted) {
                  setState(() {
                    _isNetworkAvail = true;
                  });
                }
                callApi();
              } else {
                await buttonController.reverse();
                if (mounted) setState(() {});
              }
            });
          },
        )
      ]),
    );
  }

  Future<void> addToCart(int index, String qty, int from) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (context.read<UserProvider>().userId != "") {
        if (mounted) {
          setState(() {
            _isProgress = true;
          });
        }

        if (int.parse(qty) < productList[index].minOrderQuntity!) {
          qty = productList[index].minOrderQuntity.toString();

          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }

        var parameter = {
          USER_ID: context.read<UserProvider>().userId,
          PRODUCT_VARIENT_ID: productList[index]
              .prVarientList![productList[index].selVarient!]
              .id,
          QTY: qty
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = data['cart_count'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            productList[index]
                .prVarientList![productList[index].selVarient!]
                .cartCount = qty.toString();

            var cart = getdata["cart"];
            List<SectionModel> cartList = (cart as List)
                .map((cart) => SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(cartList);
          } else {
            setSnackbar(msg!, context);
          }
          if (mounted) {
            setState(() {
              _isProgress = false;
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          if (mounted) {
            setState(() {
              _isProgress = false;
            });
          }
        });
      } else {
        setState(() {
          _isProgress = true;
        });

        if (from == 1) {
          int cartCount = await db.getTotalCartCount(context);
          if (int.parse(MAX_ITEMS!) > cartCount) {
            List<Product>? prList = [];

            bool add = await db.insertCart(
                productList[index].id!,
                productList[index]
                    .prVarientList![productList[index].selVarient!]
                    .id!,
                qty,
                productList[index].productType!,
                context);
            if (add) {
              prList.add(productList[index]);
              context.read<CartProvider>().addCartItem(SectionModel(
                    qty: qty,
                    productList: prList,
                    varientId: productList[index]
                        .prVarientList![productList[index].selVarient!]
                        .id!,
                    id: productList[index].id,
                  ));
            }
          } else {
            setSnackbar(
                "In Cart maximum ${int.parse(MAX_ITEMS!)} product allowed",
                context);
          }
        } else {
          if (int.parse(qty) >
              int.parse(productList[index].itemsCounter!.last)) {
            // qty = productList[index].minOrderQuntity.toString();

            setSnackbar(
                "${getTranslated(context, 'MAXQTY')!} ${productList[index].itemsCounter!.last}",
                context);
          } else {
            context.read<CartProvider>().updateCartItem(
                productList[index].id!,
                qty,
                productList[index].selVarient!,
                productList[index]
                    .prVarientList![productList[index].selVarient!]
                    .id!);
            db.updateCart(
                productList[index].id!,
                productList[index]
                    .prVarientList![productList[index].selVarient!]
                    .id!,
                qty);
          }
        }
        setState(() {
          _isProgress = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  _deliverPincode() {
    return InkWell(
      onTap: _pincodeCheck,
      child: Container(
        // padding: EdgeInsets.symmetric(vertical: 8),
        color: Theme.of(context).colorScheme.lightWhite,
        child: ListTile(
          dense: true,
          minLeadingWidth: 10,
          leading: const Icon(
            Icons.location_pin,
          ),
          title: /*Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              print('pincode-------${userProvider.curPincode}');*/
              Text(
            '${(pincodeOrCityName == null || pincodeOrCityName.toString().isEmpty) ? getTranslated(context, 'SELOC')! : getTranslated(context, 'DELIVERTO')!}  ${pincodeOrCityName ?? ''}',
            style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
          ),

          /* },
           // selector: (_, provider) => provider.curPincode,
          ),*/
          trailing: const Icon(Icons.keyboard_arrow_right),
        ),
      ),
    );
  }

  _getSearchBar() {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: 44,
          child: TextField(
            enabled: false,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(50.0),
                  ),
                  borderSide: BorderSide(
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
                isDense: true,
                hintText: getTranslated(context, 'searchHint'),
                hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                    ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    'assets/images/search.svg',
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primarytheme,
                        BlendMode.srcIn),
                  ),
                ),
                fillColor: Theme.of(context).colorScheme.lightWhite,
                filled: true),
          ),
        ),
      ),
      onTap: () async {
        // await Navigator.push(
        //     context,
        //     CupertinoPageRoute(
        //       builder: (context) => const SearchScreen(),
        //     ));

        await Navigator.pushNamed(context, Routers.searchScreen);

        if (mounted) setState(() {});
      },
    );
  }

  searchBar() {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: SizedBox(
          height: 50,
          child: TextField(
            enabled: false,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(15.0, 0.0, 0, 0.0),
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
                    color: const Color(0XFF696969),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(15.0),
                child: SvgPicture.asset(
                  'assets/images/search.svg',
                  colorFilter: const ColorFilter.mode(
                    Color(0XFF696969),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
      ),
      onTap: () async {
        // await Navigator.push(
        //     context,
        //     CupertinoPageRoute(
        //       builder: (context) => const SearchScreen(),
        //     ));

        await Navigator.pushNamed(context, Routers.searchScreen);

        if (mounted) setState(() {});
      },
    );
  }

  void _pincodeCheck() async {
    if (isCityWiseDelivery == true) {
      var cityResponse = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (context) {
          return const LocationSelectorWidget();
        },
      );
      if (cityResponse != null) {
        pincodeOrCityName = cityResponse['name'];
        slectedCityId = cityResponse['id'];
        if (pincodeOrCityName == null && selectedCity == null) {
          setState(() {});
        }

        context
            .read<SettingProvider>()
            .setPrefrence("cityId", slectedCityId ?? "");

        context.read<HomeProvider>().setSecLoading(true);
        context.read<FetchFeaturedSectionsCubit>().fetchSections(context,
            isCityWiseDelivery: isCityWiseDelivery!,
            userId: context.read<UserProvider>().userId,
            pincodeOrCityName:
                isCityWiseDelivery! ? slectedCityId : pincodeOrCityName);
        setState(() {});
      }

      return;
    }

    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9),
              child: ListView(shrinkWrap: true, children: [
                Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, bottom: 40, top: 30),
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Icon(Icons.close),
                                ),
                              ),
                              TextFormField(
                                controller: TextEditingController(
                                    text: pincodeOrCityName),
                                autofocus: true,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                validator: (val) => validatePincode(val!,
                                    getTranslated(context, 'PIN_REQUIRED')),
                                onSaved: (String? value) {
                                  setState(() {
                                    pincodeOrCityName = value!;
                                  });
                                  /*context
                                      .read<UserProvider>()
                                      .setPincode(value!);*/
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                                decoration: InputDecoration(
                                  isDense: false,
                                  prefixIcon: const Icon(Icons.location_on),
                                  hintText:
                                      getTranslated(context, 'PINCODEHINT_LBL'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsetsDirectional.only(
                                          start: 20),
                                      width: deviceWidth! * 0.35,
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          context
                                              .read<UserProvider>()
                                              .setPincode('');
                                          await context
                                              .read<SettingProvider>()
                                              .removeKey(pinCodeOrCityNameKey);
                                          pincodeOrCityName = "";
                                          setState(() {});
                                          context
                                              .read<HomeProvider>()
                                              .setSecLoading(true);

                                          context
                                              .read<
                                                  FetchFeaturedSectionsCubit>()
                                              .fetchSections(context,
                                                  isCityWiseDelivery:
                                                      isCityWiseDelivery!,
                                                  userId: context
                                                      .read<UserProvider>()
                                                      .userId,
                                                  pincodeOrCityName:
                                                      pincodeOrCityName);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                            getTranslated(context, 'All')!),
                                      ),
                                    ),
                                    const Spacer(),
                                    SimBtn(
                                        width: 0.35,
                                        height: 35,
                                        title: getTranslated(context, 'APPLY'),
                                        onBtnSelected: () async {
                                          if (validateAndSave()) {
                                            context
                                                .read<HomeProvider>()
                                                .setSecLoading(true);
                                            getFeaturedSection(
                                                pincode: pincodeOrCityName);
                                            context
                                                .read<
                                                    FetchFeaturedSectionsCubit>()
                                                .fetchSections(context,
                                                    isCityWiseDelivery:
                                                        isCityWiseDelivery!,
                                                    userId: context
                                                        .read<UserProvider>()
                                                        .userId,
                                                    pincodeOrCityName:
                                                        pincodeOrCityName);
                                            Navigator.pop(context);
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ))
              ]),
            );
            //});
          });
        });
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;

    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  void getSlider() {
    try {
      Map map = {};

      apiBaseHelper.postAPICall(getSliderApi, map).then((getdata) {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          homeSliderList =
              (data as List).map((data) => Model.fromSlider(data)).toList();

          pages = homeSliderList.map((slider) {
            return _buildImagePageItem(slider);
          }).toList();
        } else {
          setSnackbar(msg!, context);
        }

        context.read<HomeProvider>().setSliderLoading(false);
      }, onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setSliderLoading(false);
      });
    } on FormatException catch (e) {
      // setSnackbar(e.message, context);
    }
  }

  void getCat() {
    try {
      Map parameter = {
        CAT_FILTER: "false",
      };
      apiBaseHelper.postAPICall(getCatApi, parameter).then((getdata) {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          catList =
              (data as List).map((data) => Product.fromCat(data)).toList();

          if (getdata.containsKey("popular_categories")) {
            var data = getdata["popular_categories"];
            popularList =
                (data as List).map((data) => Product.fromCat(data)).toList();

            if (popularList.isNotEmpty) {
              Product pop =
                  Product.popular("Popular", "${imagePath}popular.svg");
              catList.insert(0, pop);
              context.read<CategoryProvider>().setSubList(popularList);
            }
          }
        } else {
          setSnackbar(msg!, context);
        }

        context.read<HomeProvider>().setCatLoading(false);
      }, onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setCatLoading(false);
      });
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  sectionLoading() {
    return Column(
        children: [0, 1, 2, 3, 4]
            .map((_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 80.0),
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

  void appMaintenanceDialog() async {
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          title: Text(
            getTranslated(context, 'APP_MAINTENANCE')!,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal,
                fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Lottie.asset('assets/animation/maintenance.json'),
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                IS_APP_MAINTENANCE_MESSAGE != ''
                    ? IS_APP_MAINTENANCE_MESSAGE!
                    : getTranslated(context, 'MAINTENANCE_DEFAULT_MESSAGE')!,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 12),
              )
            ],
          ),
        ),
      );
    }));
  }

  void showPopUpOfferDialog() async {
    PopupOfferDialog(
      onDialogClick: () {},
      popupOffer: popUpOffer,
    ).show(context);
  }
}

class BrandsListWidget extends StatelessWidget {
  const BrandsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandsListCubit, BrandsListState>(
      builder: (context, state) {
        if (state is BrandsListSuccess) {
          return state.brands.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        getTranslated(context, 'Brands')!,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontFamily: 'ubuntu',
                              color: Theme.of(context).colorScheme.fontColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          itemCount: state.brands.length,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(end: 18),
                              child: GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   CupertinoPageRoute(
                                  //     builder: (context) => ProductListScreen(
                                  //
                                  //     ),
                                  //   ),
                                  // );
                                  Navigator.pushNamed(
                                      context, Routers.productListScreen,
                                      arguments: {
                                        "name": state.brands[index].name,
                                        "id": state.brands[index].id,
                                        "brandId": state.brands[index].id,
                                        "tag": false,
                                        "fromSeller": false,
                                      });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: networkImageCommon(
                                        state.brands[index].image,
                                        60,
                                        false,
                                        boxFit: BoxFit.cover,
                                        height: 60.0,
                                        width: 60.0,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: SizedBox(
                                        width: 60,
                                        child: Text(
                                          state.brands[index].name,
                                          maxLines: 2,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                fontFamily: 'ubuntu',
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink();
        } else if (state is BrandsListInProgress) {
          return SizedBox(
            width: double.infinity,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.simmerBase,
              highlightColor: Theme.of(context).colorScheme.simmerHigh,
              child: brandLoading(context),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  static Widget brandLoading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: 100,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                  .map(
                    (_) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.white,
                        shape: BoxShape.circle,
                      ),
                      width: 50.0,
                      height: 50.0,
                    ),
                  )
                  .toList(),
            ),
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
}

class LocationSelectorWidget extends StatefulWidget {
  const LocationSelectorWidget({super.key});

  @override
  State<LocationSelectorWidget> createState() => _LocationSelectorWidgetState();
}

class _LocationSelectorWidgetState extends State<LocationSelectorWidget> {
// ScrollController _controller=ScrollController();

  final ScrollController _pageScrollController = ScrollController();
  final TextEditingController _cityName = TextEditingController();
  Timer? timer;
  @override
  void initState() {
    context.read<FetchCitiesCubit>().fetch();

    _pageScrollController.addListener(() {
      if (_pageScrollController.isEndReached()) {
        if (context.read<FetchCitiesCubit>().hasMoreData()) {
          context.read<FetchCitiesCubit>().fetchMore();
        }
      }
    });

    _cityName.addListener(() {
      if (timer?.isActive ?? false) timer?.cancel();
      timer = Timer(
        const Duration(milliseconds: 700),
        () {
          context.read<FetchCitiesCubit>().fetch(search: _cityName.text);
        },
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      expand: false,
      minChildSize: 0.6,
      maxChildSize: 0.91,
      builder: (context, ScrollController scrollController) {
        return BlocBuilder<FetchCitiesCubit, FetchCitiesState>(
          builder: (context, state) {
            return ListView(controller: _pageScrollController, children: [
              Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20, bottom: 40, top: 30),
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Form(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Icon(Icons.close),
                          ),
                        ),
                        TextFormField(
                          controller: _cityName,
                          // keyboardType: TextInputType.,
                          // textCapitalization: TextCapitalization.words,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor),
                          decoration: InputDecoration(
                            isDense: false,
                            prefixIcon: const Icon(
                              Icons.location_on,
                            ),
                            hintText: getTranslated(context, 'CITY_NAME'),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context, {"city": null, "id": null});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: context.color.primarytheme,
                                borderRadius: BorderRadius.circular(3)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Clear ",
                                    style: TextStyle(color: colors.cardColor)),
                                Text("X",
                                    style: TextStyle(color: colors.cardColor)),
                              ],
                            ),
                          ),
                        ),
                        BlocBuilder<FetchCitiesCubit, FetchCitiesState>(
                          builder: (context, state) {
                            if (state is FetchCitiesFail) {
                              return const Center(
                                child: Text("Something went wrong"),
                              );
                            }
                            if (state is FetchCitiesInInProgress) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state is FetchCitiesSuccess) {
                              if (state.cities.isEmpty) {
                                return const Center(
                                  child: Text("No data"),
                                );
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListView.builder(
                                    itemCount: state.cities.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> city =
                                          state.cities[index];
                                      return GestureDetector(
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.pop(context, city);
                                          },
                                          title: Text(city['name']).color(
                                              context
                                                  .color.blackInverseInDarkTheme
                                                  .withAlpha(230)),
                                        ),
                                      );
                                    },
                                  ),
                                  if (state.isLoadingMore)
                                    const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  if (state.loadingMoreError)
                                    const Center(
                                      child: Text("Something went wrong"),
                                    )
                                ],
                              );
                            }
                            return Container();
                          },
                        ),
                      ],
                    )),
                  ))
            ]);
          },
        );
      },
    );
  }
}

final List<Widget> imgList = [
  imageList(
    'assets/images/home/Slider 1.png',
    () {
      debugPrint("Explore Now Button Pressed");
    },
  ),
  imageList(
    'assets/images/home/Slider 2.png',
    () {
      debugPrint("Explore Now Button Pressed");
    },
  ),
  imageList(
    'assets/images/home/Slider 3 (2).png',
    () {
      debugPrint("Explore Now Button Pressed");
    },
  ),
];

Stack imageList(
  String image,
  VoidCallback onTap,
) {
  return Stack(
    children: [
      Image.asset(
        image,
        fit: BoxFit.cover,
        height: 600,
        width: deviceWidth! * 0.88,
      ),
      Positioned(
        bottom: 35,
        left: 35,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox(
            width: 92,
            height: 55,
            // child: Text(
            //   "Explore now",
            //   overflow: TextOverflow.ellipsis,
            // ),
          ),
        ),
      ),
    ],
  );
}

List<String> sellingDiscount = [
  "BEST SELLERS",
  "OFF 24%",
  "OFF 64%",
  "OFF 74%",
];
