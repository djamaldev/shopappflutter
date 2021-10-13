import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/products.dart';
import 'package:shopapp/providers/products.dart';
import 'package:shopapp/screens/edit_product_screen.dart';
import 'package:shopapp/widgets/app_drawer.dart';

class UserProductScreen extends StatelessWidget {
  static const routName = '/user-product';

  Future<void> _refreshProduct(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetData(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your products'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () =>
                  Navigator.of(context).pushNamed(EditProductScreen.routName),
            )
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _refreshProduct(context),
          builder: (ctx, snapShot) =>
              snapShot.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      child: Consumer<Products>(
                        builder: (ctx, productData, _) => Padding(
                          padding: EdgeInsets.all(8),
                          child: ListView.builder(
                            itemCount: productData.items.length,
                            itemBuilder: (_, int index) => Column(
                              children: [],
                            ),
                          ),
                        ),
                      ),
                      onRefresh: () => _refreshProduct(context)),
        ));
  }
}
