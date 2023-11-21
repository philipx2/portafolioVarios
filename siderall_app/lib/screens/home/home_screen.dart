import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/screens/home/components/body.dart';
import 'package:shop_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/screens/home/load_pay.dart';
import 'package:shop_app/screens/details/components/cart_counter.dart';

int functTotalPrice(){
  int totalPrice = 0;
  for(int i=0;i<listProduct.length;i++){
    totalPrice = totalPrice + listProduct[i].price * countProduct[i];
  }
  return totalPrice;
}
class HomeScreen extends StatelessWidget {
  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Carrito de compras'),
          content: SingleChildScrollView(
            child: Container(
              height: 300.0, // Change as per your requirement
              width: 300.0, // Change as per your requirement
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: listProduct.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if(listProduct.length> index){
                    return ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.remove_shopping_cart),
                        onPressed: (){
                          listProduct.removeAt(index);
                          countProduct.removeAt(index);
                          Navigator.pop(context);
                        },
                      ),
                      title: Text(listProduct[index].title),
                      subtitle: Text("\$" + listProduct[index].price.toString() + " x U"),
                      trailing: Container(height: 150, width: 90,child: Transform.translate(offset: Offset(0,0), child: CartCounter(posProduct: index,),),),
                      //leading: Text(countProduct[index].toString() + "    x"),
                    );
                  }
                  else{
                    return ListTile(
                      title: Text("Total"),
                      //trailing: Text("\$" + totalPrice.toString(),style: TextStyle(color: Colors.red),),
                      trailing: TotalCounter(),
                    );
                  }
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Volver'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Comprar'),
              onPressed: () {

                Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new HowComerce(pay: functTotalPrice(),)),
                );
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Body(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset("assets/icons/back.svg"),
        onPressed: () {},
      ),
      actions: <Widget>[
        IconButton(
          icon: SvgPicture.asset(
            "assets/icons/search.svg",
            // By default our  icon color is white
            color: kTextColor,
          ),
          onPressed: () {

          },
        ),
        IconButton(
          icon: SvgPicture.asset(
            "assets/icons/cart.svg",
            // By default our  icon color is white
            color: kTextColor,
          ),
          onPressed: () {
            print("countProduct[0]: " + countProduct[0].toString());
            _showMyDialog(context);
          },
        ),
        SizedBox(width: kDefaultPaddin / 2)
      ],
    );
  }
}
