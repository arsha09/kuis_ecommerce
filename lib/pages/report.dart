import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kuis_ecommerce/data/model.dart';
import 'package:kuis_ecommerce/data/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kuis_ecommerce/pages/admin.dart';
import 'package:kuis_ecommerce/pages/product_page.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';

import '../data/colors.dart';
import '../data/theme.dart';
import '../data/urls.dart';
import 'home.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with WidgetsBindingObserver {
  String filter = '%Y-%m';
  String dropdownvalue = 'Bulanan';
  final Map itemMaps = {
    'Bulanan' : '%Y-%m',
    'Harian' : '%Y-%m-%d',
  };
  var items = [
    'Bulanan',
    'Harian',
  ];

  String formatDate(String date, String dateFormat) {
    final DateFormat displayFormater = DateFormat(dateFormat);
    final DateTime displayDate = displayFormater.parse(date);
    String formattedDate = DateFormat.yMMMM().format(displayDate);
    return formattedDate;
  }

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
        backgroundColor: AppColors.bg_navy,
        elevation: 0,
        titleSpacing: 0,
        title: const Text('Laporan Penjualan',
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
        child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(28, 28, 28, 0),
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: AppColors.bg_grey),
                  ],
                ),
                child: DropdownButton(
                  isExpanded: true,
                  value: dropdownvalue,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: items.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownvalue = newValue!;
                      filter = itemMaps[newValue];
                    });
                  },
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  child: FutureBuilder(
                    future: getReports(filter),
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
                            return InkWell(
                              onTap: () {
                                //
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
                                                    dropdownvalue=='Bulanan' ? formatDate(snapshot.data[index].tanggal, 'yyyy-MM') : snapshot.data[index].tanggal,
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Colors.black54,
                                                        fontFamily: 'PoppinsMedium'),
                                                  ),
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
                                                "Total transaksi : ${snapshot.data[index].total_transaksi}",
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black54,
                                                    fontFamily: 'PoppinsRegular'),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Text(
                                                "Total produk terjual : ${snapshot.data[index].total_produk}",
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black54,
                                                    fontFamily: 'PoppinsRegular'),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Text(
                                                "Total omset : ${currencyFormatter.format(double.parse(snapshot.data[index].total_omset.toString())).toString().replaceAll('IDR', 'IDR. ')}",
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
    );
  }
}