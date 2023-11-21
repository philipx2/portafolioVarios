import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop_app/models/Product.dart';
import 'package:shop_app/main.dart';
import 'cart_counter.dart';
import 'package:shop_app/screens/details/details_screen.dart';
import 'package:shop_app/screens/home/load_pay.dart';

import '../../../constants.dart';

class AddToCart extends StatelessWidget {
  const AddToCart({
    Key key,
    @required this.product,

  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: kDefaultPaddin),
            height: 50,
            width: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: product.color,
              ),
            ),
            child: IconButton(
              icon: SvgPicture.asset(
                "assets/icons/add_to_cart.svg",
                color: product.color,
              ),
              onPressed: () {
                int check = -1;
                for(int i=0;i<listProduct.length;i++){
                  if(product==listProduct[i]){
                    check = i;
                  }
                }
                if(check>=0){
                  countProduct[check]=countProduct[check] + count;
                }
                else{
                  listProduct.add(product);
                  countProduct.add(count);
                }
                count = 1;
                print("countProduct[0]: " + countProduct[0].toString());
                print("countProduct.length: " + countProduct.length.toString());
              },
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 50,
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                color: product.color,
                onPressed: () {
                  int totalPrice = product.price * count;
                  print("Precio total a pagar: " + totalPrice.toString());
                  count = 1;
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new HowComerce(pay: totalPrice,)),
                  );
                },
                child: Text(
                  "Buy  Now".toUpperCase(),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
