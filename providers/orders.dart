import 'package:flutter/material.dart';
import 'package:shopapp/providers/cart.dart';
import 'package:shopapp/providers/products.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrederItem {
  final String? id;
  final double? amount;
  final List<CartItem>? products;
  final DateTime? dateTime;

  OrederItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrederItem> _orders = [];
  String? authToken;
  String? userId;

  getData(String authTok, String uId, List<OrederItem> order) {
    authToken = authTok;
    userId = uId;
    _orders = order;
    notifyListeners();
  }

  List<OrederItem> get order {
    return [..._orders];
  }

  Future<void> fetchAndSetOrder() async {
    final url =
        "https://shopapp-cef20-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";

    try {
      final res = await http.get(url);
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<OrederItem> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrederItem(
            id: orderId,
            amount: orderData['amount'],
            products: (orderData['products'] as List<dynamic>)
                .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price']))
                .toList(),
            dateTime: DateTime.parse(orderData['dateTime'])));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addOrdert(List<CartItem> cartProduct, double total) async {
    final url =
        "https://shopapp-cef20-default-rtdb.firebaseio.com/orders.json?auth=$authToken";
    final timeStamp = DateTime.now();
    // add order to server
    try {
      http.Response res = await http.post(Uri.parse(url),
          body: json.encode({
            "amount": total,
            "dateTime": timeStamp.toIso8601String(),
            "products": cartProduct
                .map((cartProd) => {
                      'id': cartProd.id,
                      'title': cartProd.title,
                      'quantity': cartProd.quantity,
                      'price': cartProd.price
                    })
                .toList(),
          }));
      //add order to app
      _orders.insert(
          0,
          OrederItem(
              id: json.decode(res.body)['name'],
              amount: total,
              products: cartProduct,
              dateTime: timeStamp));
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
