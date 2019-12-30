import 'dart:async';
import 'package:flutter/foundation.dart';
import 'numbers_api_provider.dart';
import 'numbers_db_provider.dart';
import '../models/numbers/item_model.dart';

class NumberRepository {
  List<Source> sources = <Source>[];
  List<Cache> caches = <Cache>[];
  NumberRepository() {
    sources.add(kIsWeb?null:numberDbProvider);
    sources.add(NumbersApiProvider());
    sources.removeWhere((item) => item == null);
    caches.add(kIsWeb?null:numberDbProvider);
    caches.removeWhere((item) => item == null);
  }

  Future<ItemModel> fetchItem(int id) async {
    ItemModel item;
    var source;
    for (source in sources) {
      item = await source.fetchItem(id);
      if (item != null) {
        break;
      }
    }
    for (var cache in caches) {
      if (cache != source) {
        cache.addItem(item);
      }
    }
    return item;
  }

  clearCache() async {
    for (var cache in caches) {
      await cache.clear();
    }
  }
}

abstract class Source {
  Future<List<int>> fetchRange(int start, int end, {String type});
  Future<ItemModel> fetchItem(int id);
  Future<ItemModel> fetchTrivia(int id);
  Future<ItemModel> fetchMath(int id);
  Future<ItemModel> fetchDate(int month, int day);
  Future<ItemModel> fetchYear(int id);
  Future<ItemModel> fetchRandom(String id);
}

abstract class Cache {
  Future<int> addItem(ItemModel item);
  Future<int> clear();
}
