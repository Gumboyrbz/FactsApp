import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'numbers_api_provider.dart';
import 'numbers_db_provider.dart';
import '../models/numbers/item_model.dart';

class NumberRepository {
  List<Source> sources = <Source>[];
  List<Cache> caches = <Cache>[];
  final numbersApiProvider = NumbersApiProvider();
  Timer timer;
  static const _maxNum = 6000;
  var _highNum = 0;
  var _lowNum = 0;
  var _lowtemp = 0;
  var _offset = 100;
  var _random = new Random(DateTime.now().millisecondsSinceEpoch);
  var globalType = "trivia";
  NumberRepository() {
    sources.add(kIsWeb ? null : numberDbProvider);
    sources.add(numbersApiProvider);
    sources.removeWhere((item) => item == null);
    caches.add(kIsWeb ? null : numberDbProvider);
    caches.removeWhere((item) => item == null);
    factsEverySec();
  }
  //Perform a function call every [sec] secs to retrieve data from api
  void factsEverySec([int sec = 5]) async {
    timer =
        Timer.periodic(Duration(seconds: sec), (Timer t) => getfactsfromApi());
  }

  //Return a random number between min and max
  int next(int min, int max) => min + _random.nextInt(max - min);

  // Retrieves facts from api and places them in database
  void getfactsfromApi() async {
    _lowNum = next(_lowtemp, _maxNum);
    _highNum = _lowNum + _offset;
    var maxVal = _maxNum;
    if (globalType == "date") {
      maxVal = 366;
    }
    List<ItemModel> listfacts =
        await numbersApiProvider.fetchMultiple(100, globalType, maxVal);
    ItemModel item;
    if (caches != null && listfacts != null) {
      for (item in listfacts) {
        for (var cache in caches) {
          cache.addItem(item);
        }
      }
    }
  }

  Future<ItemModel> fetchItem(int id, [String type = "trivia"]) async {
    ItemModel item;
    var source;
    globalType = type;
    for (source in sources) {
      item = await source.fetchItem(id, type);
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

  Future<ItemModel> fetchRandom(String type) async {
    ItemModel item;
    var source;
    globalType = type;
    for (source in sources) {
      item = await source.fetchRandom(type);
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

  Future<List<ItemModel>> fetchMultiple(
      [int size, String type = "trivia", int maxVal = _maxNum]) async {
    List<ItemModel> items;
    var source;
    var count = 0;
    globalType = type;
    if (type == 'date') {
      maxVal = 366;
    }
    OUTER:
    while (count <= 0) {
      for (var source in sources) {
        items = await source.fetchMultiple(size, type, maxVal);
        if (items != null) {
          break OUTER;
        }
        count++;

        if (count > 1) {
          if (!kIsWeb) {
            numberDbProvider.resetUsedFacts();
          }
          count = 0;
        }
      }
    }
    for (var cache in caches) {
      if (cache != source) {
        for (var i in items) {
          cache.addItem(i);
        }
      }
    }
    return items;
  }
}

abstract class Source {
  Future<List<ItemModel>> fetchRange(int start, int end, [String type]);
  Future<ItemModel> fetchItem(int id, [String type]);
  Future<ItemModel> fetchTrivia(int id);
  Future<ItemModel> fetchMath(int id);
  Future<ItemModel> fetchDate(int day);
  Future<ItemModel> fetchYear(int id);
  Future<ItemModel> fetchRandom(String type);
  Future<List<ItemModel>> fetchMultiple([int size, String type, int maxVal]);
}

abstract class Cache {
  Future<int> addItem(ItemModel item);
  Future<int> clear();
}
