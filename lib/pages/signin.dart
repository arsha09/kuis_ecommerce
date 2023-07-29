import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:kuis_ecommerce/pages/admin.dart';
import 'package:kuis_ecommerce/pages/home.dart';
import 'package:kuis_ecommerce/pages/signup.dart';

import '../data/colors.dart';
import '../data/urls.dart';
import '../data/utils.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodePassword = FocusNode();
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
                      const SizedBox(height: 100),
                      Image.asset('assets/images/kuis_logo.png', height: 100, width: 100,),
                      const SizedBox(height: 10),
                      Text(
                        "Selamat Datang",
                        style: TextStyle(
                          fontSize: 28,
                          color: AppColors.red_accent,
                          fontFamily: 'PoppinsSemiBold',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Silahkan masuk dengan akun Anda",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'PoppinsRegular',
                        ),
                      ),
                      const SizedBox(height: 50),
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

                                String urlLogin = Strings.URL_LOGIN;
                                Map<String, String> mapLogin = {
                                  'username': _controllerUsername.text,
                                  'password': _controllerPassword.text
                                };

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
                                    setdata("password",_controllerPassword.text);
                                    setdata("roles",data["data"]["roles"].toString());

                                    if(data["data"]["roles"].toString()=="admin") {
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AdminPage()));
                                    } else {
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
                                    }
                                  } else {
                                    showToast(context, "Username dan password tidak sesuai");
                                  }
                                });

                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) {
                                //       return HomePage();
                                //     },
                                //   ),
                                // );
                              }
                            },
                            child: const Text(
                              "Login",
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
                                "Belum punya akun?",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontFamily: 'PoppinsRegular',
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _formKey.currentState?.reset();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const SignUpPage();
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                  "Registrasi",
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