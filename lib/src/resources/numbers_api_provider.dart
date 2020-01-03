import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' show Client;
import '../models/numbers/item_model.dart';
import 'numbers_repository.dart';

class NumbersApiProvider implements Source {
  Client client = Client();
  final _url = "http://numbersapi.com/";
  final _ujson = '?json';
  final types = ["trivia", "math", "date", "year"];
  Timer timer;
  var randomNum = 0;
  NumbersApiProvider() {
    init();
  }
  void init() async {
    timer =
        Timer.periodic(Duration(seconds: 15), (Timer t) => getfactsfromApi());
  }

  void getfactsfromApi() {
    randomNum = new Random().nextInt(100);
    print(randomNum);
    fetchRange(0, randomNum);
  }

  Future<void> fetchRange(int start, int end, [String type = "trivia"]) async {
    String gettype = "/$type";
    if (type.isEmpty) {
      gettype = "";
    }
    final idUrl = "$_url$start..$end$gettype$_ujson";
    final ids = await jsonResponse(idUrl);
    ids?.forEach((k, v) {
      ItemModel.fromJson(v);
    });
  }

  Future<ItemModel> fetchItem(int id, [String type = "trivia"]) async {
    final itemUrl = "$_url$id/$type$_ujson";
    final response = await jsonResponse(itemUrl);
    final parsedJson = json.decode(response.body);
    return ItemModel.fromJson(parsedJson);
  }

  jsonResponse(String idUrl) async {
    try {
      final response = await client.get(idUrl);
      final ids = json.decode(response.body);
      return ids;
    } catch (e) {
      print("No Connection");
    }
  }

  Future<ItemModel> fetchTrivia(int id) async {
    final itemUrl = "$_url$id/trivia$_ujson";
    final response = await client.get(itemUrl);
    final parsedJson = json.decode(response.body);
    return ItemModel.fromJson(parsedJson);
  }

  Future<ItemModel> fetchMath(int id) async {
    final itemUrl = "$_url$id/math$_ujson";
    final response = await client.get(itemUrl);
    final parsedJson = json.decode(response.body);
    return ItemModel.fromJson(parsedJson);
  }

  Future<ItemModel> fetchDate(int day) async {
    //The day is 1-indexced with a leap year
    final itemUrl = "$_url/$day/date$_ujson";
    final response = await client.get(itemUrl);
    final parsedJson = json.decode(response.body);
    return ItemModel.fromJson(parsedJson);
  }

  Future<ItemModel> fetchYear(int id) async {
    final itemUrl = "$_url/$id/year$_ujson";
    final response = await client.get(itemUrl);
    final parsedJson = json.decode(response.body);
    return ItemModel.fromJson(parsedJson);
  }

  Future<ItemModel> fetchRandom(String id) async {
    final itemUrl = "$_url/random/$id$_ujson";
    final response = await jsonResponse(itemUrl);
    final parsedJson = json.decode(response.body);
    return ItemModel.fromJson(parsedJson);
  }
}
