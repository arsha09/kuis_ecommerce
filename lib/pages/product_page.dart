import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kuis_ecommerce/pages/product_add.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../data/colors.dart';
import '../data/model.dart';
import '../data/theme.dart';
import '../data/urls.dart';
import '../data/utils.dart';
import 'admin.dart';
import 'cart.dart';

class ProductPage extends StatefulWidget {
  final String product_id;
  const ProductPage({Key? key, required this.product_id}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> with WidgetsBindingObserver {
  List images = [
    'assets/image_shoes.png',
    'assets/image_shoes2.png',
    'assets/image_shoes3.png',
  ];

  List familiarShoes = [
    'assets/image_shoes.png',
    'assets/image_shoes2.png',
    'assets/image_shoes3.png',
    'assets/image_shoes4.png',
    'assets/image_shoes5.png',
    'assets/image_shoes6.png',
    'assets/image_shoes7.png',
    'assets/image_shoes8.png',
  ];

  bool _isLoad = false;
  int currentIndex = 0;
  String? roles;
  List<String> cardList = [];

  @override
  void initState() {
    getdata("roles").then((value) {setState(() {roles = value.toString();});});
    super.initState();
  }

  Future<List<ContentUpdate>> getContentBanner(String product_id) async {
    String url = Strings.URL_PRODUCT_GALLERIES;
    Map<String, String> map = {
      'products_id': product_id
    };

    var body = json.encode(map);
    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body
    );

    print("$map");
    print("${response.statusCode}");
    print("${response.body}");

    var responseData = json.decode(response.body);
    var data = responseData['data'];

    List<ContentUpdate> contents = [];
    cardList.clear();
    for (var singleCabang in data) {
      cardList.add("${Strings.URL_IMG}${singleCabang["url"].toString()}");
    }

    return contents;
  }

  Future<void> addItems(String qty) async {
    String? id_user = await getdata("id");
    String urlLogin = Strings.URL_ADD_ITEM;
    Map<String, String> mapLogin = {
      'users_id': id_user.toString(),
      'products_id': widget.product_id,
      'quantity': qty
    };

    postRequest(urlLogin, mapLogin).then((result) {
      String? statusCode = "${result.statusCode}";
      setState(() {
        _isLoad = false;
      });
      var data = json.decode(result.body);
      if(statusCode.toString()=="200") {
        showSuccessDialog(qty);
      } else {
        showToast(context, data["message"].toString());
      }
    });
  }

  Future<void> showSuccessDialog(String qty) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => Container(
        width: MediaQuery.of(context).size.width - (2 * defaultMargin),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: AppColors.red_accent,
                    ),
                  ),
                ),
                // Image.asset(
                //   'assets/icon_success.png',
                //   width: 100,
                // ),
                Lottie.asset("assets/lottie/check.json", height: 150),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'Berhasil!',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.red_accent,
                    fontFamily: 'PoppinsMedium',
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'Produk berhasil ditambahkan\nke dalam ${qty=="1" ? "keranjang" : "favorit"}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontFamily: 'PoppinsRegular',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Visibility(
                  visible: qty=="1",
                  child: Container(
                    width: 154,
                    height: 44,
                    child: TextButton(
                      onPressed: () {
                        // Navigator.push(context, MaterialPageRoute(builder: (context) {
                        //   return const CartPage();
                        // }));
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                          return const CartPage();
                        }));
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.red_accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Lihat Keranjang',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'PoppinsMedium',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // WishlistProvider wishlistProvider = Provider.of<WishlistProvider>(context);
    // CartProvider cartProvider = Provider.of<CartProvider>(context);

    Widget indicator(int index) {
      return Container(
        width: currentIndex == index ? 16 : 4,
        height: 4,
        margin: EdgeInsets.symmetric(
          horizontal: 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: currentIndex == index ? AppColors.red_accent : Color(0xffC4C4C4),
        ),
      );
    }

    Widget familiarShoesCard(String imageUrl) {
      return Container(
        width: 54,
        height: 54,
        margin: EdgeInsets.only(
          right: 16,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imageUrl),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    Widget header() {
      int index = -1;

      return Column(
        children: [
          // FutureBuilder(
          //   future: getContentBanner(),
          //   builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          //     if (snapshot.data == null) {
          //       return Container(
          //         margin: const EdgeInsets.all(16.0),
          //         child: SizedBox(
          //           height: 110,
          //           width: double.infinity,
          //           child: ClipRRect(
          //             borderRadius: BorderRadius.circular(10),
          //             child: Shimmer.fromColors(
          //               baseColor: Colors.grey[300]!,
          //               highlightColor: Colors.white,
          //               child: Container(
          //                 color: Colors.grey,
          //               ),
          //             ),
          //           ),
          //         ),
          //       );
          //     } else {
          //       return Container(
          //         margin: EdgeInsets.only(top: 30.0),
          //         child: Center(
          //           child: Column(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               CarouselSlider(
          //                 options: CarouselOptions(
          //                     //autoPlay: true,
          //                     autoPlayInterval: Duration(seconds: 10),
          //                     autoPlayAnimationDuration: Duration(milliseconds: 800),
          //                     autoPlayCurve: Curves.fastOutSlowIn,
          //                     pauseAutoPlayOnTouch: true,
          //                     enlargeCenterPage: true,
          //                     viewportFraction: 0.8,
          //                     height: 100,
          //                     onPageChanged: (index, reason) {
          //                       setState(() {
          //                         _currentIndex = index;
          //                       });
          //                     }),
          //                 items: cardList.map((item) {
          //                   return ItemCard(title: item.toString(), key: null,);
          //                 }).toList(),
          //               ),
          //               Row(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 children: map<Widget>(cardList, (index, url) {
          //                   return Container(
          //                     width: _currentIndex == index ? 20 : 6.0,
          //                     height: 6.0,
          //                     margin:
          //                     EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          //                     decoration: BoxDecoration(
          //                       borderRadius: BorderRadius.circular(5),
          //                       color: _currentIndex == index
          //                           ? Colors.teal
          //                           : Colors.teal.withOpacity(0.3),
          //                     ),
          //                   );
          //                 }),
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     }
          //   },
          // ),
          SizedBox(
            //height: 300,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                FutureBuilder(
                  future: getContentBanner(widget.product_id),
                  builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Container(
                        margin: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          height: 400,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.white,
                              child: Container(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return CarouselSlider(
                        options: CarouselOptions(
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 10),
                            autoPlayAnimationDuration: Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            pauseAutoPlayOnTouch: true,
                            enlargeCenterPage: true,
                            viewportFraction: 1,
                            height: 400,
                            onPageChanged: (index, reason) {
                              setState(() {
                                currentIndex = index;
                              });
                            }),
                        items: cardList.map((item) {
                          //return ItemCard(title: item.toString(), key: null,);
                          return Image.network(
                            item.toString(),
                            //width: 350,
                            width: MediaQuery.of(context).size.width,
                            // height: MediaQuery.of(context).size.height,
                            fit: BoxFit.cover,
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
                // CarouselSlider(
                //   items: images.map((image) =>
                //       Image.asset(
                //           image.toString(),
                //           width: MediaQuery.of(context).size.width,
                //           //height: 310,
                //           fit: BoxFit.cover,
                //       ),
                //     ).toList(),
                //   // items: cardList.map((item) {
                //   //   return ItemCard(title: item.toString(), key: null,);
                //   // }).toList(),
                //   options: CarouselOptions(
                //     initialPage: 0,
                //     onPageChanged: (index, reason) {
                //       setState(() {
                //         currentIndex = index;
                //       });
                //     },
                //   ),
                // ),
                // Container(
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.vertical(
                //       top: Radius.circular(50),
                //     ),
                //     color: Colors.white,
                //   ),
                //   child: SizedBox(height: 20,),
                // ),
              ],
            ),
          ),
          // SizedBox(
          //   height: 20,
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: images.map((e) {
          //     index++;
          //     return indicator(index);
          //   }).toList(),
          // ),
        ],
      );
    }

    Widget content(data) {
      int index = -1;

      return Container(
        width: double.infinity,
        //margin: EdgeInsets.only(top: 17),
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.vertical(
          //   top: Radius.circular(24),
          // ),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // NOTE: HEADER
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: cardList.map((e) {
                  index++;
                  return indicator(index);
                }).toList(),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                // top: defaultMargin,
                top: 16.0,
                left: defaultMargin,
                right: defaultMargin,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data[0].category,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontFamily: 'PoppinsRegular'
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          data[0].name,
                          style: TextStyle(
                            fontSize: 18,
                            color: roles == "admin" ? AppColors.bg_navy : AppColors.red_accent,
                            fontFamily: 'PoppinsMedium',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10,),
                  FutureBuilder<String?>(
                      future: getdata("roles"),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data=="customer") {
                            return RawMaterialButton(
                              onPressed: () {
                                addItems("0");
                              },
                              fillColor: Colors.red,
                              child: Icon(
                                Icons.favorite,
                                size: 25.0,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.all(15.0),
                              shape: CircleBorder(),
                            );
                          }
                        }
                        return Container();
                      }
                  ),
                ],
              ),
            ),

            // NOTE: PRICE
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                top: 20,
                left: defaultMargin,
                right: defaultMargin,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.container,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stok : ${data[0].stock.toString()}',
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'PoppinsRegular'
                    ),
                  ),
                  Text(
                    // "IDR. ${data[0].price}",
                    "${currencyFormatter.format(double.parse(data[0].price.toString())).toString().replaceAll('IDR', 'IDR. ')}",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'PoppinsRegular'
                    ),
                  ),
                ],
              ),
            ),

            // NOTE: DESCRIPTION
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                top: defaultMargin,
                left: defaultMargin,
                right: defaultMargin,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontFamily: 'PoppinsMedium'
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    data[0].description,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'PoppinsRegular'
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            // NOTE: FAMILIAR SHOES
            // Container(
            //   width: double.infinity,
            //   margin: EdgeInsets.only(
            //     top: defaultMargin,
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Padding(
            //         padding: EdgeInsets.symmetric(
            //           horizontal: defaultMargin,
            //         ),
            //         child: Text(
            //           'Fimiliar Shoes',
            //           style: TextStyle(
            //             fontSize: 14,
            //             color: Colors.black87,
            //             fontFamily: 'PoppinsMedium'
            //           ),
            //         ),
            //       ),
            //       SizedBox(
            //         height: 12,
            //       ),
            //       SingleChildScrollView(
            //         scrollDirection: Axis.horizontal,
            //         child: Row(
            //           children: familiarShoes.map((image) {
            //             index++;
            //             return Container(
            //               margin: EdgeInsets.only(
            //                   left: index == 0 ? defaultMargin : 0),
            //               child: familiarShoesCard(image),
            //             );
            //           }).toList(),
            //         ),
            //       )
            //     ],
            //   ),
            // ),

            // NOTE: BUTTONS
            FutureBuilder(
                future: getProducts("where", "id", "asc", "", "products.id", widget.product_id),
                builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(defaultMargin),
                      child: Column(
                        children: [
                          Container(
                            height: 54,
                            child: TextButton(
                              onPressed: () {
                                if (roles=="customer") {
                                  if(snapshot.data[0].stock == "0") {
                                    showToast(context, "Mohon maaf stok habis");
                                  } else {
                                    addItems("1");
                                  }
                                } else {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return AddProductPage(
                                      code: "edit",
                                      id: snapshot.data[0].id,
                                      name: snapshot.data[0].name,
                                      price: snapshot.data[0].price,
                                      stock: snapshot.data[0].stock,
                                      tags: snapshot.data[0].tags,
                                      categories: snapshot.data[0].categories,
                                      category: snapshot.data[0].category,
                                      desc: snapshot.data[0].description,
                                      image: snapshot.data[0].url,
                                    );
                                    //return ImageUpload();
                                  }));
                                }
                              },
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: roles == "admin" ? AppColors.bg_navy : snapshot.data[0].stock == "0" ? AppColors.borderdanger : AppColors.red_accent,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(roles == "customer" ? Icons.add_shopping_cart : Icons.edit_note_rounded, size: 25, color: Colors.white,),
                                  SizedBox(width: 10,),
                                  Text(
                                    roles == "customer" ? 'Add to Cart' : 'Edit Produk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontFamily: "PoppinsMedium",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Visibility(
                            visible: roles == "admin",
                            child: Container(
                              height: 54,
                              child: OutlinedButton(
                                onPressed: () async {
                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('Hapus produk'),
                                      content: const Text('Anda yakin ingin menghapus produk ini?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            setState(() {
                                              _isLoad = true;
                                            });

                                            DateTime now = DateTime.now();
                                            String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);

                                            String urlLogin = Strings.URL_UPDATE;
                                            Map<String, String> mapLogin = {
                                              'table': "products",
                                              'id': snapshot.data[0].id,
                                              'is_active': '0',
                                              'deleted_at': formattedDate
                                            };
                                            postRequest(urlLogin, mapLogin).then((result) {
                                              String? statusCode = "${result.statusCode}";
                                              setState(() {
                                                _isLoad = false;
                                              });
                                              if(statusCode.toString()=="200") {
                                                //var data = json.decode(result.body);
                                                showToast(context, "Produk berhasil dihapus");
                                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                  return AdminPage();
                                                }));
                                              } else {
                                                showToast(context, "Hapus produk gagal, coba lagi nanti");
                                              }
                                            });
                                          },
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: AppColors.bg_navy, width: 1),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete_outline, size: 25, color: AppColors.bg_navy,),
                                    SizedBox(width: 10,),
                                    Text(
                                      'Hapus Produk',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.bg_navy,
                                        fontFamily: "PoppinsMedium",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Container();
                }
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          //backgroundColor: backgroundColor6,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            title: Text('Detail Produk',
                style: TextStyle(
                  color: roles == "admin" ? AppColors.bg_navy : AppColors.red_accent,
                  fontFamily: 'PoppinsMedium',
                  fontSize: 16.0,
                )
            ),
            leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: roles == "admin" ? AppColors.bg_navy : AppColors.red_accent,
                size: 25,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // body: ListView(
          //   children: [
          //     header(),
          //     content(),
          //   ],
          // ),
          body: FutureBuilder(
            future: getProducts("where", "id", "asc", "", "products.id", widget.product_id),
            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: double.infinity,
                        height: 250,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.white,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      shimmerList(),
                      shimmerList(),
                      shimmerList(),
                      shimmerList(),
                      shimmerList(),
                      shimmerList(),
                      SizedBox(
                        width: 16.0,
                      ),
                    ],
                  ),
                );
              } else {
                return snapshot.data.length < 1 ?
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      Lottie.asset("assets/lottie/not_found.json", height: 150),
                      const Text(
                        'Mohon maaf\ndata tidak ditemukan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black26,
                          fontFamily: 'PoppinsMedium',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ) :
                ListView(
                  children: [
                    header(),
                    content(snapshot.data),
                  ],
                );
              }
            },
          )
        ),
        Positioned.fill(
          child: Stack(
            children: [
              Visibility(
                visible: _isLoad ? true : false,
                child: Container(
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.5)
                  ),
                ),
              ),
              Center(
                child: _isLoad ? const CircularProgressIndicator() : Container(),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class ItemCard extends StatelessWidget {
  final String title;

  const ItemCard({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
            image: NetworkImage(title),
            fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(color: AppColors.container),
        ],
      ),
    );
  }
}
