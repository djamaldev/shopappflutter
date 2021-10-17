import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/products.dart';
import 'package:shopapp/widgets/product_items.dart';

class ProductGrid extends StatelessWidget {
  final bool? showFavorite;

  const ProductGrid(this.showFavorite);

  @override
  Widget build(BuildContext context) {
    final prodData = Provider.of<Products>(context, listen: false);
    final products = showFavorite! ? prodData.favoriteItems : prodData.items;
    return products.isEmpty
        ? Center(
            child: Text('There is no product!'),
          )
        : GridView.builder(
            padding: EdgeInsets.all(10.0),
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
              value: products[index],
              child: ProductItems(),
            ),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
          );
  }
}
