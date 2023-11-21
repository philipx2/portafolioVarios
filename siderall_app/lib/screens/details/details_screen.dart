import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/Product.dart';
import 'package:shop_app/screens/details/components/body.dart';
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


class DetailsScreen extends StatelessWidget {
  final Product product;

  const DetailsScreen({Key key, this.product}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // each product have a color
      backgroundColor: product.color,
      appBar: buildAppBar(context),
      body: Body(product: product),
    );
  }
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
                count = 1;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Comprar'),
              onPressed: () {
                count = 1;
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

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: product.color,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/back.svg',
          color: Colors.white,
        ),
        onPressed: (){
          count = 1;
          Navigator.pushReplacement(
            context,
            new MaterialPageRoute(builder: (context) => new MyApp()),
          );
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: SvgPicture.asset("assets/icons/search.svg"),
          onPressed: () {
            //print(Redelcom("redelcom","5000","2345","1","1").toJson());
            //sendPayRedelcom2(product.price.toString());
          },
        ),
        IconButton(
          icon: SvgPicture.asset("assets/icons/cart.svg"),
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
