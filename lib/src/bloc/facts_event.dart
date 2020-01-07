import 'package:equatable/equatable.dart';

abstract class FactsEvent extends Equatable {
  const FactsEvent();
}

class GetFact extends FactsEvent {
  final String type;
  const GetFact(this.type);
  @override
  List<Object> get props => [type];
}
class GetFacts extends FactsEvent {
  final int size;
  const GetFacts(this.size);
  @override
  List<Object> get props => [size];
}
