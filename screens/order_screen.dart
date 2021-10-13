import 'package:flutter/material.dart';
import 'package:shopapp/widgets/app_drawer.dart';

class OrederScreen extends StatelessWidget {
  static const routName = '/order';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: Center(
        child: Text('Oredrs'),
      ),
      drawer: AppDrawer(),
    );
  }
}
