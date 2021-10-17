import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/cart.dart' show Cart;
import 'package:shopapp/providers/orders.dart';
import 'package:shopapp/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6!
                              .color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemCount: cart.item.length,
            itemBuilder: (ctx, int index) => CartItem(
              id: cart.item.values.toList()[index].id,
              productId: cart.item.keys.toList()[index],
              quantity: cart.item.values.toList()[index].quantity,
              price: cart.item.values.toList()[index].price,
              title: cart.item.values.toList()[index].title,
            ),
          ))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  final Cart? cart;

  OrderButton({@required this.cart});

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart!.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrdert(
                widget.cart!.item.values.toList(),
                widget.cart!.totalAmount,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart!.clear();
            },
      child: _isLoading ? CircularProgressIndicator() : Text('Order Now'),
      style: TextButton.styleFrom(
        textStyle: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }
}
