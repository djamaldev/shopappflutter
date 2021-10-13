import 'package:flutter/material.dart';

class CartItem {
  final String? id;
  final String? title;
  final int? quantity;
  final double? price;

  CartItem(
      {@required this.id,
      @required this.title,
      @required this.quantity,
      @required this.price});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _item = {};

  Map<String, CartItem> get item {
    return {..._item};
  }

  int get itemCount {
    return _item.length;
  }

  double get totalAmount {
    var total = 0.0;
    _item.forEach((key, CartItem) {
      total += CartItem.price! * CartItem.quantity!;
    });
    return total;
  }

  void addItems(String productId, String title, double price) {
    if (_item.containsKey(productId)) {
      _item.update(
          productId,
          (existingItem) => CartItem(
              id: existingItem.id,
              title: existingItem.title,
              quantity: existingItem.quantity! + 1,
              price: existingItem.price));
    } else {
      _item.putIfAbsent(
        productId,
        () => CartItem(
            id: DateTime.now().toString(),
            title: title,
            quantity: 1,
            price: price),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _item.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_item.containsKey(productId)) {
      return;
    }
    if (_item[productId]!.quantity! > 1) {
      _item.update(
          productId,
          (existingItem) => CartItem(
              id: existingItem.id,
              title: existingItem.title,
              quantity: existingItem.quantity! - 1,
              price: existingItem.price));
    } else {
      _item.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _item = {};
    notifyListeners();
  }
}
