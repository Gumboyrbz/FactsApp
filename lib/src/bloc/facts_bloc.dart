import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:random_facts/src/resources/numbers_repository.dart';
import './bloc.dart';

class FactsBloc extends Bloc<FactsEvent, FactsState> {
  final NumberRepository numberRepository;
  FactsBloc(this.numberRepository);

  @override
  FactsState get initialState => InitialFactsState();

  @override
  Stream<FactsState> mapEventToState(
    FactsEvent event,
  ) async* {
    // TODO: Add Logic
    yield LoadingFactsState();
    if (event is GetFact) {
      // print(event.number);
      try {
        final fact = await numberRepository.fetchItem(event.number);
        yield LoadedFactsState(fact);
      } catch (e) {
        print(e);
        yield ErrorFactsState('Couldn\'t get fact data');
      }
    }
  }
}
