import 'package:equatable/equatable.dart';

class ItemModel extends Equatable {
  final int number;
  final bool found;
  final String type;
  final String text;
  final bool used;

  ItemModel.fromJson(Map<String, dynamic> parsedJson)
      : number = int.parse(parsedJson['number'].toString()),
        found = parsedJson['found'] ?? false,
        type = parsedJson['type'],
        text = parsedJson['text'],
        used = false;

  ItemModel.fromDb(Map<String, dynamic> parsedJson)
      : number = parsedJson['number'],
        found = parsedJson['found'] == 1,
        type = parsedJson['type'],
        text = parsedJson['text'],
        used = parsedJson['used'] == 1;

  Map<String, dynamic> toMapForDb() {
    return <String, dynamic>{
      'number_id': number,
      'found': found ? 1 : 0,
      'type': type,
      'text': text,
      'used': used ? 1 : 0,
    };
  }

  @override
  List<Object> get props => [number, found, type, text, used];
}
