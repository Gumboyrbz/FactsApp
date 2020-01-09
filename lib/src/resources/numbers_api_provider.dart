import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' show Client;
import '../models/numbers/item_model.dart';
import 'numbers_repository.dart';

class NumbersApiProvider implements Source {
  Client client = Client();
  final _url = "http://numbersapi.com";
  final _ujson = '?json&notfound=floor';
  final types = ["trivia", "math", "date", "year"];
  var _random = new Random(DateTime.now().millisecondsSinceEpoch);
  Future<List<ItemModel>> fetchRange(int start, int end, [String type]) async {
    final idUrl = "$_url/$start..$end/$type$_ujson";
    final ids = await jsonResponse(idUrl);
    if (ids != -1) {
      List<ItemModel> rangeofItems = List<ItemModel>();
      ids?.forEach((k, v) {
        rangeofItems.add(ItemModel.fromJson(v));
      });
      return rangeofItems;
    } else {
      return null;
    }
  }

  Future<ItemModel> fetchItem(int id, [String type]) async {
    final itemUrl = "$_url/$id/$type$_ujson";
    final parsedJson = await jsonResponse(itemUrl);
    return ItemModel.fromJson(parsedJson);
  }

  jsonResponse(String idUrl) async {
    try {
      final response = await client?.get(idUrl);
      final ids = json.decode(response.body);
      return ids;
    } catch (e) {
      return -1;
    }
  }

  Future<ItemModel> fetchTrivia(int id) async {
    final itemUrl = "$_url/$id/trivia$_ujson";
    final parsedJson = await jsonResponse(itemUrl);
    return ItemModel.fromJson(parsedJson);
  }

  Future<ItemModel> fetchMath(int id) async {
    final itemUrl = "$_url/$id/math$_ujson";
    final parsedJson = await jsonResponse(itemUrl);
    return ItemModel.fromJson(parsedJson);
  }

  Future<ItemModel> fetchDate(int day) async {
    //The day is 1-indexced with a leap year
    final itemUrl = "$_url/$day/date$_ujson";
    final parsedJson = await jsonResponse(itemUrl);
    return ItemModel.fromJson(parsedJson);
  }

  Future<ItemModel> fetchYear(int id) async {
    final itemUrl = "$_url/$id/year$_ujson";
    final parsedJson = await jsonResponse(itemUrl);
    return ItemModel.fromJson(parsedJson);
  }
               
  Future<ItemModel> fetchRandom(String id) async {
    final itemUrl = "$_url/random/$id$_ujson";
    final parsedJson = await jsonResponse(itemUrl);
    return ItemModel.fromJson(parsedJson);
  }

  Future<List<ItemModel>> fetchMultiple(
      [int size, String type, int maxVal]) async {
    var min = 0;
    if (type == "date") {
      min = 1;
    }
    var randomList =
        new List.generate(size, (_) => min + _random.nextInt(maxVal - min));
    final itemUrl = "$_url/${randomList.join(',')}/$type/$_ujson";
    print(itemUrl);
    final ids = await jsonResponse(itemUrl);
    if (ids != -1) {
      List<ItemModel> rangeofItems = List<ItemModel>();
      ids?.forEach((k, v) {
        rangeofItems.add(ItemModel.fromJson(v));
      });
      return rangeofItems;
    } else {
      return null;
    }
  }
}
