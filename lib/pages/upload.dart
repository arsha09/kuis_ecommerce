import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
//import http package manually

class ImageUpload extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _ImageUpload();
  }
}

class _ImageUpload extends State<ImageUpload>{
  ImagePicker picker = ImagePicker();
  XFile? image;

  Future<void> chooseImage() async {
    var choosedimage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = choosedimage;
    });
  }

  Future<void> uploadImage() async {
    String uploadurl = "http://10.224.1.187/kuis-backend/image_upload.php";

    try{
      List<int> imageBytes = File(image!.path).readAsBytesSync();
      String baseimage = base64Encode(imageBytes);
      var response = await http.post(
          Uri.parse(uploadurl),
          body: {
            'image': baseimage,
            'filename': "baseimage",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image to Server"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body:Container(
        height:300,
        alignment: Alignment.center,
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center, //content alignment to center
          children: <Widget>[
            Container(  //show image here after choosing image
                child: image == null?
                Container(): //if uploadimage is null then show empty container
                Container(   //elese show image here
                    child: SizedBox(
                        height:150,
                        child:Image.file(File(image!.path)) //load image from file
                    )
                )
            ),

            Container(
              //show upload button after choosing image
                child:image == null?
                Container(): //if uploadimage is null then show empty container
                Container(   //elese show uplaod button
                    child:RaisedButton.icon(
                      onPressed: (){
                        uploadImage();
                        //start uploading image
                      },
                      icon: Icon(Icons.file_upload),
                      label: Text("UPLOAD IMAGE"),
                      color: Colors.deepOrangeAccent,
                      colorBrightness: Brightness.dark,
                      //set brghtness to dark, because deepOrangeAccent is darker coler
                      //so that its text color is light
                    )
                )
            ),

            Container(
              child: RaisedButton.icon(
                onPressed: (){
                  chooseImage(); // call choose image function
                },
                icon:Icon(Icons.folder_open),
                label: Text("CHOOSE IMAGE"),
                color: Colors.deepOrangeAccent,
                colorBrightness: Brightness.dark,
              ),
            )
          ],),
      ),
    );
  }
}