import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Badge extends StatelessWidget {
  final Widget? child;
  final String? value;
  final Color? color;

  const Badge({@required this.value, this.color, @required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: EdgeInsets.all(2.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: color != null
                    ? color
                    : Theme.of(context).colorScheme.secondary),
            constraints: BoxConstraints(minHeight: 16, minWidth: 16),
            child: Text(
              value!,
              style: TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }
}
