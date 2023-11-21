import 'package:flutter/material.dart';

class Product {
  final String image, title, description;
  final int price, size, id;
  final Color color;
  Product({
    this.id,
    this.image,
    this.title,
    this.price,
    this.description,
    this.size,
    this.color,
  });
}

List<Product> products = [
  /*Product(
      id: 1,
      title: "Office Code",
      price: 234,
      size: 12,
      description: dummyText,
      image: "assets/images/bag_1.png",
      color: Color(0xFF3D82AE)),
  Product(
      id: 2,
      title: "Belt Bag",
      price: 234,
      size: 8,
      description: dummyText,
      image: "assets/images/bag_2.png",
      color: Color(0xFFD3A984)),
  Product(
      id: 3,
      title: "Hang Top",
      price: 234,
      size: 10,
      description: dummyText,
      image: "assets/images/bag_3.png",
      color: Color(0xFF989493)),
  Product(
      id: 4,
      title: "Old Fashion",
      price: 234,
      size: 11,
      description: dummyText,
      image: "assets/images/bag_4.png",
      color: Color(0xFFE6B398)),
  Product(
      id: 5,
      title: "Office Code",
      price: 234,
      size: 12,
      description: dummyText,
      image: "assets/images/bag_5.png",
      color: Color(0xFFFB7883)),
  Product(
    id: 6,
    title: "Office Code",
    price: 234,
    size: 12,
    description: dummyText,
    image: "assets/images/bag_6.png",
    color: Color(0xFFAEAEAE),
  ),

  Product(
      id: 12,
      title: "Siderall AutoPay 1",
      price: 190000,
      size: 100,
      description: "Kisco personalizado para autocompras de escritorio",
      image: "assets/images/sid2.png",
      color: Color(0xFFFFA8B0)
  ),
  Product(
      id: 7,
      title: "Siderall AutoPay 2",
      price: 200000,
      size: 100,
      description: "Kisco personalizado para autocompras con soporte",
      image: "assets/images/sid3.png",
      color: Color(0xFFE6B398)
  ),
  Product(
      id: 8,
      title: "Siderall Ticket",
      price: 199990,
      size: 100,
      description: "Kisco personalizado para impresión de tickets",
      image: "assets/images/sid4.png",
      color: Color(0xFF989493)
  ),
  Product(
      id: 9,
      title: "Siderall Gabinete",
      price: 299990,
      size: 100,
      description: "Kisco tipo gabinete",
      image: "assets/images/sid5.png",
      color: Color(0xFFA3D190)
  ),
  Product(
      id: 10,
      title: "Siderall Impresión",
      price: 149990,
      size: 100,
      description: "Kisco personalizado para impresiones generales color azul",
      image: "assets/images/sid6.png",
      color: Color(0xFF3D82AE)
  ),
  Product(
      id: 11,
      title: "Siderall Kiosk",
      price: 219990,
      size: 100,
      description: "Kisco personalizado para impresión con sistema antivandálico",
      image: "assets/images/sid7.png",
      color: Color(0xFFD3A984)
  ),*/
  Product(
      id: 13,
      title: "Hamburguesa",
      price: 5990,
      size: 200,
      description: "Hamburguesa directamente emitida a tu paladar",
      image: "assets/images/hamburguesa.png",
      color: Color(0xFFFFA8B0)
  ),
  Product(
      id: 14,
      title: "Completos",
      price: 3990,
      size: 15,
      description: "Completo italiano",
      image: "assets/images/completos.png",
      color: Color(0xFFE6B398),
  ),
  Product(
      id: 15,
      title: "Pizza",
      price: 17990,
      size: 250,
      description: "Pizza con pepperoni, queso mozarella. Masa delgada",
      image: "assets/images/pizza.png",
      color: Color(0xFF989493)
  ),
  Product(
      id: 16,
      title: "Papas Fritas",
      price: 4990,
      size: 500,
      description: "Papas fritas de 500 gramos para compartir (2 personas)",
      image: "assets/images/papasfritas.png",
      color: Color(0xFFA3D190)
  ),
  Product(
      id: 17,
      title: "Waffles",
      price: 7990,
      size: 170,
      description: "Waffles con frutilla y miel",
      image: "assets/images/waffles.png",
      color: Color(0xFF3D82AE)
  ),
  Product(
      id: 18,
      title: "Bebidas",
      price: 1490,
      size: 237,
      description: "Tu bebida favorita en 237ml",
      image: "assets/images/bebidas.png",
      color: Color(0xFFD3A984)
  ),
  Product(
      id: 19,
      title: "helados",
      price: 1890,
      size: 200,
      description: "Un helado de postre. El sabor que tu elijas",
      image: "assets/images/helados.png",
      color: Color(0xFFD3A984)
  ),
];

String dummyText =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since. When an unknown printer took a galley.";
