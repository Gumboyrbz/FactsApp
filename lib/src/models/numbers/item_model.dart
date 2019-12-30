import 'package:equatable/equatable.dart';

class ItemModel extends Equatable {
  final int number;
  final bool found;
  final String type;
  final String text;

  ItemModel.fromJson(Map<String, dynamic> parsedJson)
      : number = parsedJson['number'],
        found = parsedJson['found'] ?? false,
        type = parsedJson['type'],
        text = parsedJson['text'];

  ItemModel.fromDb(Map<String, dynamic> parsedJson)
      : number = parsedJson['number'],
        found = parsedJson['found'] == 1,
        type = parsedJson['type'],
        text = parsedJson['text'];

  Map<String, dynamic> toMapForDb() {
    return <String, dynamic>{
      'number': number,
      'found': found ? 1 : 0,
      'type': type,
      'text': text,
    };
  }

  @override
  List<Object> get props => [number, found, type, text];
}
