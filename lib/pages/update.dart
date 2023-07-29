import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kuis_ecommerce/data/colors.dart';
import 'package:kuis_ecommerce/pages/admin.dart';

import '../data/theme.dart';
import '../data/urls.dart';
import '../data/utils.dart';
import 'home.dart';

class UpdatePage extends StatefulWidget{
  final String code;
  const UpdatePage({Key? key, required this.code}) : super(key: key);

  @override
  _UpdatePage createState() => _UpdatePage();
}

class _UpdatePage extends State<UpdatePage> with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKeyProfile = GlobalKey();
  final GlobalKey<FormState> _formKeyPassword = GlobalKey();
  bool _isLoad = false;
  String? name, phone, email, username, password, roles;
  bool _obscureLastPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController lastPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    getdata("name").then((value) {setState(() {nameController.text = value.toString();});});
    getdata("phone").then((value) {setState(() {phoneController.text = value.toString();});});
    getdata("email").then((value) {setState(() {emailController.text = value.toString();});});
    getdata("username").then((value) {setState(() {usernameController.text = value.toString();});});
    getdata("password").then((value) {setState(() {password = value.toString();});});
    getdata("roles").then((value) {setState(() {roles = value.toString();});});
    super.initState();
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
              decoration: InputDecoration(
                hintText: title,
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
        child:
        widget.code == "profile" ?
        Form(
          key: _formKeyProfile,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                margin: EdgeInsets.only(
                  top: defaultMargin,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/avatar.png',)
                  ),
                ),
              ),
              inputField("Nama Lengkap", TextInputType.name, nameController),
              inputField("Nomor HP", TextInputType.phone, phoneController),
              inputField("Email", TextInputType.emailAddress, emailController),
              inputField("Username", TextInputType.text, usernameController),
            ],
          ),
        ) :
        Form(
          key: _formKeyPassword,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Password saat ini",
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
                      keyboardType: TextInputType.visiblePassword,
                      controller: lastPasswordController,
                      obscureText: _obscureLastPassword,
                      decoration: InputDecoration(
                        hintText: "Password saat ini",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontFamily: 'PoppinsRegular',
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: subtitleColor,
                          ),
                        ),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureLastPassword = !_obscureLastPassword;
                              });
                            },
                            icon: _obscureLastPassword
                                ? const Icon(Icons.visibility_outlined)
                                : const Icon(Icons.visibility_off_outlined)
                        ),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Wajib diisi";
                        } else if (value != password) {
                          return "Password saat ini tidak sesuai";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Password baru",
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
                      keyboardType: TextInputType.visiblePassword,
                      controller: newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        hintText: "Password baru",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontFamily: 'PoppinsRegular',
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: subtitleColor,
                          ),
                        ),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                            icon: _obscureNewPassword
                                ? const Icon(Icons.visibility_outlined)
                                : const Icon(Icons.visibility_off_outlined)
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
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Konfirmasi password baru",
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
                      keyboardType: TextInputType.visiblePassword,
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: "Konfirmasi password baru",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontFamily: 'PoppinsRegular',
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: subtitleColor,
                          ),
                        ),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                            icon: _obscureConfirmPassword
                                ? const Icon(Icons.visibility_outlined)
                                : const Icon(Icons.visibility_off_outlined)
                        ),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Wajib diisi";
                        } else if (value != newPasswordController.text) {
                          return "Password baru tidak sesuai";
                        }
                        return null;
                      },
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
            backgroundColor: roles == "admin" ? AppColors.bg_navy : AppColors.red_accent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              widget.code == "profile" ? 'Edit Profile' : 'Change Password',
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                onPressed: () async {
                  var id_user = await getdata("id");
                  Map<String, String> mapLogin;
                  bool isValidate = false;

                  if (widget.code == "profile") {
                    if (_formKeyProfile.currentState?.validate() ?? false) {
                      isValidate = true;
                    }
                    mapLogin = {
                      'table': "users",
                      'id': id_user.toString(),
                      'name': nameController.text,
                      'phone': phoneController.text,
                      'email': emailController.text,
                      'username': usernameController.text
                    };
                  } else {
                    if (_formKeyPassword.currentState?.validate() ?? false) {
                      isValidate = true;
                    }
                    mapLogin = {
                      'table': "users",
                      'id': id_user.toString(),
                      'password': confirmPasswordController.text,
                    };
                  }

                  if (isValidate==true) {
                    setState(() {
                      _isLoad = true;
                    });

                    String urlLogin = Strings.URL_UPDATE;
                    postRequest(urlLogin, mapLogin).then((result) {
                      String? statusCode = "${result.statusCode}";
                      setState(() {
                        _isLoad = false;
                      });
                      if(statusCode.toString()=="200") {
                        var data = json.decode(result.body);

                        setdata("session","isLoggedIn");
                        setdata("id",data["data"]["id"].toString());
                        setdata("name",data["data"]["name"].toString());
                        setdata("email",data["data"]["email"].toString());
                        setdata("phone",data["data"]["phone"].toString());
                        setdata("username",data["data"]["username"].toString());
                        setdata("roles",data["data"]["roles"].toString());

                        if (widget.code == "password") {setdata("password",confirmPasswordController.text);}

                        showToast(context, "Update profil sukses");
                        //Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return roles=="admin" ? AdminPage() : HomePage();
                        }));
                      } else {
                        showToast(context, "Update profil gagal, coba lagi nanti");
                      }
                    });
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
