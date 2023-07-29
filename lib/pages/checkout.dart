import 'dart:convert';
import 'package:kuis_ecommerce/data/model.dart';
import 'package:kuis_ecommerce/data/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kuis_ecommerce/pages/product_page.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../data/colors.dart';
import '../data/theme.dart';
import '../data/urls.dart';
import 'home.dart';

class CheckoutPage extends StatefulWidget {
  final String? amount;
  final List listQty;
  const CheckoutPage({Key? key, required this.amount, required this.listQty}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> with WidgetsBindingObserver {
  final TextEditingController _controllerAddress = TextEditingController();
  bool _isLoad = false;

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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.container,
          appBar: AppBar(
            backgroundColor: AppColors.red_accent,
            elevation: 0,
            titleSpacing: 0,
            title: const Text('Halaman Checkout',
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
                    margin: EdgeInsets.only(
                        top: defaultMargin,
                        left: 28.0,
                        right: 28.0
                    ),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Produk',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'PoppinsSemiBold'
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: FutureBuilder(
                            future: getTransactionItems("", "= 0", "<> 0"),
                            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                              if (snapshot.data == null) {
                                return Container(
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
                                );
                              } else {
                                return ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                                          return ProductPage(product_id: snapshot.data[index].id);
                                        }));
                                      },
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: 60,
                                            height: 60,
                                            margin: EdgeInsets.only(bottom: 16.0, right: 18.0),
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
                                              padding: const EdgeInsets.all(0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    snapshot.data[index].product,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black54,
                                                        fontFamily: 'PoppinsRegular'),
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  Text(
                                                    // "IDR. ${snapshot.data[index].price}",
                                                    "${currencyFormatter.format(double.parse(snapshot.data[index].price.toString())).toString().replaceAll('IDR', 'IDR. ')}",
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: AppColors.red_accent,
                                                        fontFamily: 'PoppinsRegular'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                                            child: Text(
                                              "X${widget.listQty[index]}",
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.black54,
                                                  fontFamily: 'PoppinsMedium'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: defaultMargin, vertical: 16.0),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rincian',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'PoppinsSemiBold'
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        TextFormField(
                          controller: _controllerAddress,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: "Alamat Lengkap",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          // onEditingComplete: () => _focusNodeEmail.requestFocus(),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter address.";
                              // } else if (!_boxAccounts.containsKey(value)) {
                              //   return "Username is not registered.";
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: defaultMargin),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pembayaran',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'PoppinsSemiBold'
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'PoppinsRegular'
                              ),
                            ),
                            Text(
                              "${currencyFormatter.format(double.parse(widget.amount.toString())).toString().replaceAll('IDR', '')}",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'PoppinsMedium'
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'PoppinsRegular'
                              ),
                            ),
                            Text(
                              '0,00',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'PoppinsMedium'
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'PoppinsRegular'
                              ),
                            ),
                            Text(
                              '0,00',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'PoppinsMedium'
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Divider(
                          thickness: 1,
                          color: Color(0xff2E3141),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'PoppinsMedium'
                              ),
                            ),
                            Text(
                              "${currencyFormatter.format(double.parse(widget.amount.toString())).toString().replaceAll('IDR', 'IDR. ')}",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'PoppinsSemiBold'
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder(
                    future: getTransactionItems("", "= 0", "<> 0"),
                    builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: defaultMargin, vertical: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 54,
                                  child: TextButton(
                                    onPressed: () async {
                                      if(_controllerAddress.text=="") {
                                        showToast(context, "Mohon isi alamat lengkap");
                                      } else {
                                        setState(() {
                                          _isLoad = true;
                                        });

                                        bool isEmptyStock = false;
                                        var listStock = [];
                                        var listSold = [];
                                        for (int i = 0; i < snapshot.data.length; i++) {
                                          String url = Strings.URL_ALL_DATA;
                                          Map<String, String> maps = {
                                            'table': "products",
                                            'where': "true",
                                            'value': "id = ${snapshot.data[i].products_id}",
                                          };

                                          var body = json.encode(maps);
                                          var response = await http.post(Uri.parse(url),
                                              headers: {"Content-Type": "application/json"},
                                              body: body
                                          );

                                          String? statusCode = "${response.statusCode}";
                                          if(statusCode.toString()=="200") {
                                            var data = json.decode(response.body);
                                            listStock.add(int.parse(data["data"][0]["stock"]));
                                            listSold.add(int.parse(data["data"][0]["sold"]));
                                            if(data["data"][0]["stock"].toString() == "0") {
                                              isEmptyStock = true;

                                              String? id_user = await getdata("id");
                                              String urlLogin = Strings.URL_DELETE_ITEM;
                                              Map<String, String> mapLogin = {
                                                'users_id': id_user.toString(),
                                                'id': snapshot.data[i].id
                                              };

                                              postRequest(urlLogin, mapLogin).then((result) {
                                                String? statusCode = "${result.statusCode}";
                                                if(statusCode.toString()=="200") {
                                                  print("items deleted");
                                                }
                                              });
                                            }
                                          }
                                        }

                                        if(isEmptyStock == true) {
                                          showToast(context, "Terdapat produk yang habis. Mohon checkout ulang.");
                                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            return HomePage();
                                          }));
                                        } else {
                                          var id_user = await getdata("id");
                                          String urlLogin = Strings.URL_ADD_TRANSACTIONS;
                                          Map<String, String> mapLogin = {
                                            'users_id': id_user.toString(),
                                            'total_price': widget.amount.toString(),
                                            'shipping_price': "0",
                                            'address': _controllerAddress.text,
                                            'status': "1",
                                            'payment': "MANUAL"
                                          };

                                          postRequest(urlLogin, mapLogin).then((result) async {
                                            String? statusCode = "${result.statusCode}";

                                            if(statusCode.toString()=="200") {
                                              var data = json.decode(result.body);
                                              int items = 0;
                                              int stock = 0;

                                              //UPDATE TRANSACTION ITEMS
                                              for (int i = 0; i < snapshot.data.length; i++) {
                                                String urlLogin = Strings.URL_UPDATE;
                                                Map<String, String> mapLogin = {
                                                  'table': "transaction_items",
                                                  'id': snapshot.data[i].id,
                                                  'quantity': widget.listQty[i].toString(),
                                                  'transactions_code': data["data"]["transaction_code"].toString(),
                                                  'transactions_id': data["data"]["id"].toString()
                                                };

                                                var body = json.encode(mapLogin);
                                                var response = await http.post(Uri.parse(urlLogin),
                                                    headers: {"Content-Type": "application/json"},
                                                    body: body
                                                );

                                                String? statusCode = "${response.statusCode}";
                                                if(statusCode.toString()=="200") {
                                                  items = 1;
                                                }

                                                // postRequest(urlLogin, mapLogin).then((result) {
                                                //   String? statusCode = "${result.statusCode}";
                                                //   if(i + 1 == snapshot.data.length) {
                                                //     setState(() {
                                                //       _isLoad = false;
                                                //     });
                                                //
                                                //     if(statusCode.toString()=="200") {
                                                //       showToast(context, "Checkout berhasil!");
                                                //       Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                //         return HomePage();
                                                //       }));
                                                //     } else {
                                                //       showToast(context, "Checkout gagal, coba lagi nanti");
                                                //     }
                                                //   }
                                                // });
                                              }

                                              //UPDATE STOK AND SOLD
                                              for (int i = 0; i < snapshot.data.length; i++) {
                                                String urlLogin2 = Strings.URL_UPDATE;
                                                Map<String, String> mapLogin2 = {
                                                  'table': "products",
                                                  'id': snapshot.data[i].products_id,
                                                  'stock': (int.parse(listStock[i].toString()) - int.parse(widget.listQty[i].toString())).toString(),
                                                  'sold': (int.parse(listSold[i].toString()) + int.parse(widget.listQty[i].toString())).toString(),
                                                };

                                                var body = json.encode(mapLogin2);
                                                var response = await http.post(Uri.parse(urlLogin2),
                                                    headers: {"Content-Type": "application/json"},
                                                    body: body
                                                );

                                                String? statusCode = "${response.statusCode}";
                                                if(statusCode.toString()=="200") {
                                                  stock = 1;
                                                }

                                                // postRequest(urlLogin, mapLogin).then((result) {
                                                //   String? statusCode = "${result.statusCode}";
                                                //   if(i + 1 == snapshot.data.length) {
                                                //     setState(() {
                                                //       _isLoad = false;
                                                //     });
                                                //
                                                //     if(statusCode.toString()=="200") {
                                                //       showToast(context, "Checkout berhasil!");
                                                //       Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                //         return HomePage();
                                                //       }));
                                                //     } else {
                                                //       showToast(context, "Checkout gagal, coba lagi nanti");
                                                //     }
                                                //   }
                                                // });
                                              }

                                              setState(() {
                                                _isLoad = false;
                                              });

                                              if(items+stock == 2) {
                                                showToast(context, "Checkout berhasil!");
                                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                  return HomePage();
                                                }));
                                              } else {
                                                showToast(context, "Checkout gagal, coba lagi nanti");
                                              }
                                            } else {
                                              showToast(context, "Checkout gagal, coba lagi nanti");
                                            }
                                          });
                                        }
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: AppColors.red_accent,
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle_outline, size: 25, color: Colors.white,),
                                        SizedBox(width: 10,),
                                        Text(
                                          'Checkout',
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
                              ),
                            ],
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ]
            ),
          ),
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