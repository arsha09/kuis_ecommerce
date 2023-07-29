import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:kuis_ecommerce/data/colors.dart';
import 'package:kuis_ecommerce/pages/admin.dart';

import '../data/model.dart';
import '../data/theme.dart';
import '../data/urls.dart';
import '../data/utils.dart';

class AddProductPage extends StatefulWidget{
  final String code, id, name, price, stock, tags, categories, category, desc, image;
  const AddProductPage({
    Key? key,
    required this.code,
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.tags,
    required this.categories,
    required this.category,
    required this.desc,
    required this.image
  }) : super(key: key);

  @override
  _AddProductPage createState() => _AddProductPage();
}

class _AddProductPage extends State<AddProductPage> with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKeyProduct = GlobalKey();
  bool _isLoad = false;
  String? name, phone, email, username, password, roles;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String dropdownvalue = '--Pilih Kategori--';
  var items = ['--Pilih Kategori--',];
  Map<String, String> someMap = {'--Pilih Kategori--': '0'};

  ImagePicker picker = ImagePicker();
  XFile? image;

  @override
  void initState() {
    getdata("roles").then((value) {setState(() {roles = value.toString();});});
    if(widget.code=="edit") {
      setState(() {
        dropdownvalue = widget.category;
        items = [widget.category,];
        someMap = {widget.category: widget.categories};
      });

      nameController.text = widget.name;
      priceController.text = widget.price;
      stockController.text = widget.stock;
      tagsController.text = widget.tags;
      descriptionController.text = widget.desc;
    }
    super.initState();
  }

  Future<List<General>> getAllData() async {
    String url = Strings.URL_ALL_DATA;
    Map<String, String> maps = {
      'table': "product_categories",
      'where': "false",
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

    items.clear();
    items.add('--Pilih Kategori--');
    someMap["--Pilih Kategori--"] = "0";
    List<General> contents = [];
    for (var singleCabang in data) {
      General content = General(
        id: singleCabang["id"].toString(),
        title: singleCabang["name"].toString(),
        content: "",);

      contents.add(content);
      items.add(singleCabang["name"].toString());
      someMap[singleCabang["name"].toString()] = singleCabang["id"].toString();
    }

    return contents;
  }

  Future<void> chooseImage() async {
    var choosedimage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = choosedimage;
    });
  }

  @override
  Widget build(BuildContext context) {

    Widget inputField(String title, TextInputType type, TextEditingController controller) {
      return Container(
        margin: EdgeInsets.only(
          top: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'PoppinsMedium',
              ),
            ),
            TextFormField(
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'PoppinsRegular',
              ),
              keyboardType: type,
              controller: controller,
              maxLines: null,
              decoration: InputDecoration(
                hintText: title=="Tags" ? "Tags (pisahkan dengan koma)" : title,
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: 'PoppinsRegular',
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: subtitleColor,
                  ),
                ),
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Wajib diisi";
                }
                return null;
              },
            ),
          ],
        ),
      );
    }

    Widget content() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: defaultMargin,
        ),
        margin: EdgeInsets.only(bottom: 50),
        child: Form(
          key: _formKeyProduct,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FutureBuilder(
                future: getAllData(),
                builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container();
                  } else {
                    return Container(
                      margin: EdgeInsets.only(
                        top: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Kategori",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'PoppinsMedium',
                            ),
                          ),
                          DropdownButton(
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
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              inputField("Nama Produk", TextInputType.name, nameController),
              inputField("Harga", TextInputType.number, priceController),
              inputField("Stok", TextInputType.number, stockController),
              inputField("Tags", TextInputType.text, tagsController),
              inputField("Deskripsi", TextInputType.multiline, descriptionController),
              Container(
                margin: EdgeInsets.only(top: 16.0),
                alignment: Alignment.center,
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center, //content alignment to center
                  children: <Widget>[
                    Container(  //show image here after choosing image
                        child:
                        widget.code == "edit" && widget.image != "null" && image == null ?
                        Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),//elese show image here
                            child: SizedBox(
                              // height:150,
                                child: Image.network("${Strings.URL_IMG}${widget.image}"),
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

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.bg_navy,
                        minimumSize: const Size.fromHeight(40), // NEW
                      ),
                      onPressed: () {
                        chooseImage(); // call choose image function
                      },
                      child: Text(
                        image == null ? 'Upload Foto Produk' : 'Ganti Foto Produk',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'PoppinsRegular'
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: AppColors.bg_navy,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Tambah Produk Baru',
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                onPressed: () async {
                  if (_formKeyProduct.currentState?.validate() ?? false) {
                    if(someMap[dropdownvalue.toString()] == "0") {
                      showToast(context, "Pilih kategori terlebih dahulu");
                    } else {
                      if(widget.code=="add") {
                        if(image.toString() == "null") {
                          showToast(context, "Upload Foto Produk");
                        } else {
                          setState(() {
                            _isLoad = true;
                          });

                          String urlLogin = Strings.URL_ADD_PRODUCT;
                          Map<String, String> mapLogin = {
                            'name': nameController.text,
                            'price': priceController.text,
                            'stock': stockController.text,
                            'description': descriptionController.text,
                            'tags': tagsController.text,
                            'categories_id': someMap[dropdownvalue.toString()].toString()
                          };

                          postRequest(urlLogin, mapLogin).then((result) {
                            String? statusCode = "${result.statusCode}";

                            if(statusCode.toString()=="200") {
                              var data = json.decode(result.body);

                              String urlGalleries = Strings.URL_ADD_PRODUCT_GALLERIES;
                              Map<String, String> mapGalleries = {
                                'products_id': data["data"]["id"].toString(),
                                'url': 'product${data["data"]["id"].toString()}-1.jpg',
                              };

                              postRequest(urlGalleries, mapGalleries).then((result) {
                                String? statusCode = "${result.statusCode}";
                                setState(() {
                                  _isLoad = false;
                                });

                                if(statusCode.toString()=="200") {
                                  uploadImage("product${data["data"]["id"].toString()}-1", image!, "product");
                                  showToast(context, "Tambah produk berhasil!");
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return AdminPage();
                                  }));
                                } else {
                                  showToast(context, "Tambah produk gagal, coba lagi nanti");
                                }
                              });
                            } else {
                              showToast(context, "Tambah produk gagal, coba lagi nanti");
                            }
                          });
                        }
                      } else {
                        setState(() {
                          _isLoad = true;
                        });

                        String urlUpdate = Strings.URL_UPDATE;
                        Map<String, String> mapUpdate = {
                          'table': "products",
                          'id': widget.id,
                          'name': nameController.text,
                          'price': priceController.text,
                          'stock': stockController.text,
                          'description': descriptionController.text,
                          'tags': tagsController.text,
                          'categories_id': someMap[dropdownvalue.toString()].toString()
                        };
                        postRequest(urlUpdate, mapUpdate).then((result) {
                          String? statusCode = "${result.statusCode}";
                          setState(() {
                            _isLoad = false;
                          });
                          if(statusCode.toString()=="200") {
                            if(image!=null) {
                              uploadImage("product${widget.id}-1", image!, "product");
                            }
                            showToast(context, "Update produk berhasil!");
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return AdminPage();
                            }));
                          } else {
                            showToast(context, "Update profil gagal, coba lagi nanti");
                          }
                        });
                      }
                    }
                  }
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: [
                content(),
              ],
            ),
          ),
          // resizeToAvoidBottomInset: false,
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