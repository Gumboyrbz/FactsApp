import 'package:equatable/equatable.dart';

abstract class FactsEvent extends Equatable {
  const FactsEvent();
}

class GetFact extends FactsEvent {
  final int number;
  const GetFact(this.number);
  @override
  List<Object> get props => [number];
}
