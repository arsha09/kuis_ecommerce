import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:kuis_ecommerce/data/model.dart';
import 'package:kuis_ecommerce/data/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kuis_ecommerce/pages/checkout.dart';
import 'package:kuis_ecommerce/pages/product_all.dart';
import 'package:lottie/lottie.dart';
import 'package:collection/collection.dart';

import '../data/colors.dart';
import '../data/theme.dart';
import '../data/urls.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with WidgetsBindingObserver {
  int amount = 0;
  int counter = 0;
  var listQty = [];
  var listPrice = [];
  var listAmount = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    print("oncreate");
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("onresume!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getTransactionItems("", "= 0", "<> 0"),
      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return Scaffold(
            backgroundColor: AppColors.container,
            appBar: AppBar(
              backgroundColor: AppColors.red_accent,
              elevation: 0,
              titleSpacing: 0,
              title: Text('Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PoppinsMedium',
                    fontSize: 20.0,
                  )
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.white,
                  size: 25,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                  children: <Widget>[
                    Container(
                      child: ListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: const <Widget>[
                          shimmerCabang(),
                          shimmerCabang(),
                          shimmerCabang(),
                          shimmerCabang(),
                          shimmerCabang(),
                          shimmerCabang(),
                          SizedBox(
                            width: 16.0,
                          ),
                        ],
                      ),
                    )
                  ]
              ),
            ),
          );
        } else {
          final list = [0];
          for (int i = 0; i < snapshot.data.length; i++) {
            list.add(int.parse(snapshot.data[i].price));
          }
          final sum = list.sum;
          print(sum.toString());
          amount = sum;

          if(listQty.length==0) {
            for (int i = 0; i < snapshot.data.length; i++) {
              listQty.add(int.parse(snapshot.data[i].quantity));
              listPrice.add(int.parse(snapshot.data[i].price));
              listAmount.add(int.parse(snapshot.data[i].price));
              //sum += int.parse(snapshot.data[i].price);
            }
          }

          return snapshot.data.length < 1 ?
          Scaffold(
            backgroundColor: AppColors.container,
            appBar: AppBar(
              backgroundColor: AppColors.red_accent,
              elevation: 0,
              titleSpacing: 0,
              title: Text('Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PoppinsMedium',
                    fontSize: 20.0,
                  )
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.white,
                  size: 25,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: 50),
                          Lottie.asset("assets/lottie/not_found.json", height: 150),
                          const Text(
                            'Tidak ada produk\ndi dalam keranjang',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black26,
                              fontFamily: 'PoppinsMedium',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10,),
                          ElevatedButton(
                            onPressed: () {
                              // Navigator.push(context, MaterialPageRoute(builder: (context) {
                              //   return const AllProductPage(model: "all", where: "", value: "",);
                              // }));
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                return const AllProductPage(model: "all", where: "", value: "",);
                              }));
                            },
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    )
                                )
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                'Cari produk',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontFamily: 'PoppinsMedium'
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ]
              ),
            ),
          ) :
          Scaffold(
            backgroundColor: AppColors.container,
            appBar: AppBar(
              backgroundColor: AppColors.red_accent,
              elevation: 0,
              titleSpacing: 0,
              title: Text('Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PoppinsMedium',
                    fontSize: 20.0,
                  )
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.white,
                  size: 25,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            body: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(16.0),
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.bg_grey,
                                boxShadow: [
                                  BoxShadow(color: AppColors.bg_grey),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 75,
                                    height: 75,
                                    margin: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                          image: NetworkImage("${Strings.URL_IMG}${snapshot.data[index].url}"),
                                          fit: BoxFit.cover),
                                      boxShadow: [
                                        BoxShadow(color: AppColors.container),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            snapshot.data[index].category,
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.black54,
                                                fontFamily: 'PoppinsRegular'),
                                          ),
                                          Text(
                                            snapshot.data[index].product,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black54,
                                                fontFamily: 'PoppinsMedium'),
                                          ),
                                          Text(
                                            // "IDR. ${snapshot.data[index].price}",
                                            "${currencyFormatter.format(double.parse(snapshot.data[index].price.toString())).toString().replaceAll('IDR', 'IDR. ')}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                color: AppColors.red_accent,
                                                fontFamily: 'PoppinsRegular'),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Quantity : ",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                  fontFamily: 'PoppinsRegular',
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => setState(() {
                                                  listQty[index] == 1 ? print('counter at 0') : listQty[index]--;
                                                  (listAmount.where((c) => c == int.parse(snapshot.data[index].price))).length == 1 ? print('counter at 0') : listAmount.remove(int.parse(snapshot.data[index].price));
                                                }),
                                                child: Icon(CupertinoIcons.minus_square_fill, color: AppColors.red_accent,),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                '${listQty[index]}',
                                                style: TextStyle(
                                                    fontFamily: 'PoppinsRegular'),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                onTap: () {setState(() {
                                                  print('set ${listQty[index]} != ${int.parse(snapshot.data[index].stock)}');
                                                  if(listQty[index] != int.parse(snapshot.data[index].stock)) {
                                                    listQty[index]++;
                                                    listAmount.add(int.parse(snapshot.data[index].price));
                                                  }
                                                  // listQty[index] == int.parse(snapshot.data[index].stock) ? print('counter max') : listQty[index]++;
                                                  // listQty[index] == int.parse(snapshot.data[index].stock) ? print('counter max') : listAmount.add(int.parse(snapshot.data[index].price));
                                                });},
                                                child: Icon(CupertinoIcons.plus_app_fill, color: AppColors.red_accent,),
                                              ),
                                            ],
                                          ),
                                          // Text("${listQty[index]} ${snapshot.data[index].stock}"),
                                          // Text("${listAmount.reduce((a, b) => a + b)}"),
                                          // Text("${listPrice} ${listAmount} ${listQty} ${listAmount.reduce((a, b) => a + b)} ${listAmount.where((c) => c == int.parse(snapshot.data[index].price)).length}")
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    iconSize: 25.0,
                                    icon: Icon(Icons.cancel_outlined, color: Colors.grey,),
                                    onPressed: () async {
                                      showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) => AlertDialog(
                                          title: const Text('Hapus dari keranjang'),
                                          content: const Text('Anda yakin ingin menghapus produk ini dari keranjang?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                String? id_user = await getdata("id");
                                                String urlLogin = Strings.URL_DELETE_ITEM;
                                                Map<String, String> mapLogin = {
                                                  'users_id': id_user.toString(),
                                                  'id': snapshot.data[index].id
                                                };

                                                postRequest(urlLogin, mapLogin).then((result) {
                                                  String? statusCode = "${result.statusCode}";
                                                  // setState(() {
                                                  //   _isLoad = false;
                                                  // });
                                                  var data = json.decode(result.body);
                                                  if(statusCode.toString()=="200") {
                                                    showToast(context, "Produk dihapus dari keranjang");
                                                    //showSuccessDialog(qty);
                                                    Navigator.pop(context);
                                                    listPrice.removeWhere((c) => c == int.parse(snapshot.data[index].price));
                                                    listAmount.removeWhere((c) => c == int.parse(snapshot.data[index].price));
                                                    setState(() {});
                                                  } else {
                                                    showToast(context, data["message"].toString());
                                                  }
                                                });
                                              },
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                    ),
                    SizedBox(height: 150,)
                  ]
              ),
            ),

            bottomSheet: Container(
              height: 150,
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'PoppinsMedium'),
                          //style: primaryTextStyle,
                        ),
                        Text(
                          // 'IDR. ${amount}',
                          "${currencyFormatter.format(double.parse(listAmount.reduce((a, b) => a + b).toString())).toString().replaceAll('IDR', 'IDR. ')}",
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PoppinsSemiBold'
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 0.3,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return CheckoutPage(amount: listAmount.reduce((a, b) => a + b).toString(), listQty: listQty);
                        }));
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.red_accent,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Continue to Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: "PoppinsMedium",
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}