import 'dart:async';
import 'package:kuis_ecommerce/data/colors.dart';
import 'package:kuis_ecommerce/data/utils.dart';
import 'package:flutter/material.dart';
import 'package:kuis_ecommerce/pages/admin.dart';
import 'package:kuis_ecommerce/pages/signin.dart';

import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  startSplashScreen() async {
    var duration = const Duration(seconds: 5);
    return Timer(duration, () {
      cekdata("session").then((value) {
        if(value.toString()=="true") {
          getdata("roles").then((value) {
            if(value=="admin") {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AdminPage()));
            } else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
            }
          });
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignInPage()));
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startSplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            // color: Colors.white,
            image: DecorationImage(
                image: AssetImage("assets/images/bg_splash.png"), fit: BoxFit.cover)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Image.asset('assets/images/kuis_logo.png', height: 150, width: 150,)),
          ],
        )
        // child: SizedBox(
        //     width: 150,
        //     height: 150,
        //     child: Image.asset('assets/images/kuis_logo.png')
        // ),
      ),
    );
  }
}