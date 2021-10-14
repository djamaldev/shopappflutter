import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/orders.dart';
import 'package:shopapp/widgets/app_drawer.dart';
import 'package:shopapp/widgets/order_item.dart';

class OrederScreen extends StatelessWidget {
  static const routName = '/order';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrder(),
          builder: (ctx, snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              if (snapShot.error != null) {
                return Center(
                  child: Text('An error occurd'),
                );
              } else {
                return Consumer<Orders>(
                  builder: (cx, oredrData, child) => ListView.builder(
                    itemCount: oredrData.order.length,
                    itemBuilder: (_, index) =>
                        OrderItem(oredrData.order[index]),
                  ),
                );
              }
            }
          },
        ));
  }
}
