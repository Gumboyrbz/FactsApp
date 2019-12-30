import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'numbers_repository.dart';
import '../models/numbers/item_model.dart';

class NumberDbProvider implements Source, Cache {
  Database db;

  NumberDbProvider() {
    init();
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
              found INTEGER
            )
          """);
      },
    );
  }

  @override
  Future<int> addItem(ItemModel item) {
    return db.insert("Numbers", item.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  @override
  Future<int> clear() {
    return db.delete("Numbers");
  }

  @override
  Future<ItemModel> fetchDate(int month, int day) {
    // TODO: implement fetchDate
    throw UnimplementedError();
  }

  @override
  Future<ItemModel> fetchItem(int id) async {
    final maps = await db.query(
      "Numbers",
      columns: null,
      where: "number = ?",
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
  Future<ItemModel> fetchRandom(String id) {
    // TODO: implement fetchRandom
    throw UnimplementedError();
  }

  @override
  Future<List<int>> fetchRange(int start, int end, {String type}) {
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