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
    yield LoadingFactsState();
    if (event is GetFact) {
      try {
        final fact = await numberRepository.fetchRandom(event.type);
        yield LoadedFactsState(fact);
      } catch (e) {
        yield ErrorFactsState('Couldn\'t get fact data');
      }
    }
    else if(event is GetFacts){
      try {
        final facts = await numberRepository.fetchMultiple(event.size, event.type);
        yield LoadedMultipleFactsState(facts);
      } catch (e) {
        yield ErrorFactsState('Couldn\'t get facts data');
      }

    }
    else if(event is GetInitial){
      yield InitialFactsState();
    }
  }
}
