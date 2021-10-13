import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final String? id;
  final String? title;
  final String? description;
  final double? price;
  final String? imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatues = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url =
        "https://shopapp-cef20-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token";
    try {
      final res = await http.put(url, body: json.encode(isFavorite));
      if (res.statusCode >= 400) {
        _setFavValue(oldStatues);
      }
    } catch (e) {
      _setFavValue(oldStatues);
    }
  }
}
