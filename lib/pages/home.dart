import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:kuis_ecommerce/data/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuis_ecommerce/data/urls.dart';
import 'package:kuis_ecommerce/pages/general.dart';
import 'package:kuis_ecommerce/pages/update.dart';
import 'package:kuis_ecommerce/pages/product_all.dart';
import 'package:kuis_ecommerce/pages/product_page.dart';
import 'package:kuis_ecommerce/pages/signin.dart';
import 'package:kuis_ecommerce/pages/transaction.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../data/model.dart';
import '../data/theme.dart';
import '../data/utils.dart';
import 'cart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class DummyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => HomePage();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final PageController _myPage = PageController(initialPage: 0);
  late Color _iconColor1 = AppColors.red_accent;
  late Color _iconColor2 = Colors.grey;
  late Color _iconColor3 = Colors.grey;
  late Color _iconColor4 = Colors.grey;
  var ctime;
  String? token, name, username;
  bool _isLoad = false;

  List<String> imageList = [];

  int _currentIndex = 0;
  List<String> cardList = [];
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  // _showDialog() async {
  //   await Future.delayed(Duration(milliseconds: 50));
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         Future.delayed(Duration(seconds: 2), () {
  //           Navigator.of(context).pop(true);
  //         });
  //         return AlertDialog(
  //           contentPadding: EdgeInsets.zero,
  //           shape: RoundedRectangleBorder(borderRadius:
  //           BorderRadius.all(Radius.circular(15))),
  //           title: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Lottie.asset("assets/lottie/check.json", height: 150),
  //               Text(
  //                 widget.code=="booking" ? "Booking Online\nBerhasil!" : "Aktivasi CEC\nBerhasil!",
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                     fontSize: 20.0,
  //                     color: AppColors.red_accent,
  //                     fontFamily: 'PoppinsMedium'),
  //               ),
  //               SizedBox(height: 15,)
  //             ],
  //           ),
  //         );
  //       });
  // }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    print("oncreate");
    _refreshData();

    getdata("name").then((value) {setState(() {name = value.toString();});});
    getdata("username").then((value) {setState(() {username = value.toString();});});

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

  Future _reset() async {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => DummyWidget(),
      ),
    );
  }

  Future _refreshData() async {
    // setState(() {
    //   _isLoad = true;
    // });
    print("reload!");

    // String urlContent = 'https://hasil.labcito.co.id/wapi/apiberandacontent_new.php';
    // Map<String, String> mapContent = {
    //   'model': "info"
    // };
    //
    // postRequest(urlContent, mapContent).then((result) {
    //   String? statusCode = "${result.statusCode}";
    //   setState(() {
    //     _isLoad = false;
    //   });
    //   if(statusCode.toString()=="200") {
    //     print("suksessss");
    //   } else {
    //     print("error");
    //   }
    // });

    setState(() {});
  }

  Future<List<ProductCategories>> getProductCategories() async {
    String url = Strings.URL_PRODUCT_CATEGORIES;
    Map<String, String> map = {};

    var body = json.encode(map);
    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body
    );

    var responseData = json.decode(response.body);
    var data = responseData['data'];

    print("$map");
    print("${response.statusCode}");
    print("${response.body}");

    List<ProductCategories> contents = [];
    for (var singleCategories in data) {
      ProductCategories content = ProductCategories(
          id: singleCategories["id"].toString(),
          name: singleCategories["name"].toString());

      contents.add(content);
    }

    return contents;
  }

  Future<List<Products>> getRecommendProducts() async {
    List<Products> contents = [];
    var id_user = await getdata("id");

    // var list1 = [];
    var list1 = [1,2,4]; //testing
    var listProductUserMain = [];
    List<TransactionItems> listCheck = await getTransactionItems(id_user.toString(), "<> 0", "<> 0");
    for (int i = 0; i < listCheck.length; i++) {
      listProductUserMain.add(int.parse(listCheck[i].products_id.toString()));
    }
    // list1 = listProductUserMain.toSet().toList();
    // list1.sort((a, b) => a.compareTo(b));

    print("Check user's product : ${list1}");
    print("Check user's product : ${list1.length}");

    //Algoritma dijalankan hanya jika ada transaksi
    if(list1.length != 0) {
      //GET ALL USERS
      String urlUsers = Strings.URL_USERS;
      var responseUsers = await http.get(Uri.parse(urlUsers));
      var responseUsersData = json.decode(responseUsers.body);
      var dataUsers = responseUsersData['data'];

      //GET USER'S TRANSACTION ITEMS
      Map<String, List> map = {};
      SplayTreeMap<double, int> mapRank = SplayTreeMap<double, int>();

      for (var singleTransaction in dataUsers) {
        List<TransactionItems> listItems = await getTransactionItems(singleTransaction["id"].toString(), "<> 0", "<> 0");

        var listProductUser = [];
        for (int i = 0; i < listItems.length; i++) {
          if(singleTransaction["id"].toString() != id_user.toString()) {
            listProductUser.add(int.parse(listItems[i].products_id.toString()));
          }
        }

        if(singleTransaction["id"].toString() != id_user.toString()) {
          var distinctIds = listProductUser.toSet().toList();
          // distinctIds.sort((a, b) => a.compareTo(b));
          // map[singleTransaction["id"].toString()] = distinctIds;

          //testing
          map["3"] = [1,2,3,5];
          map["4"] = [2,3,4,8];
          map["5"] = [5,6,7,8];
          map["6"] = [1,2,4,11];
        }
      }

      print("Main user list : ${list1}");
      print("Other users list : "+map.toString());

      //PERHITUNGAN ALGORITMA
      map.forEach((i, value) {
        if(i != id_user) {
          if(value.length > list1.length) {
            var listMain = [];
            var listSame = [];
            for (int x = 0; x < list1.length; x++) {
              listMain.add(1);
              if(list1[x]==value[x]) {
                listSame.add(1);
              } else {
                listSame.add(0);
              }
            }

            //Cek jika sama sekali tidak ada produk yang sama
            if(listSame.toSet().toList().toString() != "[0]") {
              print("Persamaan user utama : ${listMain}");
              print("Persamaan user ${i} : ${listSame}");

              var listKuadrat1 = [];
              var listKuadrat2 = [];
              var listAtas = [];

              for (int x = 0; x < list1.length; x++) {
                listAtas.add(listMain[x] * listSame[x]);
                listKuadrat1.add(pow(listMain[x], 2));
                listKuadrat2.add(pow(listSame[x], 2));
              }

              double sum = listAtas.fold(0, (a, b) => a + b);
              double sumKuadrat1 = sqrt(listKuadrat1.fold(0, (a, b) => a + b));
              double sumKuadrat2 = sqrt(listKuadrat2.fold(0, (a, b) => a + b));
              print(cos(sum / (sumKuadrat1 * sumKuadrat2)));
              print(sum / (sumKuadrat1 * sumKuadrat2));
              print("Produk rekomendasi : ${value[list1.length]}");
              print("\n");

              mapRank[cos(sum / (sumKuadrat1 * sumKuadrat2))] = value[list1.length];
            }
          }
        }
      });

      print("Final rank : ${mapRank}");
      var listRecommendProduct = [];
      mapRank.forEach((i, value) {
        listRecommendProduct.add(value);
      });
      print("Rekomendasi produk : ${listRecommendProduct}");

      //Jika transaksi kurang dari 3, atau user kosong
      if(list1.length < 3 || listRecommendProduct.length == 0) {
        List<TransactionItems> listTest = await getTransactionItems("", "<> 0", "<> 0");
        var listCategory = [];
        for (int i = 0; i < listTest.length; i++) {
          listCategory.add(listTest[i].categories_id);
        }
        var distinctCat = listCategory.toSet().toList();
        for (int x = 0; x < distinctCat.length; x++) {
          List<Products> listProduct = await getProducts("where", "RAND()", "asc", "", "products.categories_id", distinctCat[x]);

          for (int i = 0; i < listProduct.length; i++) {
            Products content = Products(
              id: listProduct[i].id.toString(),
              name: listProduct[i].name.toString(),
              price: listProduct[i].price.toString(),
              stock: listProduct[i].stock.toString(),
              sold: listProduct[i].sold.toString(),
              description: listProduct[i].description.toString(),
              tags: listProduct[i].tags.toString(),
              categories: listProduct[i].categories.toString(),
              url: listProduct[i].url.toString(),
              category: listProduct[i].category.toString(),);

            if(contents.length < 6) {
              contents.add(content);
            }
          }
        }
      } else {
        for (int x = 0; x < listRecommendProduct.length; x++) {
          List<Products> listProduct = await getProducts("where", "id", "asc", "", "products.id", listRecommendProduct[x].toString());

          for (int i = 0; i < listProduct.length; i++) {
            Products content = Products(
              id: listProduct[i].id.toString(),
              name: listProduct[i].name.toString(),
              price: listProduct[i].price.toString(),
              stock: listProduct[i].stock.toString(),
              sold: listProduct[i].sold.toString(),
              description: listProduct[i].description.toString(),
              tags: listProduct[i].tags.toString(),
              categories: listProduct[i].categories.toString(),
              url: listProduct[i].url.toString(),
              category: listProduct[i].category.toString(),);

            // if(contents.length < 6) {
            //   contents.add(content);
            // }
            contents.add(content);
          }
        }
      }
    }

    contents.shuffle();
    return contents;
  }

  String selectedValue = "Semua Jenis";
  List<DropdownMenuItem<String>> get dropdownItems{
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Semua Jenis"),value: "Semua Jenis"),
      DropdownMenuItem(child: Text("Booking Online"),value: "Booking Online"),
      DropdownMenuItem(child: Text("Rujukan Dokter"),value: "Rujukan DOkter"),
    ];
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (ctime == null || now.difference(ctime) > const Duration(seconds: 2)) {
          ctime = now;
          showToast(context, "Tekan kembali untuk keluar");
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Stack(
        children: [
          Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        setState(() {
                          _myPage.jumpToPage(0);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 20.0, top: 5.0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 36.0,
                              child: IconButton(
                                iconSize: 25.0,
                                icon: Icon(Icons.home_filled, color: _iconColor1,),
                                onPressed: () {
                                  setState(() {
                                    _myPage.jumpToPage(0);
                                  });
                                },
                              ),
                            ),
                            Text(
                              'Home',
                              style: TextStyle(
                                fontSize: 12,
                                color: _iconColor1,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _myPage.jumpToPage(1);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 15.0, top: 5.0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 36.0,
                              child: IconButton(
                                iconSize: 25.0,
                                icon: Icon(Icons.history, color: _iconColor2,),
                                onPressed: () {
                                  setState(() {
                                    _myPage.jumpToPage(1);
                                  });
                                },
                              ),
                            ),
                            Text(
                              'Orders',
                              style: TextStyle(
                                fontSize: 12,
                                color: _iconColor2,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: 41.0,
                        ),
                        Text(
                          'Cart',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'PoppinsMedium',
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _myPage.jumpToPage(2);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 15.0, top: 5.0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 36.0,
                              child: IconButton(
                                iconSize: 25.0,
                                icon: Icon(Icons.favorite, color: _iconColor3,),
                                onPressed: () {
                                  setState(() {
                                    _myPage.jumpToPage(2);
                                  });
                                },
                              ),
                            ),
                            Text(
                              'Wishlist',
                              style: TextStyle(
                                fontSize: 12,
                                color: _iconColor3,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _myPage.jumpToPage(3);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 20.0, top: 5.0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 36.0,
                              child: IconButton(
                                iconSize: 25.0,
                                icon: Icon(Icons.person, color: _iconColor4,),
                                onPressed: () {
                                  setState(() {
                                    _myPage.jumpToPage(3);
                                  });
                                },
                              ),
                            ),
                            Text(
                              'Account',
                              style: TextStyle(
                                fontSize: 12,
                                color: _iconColor4,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light.copyWith(statusBarColor: AppColors.red_accent,),
              child: SafeArea(
                child: PageView(
                  controller: _myPage,
                  onPageChanged: (int) {
                    print('Page Changes to index $int');
                    if(int==0) {
                      _iconColor1 = AppColors.red_accent;
                      _iconColor2 = Colors.grey;
                      _iconColor3 = Colors.grey;
                      _iconColor4 = Colors.grey;
                    } else if(int==1) {
                      _iconColor1 = Colors.grey;
                      _iconColor2 = AppColors.red_accent;
                      _iconColor3 = Colors.grey;
                      _iconColor4 = Colors.grey;
                    } else if(int==2) {
                      _iconColor1 = Colors.grey;
                      _iconColor2 = Colors.grey;
                      _iconColor3 = AppColors.red_accent;
                      _iconColor4 = Colors.grey;
                    } else if(int==3) {
                      _iconColor1 = Colors.grey;
                      _iconColor2 = Colors.grey;
                      _iconColor3 = Colors.grey;
                      _iconColor4 = AppColors.red_accent;
                    }
                  },
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    //BERANDA
                    Scaffold(
                      // appBar: AppBar(
                      //   systemOverlayStyle: SystemUiOverlayStyle(
                      //     statusBarColor: AppColors.red_accent,
                      //     statusBarIconBrightness: Brightness.dark,
                      //     statusBarBrightness: Brightness.light,
                      //   ),
                      //   //backgroundColor: const Color.fromRGBO(200, 233, 229, 1),
                      //   backgroundColor: AppColors.red_accent,
                      //   elevation: 0,
                      //   title: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       SizedBox(width: 20,),
                      //       Icon(Icons.home_filled),
                      //       SizedBox(width: 10,),
                      //       Text('Home',
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //             fontFamily: 'PoppinsMedium',
                      //             fontSize: 20.0,
                      //           )
                      //       ),
                      //     ],
                      //   ),
                      //   // actions: <Widget>[
                      //   //   Padding(
                      //   //     padding: const EdgeInsets.all(0),
                      //   //     child: SizedBox(
                      //   //       width: 32.0,
                      //   //       child: IconButton(
                      //   //         icon: const Icon(
                      //   //           Icons.headphones,
                      //   //           color: Colors.white,
                      //   //           size: 26,
                      //   //         ),
                      //   //         onPressed: () {
                      //   //           // Navigator.push(context, MaterialPageRoute(builder: (context) {
                      //   //           //   return const ContactPage();
                      //   //           // }));
                      //   //         },
                      //   //       ),
                      //   //     ),
                      //   //   ),
                      //   //   Padding(
                      //   //     padding: const EdgeInsets.all(0),
                      //   //     child: Container(
                      //   //       margin: const EdgeInsets.only(right: 16.0),
                      //   //       child: SizedBox(
                      //   //         child: IconButton(
                      //   //           icon: const Icon(
                      //   //             Icons.notifications,
                      //   //             color: Colors.white,
                      //   //             size: 26,
                      //   //           ),
                      //   //           onPressed: () {
                      //   //             // Navigator.push(context, MaterialPageRoute(builder: (context) {
                      //   //             //   return const InboxPage();
                      //   //             // }));
                      //   //           },
                      //   //         ),
                      //   //       ),
                      //   //     ),
                      //   //   ),
                      //   // ],
                      //   titleSpacing: 0,
                      // ),
                      body: RefreshIndicator(
                        onRefresh: _reset,
                        child: SingleChildScrollView(
                          physics: ScrollPhysics(),
                          child: Container(
                            //color: const Color.fromRGBO(200, 233, 229, 1),
                            color: AppColors.red_accent,
                            child: Column(
                                children: <Widget>[
                                  // Container(
                                  //     decoration: BoxDecoration(
                                  //       borderRadius: BorderRadius.circular(10),
                                  //       image: const DecorationImage(
                                  //           image: AssetImage("assets/images/bg_header_home.png"),
                                  //           fit: BoxFit.cover),
                                  //     ),
                                  //     width: double.infinity,
                                  //     padding: const EdgeInsets.all(16.0),
                                  //     margin: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 20.0),
                                  //     child: Column(
                                  //       children: [
                                  //         Visibility(
                                  //           visible: _isLoad ? true : false,
                                  //           child: Column(
                                  //             crossAxisAlignment: CrossAxisAlignment.start,
                                  //             children: <Widget>[
                                  //               SizedBox(
                                  //                 height: 15,
                                  //                 width: 150,
                                  //                 child: ClipRRect(
                                  //                   borderRadius: BorderRadius.circular(16),
                                  //                   child: Shimmer.fromColors(
                                  //                     baseColor: const Color.fromRGBO(191, 191, 191, 0.5),
                                  //                     highlightColor: Colors.white,
                                  //                     child: Container(
                                  //                       color: Colors.grey,
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //               const SizedBox(
                                  //                 height: 5,
                                  //               ),
                                  //               SizedBox(
                                  //                 height: 15,
                                  //                 width: double.infinity,
                                  //                 child: ClipRRect(
                                  //                   borderRadius: BorderRadius.circular(16),
                                  //                   child: Shimmer.fromColors(
                                  //                     baseColor: const Color.fromRGBO(191, 191, 191, 0.5),
                                  //                     highlightColor: Colors.white,
                                  //                     child: Container(
                                  //                       color: Colors.grey,
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //               const SizedBox(
                                  //                 height: 10,
                                  //               ),
                                  //               SizedBox(
                                  //                 height: 18,
                                  //                 width: 200,
                                  //                 child: ClipRRect(
                                  //                   borderRadius: BorderRadius.circular(16),
                                  //                   child: Shimmer.fromColors(
                                  //                     baseColor: const Color.fromRGBO(191, 191, 191, 0.5),
                                  //                     highlightColor: Colors.white,
                                  //                     child: Container(
                                  //                       color: Colors.grey,
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //         Visibility(
                                  //           visible: _isLoad ? false : true,
                                  //           child: Container(
                                  //             width: double.infinity,
                                  //             child: Column(
                                  //               crossAxisAlignment: CrossAxisAlignment.start,
                                  //               children: <Widget>[
                                  //                 FutureBuilder<String?>(
                                  //                     future: getdata("rm"),
                                  //                     builder: (context, snapshot) {
                                  //                       if (snapshot.hasData) {
                                  //                         if (snapshot.data=='-') {
                                  //                           return const Text(
                                  //                             'Selamat datang',
                                  //                             style: TextStyle(
                                  //                               fontSize: 16,
                                  //                               color: AppColors.red_accentAccent,
                                  //                               fontFamily: 'PoppinsMedium',
                                  //                             ),
                                  //                           );
                                  //                         }
                                  //                       }
                                  //                       return Container();
                                  //                     }
                                  //                 ),
                                  //                 FutureBuilder<String?>(
                                  //                     future: getdata("name"),
                                  //                     builder: (context, snapshot) {
                                  //                       if (snapshot.hasData) {
                                  //                         return Text(
                                  //                           capitalizeAllWord(snapshot.data!.toLowerCase()),
                                  //                           style: TextStyle(
                                  //                             fontSize: 16,
                                  //                             color: Colors.white,
                                  //                             fontFamily: 'PoppinsMedium',
                                  //                           ),
                                  //                         );
                                  //                       }
                                  //                       return Container();
                                  //                     }
                                  //                 ),
                                  //                 FutureBuilder<String?>(
                                  //                     future: getdata("rm"),
                                  //                     builder: (context, snapshot) {
                                  //                       if (snapshot.hasData) {
                                  //                         if (snapshot.data!='-') {
                                  //                           return Text(
                                  //                             "Nomor RM. ${snapshot.data!}",
                                  //                             style: TextStyle(
                                  //                                 fontSize: 14,
                                  //                                 color: AppColors.red_accentAccent,
                                  //                                 fontFamily: 'PoppinsRegular',
                                  //                                 height: 1.8
                                  //                             ),
                                  //                           );
                                  //                         }
                                  //                       }
                                  //                       return Container();
                                  //                     }
                                  //                 ),
                                  //                 FutureBuilder<String?>(
                                  //                     future: getdata("rm"),
                                  //                     builder: (context, snapshot) {
                                  //                       if (snapshot.hasData) {
                                  //                         if (snapshot.data=='-') {
                                  //                           return Container(
                                  //                             margin: const EdgeInsets.only(top: 8.0),
                                  //                             child: SizedBox(
                                  //                               height:23,
                                  //                               child: RawMaterialButton(
                                  //                                 fillColor: Colors.white,
                                  //                                 splashColor: Colors.white70,
                                  //                                 elevation: 0,
                                  //                                 shape: const StadiumBorder(),
                                  //                                 onPressed: () {
                                  //                                   Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  //                                     return const MemberPage();
                                  //                                   }));
                                  //                                 },
                                  //                                 child: Padding(
                                  //                                   padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
                                  //                                   child: Row(
                                  //                                     mainAxisSize: MainAxisSize.min,
                                  //                                     children: const [
                                  //                                       Icon(
                                  //                                         Icons.credit_card,
                                  //                                         color: AppColors.red_accent,
                                  //                                         size: 16,
                                  //                                       ),
                                  //                                       SizedBox(
                                  //                                         width: 5.0,
                                  //                                       ),
                                  //                                       Text(
                                  //                                         "Aktivasi CEC Membership",
                                  //                                         maxLines: 1,
                                  //                                         style: TextStyle(
                                  //                                           color: AppColors.red_accent,
                                  //                                           fontSize: 12,
                                  //                                           fontFamily: 'PoppinsMedium',
                                  //
                                  //                                         ),
                                  //                                       ),
                                  //                                       SizedBox(
                                  //                                         width: 5.0,
                                  //                                       ),
                                  //                                       Icon(
                                  //                                         Icons.keyboard_arrow_right,
                                  //                                         color: AppColors.red_accent,
                                  //                                         size: 16,
                                  //                                       ),
                                  //                                     ],
                                  //                                   ),
                                  //                                 ),
                                  //                               ),
                                  //                             ),
                                  //                           );
                                  //                         }
                                  //                       }
                                  //                       return Row(
                                  //                         mainAxisSize: MainAxisSize.min,
                                  //                         children: [
                                  //                           Container(
                                  //                             margin: const EdgeInsets.only(top: 8.0),
                                  //                             child: SizedBox(
                                  //                               height:23,
                                  //                               child: RawMaterialButton(
                                  //                                 fillColor: Colors.white,
                                  //                                 splashColor: Colors.white70,
                                  //                                 elevation: 0,
                                  //                                 shape: const StadiumBorder(),
                                  //                                 onPressed: () {  },
                                  //                                 child: Padding(
                                  //                                   padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
                                  //                                   child: Row(
                                  //                                     mainAxisSize: MainAxisSize.min,
                                  //                                     children: [
                                  //                                       Icon(
                                  //                                         Icons.monetization_on,
                                  //                                         color: AppColors.red_accent,
                                  //                                         size: 16,
                                  //                                       ),
                                  //                                       SizedBox(
                                  //                                         width: 5.0,
                                  //                                       ),
                                  //                                       FutureBuilder<String?>(
                                  //                                           future: getPoint(),
                                  //                                           builder: (context, snapshot) {
                                  //                                             if (snapshot.hasData) {
                                  //                                               return Text(
                                  //                                                 "${snapshot.data!} poin",
                                  //                                                 maxLines: 1,
                                  //                                                 style: TextStyle(
                                  //                                                   color: AppColors.red_accent,
                                  //                                                   fontSize: 12,
                                  //                                                   fontFamily: 'PoppinsMedium',
                                  //                                                 ),
                                  //                                               );
                                  //                                             }
                                  //                                             return Text(
                                  //                                               " poin",
                                  //                                               maxLines: 1,
                                  //                                               style: TextStyle(
                                  //                                                 color: AppColors.red_accent,
                                  //                                                 fontSize: 12,
                                  //                                                 fontFamily: 'PoppinsMedium',
                                  //                                               ),
                                  //                                             );
                                  //                                           }
                                  //                                       ),
                                  //                                     ],
                                  //                                   ),
                                  //                                 ),
                                  //                               ),
                                  //                             ),
                                  //                           ),
                                  //                           const SizedBox(
                                  //                             width: 10.0,
                                  //                           ),
                                  //                           Container(
                                  //                             margin: const EdgeInsets.only(top: 8.0),
                                  //                             child: SizedBox(
                                  //                               height:23,
                                  //                               child: RawMaterialButton(
                                  //                                 fillColor: Colors.white,
                                  //                                 splashColor: Colors.white70,
                                  //                                 elevation: 0,
                                  //                                 shape: const StadiumBorder(),
                                  //                                 onPressed: () {
                                  //                                   Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  //                                     return const MemberPage();
                                  //                                   }));
                                  //                                 },
                                  //                                 child: Padding(
                                  //                                   padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
                                  //                                   child: Row(
                                  //                                     mainAxisSize: MainAxisSize.min,
                                  //                                     children: const [
                                  //                                       Icon(
                                  //                                         Icons.credit_card,
                                  //                                         color: AppColors.red_accent,
                                  //                                         size: 16,
                                  //                                       ),
                                  //                                       SizedBox(
                                  //                                         width: 5.0,
                                  //                                       ),
                                  //                                       Text(
                                  //                                         "Member",
                                  //                                         maxLines: 1,
                                  //                                         style: TextStyle(
                                  //                                           color: AppColors.red_accent,
                                  //                                           fontSize: 12,
                                  //                                           fontFamily: 'PoppinsMedium',
                                  //
                                  //                                         ),
                                  //                                       ),
                                  //                                       SizedBox(
                                  //                                         width: 5.0,
                                  //                                       ),
                                  //                                       Icon(
                                  //                                         Icons.keyboard_arrow_right,
                                  //                                         color: AppColors.red_accent,
                                  //                                         size: 16,
                                  //                                       ),
                                  //                                     ],
                                  //                                   ),
                                  //                                 ),
                                  //                               ),
                                  //                             ),
                                  //                           ),
                                  //                         ],
                                  //                       );
                                  //                     }
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     )
                                  // ),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(20, 8, 30, 25),
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        FutureBuilder<String?>(
                                            future: getdata("name"),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Selamat datang,',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontFamily: 'PoppinsRegular',
                                                      ),
                                                    ),
                                                    Text(
                                                      capitalizeAllWord(snapshot.data!.toLowerCase()),
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontFamily: 'PoppinsMedium',
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 12,
                                                    width: 150,
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
                                                  SizedBox(height: 10,),
                                                  SizedBox(
                                                    height: 12,
                                                    width: 200,
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
                                                ],
                                              );
                                            }
                                        ),
                                        Spacer(),
                                        Image.asset('assets/images/kuis_logo.png', width: 70,),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 30),
                                      decoration: BoxDecoration(
                                          color: AppColors.bg_grey,
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(22.0), topRight: Radius.circular(22.0))
                                      ),
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          FutureBuilder(
                                            future: getTransactions("", "1", "created_at", "desc"),
                                            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                                              if (snapshot.data == null) {
                                                return Container(
                                                  margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                                                  child: SizedBox(
                                                    height: 75,
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
                                                bool isNeedConfirm = false;
                                                if(snapshot.data.length > 0) {
                                                  for (int i = 0; i < snapshot.data.length; i++) {
                                                    if(snapshot.data[i].expired_time.toString() != "null") {
                                                      if(!DateTime.parse(snapshot.data[i].expired_time).isBefore(DateTime.now()) && snapshot.data[i].status == "1") {
                                                        isNeedConfirm = true;
                                                      }
                                                    }
                                                  }
                                                } else {
                                                  isNeedConfirm = false;
                                                }
                                                return !isNeedConfirm ?
                                                Container() :
                                                Container(
                                                    decoration: BoxDecoration(
                                                      color: AppColors.bgdanger,
                                                      border: Border.all(color: AppColors.borderdanger, width: 1.5),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.all(8.0),
                                                    margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                                                    child: Center(
                                                      child: Row(
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons.warning_amber_outlined,
                                                              color: AppColors.borderdanger,
                                                              size: 25,
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                'Anda perlu melakukan pembayaran untuk transaksi yang telah dilakukan. Silahkan buka menu cart atau riwayat.',
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    color: AppColors.borderdanger,
                                                                    fontFamily: 'PoppinsMedium'
                                                                ),
                                                              ),
                                                            ),
                                                          ]
                                                      ),
                                                    )
                                                );
                                              }
                                            },
                                          ),
                                          FutureBuilder(
                                            future: getProductCategories(),
                                            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                                              if (snapshot.data == null) {
                                                return Container(
                                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: SizedBox(
                                                    height: 40,
                                                    child: ListView(
                                                      scrollDirection: Axis.horizontal,
                                                      children: <Widget>[
                                                        shimmerCategories(),
                                                        shimmerCategories(),
                                                        shimmerCategories(),
                                                        SizedBox(
                                                          width: 16.0,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Container(
                                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: SizedBox(
                                                    height: 38,
                                                    child: ListView.builder(
                                                      physics: ClampingScrollPhysics(),
                                                      shrinkWrap: true,
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: snapshot.data.length,
                                                      itemBuilder: (context, index) {
                                                        return InkWell(
                                                          onTap: () {
                                                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                              return AllProductPage(model: "where", where: "products.categories_id", value: snapshot.data[index].id,);
                                                            }));
                                                          },
                                                          child: Container(
                                                            margin: EdgeInsets.only(left: 12.0),
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(20),
                                                                color: AppColors.container
                                                            ),
                                                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                                            child: Text(
                                                              snapshot.data[index].name,
                                                              style: TextStyle(
                                                                  fontSize: 14.0,
                                                                  color: Colors.black54,
                                                                  fontFamily: 'PoppinsRegular'),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          FutureBuilder(
                                            //future: getProducts("limit", "RAND()", "asc", "5", "", ""),
                                            future: getRecommendProducts(),
                                            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                                              if (snapshot.data == null) {
                                                return Container(
                                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: SizedBox(
                                                    height: 265,
                                                    child: ListView(
                                                      scrollDirection: Axis.horizontal,
                                                      children: const <Widget>[
                                                        shimmerPenawaran(),
                                                        shimmerPenawaran(),
                                                        shimmerPenawaran(),
                                                        SizedBox(
                                                          width: 16.0,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return
                                                snapshot.data.toString()=="[]" ?  Container() :
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                                                      child: const Text(
                                                        'Rekomendasi untuk Anda',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.black54,
                                                            fontFamily: 'PoppinsRegular',
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                                                      child: SizedBox(
                                                        height: 300,
                                                        child: ListView.builder(
                                                          physics: ClampingScrollPhysics(),
                                                          shrinkWrap: true,
                                                          scrollDirection: Axis.horizontal,
                                                          itemCount: snapshot.data.length,
                                                          itemBuilder: (context, index) {
                                                            return InkWell(
                                                              onTap: () {
                                                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                                  return ProductPage(product_id: snapshot.data[index].id);
                                                                }));
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(4.0),
                                                                child: Container(
                                                                    width: 170,
                                                                    margin: const EdgeInsets.only(left: 10.0, right: 4),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius: BorderRadius.circular(10),
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                          color: Colors.grey,
                                                                          offset: Offset(1, 1),
                                                                          blurRadius: 2,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: <Widget>[
                                                                        ClipRRect(
                                                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                                                          child: Container(
                                                                            width: 170,
                                                                            height: 170,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                                                              image: DecorationImage(
                                                                                  image: NetworkImage("${Strings.URL_IMG}${snapshot.data[index].url}"),
                                                                                  fit: BoxFit.cover),
                                                                              boxShadow: [
                                                                                BoxShadow(color: AppColors.container),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 15,),
                                                                        Container(
                                                                          width: 170,
                                                                          margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                                                          child: Text(
                                                                            snapshot.data[index].category,
                                                                            style: TextStyle(
                                                                                fontSize: 12.0,
                                                                                color: Colors.black54,
                                                                                fontFamily: 'PoppinsRegular'),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width: 170,
                                                                          margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
                                                                          child: Text(
                                                                            snapshot.data[index].name,
                                                                            maxLines: 2,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                              fontSize: 16,
                                                                              color: Colors.black54,
                                                                              fontFamily: 'PoppinsMedium',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                                                          child: Text(
                                                                            // 'IDR. ${snapshot.data[index].price}',
                                                                            "${currencyFormatter.format(double.parse(snapshot.data[index].price.toString())).toString().replaceAll('IDR', 'IDR. ')}",
                                                                            style: TextStyle(
                                                                              fontSize: 14,
                                                                              color: AppColors.red_accent,
                                                                              fontFamily: 'PoppinsMedium',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            },
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                                            child: const Text(
                                              'Produk Populer',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                  fontFamily: 'PoppinsRegular',
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                          FutureBuilder(
                                            future: getProducts("limit", "sold", "desc", "5", "", ""),
                                            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                                              if (snapshot.data == null) {
                                                return Container(
                                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: SizedBox(
                                                    height: 265,
                                                    child: ListView(
                                                      scrollDirection: Axis.horizontal,
                                                      children: const <Widget>[
                                                        shimmerPenawaran(),
                                                        shimmerPenawaran(),
                                                        shimmerPenawaran(),
                                                        SizedBox(
                                                          width: 16.0,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Container(
                                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: SizedBox(
                                                    height: 320,
                                                    child: ListView.builder(
                                                      physics: ClampingScrollPhysics(),
                                                      shrinkWrap: true,
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: snapshot.data.length,
                                                      itemBuilder: (context, index) {
                                                        return InkWell(
                                                          onTap: () {
                                                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                              return ProductPage(product_id: snapshot.data[index].id);
                                                            }));
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(4.0),
                                                            child: Container(
                                                                width: 170,
                                                                margin: const EdgeInsets.only(left: 10.0, right: 4),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  boxShadow: const [
                                                                    BoxShadow(
                                                                      color: Colors.grey,
                                                                      offset: Offset(1, 1),
                                                                      blurRadius: 2,
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: <Widget>[
                                                                    ClipRRect(
                                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                                                      child: Container(
                                                                        width: 170,
                                                                        height: 170,
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                                                          image: DecorationImage(
                                                                              image: NetworkImage("${Strings.URL_IMG}${snapshot.data[index].url}"),
                                                                              fit: BoxFit.cover),
                                                                          boxShadow: [
                                                                            BoxShadow(color: AppColors.container),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 15,),
                                                                    Container(
                                                                      width: 170,
                                                                      margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                                                      child: Text(
                                                                        snapshot.data[index].category,
                                                                        style: TextStyle(
                                                                            fontSize: 12.0,
                                                                            color: Colors.black54,
                                                                            fontFamily: 'PoppinsRegular'),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: 170,
                                                                      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
                                                                      child: Text(
                                                                        snapshot.data[index].name,
                                                                        maxLines: 2,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                          fontSize: 16,
                                                                          color: Colors.black54,
                                                                          fontFamily: 'PoppinsMedium',
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                                                      child: Text(
                                                                        // 'IDR. ${snapshot.data[index].price}',
                                                                        "${currencyFormatter.format(double.parse(snapshot.data[index].price.toString())).toString().replaceAll('IDR', 'IDR. ')}",
                                                                        style: TextStyle(
                                                                          fontSize: 14,
                                                                          color: AppColors.red_accent,
                                                                          fontFamily: 'PoppinsMedium',
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 5,),
                                                                    Container(
                                                                      width: 170,
                                                                      margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                                                      child: Text(
                                                                        "Terjual ${snapshot.data[index].sold} produk",
                                                                        style: TextStyle(
                                                                            fontSize: 12.0,
                                                                            color: Colors.black54,
                                                                            fontFamily: 'PoppinsRegular'),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                                            child: const Text(
                                              'Produk Terbaru',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                  fontFamily: 'PoppinsRegular',
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                          FutureBuilder(
                                            future: getProducts("limit", "created_at", "desc", "5", "", ""),
                                            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                                              if (snapshot.data == null) {
                                                return Container(
                                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: SizedBox(
                                                    height: 300,
                                                    child: ListView(
                                                      scrollDirection: Axis.horizontal,
                                                      children: const <Widget>[
                                                        shimmerPenawaran(),
                                                        shimmerPenawaran(),
                                                        shimmerPenawaran(),
                                                        SizedBox(
                                                          width: 16.0,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Container(
                                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: SizedBox(
                                                    height: 300,
                                                    child: ListView.builder(
                                                      physics: ClampingScrollPhysics(),
                                                      shrinkWrap: true,
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: snapshot.data.length,
                                                      itemBuilder: (context, index) {
                                                        return InkWell(
                                                          onTap: () {
                                                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                              return ProductPage(product_id: snapshot.data[index].id);
                                                            }));
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(4.0),
                                                            child: Container(
                                                                width: 170,
                                                                margin: const EdgeInsets.only(left: 10.0, right: 4),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  boxShadow: const [
                                                                    BoxShadow(
                                                                      color: Colors.grey,
                                                                      offset: Offset(1, 1),
                                                                      blurRadius: 2,
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: <Widget>[
                                                                    ClipRRect(
                                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                                                      child: Banner(
                                                                        message: 'New Product',
                                                                        location: BannerLocation.topEnd,
                                                                        color: AppColors.red_accent,
                                                                        child: Container(
                                                                          width: 170,
                                                                          height: 170,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                                                            image: DecorationImage(
                                                                                image: NetworkImage("${Strings.URL_IMG}${snapshot.data[index].url}"),
                                                                                fit: BoxFit.cover),
                                                                            boxShadow: [
                                                                              BoxShadow(color: AppColors.container),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 15,),
                                                                    Container(
                                                                      width: 170,
                                                                      margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                                                      child: Text(
                                                                        snapshot.data[index].category,
                                                                        style: TextStyle(
                                                                            fontSize: 12.0,
                                                                            color: Colors.black54,
                                                                            fontFamily: 'PoppinsRegular'),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: 170,
                                                                      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
                                                                      child: Text(
                                                                        snapshot.data[index].name,
                                                                        maxLines: 2,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                          fontSize: 16,
                                                                          color: Colors.black54,
                                                                          fontFamily: 'PoppinsMedium',
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                                                      child: Text(
                                                                        // 'IDR. ${snapshot.data[index].price}',
                                                                        "${currencyFormatter.format(double.parse(snapshot.data[index].price.toString())).toString().replaceAll('IDR', 'IDR. ')}",
                                                                        style: TextStyle(
                                                                          fontSize: 14,
                                                                          color: AppColors.red_accent,
                                                                          fontFamily: 'PoppinsMedium',
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                                            child: const Text(
                                              'Semua Produk',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                  fontFamily: 'PoppinsRegular',
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(16.0),
                                            child: FutureBuilder(
                                              future: getProducts("limit", "id", "asc", "6", "", ""),
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
                                                              width: 100,
                                                              height: 100,
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
                                                                      style: TextStyle(
                                                                          fontSize: 15.0,
                                                                          color: AppColors.red_accent,
                                                                          fontFamily: 'PoppinsRegular'),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 16.0),
                                            child: SizedBox(
                                              height: 50,
                                              width: double.infinity,
                                              child: OutlinedButton(
                                                onPressed: () async {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                    return const AllProductPage(model: "all", where: "", value: "",);
                                                  }));
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  backgroundColor: AppColors.container,
                                                  side: BorderSide(color: AppColors.container, width: 1),
                                                ),
                                                child: Row(
                                                  children: const [
                                                    Text(
                                                      "Lihat semua produk",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize: 16,
                                                        fontFamily: 'PoppinsRegular',
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Icon(
                                                      Icons.keyboard_arrow_right_rounded,
                                                      color: Colors.black45,
                                                      size: 25,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 50.0,
                                          ),
                                        ],
                                      )
                                  ),
                                ]
                            ),
                          ),
                        ),
                      ),
                    ),

                    //#RIWAYAT
                    Scaffold(
                      backgroundColor: AppColors.container,
                      appBar: AppBar(
                          centerTitle: true,
                          automaticallyImplyLeading: false,
                          backgroundColor: AppColors.red_accent,
                          elevation: 0,
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.article_sharp),
                              SizedBox(width: 10,),
                              Text('My Orders',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'PoppinsMedium',
                                    fontSize: 20.0,
                                  )
                              ),
                            ],
                          )
                        // title: const Text('Wishlist',
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontFamily: 'PoppinsMedium',
                        //       fontSize: 20.0,
                        //     )
                        // ),
                      ),
                      body: SingleChildScrollView(
                        child: Column(
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.all(28.0),
                                  child: FutureBuilder(
                                    future: getTransactions("", "", "created_at", "desc"),
                                    builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                                      if (snapshot.data == null) {
                                        return Container(
                                          child: ListView(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            children: const <Widget>[
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
                                        ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: snapshot.data.length,
                                          itemBuilder: (context, index) {
                                            bool isExpired = false;
                                            if(snapshot.data[index].expired_time != "null") {
                                              if(DateTime.parse(snapshot.data[index].expired_time).isBefore(DateTime.now()) && snapshot.data[index].status == "1") {
                                                isExpired = true;
                                              } else {
                                                isExpired = false;
                                              }
                                            } else {
                                              isExpired = false;
                                            }
                                            return InkWell(
                                              onTap: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                  return TransactionPage(transaction_id: snapshot.data[index].id,);
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
                                                    Expanded(
                                                      flex: 2,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    snapshot.data[index].created_at,
                                                                    style: TextStyle(
                                                                        fontSize: 16.0,
                                                                        color: Colors.black54,
                                                                        fontFamily: 'PoppinsMedium'),
                                                                  ),
                                                                  Spacer(),
                                                                  pillStatus(snapshot.data[index].status, isExpired)
                                                                ],
                                                              ),
                                                            ),
                                                            Divider(
                                                              thickness: 0.3,
                                                              color: Colors.grey,
                                                            ),
                                                            SizedBox(height: 5,),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                              child: Text(
                                                                "Kode : ${snapshot.data[index].transaction_code}",
                                                                style: TextStyle(
                                                                    fontSize: 14.0,
                                                                    color: Colors.black54,
                                                                    fontFamily: 'PoppinsRegular'),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                              child: FutureBuilder(
                                                                future: getTransactionItems("", "= ${snapshot.data[index].id}", ""),
                                                                builder: (BuildContext ctx, AsyncSnapshot snapshots) {
                                                                  if (snapshots.data == null) {
                                                                    return Container();
                                                                  } else {
                                                                    return snapshots.data.length < 1 ?
                                                                    Container() :
                                                                    Text(
                                                                      "Produk : ${snapshots.data[0].product} ${snapshots.data.length > 1 ? ","+snapshots.data[1].product : ""}",
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: TextStyle(
                                                                          fontSize: 14.0,
                                                                          color: Colors.black54,
                                                                          fontFamily: 'PoppinsRegular'),
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                              child: Text(
                                                                // "Total Amount : IDR. ${snapshot.data[index].total_price}",
                                                                "Total Amount : ${currencyFormatter.format(double.parse(snapshot.data[index].total_price.toString())).toString().replaceAll('IDR', 'IDR. ')}",
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    fontSize: 15.0,
                                                                    color: AppColors.red_accent,
                                                                    fontFamily: 'PoppinsRegular'),
                                                              ),
                                                            ),
                                                            SizedBox(height: 8,),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                  )
                              ),
                            ]
                        ),
                      ),
                    ),

                    //#BANTUAN
                    Scaffold(
                      backgroundColor: AppColors.container,
                      appBar: AppBar(
                        centerTitle: true,
                          automaticallyImplyLeading: false,
                        backgroundColor: AppColors.red_accent,
                        elevation: 0,
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite),
                            SizedBox(width: 10,),
                            Text('Wishlist',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'PoppinsMedium',
                                  fontSize: 20.0,
                                )
                            ),
                          ],
                        )
                        // title: const Text('Wishlist',
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontFamily: 'PoppinsMedium',
                        //       fontSize: 20.0,
                        //     )
                        // ),
                      ),
                      body: SingleChildScrollView(
                        child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(28.0),
                                child: FutureBuilder(
                                  future: getTransactionItems("", "= 0", "= 0"),
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
                                      ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                return ProductPage(product_id: snapshot.data[index].products_id);
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
                                                            snapshot.data[index].product,
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
                                                    margin: EdgeInsets.all(16),
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.favorite,
                                                        color: Colors.pink,
                                                        size: 25,
                                                      ),
                                                      onPressed: () {
                                                        showDialog<String>(
                                                          context: context,
                                                          builder: (BuildContext context) => AlertDialog(
                                                            title: const Text('Hapus dari wishlist'),
                                                            content: const Text('Anda yakin ingin menghapus produk ini dari wishlist?'),
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
                                                                    setState(() {
                                                                      _isLoad = false;
                                                                    });
                                                                    var data = json.decode(result.body);
                                                                    if(statusCode.toString()=="200") {
                                                                      showToast(context, "Produk dihapus dari list");
                                                                      //showSuccessDialog(qty);
                                                                      Navigator.pop(context);
                                                                      //setState(() {});
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
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                )
                              ),
                            ]
                        ),
                      ),
                    ),

                    //#AKUN
                    accountPage(context, "customer"),
                  ],
                ),
              )
            ),
            floatingActionButton: SizedBox(
              height: 65.0,
              width: 65.0,
              child: FittedBox(
                child: FloatingActionButton(
                  backgroundColor: AppColors.red_accent,
                  onPressed: () async {
                    setState(() {
                      _isLoad = true;
                    });

                    String? id_user = await getdata("id");
                    String url = Strings.URL_TRANSACTIONS;
                    Map<String, String> maps = {
                      'users_id': id_user.toString(),
                      'order_by': "created_at",
                      'order': "desc",
                      'status': "1"
                    };

                    postRequest(url, maps).then((result) {
                      String? statusCode = "${result.statusCode}";
                      setState(() {
                        _isLoad = false;
                      });
                      if(statusCode.toString()=="200") {
                        var responseData = json.decode(result.body);
                        var data = responseData['data'];
                        bool isNeedConfirm = false;
                        for (var singleCabang in data) {
                          if(singleCabang["expired_time"].toString() != "null") {
                            if(!DateTime.parse(singleCabang["expired_time"].toString()).isBefore(DateTime.now())) {
                              isNeedConfirm = true;
                            }
                          }
                        }

                        if(isNeedConfirm) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return TransactionPage(transaction_id: responseData["data"][0]["id"].toString());
                          }));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return const CartPage();
                          }));
                        }
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const CartPage();
                        }));
                      }
                    });
                  },
                  child: Icon(Icons.shopping_cart_outlined),
                  //child: Image.asset('assets/images/circle_bottomnav.png',)
                ),
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
      ),
    );
  }
}

class shimmerPenawaran extends StatelessWidget {
  const shimmerPenawaran({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
          width: 170,
          margin: const EdgeInsets.only(left: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 170,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.white,
                    child: Container(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 0),
                child: SizedBox(
                  height: 12,
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
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 0),
                child: SizedBox(
                  height: 12,
                  width: 130,
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
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(8.0, 13.0, 8.0, 0),
                child: SizedBox(
                  height: 10,
                  width: 100,
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
              ),
            ],
          )
      ),
    );
  }
}

class shimmerCategories extends StatelessWidget {
  const shimmerCategories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        margin: EdgeInsets.only(left: 12.0),
        width: 100,
        // decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(10),
        //     color: AppColors.container
        // ),
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
  }
}

class shimmerNewsFeed extends StatelessWidget {
  const shimmerNewsFeed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
          width: 200,
          margin: const EdgeInsets.only(left: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 150,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.white,
                    child: Container(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 0),
                child: SizedBox(
                  height: 12,
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
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 0),
                child: SizedBox(
                  height: 12,
                  width: 130,
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
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(8.0, 13.0, 8.0, 0),
                child: SizedBox(
                  height: 10,
                  width: 100,
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
              ),
            ],
          )
      ),
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