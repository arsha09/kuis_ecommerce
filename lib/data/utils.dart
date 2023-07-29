import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kuis_ecommerce/data/colors.dart';
import 'package:kuis_ecommerce/data/theme.dart';
import 'package:kuis_ecommerce/data/urls.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../pages/general.dart';
import '../pages/signin.dart';
import '../pages/update.dart';
import 'model.dart';

final currencyFormatter = NumberFormat.currency(locale: 'ID');
void setdata(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

Future<String?> getdata(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? stringValue = prefs.getString(key);
  return stringValue;
}

Future<bool> cekdata(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool boolValue = prefs.containsKey(key);
  return boolValue;
}

void cleardata(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

Future<http.Response> postRequest(String url, Map<String, String> map) async {
  var body = json.encode(map);

  var response = await http.post(Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: body
  );
  print("$map");
  print("${response.statusCode}");
  print("${response.body}");
  return response;
}

Future<http.Response> getRequest(String url) async {
  var response = await http.get(Uri.parse(url));
  print("${response.statusCode}");
  print("${response.body}");
  return response;
}

void showToast(BuildContext context, String message) {
  // final scaffold = ScaffoldMessenger.of(context);
  // scaffold.showSnackBar(
  //   SnackBar(
  //     content: const Text('Added to favorite'),
  //     action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
  //   ),
  // );
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

String capitalizeAllWord(String value) {
  var result = value[0].toUpperCase();
  for (int i = 1; i < value.length; i++) {
    if (value[i - 1] == " ") {
      result = result + value[i].toUpperCase();
    } else {
      result = result + value[i];
    }
  }
  return result;
}

String convertDateTimeDisplay(String date, String dateFormat) {
  final DateFormat displayFormater = DateFormat(dateFormat);
  final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
  final DateTime displayDate = displayFormater.parse(date);
  final String formatted = serverFormater.format(displayDate);
  return formatted;
}

Widget accountPage(BuildContext context, String roles) {
  return Column(
      children: <Widget>[
        AppBar(
          backgroundColor: roles == "admin" ? AppColors.bg_navy : AppColors.red_accent,
          automaticallyImplyLeading: false,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Container(
              padding: EdgeInsets.all(
                defaultMargin,
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset('assets/images/avatar.png', width: 64,),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String?>(
                            future: getdata("name"),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  capitalizeAllWord(snapshot.data!.toLowerCase()),
                                  // capitalizeAllWord(name!.toLowerCase()),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'PoppinsMedium',
                                      color: Colors.white
                                  ),
                                );
                              }
                              return SizedBox(
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
                              );
                            }
                        ),

                        FutureBuilder<String?>(
                            future: getdata("username"),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  "@${snapshot.data!.toLowerCase()}",
                                  // "@${username}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'PoppinsRegular',
                                      color: Colors.white
                                  ),
                                );
                              }
                              return Container(
                                margin: EdgeInsets.only(top: 8.0),
                                child: SizedBox(
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
                              );
                            }
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: defaultMargin,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  'General',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'PoppinsSemiBold',
                  ),
                ),
                menuItem(context, 'Privacy & Policy',), 
                menuItem(context, 'Term of Service',),
                //menuItem(context, 'Rate App',),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'PoppinsSemiBold',
                  ),
                ),
                menuItem(context, 'Edit Profile',),
                menuItem(context, 'Change Password',),
                menuItem(context, 'Logout',),
              ],
            ),
          ),
        ),
      ]
  );
}

Widget menuItem(BuildContext context, String text) {
  return InkWell(
    onTap: () {
      if(text=='Logout') {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Anda yakin ingin keluar dari akun?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  cleardata("session");
                  cleardata("id");
                  cleardata("name");
                  cleardata("phone");
                  cleardata("email");
                  cleardata("username");
                  cleardata("password");
                  cleardata("roles");
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                        return SignInPage();
                      }));
                  //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignInPage()));
                },
                child: const Text('Keluar'),
              ),
            ],
          ),
        );
      } else if (text=="Edit Profile") {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return UpdatePage(code: "profile",);
        }));
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return UpdatePage(code: "profile",);
        // })).then((_) {
        //   context.widget.callback(new NextPage());
        // });
      } else if (text=="Change Password") {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return UpdatePage(code: "password",);
        }));
      } else if (text=="Privacy & Policy") {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return GeneralPage(id: "1", title: "Term of Service",);
        }));
      } else if (text=="Term of Service") {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return GeneralPage(id: "2", title: "Term of Service",);
        }));
      }
    },
    child: Container(
      margin: EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
                fontSize: 14,
                fontFamily: 'PoppinsRegular'
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.black54,
          ),
        ],
      ),
    ),
  );
}

Widget pillStatus(String status, bool isExpired) {
  return Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: status == "5" ? Color.fromRGBO(205,255,199, 1) :
        status == "1" || isExpired ? Color.fromRGBO(255,199,207, 1) :
        Color.fromRGBO(255,252,150, 1)
    ),
    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
    child: Text(
      isExpired ? "Expired" :
      status == "5" ? "Selesai" :
      status == "4" ? "Sedang dikirim" :
      status == "3" ? "Sedang diproses" :
      status == "2" ? "Pending" :
      "Belum dibayar",
      style: TextStyle(
          fontSize: 12.0,
          color: Colors.black54,
          fontFamily: 'PoppinsRegular'),
    ),
  );
}

class shimmerCabang extends StatelessWidget {
  const shimmerCabang({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 80,
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.white,
                child: Container(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                  const SizedBox(
                    height: 10,
                  ),SizedBox(
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
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 12,
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
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class shimmerList extends StatelessWidget {
  const shimmerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                  const SizedBox(
                    height: 10,
                  ),SizedBox(
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
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 12,
                    width: 250,
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
              ),
            ),
          )
        ],
      ),
    );
  }
}

Future<void> uploadImage(String product_id, XFile image, String directory) async {
  String uploadurl = "${Strings.ROOT_URL}image_upload.php";

  try{
    List<int> imageBytes = File(image.path).readAsBytesSync();
    String baseimage = base64Encode(imageBytes);
    var response = await http.post(
        Uri.parse(uploadurl),
        body: {
          'image': baseimage,
          'directory': directory,
          'filename': product_id,
        }
    );
    if(response.statusCode == 200){
      var jsondata = json.decode(response.body); //decode json data
      if(jsondata["error"]){ //check error sent from server
        print(jsondata["msg"]);
      }else{
        print("Upload successful");
      }
    }else{
      print("Error during connection to server");
    }
  }catch(e){
    print("Error during converting to Base64");
  }
}

Future<List<Products>> getProducts(String model, String order_by, String order, String limit, String where, String value) async {
  String url = Strings.URL_PRODUCTS;
  Map<String, String> maps = {
    'model': model,
    'order_by': order_by,
    'order': order
  };

  if(model=='limit') {
    maps['limit'] = limit;
  } else  if(model=='where'){
    maps['where'] = where;
    maps['value'] = value;
    if(limit!="") {
      maps['limit'] = limit;
    }
  }

  var body = json.encode(maps);
  var response = await http.post(Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: body
  );

  var responseData = json.decode(response.body);
  var data = responseData['data'];

  print("$maps");
  print("${response.statusCode}");
  print("${response.body}");

  List<Products> contents = [];
  for (var singleCabang in data) {
    Products content = Products(
      id: singleCabang["id"].toString(),
      name: singleCabang["name"].toString(),
      price: singleCabang["price"].toString(),
      stock: singleCabang["stock"].toString(),
      sold: singleCabang["sold"].toString(),
      description: singleCabang["description"].toString(),
      tags: singleCabang["tags"].toString(),
      categories: singleCabang["categories_id"].toString(),
      url: singleCabang["url"].toString(),
      category: singleCabang["category"].toString(),);

    contents.add(content);
  }

  return contents;
}

Future<List<Transactions>> getTransactions(String id, String status, String order_by, String order) async {
  String? id_user = await getdata("id");
  String? roles = await getdata("roles");
  String url = Strings.URL_TRANSACTIONS;
  Map<String, String> maps = {
    'users_id': roles=="admin" ? "admin" : id_user.toString(),
    'order_by': order_by,
    'order': order,
  };

  if(id!="" && status=="") {
    maps['id'] = id;
  } else if(status!=""){
    maps['status'] = status;
  }

  var body = json.encode(maps);
  var response = await http.post(Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: body
  );

  var responseData = json.decode(response.body);
  var data = responseData['data'];

  print("$maps");
  print("${response.statusCode}");
  print("${response.body}");

  List<Transactions> contents = [];
  for (var singleCabang in data) {
    Transactions content = Transactions(
      id: singleCabang["id"].toString(),
      transaction_code: singleCabang["transaction_code"].toString(),
      users_id: singleCabang["users_id"].toString(),
      address: singleCabang["address"].toString(),
      total_price: singleCabang["total_price"].toString(),
      shipping_price: singleCabang["shipping_price"].toString(),
      status: singleCabang["status"].toString(),
      payment: singleCabang["payment"].toString(),
      bukti_transfer: singleCabang["bukti_transfer"].toString(),
      expired_time: singleCabang["expired_time"].toString(),
      created_at: singleCabang["created_at"].toString(),);

    contents.add(content);
  }

  return contents;
}

Future<List<TransactionItems>> getTransactionItems(String users_id, String trx_id, String qty) async {
  String? id_user = await getdata("id");
  String url = Strings.URL_TRANSACTION_ITEMS;
  Map<String, String> maps = {
    'users_id': users_id == "" ? id_user.toString() : users_id,
    'transactions_id': trx_id.toString(),
  };
  if(qty!="") {
    maps['quantity'] = qty;
  }

  var body = json.encode(maps);
  var response = await http.post(Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: body
  );

  var responseData = json.decode(response.body);
  var data = responseData['data'];

  print("$maps");
  print("${response.statusCode}");
  print("${response.body}");

  List<TransactionItems> contents = [];
  for (var singleCabang in data) {
    TransactionItems content = TransactionItems(
      id: singleCabang["id"].toString(),
      users_id: singleCabang["users_id"].toString(),
      products_id: singleCabang["products_id"].toString(),
      quantity: singleCabang["quantity"].toString(),
      transactions_id: singleCabang["transactions_id"].toString(),
      transaction_code: singleCabang["transaction_code"].toString(),
      product: singleCabang["product"].toString(),
      price: singleCabang["price"].toString(),
      stock: singleCabang["stock"].toString(),
      url: singleCabang["url"].toString(),
      categories_id: singleCabang["categories_id"].toString(),
      category: singleCabang["category"].toString(),);

    contents.add(content);
  }

  return contents;
}

Future<List<Reports>> getReports(filter) async {
  String url = Strings.URL_REPORTS;
  Map<String, String> maps = {
    'filter': filter,
  };

  var body = json.encode(maps);
  var response = await http.post(Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: body
  );

  var responseData = json.decode(response.body);
  var data = responseData['data'];

  print("$maps");
  print("${response.statusCode}");
  print("${response.body}");

  List<Reports> contents = [];
  for (var singleCabang in data) {
    Reports content = Reports(
      tanggal: singleCabang["tanggal"].toString(),
      total_transaksi: singleCabang["total_transaksi"].toString(),
      total_omset: singleCabang["total_omset"].toString(),
      total_produk: singleCabang["total_produk"].toString(),
    );

    contents.add(content);
  }

  return contents;
}