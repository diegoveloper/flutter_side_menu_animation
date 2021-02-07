import 'package:example/menu_value.dart';
import 'package:flutter/material.dart';

class Screen extends StatelessWidget {
  const Screen({Key key, @required this.itemsScreen}) : super(key: key);

  final List<MenuValues> itemsScreen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemsScreen.length,
        (index) => Expanded(
          child: Container(
            color: itemsScreen[index].color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(itemsScreen[index].icon, size: 75, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  itemsScreen[index].title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
