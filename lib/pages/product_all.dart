import 'dart:convert';
import 'package:kuis_ecommerce/data/model.dart';
import 'package:kuis_ecommerce/data/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kuis_ecommerce/pages/product_page.dart';
import 'package:lottie/lottie.dart';

import '../data/colors.dart';
import '../data/urls.dart';

class AllProductPage extends StatefulWidget {
  final String model;
  final String where;
  final String value;
  const AllProductPage({Key? key, required this.model, required this.where, required this.value}) : super(key: key);

  @override
  _AllProductPageState createState() => _AllProductPageState();
}

class _AllProductPageState extends State<AllProductPage> with WidgetsBindingObserver {

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
    return Scaffold(
      backgroundColor: AppColors.container,
      appBar: AppBar(
        backgroundColor: AppColors.red_accent,
        elevation: 0,
        titleSpacing: 0,
        title: const Text('Semua Produk',
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
              // SizedBox(height: 20,),
              // Container(
              //   height: 45.0,
              //   margin: const EdgeInsets.symmetric(horizontal: 28.0),
              //   child: Theme(
              //     data: Theme.of(context).copyWith(primaryColor: AppColors.red_accent,),
              //     child: TextField(
              //       decoration: InputDecoration(
              //         filled: true,
              //         fillColor: AppColors.light_grey,
              //         border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10.0),
              //             borderSide: BorderSide.none
              //         ),
              //         hintText: 'Cari produk...',
              //         prefixIcon: const Icon(Icons.search),
              //         prefixIconColor: Colors.black54,
              //         contentPadding: const EdgeInsets.symmetric(vertical: 0),
              //         focusColor: Colors.black54,
              //       ),
              //       style: TextStyle(
              //         fontSize: 16,
              //         color: Colors.black54,
              //         fontFamily: 'PoppinsRegular',
              //       ),
              //     ),
              //   ),
              // ),
              Container(
                padding: EdgeInsets.all(28.0),
                child: FutureBuilder(
                  future: getProducts(widget.model, "id", "asc", "", widget.where, widget.value),
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
                      return snapshot.data.length < 1 ?
                      Center(
                        child: Column(
                          children: [
                            SizedBox(height: 50),
                            Lottie.asset("assets/lottie/not_found.json", height: 150),
                            const Text(
                              'Mohon maaf data\ntidak ditemukan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black26,
                                fontFamily: 'PoppinsMedium',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10,)
                          ],
                        ),
                      ) :
                      ListView.builder(
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
                            child: Container(
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
                                    width: 80,
                                    height: 80,
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
                                            snapshot.data[index].name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black54,
                                                fontFamily: 'PoppinsMedium'),
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            // "IDR. ${snapshot.data[index].price}",
                                            "${currencyFormatter.format(double.parse(snapshot.data[index].price.toString())).toString().replaceAll('IDR', 'IDR. ')}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                color: AppColors.red_accent,
                                                fontFamily: 'PoppinsRegular'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(20),
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: AppColors.light_grey,
                                      size: 20,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ]
        ),
      ),
    );
  }
}