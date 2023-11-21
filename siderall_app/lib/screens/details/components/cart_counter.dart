import 'package:flutter/material.dart';
import 'package:shop_app/main.dart';
import 'package:shop_app/screens/details/details_screen.dart';

import '../../../constants.dart';
int count = 1;
class CartCounter extends StatefulWidget {
  final int posProduct;

  CartCounter({this.posProduct});
  @override
  _CartCounterState createState() => _CartCounterState(posProduct: posProduct);
}

class _CartCounterState extends State<CartCounter> {
  final int posProduct;

  _CartCounterState({this.posProduct});
  @override
  Widget build(BuildContext context) {
    if(posProduct!=null){
      return Row(
        children: <Widget>[
          buildOutlineButton(
            icon: Icons.remove,
            press: () {
              if (countProduct[posProduct] > 1) {
                setState(() {
                  if(posProduct!=null){
                    countProduct[posProduct]--;
                  }
                });
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin / 10),
            child: Text(
              // if our item is less  then 10 then  it shows 01 02 like that
              countProduct[posProduct].toString().padLeft(2, "0"),
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          buildOutlineButton(
              icon: Icons.add,
              press: () {
                setState(() {
                  if(posProduct!=null){
                    countProduct[posProduct]++;
                  }
                });
              }),
        ],
      );
    }
    else{
      return Row(
        children: <Widget>[
          buildOutlineButton(
            icon: Icons.remove,
            press: () {
              if (count > 1) {
                setState(() {
                  count--;
                });
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin / 10),
            child: Text(
              // if our item is less  then 10 then  it shows 01 02 like that
              count.toString().padLeft(2, "0"),
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          buildOutlineButton(
              icon: Icons.add,
              press: () {
                setState(() {
                  count++;
                });
              }),
        ],
      );
    }
  }

  SizedBox buildOutlineButton({IconData icon, Function press}) {
    return SizedBox(
      width: 30,
      height: 22,
      child: OutlineButton(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        onPressed: press,
        child: Icon(icon),
      ),
    );
  }
}

class TotalCounter2 extends CartCounter{
  @override
  Widget build(BuildContext context) {
    int totalPrice =0;
    for(int i=0;i<listProduct.length;i++){
      totalPrice = totalPrice + listProduct[i].price * countProduct[i];
    }
    return Text("\$" + totalPrice.toString(),style: TextStyle(color: Colors.red),);
  }
}

class TotalCounter extends StatefulWidget {

  @override
  _TotalCounterState createState() => _TotalCounterState();
}

class _TotalCounterState extends State<TotalCounter> {

  @override
  Widget build(BuildContext context) {
    int a;
    setState(() {
      a = functTotalPrice();
    });
    return Text("\$" + a.toString(),style: TextStyle(color: Colors.red),);
  }
}
