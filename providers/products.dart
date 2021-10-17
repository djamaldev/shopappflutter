import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shopapp/models/http_exception.dart';
import 'package:shopapp/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  String? authToken;
  String? userId;

  getData(String authTok, String uId, List<Product> products) {
    authToken = authTok;
    userId = uId;
    _items = products;
    notifyListeners();
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((proditem) => proditem.isFavorite).toList();
  }

  findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetData([bool filterByUser = false]) async {
    final filtredString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        "https://shopapp-cef20-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filtredString";

    try {
      final res = await http.get(url);
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      } else {
        url =
            "https://shopapp-cef20-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken";
        final favRes = await http.get(url);
        final favData = json.decode(favRes.body) as Map<String, dynamic>;
        final List<Product> loadedProducts = [];
        extractedData.forEach((prodId, prodData) {
          loadedProducts.add(Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              isFavorite: favData == null ? false : prodData[prodId] ?? false,
              imageUrl: prodData['imageUrl']));
        });
        _items = loadedProducts;
        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        "https://shopapp-cef20-default-rtdb.firebaseio.com/products.json?auth=$authToken";
    try {
      http.Response res = await http.post(Uri.parse(url),
          body: json.encode({
            "title": product.title,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl,
            "creatorId": userId
          }));
      final newProduct = Product(
        id: json.decode(res.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          "https://shopapp-cef20-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
      final res = http.patch(Uri.parse(url),
          body: json.encode({
            "title": newProduct.title,
            "description": newProduct.description,
            "price": newProduct.price,
            "imageUrl": newProduct.imageUrl,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://shopapp-cef20-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}
