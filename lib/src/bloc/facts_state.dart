import 'package:equatable/equatable.dart';
import 'package:random_facts/src/models/numbers/item_model.dart';

abstract class FactsState extends Equatable {
  const FactsState();
}

class InitialFactsState extends FactsState {
  const InitialFactsState();
  @override
  List<Object> get props => [];
}

class LoadingFactsState extends FactsState {
  const LoadingFactsState();
  @override
  List<Object> get props => [];
}

class LoadedFactsState extends FactsState {
  final ItemModel item;
  const LoadedFactsState(this.item);
  @override
  List<Object> get props => [item];
}
class LoadedMultipleFactsState extends FactsState{
  final List<ItemModel> items;
  const LoadedMultipleFactsState(this.items);
  @override
  List<Object> get props => [items];
}

class ErrorFactsState extends FactsState {
  final String message;
  const ErrorFactsState(this.message);
  @override
  List<Object> get props => [message];
}
