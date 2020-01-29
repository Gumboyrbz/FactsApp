import 'package:equatable/equatable.dart';

abstract class FactsEvent extends Equatable {
  const FactsEvent();
}

class GetInitial extends FactsEvent {
  const GetInitial();
  @override
  List<Object> get props => [];
}

class GetFact extends FactsEvent {
  final String type;
  const GetFact(this.type);
  @override
  List<Object> get props => [type];
}

class GetFacts extends FactsEvent {
  final int size;
  final String type;
  const GetFacts(this.size, [this.type = "trivia"]);
  @override
  List<Object> get props => [size, type];
}

class RefreshFacts extends FactsEvent {
  final int size;
  final String type;
  const RefreshFacts(this.size,[this.type = "trivia"]);
  @override
  List<Object> get props => [type];
}
