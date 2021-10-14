import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/cart.dart';
import 'package:shopapp/providers/products.dart';
import 'package:shopapp/screens/cart_screen.dart';
import 'package:shopapp/widgets/app_drawer.dart';
import 'package:shopapp/widgets/badge.dart';
import 'package:shopapp/widgets/product_grid.dart';

class ProductOverViewScreen extends StatefulWidget {
  const ProductOverViewScreen({Key? key}) : super(key: key);

  @override
  _ProductOverViewScreenState createState() => _ProductOverViewScreenState();
}

enum FilterOption { favorites, all }

class _ProductOverViewScreenState extends State<ProductOverViewScreen> {
  var _isLoading = false;
  var _showOnlyFavorites = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    Provider.of<Products>(context, listen: false).fetchAndSetData().then((_) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: [
          PopupMenuButton(
              onSelected: (FilterOption selectedVal) {
                setState(() {
                  if (selectedVal == FilterOption.favorites) {
                    _showOnlyFavorites = true;
                  } else {
                    _showOnlyFavorites = false;
                  }
                });
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('Only favorites'),
                      value: FilterOption.favorites,
                    ),
                    PopupMenuItem(
                      child: Text('Show all'),
                      value: FilterOption.all,
                    ),
                  ]),
          Consumer<Cart>(
            child: IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(CartScreen.routName),
                icon: Icon(Icons.shopping_cart)),
            builder: (_, cart, child) =>
                Badge(value: cart.itemCount.toString(), child: child),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(_showOnlyFavorites),
    );
  }
}
