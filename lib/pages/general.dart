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
import '../data/urls.dart';

class GeneralPage extends StatefulWidget {
  final String id;
  final String title;
  const GeneralPage({Key? key, required this.id, required this.title}) : super(key: key);

  @override
  _GeneralPageState createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> with WidgetsBindingObserver {
  String? roles;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    print("oncreate");
    getdata("roles").then((value) {setState(() {roles = value.toString();});});
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

  Future<List<General>> getAllData() async {
    String url = Strings.URL_ALL_DATA;
    Map<String, String> maps = {
      'table': "contents",
      'where': "true",
      'value': "id = ${widget.id}",
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

    List<General> contents = [];
    for (var singleCabang in data) {
      General content = General(
        id: singleCabang["id"].toString(),
        title: singleCabang["title"].toString(),
        content: singleCabang["content"].toString(),);

      contents.add(content);
    }

    return contents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: roles == "admin" ? AppColors.bg_navy : AppColors.red_accent,
        elevation: 0,
        titleSpacing: 0,
        title: Text(widget.title,
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
                child: FutureBuilder(
                  future: getAllData(),
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
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        child: Text(
                          snapshot.data[0].content,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontFamily: 'PoppinsRegular',
                          ),
                        ),
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