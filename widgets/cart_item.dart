import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/cart.dart';

class CartItem extends StatelessWidget {
  final String? id;
  final String? productId;
  final int? quantity;
  final double? price;
  final String? title;

  const CartItem(
      {this.id, this.productId, this.quantity, this.price, this.title});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: ValueKey(id),
        background: Container(
          color: Theme.of(context).errorColor,
          child: Icon(
            Icons.delete,
            size: 40,
          ),
          padding: EdgeInsets.only(right: 8),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) {
          return showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: Text('Are you sure?'),
                    content: Text('Do you want remove item from the cart?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('No')),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Yes')),
                    ],
                  ));
        },
        onDismissed: (direction) {
          Provider.of<Cart>(context).removeItem(productId!);
        },
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: FittedBox(
                    child: Text('\$$price'),
                  ),
                ),
              ),
              title: Text(title!),
              subtitle: Text('total \$${(price! * quantity!)}'),
              trailing: Text('$quantity! x'),
            ),
          ),
        ));
  }
}
