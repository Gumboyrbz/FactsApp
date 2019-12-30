import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' show Client;
import '../models/numbers/item_model.dart';
import 'numbers_repository.dart';

class NumbersApiProvider implements Source {
  Client client = Client();
  final _url = "http://numbersapi.com/";
  final _ujson = '?json';
  Future<List<int>> fetchRange(int start, int end, {String type}) async {
    String gettype = "/$type";
    if (type.isEmpty){
      gettype = "";
    }
    final idUrl = "$_url$start..$end$gettype$_ujson";
    final response = await client.get(idUrl);
    final ids = json.decode(response.body);

    return ids.cast<int>();
  }

  Future<ItemModel> fetchItem(int id) async {
    final itemUrl = "$_url$id$_ujson";
    final response = await client.get(itemUrl);
    final parsedJson = json.decode(response.body);
    return ItemModel.fromJson(parsedJson);
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

  Future<ItemModel> fetchDate(int month, int day) async {
    final itemUrl = "$_url/$month/$day/date$_ujson";
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
    final response = await client.get(itemUrl);
    final parsedJson = json.decode(response.body);
    return ItemModel.fromJson(parsedJson);
  }
}
