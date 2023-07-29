import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:kuis_ecommerce/pages/signin.dart';

import '../data/colors.dart';
import '../data/urls.dart';
import '../data/utils.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodeName = FocusNode();
  final FocusNode _focusNodePhone = FocusNode();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodeUsername = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeConfirmPassword = FocusNode();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerPhone = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool _obscurePassword = true;
  final Box _boxLogin = Hive.box("login");
  final Box _boxAccounts = Hive.box("accounts");

  bool _isLoad = false;

  @override
  Widget build(BuildContext context) {
    // if (_boxLogin.get("loginStatus") ?? false) {
    //   return Home();
    // }

    return Stack(
      children: [
        Scaffold(
          //backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(statusBarColor: AppColors.red_accent,),
            child: Container(
              decoration: const BoxDecoration(
                  //color: Colors.white,
                  image: DecorationImage(
                      image: AssetImage("assets/images/bg_splash.png"), fit: BoxFit.cover)
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Image.asset('assets/images/kuis_logo.png', height: 100, width: 100,),
                      const SizedBox(height: 10),
                      Text(
                        "Registrasi Akun",
                        style: TextStyle(
                          fontSize: 28,
                          color: AppColors.red_accent,
                          fontFamily: 'PoppinsSemiBold',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Mohon lengkapi data-data berikut ini",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'PoppinsRegular',
                        ),
                      ),
                      const SizedBox(height: 50),
                      TextFormField(
                        controller: _controllerName,
                        focusNode: _focusNodeName,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: "Nama Lengkap",
                          prefixIcon: const Icon(Icons.person_pin_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onEditingComplete: () => _focusNodeEmail.requestFocus(),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter name.";
                          // } else if (!_boxAccounts.containsKey(value)) {
                          //   return "Username is not registered.";
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _controllerPhone,
                        focusNode: _focusNodePhone,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Nomor HP",
                          prefixIcon: const Icon(Icons.phone_iphone_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter phone.";
                          // } else if (!(value.contains('@') && value.contains('.'))) {
                          //   return "Invalid email";
                          }
                          return null;
                        },
                        onEditingComplete: () => _focusNodeUsername.requestFocus(),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _controllerEmail,
                        focusNode: _focusNodeEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter email.";
                          // } else if (!(value.contains('@') && value.contains('.'))) {
                          //   return "Invalid email";
                          }
                          return null;
                        },
                        onEditingComplete: () => _focusNodeUsername.requestFocus(),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _controllerUsername,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onEditingComplete: () => _focusNodePassword.requestFocus(),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter username.";
                          // } else if (!_boxAccounts.containsKey(value)) {
                          //   return "Username is not registered.";
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _controllerPassword,
                        focusNode: _focusNodePassword,
                        obscureText: _obscurePassword,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.vpn_key_outlined),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: _obscurePassword
                                  ? const Icon(Icons.visibility_outlined)
                                  : const Icon(Icons.visibility_off_outlined)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter password.";
                          // } else if (value !=
                          //     _boxAccounts.get(_controllerUsername.text)) {
                          //   return "Wrong password.";
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                // _boxLogin.put("loginStatus", true);
                                // _boxLogin.put("userName", _controllerUsername.text);

                                setState(() {
                                  _isLoad = true;
                                });

                                String urlLogin = Strings.URL_REGISTER;
                                Map<String, String> mapLogin = {
                                  'name': _controllerName.text,
                                  'email': _controllerEmail.text,
                                  'phone': _controllerPhone.text,
                                  'roles': "customer",
                                  'username': _controllerUsername.text,
                                  'password': _controllerPassword.text
                                };

                                postRequest(urlLogin, mapLogin).then((result) {
                                  String? statusCode = "${result.statusCode}";
                                  setState(() {
                                    _isLoad = false;
                                  });
                                  if(statusCode.toString()=="200") {
                                    Navigator.pop(context);
                                  } else {
                                    showToast(context, "Registrasi gagal, coba lagi beberapa saat");
                                  }
                                });

                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) {
                                //       return Home();
                                //     },
                                //   ),
                                // );
                              }
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Sudah punya akun?",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontFamily: 'PoppinsRegular',
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _formKey.currentState?.reset();
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.red_accent,
                                    fontFamily: 'PoppinsRegular',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
    );
  }

  @override
  void dispose() {
    _focusNodePassword.dispose();
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }
}