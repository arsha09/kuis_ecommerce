import 'dart:convert';
import 'package:image_picker/image_picker.dart';
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

class TransactionPage extends StatefulWidget {
  final String transaction_id;
  const TransactionPage({Key? key, required this.transaction_id}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> with WidgetsBindingObserver {
  String? roles;
  ImagePicker picker = ImagePicker();
  XFile? image;

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

  Future<void> chooseImage() async {
    var choosedimage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = choosedimage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.container,
      appBar: AppBar(
        backgroundColor: roles == "admin" ? AppColors.bg_navy : AppColors.red_accent,
        elevation: 0,
        titleSpacing: 0,
        title: const Text('Detail Transaksi',
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

      body: FutureBuilder(
          future: getTransactions(widget.transaction_id, "", "id", "asc"),
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(
                margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: <Widget>[
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
              bool isExpired = false;
              if(snapshot.data[0].expired_time != "null") {
                if(DateTime.parse(snapshot.data[0].expired_time).isBefore(DateTime.now()) && snapshot.data[0].status == "1") {
                  isExpired = true;
                } else {
                  isExpired = false;
                }
              } else {
                isExpired = false;
              }
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
              SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Column(
                    children: <Widget>[
                      SizedBox(height: 20,),
                      Container(
                        margin: EdgeInsets.only(
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
                              'Rincian',
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
                                  'ID Transaksi',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'PoppinsRegular'
                                  ),
                                ),
                                Text(
                                  snapshot.data[0].transaction_code,
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
                                  'Tanggal transaksi',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'PoppinsRegular'
                                  ),
                                ),
                                Text(
                                  snapshot.data[0].created_at,
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
                                  'Status',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'PoppinsRegular'
                                  ),
                                ),
                                pillStatus(snapshot.data[0].status, isExpired)
                              ],
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Text(
                              'Keterangan',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'PoppinsRegular'
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              isExpired ? 'Transaksi dibatalkan dan harus diulang karena melewati batas waktu pembayaran' :
                              snapshot.data[0].status == "5" ? "Transaksi telah selesai dan barang sudah diterima oleh pelanggan" :
                              snapshot.data[0].status == "4" ? "Produk sedang dalam proses pengiriman ke alamat pelanggan" :
                              snapshot.data[0].status == "3" ? "Transaksi telah diterima dan sedang diproses oleh penjual" :
                              snapshot.data[0].status == "2" ? "Transaksi sedang menunggu konfirmasi dari penjual" :
                              "Transaksi belum di bayar dan harus dibayarkan sebelum tenggat waktu",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontFamily: 'PoppinsRegular'
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                future: getTransactionItems("", snapshot.data[0].id, ""),
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
                                        return Row(
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
                                                "X${snapshot.data[index].quantity}",
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black54,
                                                    fontFamily: 'PoppinsMedium'),
                                              ),
                                            ),
                                          ],
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
                        margin: EdgeInsets.only(
                            top: defaultMargin,
                            bottom: defaultMargin,
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
                                  // snapshot.data[0].total_price,
                                  "${currencyFormatter.format(double.parse(snapshot.data[0].total_price.toString())).toString().replaceAll('IDR', '')}",
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
                                  // 'IDR. ${snapshot.data[0].total_price}',
                                  "${currencyFormatter.format(double.parse(snapshot.data[0].total_price.toString())).toString().replaceAll('IDR', 'IDR. ')}",
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
                      Visibility(
                        visible: roles=="customer" && (snapshot.data[0].status == "1" || snapshot.data[0].status == "2") && !isExpired,
                        child: Container(
                          margin: EdgeInsets.only(
                              top: 0,
                              bottom: defaultMargin,
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
                                'Konfirmasi pembayaran',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'PoppinsSemiBold'
                                ),
                              ),
                              Visibility(
                                visible: snapshot.data[0].expired_time != "null",
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Mohon lakukan pembayaran sebelum ${snapshot.data[0].expired_time}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'PoppinsRegular'
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 16.0),
                                alignment: Alignment.center,
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.center, //content alignment to center
                                  children: <Widget>[
                                    Container(  //show image here after choosing image
                                        child:
                                        snapshot.data[0].bukti_transfer != "null" && image == null ?
                                        Container(
                                            margin: EdgeInsets.symmetric(vertical: 8.0),//elese show image here
                                            child: SizedBox(
                                              // height:150,
                                              child: Image.network("${Strings.URL_IMG_TRANSFER}${snapshot.data[0].bukti_transfer}"),
                                            )
                                        ) :
                                        image == null?
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey, width: 1.5),
                                              borderRadius: BorderRadius.all(Radius.circular(5))
                                          ),
                                          child: Icon(Icons.image_outlined, size: 75, color: Colors.grey,),
                                        ) : //if uploadimage is null then show empty container
                                        Container(
                                            margin: EdgeInsets.symmetric(vertical: 8.0),//elese show image here
                                            child: SizedBox(
                                              // height:150,
                                                child:Image.file(File(image!.path)) //load image from file
                                            )
                                        )
                                    ),

                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        // shape: RoundedRectangleBorder(
                                        //   borderRadius: BorderRadius.circular(10),
                                        // ),
                                        side: BorderSide(color: AppColors.red_accent, width: 1),
                                      ),
                                      onPressed: () {
                                        chooseImage(); // call choose image function
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.photo_library_outlined, size: 20, color: AppColors.red_accent,),
                                          SizedBox(width: 5,),
                                          Text(
                                            image == null ? 'Pilih Foto' : 'Ganti Foto',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'PoppinsRegular'
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: AppColors.red_accent,
                                        minimumSize: const Size.fromHeight(40), // NEW
                                      ),
                                      onPressed: () {
                                        if(image==null) {
                                          showToast(context, "Bukti pembayaran belum dipilih/diganti");
                                        } else {
                                          String urlLogin = Strings.URL_UPDATE;
                                          Map<String, String> mapLogin = {
                                            'table': "transactions",
                                            'id': snapshot.data[0].id,
                                            'status': "2",
                                            'bukti_transfer': "${snapshot.data[0].transaction_code}.jpg"
                                          };

                                          postRequest(urlLogin, mapLogin).then((result) {
                                            String? statusCode = "${result.statusCode}";
                                            if(statusCode.toString()=="200") {
                                              uploadImage(snapshot.data[0].transaction_code, image!, "bukti_transfer");
                                              showToast(context, "Konfirmasi pembayaran berhasil!");
                                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                return HomePage();
                                              }));
                                            } else {
                                              showToast(context, "Konfirmasi gagal, coba lagi nanti");
                                            }
                                          });
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.upload, size: 20, color: Colors.white,),
                                          SizedBox(width: 5,),
                                          Text(
                                            'Upload Bukti Pembayaran',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'PoppinsRegular'
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: roles=="admin" && snapshot.data[0].status == "2" && !isExpired,
                        child: Container(
                          margin: EdgeInsets.only(
                              top: 0,
                              bottom: defaultMargin,
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
                                'Konfirmasi pembayaran',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'PoppinsSemiBold'
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 16.0),
                                alignment: Alignment.center,
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.center, //content alignment to center
                                  children: <Widget>[
                                    Container(  //show image here after choosing image
                                        child:
                                        snapshot.data[0].bukti_transfer != "null" ?
                                        Container(
                                            margin: EdgeInsets.symmetric(vertical: 8.0),//elese show image here
                                            child: SizedBox(
                                              // height:150,
                                              child: Image.network("${Strings.URL_IMG_TRANSFER}${snapshot.data[0].bukti_transfer}"),
                                            )
                                        ) :
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey, width: 1.5),
                                              borderRadius: BorderRadius.all(Radius.circular(5))
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey,),
                                              Text(
                                                'Tidak ada foto\nbukti pembayaran',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                    fontFamily: 'PoppinsRegular'
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                    ),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: AppColors.bg_navy,
                                        minimumSize: const Size.fromHeight(40), // NEW
                                      ),
                                      onPressed: () {
                                        if(snapshot.data[0].bukti_transfer == "null") {
                                          showToast(context, "Bukti pembayaran belum diupload customer");
                                        } else {
                                          showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) => AlertDialog(
                                              title: const Text('Konfirmasi Pembayaran'),
                                              content: Text('Pastikan bukti pembayaran telah valid dan pembayaran telah Anda terima'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    String urlLogin = Strings.URL_UPDATE;
                                                    Map<String, String> mapLogin = {
                                                      'table': "transactions",
                                                      'id': snapshot.data[0].id,
                                                      'status': "3",
                                                    };

                                                    postRequest(urlLogin, mapLogin).then((result) {
                                                      String? statusCode = "${result.statusCode}";
                                                      if(statusCode.toString()=="200") {
                                                        showToast(context, "Konfirmasi pembayaran berhasil!");
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                          return AdminPage();
                                                        }));
                                                      } else {
                                                        showToast(context, "Konfirmasi gagal, coba lagi nanti");
                                                      }
                                                    });
                                                  },
                                                  child: const Text('Konfirmasi'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle_outline, size: 20, color: Colors.white,),
                                          SizedBox(width: 5,),
                                          Text(
                                            'Konfirmasi Pembayaran',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'PoppinsRegular'
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: ((roles=="admin" && snapshot.data[0].status == "3") || (roles=="customer" && snapshot.data[0].status == "4")) && !isExpired,
                        child: Container(
                          margin: EdgeInsets.only(
                              top: 0,
                              bottom: defaultMargin,
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
                                'Konfirmasi status',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'PoppinsSemiBold'
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  roles=="admin" && snapshot.data[0].status == "3" ?
                                  'Mohon update status transaksi untuk memberikan informasi ke pelanggan.' :
                                  'Mohon update status transaksi untuk menyelesaikan transaksi.',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'PoppinsRegular'
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center, //content alignment to center
                                children: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: roles=="admin" ? AppColors.bg_navy : AppColors.red_accent,
                                      minimumSize: const Size.fromHeight(40), // NEW
                                    ),
                                    onPressed: () {
                                      showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) => AlertDialog(
                                          title: const Text('Konfirmasi Status'),
                                          content: Text(
                                              roles=="admin" && snapshot.data[0].status == "3" ? "Anda yakin ingin merubah status transaksi produk sedang dikirim" :
                                              "Pastikan produk telah Anda terima dengan baik"
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                String urlLogin = Strings.URL_UPDATE;
                                                Map<String, String> mapLogin = {
                                                  'table': "transactions",
                                                  'id': snapshot.data[0].id,
                                                  'status': roles=="admin" && snapshot.data[0].status == "3" ? "4" : "5",
                                                };

                                                postRequest(urlLogin, mapLogin).then((result) {
                                                  String? statusCode = "${result.statusCode}";
                                                  if(statusCode.toString()=="200") {
                                                    showToast(context, "Konfirmasi status berhasil!");
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                      return AdminPage();
                                                    }));
                                                  } else {
                                                    showToast(context, "Konfirmasi gagal, coba lagi nanti");
                                                  }
                                                });
                                              },
                                              child: const Text('Konfirmasi'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(snapshot.data[0].status == "3" ? Icons.local_shipping_outlined : Icons.check_circle_outline, size: 20, color: Colors.white,),
                                        SizedBox(width: 5,),
                                        Text(
                                          snapshot.data[0].status == "3" ? 'Produk sedang dikirim' : 'Transaksi selesai',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'PoppinsRegular'
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                ),
              );
            }
          },
        ),
    );
  }
}