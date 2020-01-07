import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'numbers_repository.dart';
import '../models/numbers/item_model.dart';

class NumberDbProvider implements Source, Cache {
  Database db;
  final _random = new Random();
  final types = ["trivia", "math", "date", "year"];
  var batch;
  NumberDbProvider() {
    if (!kIsWeb) {
      init();
    }
    ;
  }
  void init() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, "numbers.db");
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database newDb, int version) {
        newDb.execute("""
          CREATE TABLE IF NOT EXISTS Numbers
            (
              number INTEGER PRIMARY KEY,
              type TEXT,
              text TEXT,
              found INTEGER,
              used INTEGER
            )
          """);
        newDb.execute("""
          CREATE TABLE IF NOT EXISTS trivia
            (
              id INTEGER PRIMARY KEY autoincrement,
              number_id INTEGER,
              type TEXT,
              text TEXT,
              found INTEGER,
              used INTEGER
            )
          """);
        newDb.execute("""
          CREATE TABLE IF NOT EXISTS date
            (
              id INTEGER PRIMARY KEY autoincrement,
              number_id INTEGER,
              year INTEGER,
              type TEXT,
              text TEXT,
              found INTEGER,
              used INTEGER
            )
          """);
        newDb.execute("""
          CREATE TABLE IF NOT EXISTS math
            (
              id INTEGER PRIMARY KEY autoincrement,
              number_id INTEGER,
              type TEXT,
              text TEXT,
              found INTEGER,
              used INTEGER
            )
          """);
        newDb.execute("""
          CREATE TABLE IF NOT EXISTS year
            (
              id INTEGER PRIMARY KEY autoincrement,
              number_id INTEGER,
              type TEXT,
              text TEXT,
              found INTEGER,
              used INTEGER
            )
          """);
      },
    );
    cleanUpDatabase(true);
  }

  @override
  Future<int> addItem(ItemModel item, [String type = "trivia"]) {
    db.insert("${item.type}", item.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return cleanUpDatabase();
  }

  @override
  Future<int> clear() {
    db.delete("trivia");
    db.delete("math");
    db.delete("date");
    db.delete("year");
    return db.delete("Numbers");
  }

  @override
  Future<ItemModel> fetchDate(int day) {
    // TODO: implement fetchDate
    throw UnimplementedError();
  }

  @override
  Future<ItemModel> fetchItem(int id, [String type]) async {
    final maps = await db.query(
      "$type",
      columns: null,
      where: "number_id = ?",
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return ItemModel.fromDb(maps.first);
    }
    return null;
  }

  @override
  Future<ItemModel> fetchMath(int id) {
    // TODO: implement fetchMath
    throw UnimplementedError();
  }

  @override
  Future<ItemModel> fetchRandom(String type) async {
    final maps = await db.rawQuery("SELECT * FROM $type WHERE used = 0");
    var lowlimit = 1;
    var zeroResults = 0;
    if (maps.length > zeroResults) {
      final index = _random.nextInt(maps.length);
      var mapChange = await db.rawUpdate(
          "UPDATE $type SET used = 1 WHERE number_id= ${maps[index]["number_id"]}");
      if (maps.length == lowlimit) {
        mapChange = await db.rawUpdate("UPDATE $type SET used = 0");
      }
      return ItemModel.fromDb(maps[index]);
    }

    return null;
  }

  Future<List<ItemModel>> fetchMultiple(
      [int size, String type, int maxVal]) async {
    List<ItemModel> listofItems = List<ItemModel>();
    //SELECT * FROM table WHERE id IN (SELECT id FROM table ORDER BY RANDOM() LIMIT x)
    final maps = await db.rawQuery('''SELECT * FROM $type
        WHERE id IN (SELECT id FROM $type ORDER BY RANDOM() LIMIT $size) AND used = 0''');
    var lowlimit = 1;
    var zeroResults = 0;
    var mapChange;
    if (maps.length > zeroResults) {
      for (var i in maps) {
        listofItems.add(ItemModel.fromDb(i));
        mapChange = await db.rawUpdate(
            "UPDATE $type SET used = 1 WHERE number_id= ${i["number_id"]}");
      }

      if (maps.length <= lowlimit) {
        // mapChange = await db.rawUpdate("UPDATE $type SET used = 0");
        resetUsedFacts(type);
      }

      return listofItems;
    } else if (maps.length <= lowlimit) {
      // mapChange = await db.rawUpdate("UPDATE $type SET used = 0");
      resetUsedFacts(type);
    }

    return null;
  }

  Future<int> cleanUpDatabase([bool reset = false]) async {
    batch = db.batch();
    for (var i in types) {
      if (reset) {
        resetUsedFacts(i);
      }
      deleteDupFacts(i);
    }
    return await batch.commit(noResult: true);
  }

  Future<int> resetUsedFacts([String type = "trivia"]) async {
    final resetTable = await batch.rawUpdate("UPDATE $type SET used = 0");
    return resetTable;
  }

  Future<int> deleteDupFacts([String type = "trivia"]) async {
    final deleteDup = await batch.rawDelete('''delete from $type
      where id not in
         (
         select min(id)
         from $type
         group by text
         )''');
    return deleteDup;
  }

  @override
  Future<List<ItemModel>> fetchRange(int start, int end, [String type]) {
    // TODO: implement fetchRange
    throw UnimplementedError();
  }

  @override
  Future<ItemModel> fetchTrivia(int id) {
    // TODO: implement fetchTrivia
    throw UnimplementedError();
  }

  @override
  Future<ItemModel> fetchYear(int id) {
    // TODO: implement fetchYear
    throw UnimplementedError();
  }
}

final numberDbProvider = NumberDbProvider();
