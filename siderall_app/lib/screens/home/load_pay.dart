import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/Product.dart';
import 'package:shop_app/screens/details/components/body.dart';
import 'package:shop_app/main.dart';
import 'package:shop_app/screens/details/components/cart_counter.dart';


class FutureResponse extends StatelessWidget {
  final Future<String> pay;
  final String machine;

  const FutureResponse({Key key,this.pay, this.machine}) : super(key: key);
  @override

  Widget build(BuildContext context) {
    void onCloseDialog() {
      {
        Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => new MyApp()),);
      }
    }
    return Scaffold(
      // each product have a color
      backgroundColor: Colors.green[100],
      appBar: buildAppBar(context),
      body: Center(
        child: FutureBuilder<String>(
          future: pay,
          builder: (context, snapshot){
            if(snapshot.hasData){
              Timer(const Duration(seconds: 8), onCloseDialog);
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(snapshot.data, textScaleFactor: 1.1,),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        color: Colors.green[800],
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            new MaterialPageRoute(builder: (context) => new MyApp()),
                          );
                        },
                        child: Text(
                          "Volver".toUpperCase(),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Esperando respuesta de $machine", textScaleFactor: 1.4,),
                  Container(height: 50,),
                  Transform.scale(
                    scale: 1.4,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/back.svg',
          color: Colors.white,
        ),
        onPressed: () {
          count = 1;
          Navigator.pushReplacement(
            context,
            new MaterialPageRoute(builder: (context) => new MyApp()),
          );
        }
      ),
    );
  }
}


class HowComerce extends StatelessWidget {
  final int pay;

  const HowComerce({Key key,this.pay}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // each product have a color
      backgroundColor: Colors.green[100],
      appBar: buildAppBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Ingrese el tipo de sistema a usar:", textScaleFactor: 1.5,),
            Container(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  color: Colors.green[800],
                  onPressed: () {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new Ticket(pay: pay,machine: "Redelcom",)),
                    );
                  },
                  child: Text(
                    "Redelcom".toUpperCase(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  color: Colors.green[800],
                  onPressed: () {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new Ticket(pay: pay,machine: "Transbank",)),
                    );
                  },
                  child: Text(
                    "Transbank".toUpperCase(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
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
        }
      ),
    );
  }
}

class Ticket extends StatelessWidget {
  final int pay;
  final String machine;

  const Ticket({Key key,this.pay, this.machine}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // each product have a color
      backgroundColor: Colors.green[100],
      appBar: buildAppBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("¿Quiere imprimir ticket?", textScaleFactor: 1.5,),
            Container(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  color: Colors.green[800],
                  onPressed: () {
                    if(machine == "Transbank"){
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new FutureResponse(pay: sendPay(pay.toString(), "true"),machine: machine,)),
                      );
                    }
                    else{
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new FutureResponse(pay: sendPayRedelcom2(pay.toString(), "true"),machine: machine,)),
                      );
                    }
                  },
                  child: Text(
                    "Si".toUpperCase(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  color: Colors.green[800],
                  onPressed: () {
                    if(machine=="Transbank"){
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new FutureResponse(pay: sendPay(pay.toString(), "false"),machine: machine,)),
                      );
                    }
                    else{
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new FutureResponse(pay: sendPayRedelcom2(pay.toString(), "false"),machine: machine,)),
                      );
                    }
                  },
                  child: Text(
                    "No".toUpperCase(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
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
          }
      ),
    );
  }
}