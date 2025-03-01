import 'package:eshop/Helper/ApiBaseHelper.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Model/Section_Model.dart';
import 'package:eshop/ui/widgets/ApiException.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<SectionModel> _cartList = [];

  List<SectionModel> get cartList => _cartList;
  bool _isProgress = false;

  get cartIdList => _cartList.map((fav) => fav.varientId).toList();

  /* String? qtyList(String id, String vId) {
    SectionModel? tempId =
        _cartList.firstWhereOrNull((cp) => cp.id == id && cp.varientId == vId);
    notifyListeners();
    if (tempId != null) {
      return tempId.qty;
    } else {
      return "0";
    }
  }*/

  get isProgress => _isProgress;

  setProgress(bool progress) {
    _isProgress = progress;
    notifyListeners();
  }

  bool _isProductInCart = false;

  bool get isProductInCart => _isProductInCart;

  void updateIsProductInCart(bool value) {
    _isProductInCart = value;
    notifyListeners();
  }

  removeCartItem(String id, {int? index}) {
    if (index != null) {
      _cartList.removeWhere(
          (item) => item.productList![0].prVarientList![index].id == id);
    } else {
      _cartList.removeWhere((item) => item.varientId == id);
    }

    notifyListeners();
  }

  // addCartItem(SectionModel? item) {
  //   if (item != null) {
  //     _cartList.add(item);
  //     notifyListeners();
  //   }
  // }

  void addCartItem(SectionModel? item) {
    if (item != null) {
      // If the product is already in the cart, update the quantity
      final existingIndex = _cartList
          .indexWhere((cartItem) => cartItem.varientId == item.varientId);
      if (existingIndex != -1) {
        _cartList[existingIndex].qty =
            (int.parse(_cartList[existingIndex].qty!) + 1).toString();
      } else {
        _cartList.add(item); // Add new product if not already in the cart
      }
      notifyListeners();
    }
  }

  // updateCartItem(String? id, String qty, int index, String vId) {
  //   final i = _cartList.indexWhere((cp) => cp.id == id && cp.varientId == vId);

  //   _cartList[i].qty = qty;
  //   _cartList[i].productList![0].prVarientList![index].cartCount = qty;

  //   notifyListeners();
  // }

  void updateCartItem(String? id, String qty, int index, String vId) {
    final i =
        _cartList.indexWhere((item) => item.id == id && item.varientId == vId);

    if (i != -1) {
      _cartList[i].qty = qty;
      _cartList[i].productList![0].prVarientList![index].cartCount = qty;
      notifyListeners(); // Notify only after the update
    }
  }

  // setCartlist(List<SectionModel> cartList) {
  //   _cartList.clear();
  //   _cartList.addAll(cartList);
  //   notifyListeners();
  // }
  void setCartlist(List<SectionModel> cartList) {
    _cartList.clear();
    _cartList.addAll(cartList);
    notifyListeners();
  }
}

Future<Map> getPhonePeDetails({
  required String userId,
  required String type,
  required String mobile,
  String? amount,
  required String orderId,
  required String transationId,
}) async {
  try {
    var responseData = await ApiBaseHelper().postAPICall(
      getPhonePeDetailsApi,
      {
        'type': type,
        'mobile': mobile,
        if (amount != null) 'amount': amount,
        'order_id': orderId,
        'transation_id': transationId,
        'user_id': userId
      },
    );
    return responseData;
  } on Exception catch (e) {
    throw ApiException('$e${e.toString()}');
  }
}
