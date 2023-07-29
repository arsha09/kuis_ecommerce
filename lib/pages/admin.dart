import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:kuis_ecommerce/data/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuis_ecommerce/data/urls.dart';
import 'package:kuis_ecommerce/pages/product_add.dart';
import 'package:kuis_ecommerce/pages/product_all.dart';
import 'package:kuis_ecommerce/pages/product_page.dart';
import 'package:kuis_ecommerce/pages/report.dart';
import 'package:kuis_ecommerce/pages/signin.dart';
import 'package:kuis_ecommerce/pages/transaction.dart';
import 'package:kuis_ecommerce/pages/upload.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../data/model.dart';
import '../data/theme.dart';
import '../data/utils.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class DummyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AdminPage();
}

class _AdminPageState extends State<AdminPage> with WidgetsBindingObserver {
  final PageController _myPage = PageController(initialPage: 0);
  late Color _iconColor1 = AppColors.bg_navy;
  late Color _iconColor2 = Colors.grey;
  late Color _iconColor3 = Colors.grey;
  late Color _iconColor4 = Colors.grey;
  var ctime;
  String? token;
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

    // if(widget.code!="") {
    //   _showDialog();
    // }

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
    setState(() {
      _isLoad = true;
    });
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
      child: Scaffold(
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
                            icon: Icon(Icons.breakfast_dining_rounded, color: _iconColor2,),
                            onPressed: () {
                              setState(() {
                                _myPage.jumpToPage(1);
                              });
                            },
                          ),
                        ),
                        Text(
                          'Products',
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
                      'Add Product',
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
                            icon: Icon(Icons.article, color: _iconColor3,),
                            onPressed: () {
                              setState(() {
                                _myPage.jumpToPage(2);
                              });
                            },
                          ),
                        ),
                        Text(
                          'Orders',
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
          value: SystemUiOverlayStyle.light.copyWith(statusBarColor: AppColors.bg_navy,),
          child: SafeArea(
            child: PageView(
              controller: _myPage,
              onPageChanged: (int) {
                print('Page Changes to index $int');
                if(int==0) {
                  _iconColor1 = AppColors.bg_navy;
                  _iconColor2 = Colors.grey;
                  _iconColor3 = Colors.grey;
                  _iconColor4 = Colors.grey;
                } else if(int==1) {
                  _iconColor1 = Colors.grey;
                  _iconColor2 = AppColors.bg_navy;
                  _iconColor3 = Colors.grey;
                  _iconColor4 = Colors.grey;
                } else if(int==2) {
                  _iconColor1 = Colors.grey;
                  _iconColor2 = Colors.grey;
                  _iconColor3 = AppColors.bg_navy;
                  _iconColor4 = Colors.grey;
                } else if(int==3) {
                  _iconColor1 = Colors.grey;
                  _iconColor2 = Colors.grey;
                  _iconColor3 = Colors.grey;
                  _iconColor4 = AppColors.bg_navy;
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
                        color: AppColors.bg_navy,
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
                                                  'Halaman Admin',
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
                                padding: EdgeInsets.only(top: 20),
                                  decoration: BoxDecoration(
                                      color: AppColors.bg_grey,
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(22.0), topRight: Radius.circular(22.0))
                                  ),
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                                        child: const Text(
                                          'Laporan Penjualan',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                              fontFamily: 'PoppinsRegular',
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 8.0),
                                        child: FutureBuilder(
                                          future: getReports('%Y'),
                                          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                                            if (snapshot.data == null) {
                                              return Container(
                                                margin: EdgeInsets.all(16.0),
                                                child: ListView(
                                                  physics: NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  children: const <Widget>[
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
                                              int transactions = 0;
                                              int products = 0;
                                              int omzet = 0;
                                              for (int i = 0; i < snapshot.data.length; i++) {
                                                transactions += int.parse(snapshot.data[i].total_transaksi);
                                                products += int.parse(snapshot.data[i].total_produk);
                                                omzet += int.parse(snapshot.data[i].total_omset);
                                              }
                                              return ListView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: 3,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                                                    padding: EdgeInsets.all(16.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(color: Colors.white),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Container(
                                                          width: 50,
                                                          height: 50,
                                                          margin: EdgeInsets.only(right: 12.0),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            boxShadow: [
                                                              BoxShadow(color: AppColors.bg_grey),
                                                            ],
                                                          ),
                                                          child: Icon(
                                                            index == 0 ? Icons.article_outlined : index == 1 ? Icons.breakfast_dining_rounded : Icons.monetization_on_outlined,
                                                            color: index == 0 ? Colors.blueAccent : index == 1 ? Colors.pinkAccent : Colors.greenAccent,
                                                            size: 35,),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(0),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Text(
                                                                  index == 0 ? "Total Transaksi" : index == 1 ? "Total Produk Terjual" : "Total Omset",
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(
                                                                      fontSize: 14.0,
                                                                      color: Colors.black54,
                                                                      fontFamily: 'PoppinsRegular'),
                                                                ),
                                                                const SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  index == 0 ? "${transactions} Transaksi" : index == 1 ? "${products} Produk" : "${currencyFormatter.format(double.parse(omzet.toString())).toString().replaceAll('IDR', 'IDR. ')}",
                                                                  style: TextStyle(
                                                                      fontSize: 18.0,
                                                                      color: Colors.black54,
                                                                      fontFamily: 'PoppinsMedium'),
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
                                                return ReportPage();
                                              }));
                                            },
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              backgroundColor: Colors.white,
                                              side: BorderSide(color: Colors.white, width: 1),
                                            ),
                                            child: Row(
                                              children: const [
                                                Text(
                                                  "Lihat laporan penjualan",
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
                                      SizedBox(height: 10,),
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                                        child: const Text(
                                          'Transaksi Perlu Verifikasi',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                              fontFamily: 'PoppinsRegular',
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                          child: FutureBuilder(
                                            future: getTransactions("", "2", "created_at", "desc"),
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
                                                      Lottie.asset("assets/lottie/not_found.json", height: 150),
                                                      const Text(
                                                        'Tidak ada transaksi\nyang perlu verifikasi',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black26,
                                                          fontFamily: 'PoppinsMedium',
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      SizedBox(height: 20,)
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
                                                          color: Colors.white,
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
                                      Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: OutlinedButton(
                                            onPressed: () async {
                                              setState(() {
                                                _myPage.jumpToPage(2);
                                              });
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
                                                  "Lihat semua transaksi",
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
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(16.0, 28.0, 16.0, 0),
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
                                      Container(
                                        padding: EdgeInsets.all(16.0),
                                        child: FutureBuilder(
                                          future: getProducts("where", "sold", "desc", "6", "products.sold <>", "0"),
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
                                                          width: 120,
                                                          height: 120,
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
                                                                      fontSize: 14.0,
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
                                                                      fontSize: 14.0,
                                                                      color: AppColors.red_accent,
                                                                      fontFamily: 'PoppinsRegular'),
                                                                ),
                                                                const SizedBox(
                                                                  height: 3,
                                                                ),
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      color: AppColors.container
                                                                  ),
                                                                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                                                                  child: Text(
                                                                    "Terjual ${snapshot.data[index].sold}",
                                                                    style: TextStyle(
                                                                        fontSize: 14.0,
                                                                        color: Colors.black54,
                                                                        fontFamily: 'PoppinsMedium'),
                                                                  ),
                                                                )
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
                                              setState(() {
                                                _myPage.jumpToPage(1);
                                              });
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
                      backgroundColor: AppColors.bg_navy,
                      elevation: 0,
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.breakfast_dining_rounded),
                          SizedBox(width: 10,),
                          Text('Semua Produk',
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
                              future: getProducts("all", "id", "asc", "", "", ""),
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
                ),

                //#BANTUAN
                Scaffold(
                  backgroundColor: AppColors.container,
                  appBar: AppBar(
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: AppColors.bg_navy,
                    elevation: 0,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.article),
                        SizedBox(width: 10,),
                        Text('Riwayat Transaksi',
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

                //#AKUN
                accountPage(context, "admin"),
              ],
            ),
          )
        ),
        floatingActionButton: SizedBox(
          height: 65.0,
          width: 65.0,
          child: FittedBox(
            child: FloatingActionButton(
              backgroundColor: AppColors.bg_navy,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const AddProductPage(
                    code: "add",
                    id: "",
                    name: "",
                    price: "",
                    stock: "",
                    tags: "",
                    categories: "",
                    category: "",
                    desc: "",
                    image: "",
                  );
                  //return ImageUpload();
                }));
              },
              child: Icon(Icons.add_circle_outline_rounded),
              //child: Image.asset('assets/images/circle_bottomnav.png',)
            ),
          ),
        ),
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

void _launchURL(url) async =>
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';