import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class Strings {
  Strings._();

  static String ROOT_URL = "https://kuis.my-alopedia.com/";
  // static String ROOT_URL = "http://10.224.1.187/kuis-backend/";
  // static String ROOT_URL = "http://192.168.1.8/kuis-backend/";
  // static String ROOT_URL = "http://192.168.249.235/kuis-backend/";

  static String API_URL = "${ROOT_URL}index.php/api/master/";

  static final String URL_USERS = "${API_URL}user_all";
  static final String URL_ITEMS = "${API_URL}items_all";
  static final String URL_LOGIN = "${API_URL}user_login";
  static final String URL_REGISTER = "${API_URL}user_register";
  static final String URL_PRODUCT_CATEGORIES = "${API_URL}product_categories";
  static final String URL_PRODUCTS = "${API_URL}products";
  static final String URL_PRODUCT_GALLERIES = "${API_URL}product_galleries";
  static final String URL_ADD_PRODUCT = "${API_URL}add_product";
  static final String URL_ADD_PRODUCT_GALLERIES = "${API_URL}add_product_galleries";
  static final String URL_TRANSACTIONS = "${API_URL}transactions";
  static final String URL_ADD_TRANSACTIONS = "${API_URL}add_transaction";
  static final String URL_TRANSACTION_ITEMS = "${API_URL}transaction_items";
  static final String URL_REPORTS = "${API_URL}transactions_report";
  static final String URL_ADD_ITEM = "${API_URL}add_item";
  static final String URL_DELETE_ITEM = "${API_URL}delete_item";
  static final String URL_ALL_DATA = "${API_URL}all_data";
  static final String URL_UPDATE = "${API_URL}update";
  static final String URL_IMG = "${ROOT_URL}/assets/img/product/";
  static final String URL_IMG_TRANSFER = "${ROOT_URL}/assets/img/bukti_transfer/";
}
