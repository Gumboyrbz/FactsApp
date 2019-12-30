import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_facts/src/bloc/bloc.dart';
import 'package:random_facts/src/bloc/facts_bloc.dart';
import 'package:random_facts/src/bloc/facts_state.dart';
import 'package:random_facts/src/resources/numbers_repository.dart';
import 'src/swipe_cards/flutter_tindercard.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (BuildContext context) => FactsBloc(NumberRepository()),
        child: ExampleHomePage(),
      ),
      // home: ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  @override
  _ExampleHomePageState createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage>
    with TickerProviderStateMixin {
  List<String> welcomeImages = [
    "res/portrait.jpeg",
    "res/portrait.jpeg",
    "res/portrait.jpeg",
    "res/portrait.jpeg",
    "res/portrait.jpeg",
    "res/portrait.jpeg"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: BlocBuilder<FactsBloc, FactsState>(
          builder: (context, state) {
            if (state is InitialFactsState) {
              return allCards(context, buildInitial());
            } else if (state is LoadingFactsState) {
              return allCards(context, buildLoading());
            } else if (state is LoadedFactsState) {
              return Center(
                child: allCards(
                  context,
                  formatedText("${state.item.text}"),
                ),
              );
            } else if (state is ErrorFactsState) {
              return allCards(
                context,
                formatedText("${state.message}"),
              );
            } else {
              return buildLoading();
            }
          },
        ),
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   CardController controller; //Use this to trigger swap.

  //   return new Scaffold(
  //     body: new Center(
  //       child: Container(
  //         color: Colors.blue,
  //         height: MediaQuery.of(context).size.height * 0.9,
  //         child: new TinderSwapCard(
  //           orientation: AmassOrientation.BOTTOM,
  //           totalNum: 6,
  //           stackNum: 3,
  //           swipeEdge: 4.0,
  //           maxWidth: MediaQuery.of(context).size.width * 0.9,
  //           maxHeight: MediaQuery.of(context).size.width * 0.9,
  //           minWidth: MediaQuery.of(context).size.width * 0.8,
  //           minHeight: MediaQuery.of(context).size.width * 0.8,
  //           cardBuilder: (context, index) => Card(
  //             child: Image.asset('${welcomeImages[index]}'),
  //           ),
  //           cardController: controller = CardController(),
  //           swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {
  //             /// Get swiping card's alignment
  //             if (align.x < 0) {
  //               //Card is LEFT swiping
  //             } else if (align.x > 0) {
  //               //Card is RIGHT swiping
  //             }
  //           },
  //           swipeCompleteCallback:
  //               (CardSwipeOrientation orientation, int index) {
  //             /// Get orientation & index of swiped card!
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }
// final factBloc = BlocProvider.of<FactsBloc>(context);
//     factBloc.add(GetFact(5));

  Widget allCards(BuildContext context, Widget shownWidget) {
    CardController controller;
    final factBloc = BlocProvider.of<FactsBloc>(context);

    return Center(
      child: Container(
        // color: Colors.blue,
        height: MediaQuery.of(context).size.height * 0.9,
        child: new TinderSwapCard(
          orientation: AmassOrientation.BOTTOM,
          totalNum: 6,
          stackNum: 3,
          swipeEdge: 4.0,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.width * 0.9,
          minWidth: MediaQuery.of(context).size.width * 0.8,
          minHeight: MediaQuery.of(context).size.width * 0.8,
          cardBuilder: (context, index) => Card(
            child: shownWidget,
          ),
          cardController: controller = CardController(),
          swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {
            /// Get swiping card's alignment
            if (align.x < 0) {
              // Card is LEFT swiping
            } else if (align.x > 0) {
              //Card is RIGHT swiping
            }
          },
          swipeCompleteCallback: (CardSwipeOrientation orientation, int index) {
            /// Get orientation & index of swiped card!
            if (orientation == CardSwipeOrientation.LEFT ||
                orientation == CardSwipeOrientation.RIGHT) {
              var randomNum = new Random();
              factBloc.add(GetFact(randomNum.nextInt(100)));
            }
          },
        ),
      ),
    );
  }

  Widget buildInitial() {
    return formatedText("Have I got facts for you!");
  }

  Widget buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  Widget formatedText(String displayText) {
    return Center(
      child: Container(
        padding: new EdgeInsets.only(left: 10.0, right: 10.0),
        child: Text(
          displayText,
          textAlign: TextAlign.center,
          // maxLines: 3,
          // overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              fontFamily: 'Open Sans',
              fontSize: 30),
        ),
      ),
    );
  }
}

// class MyApp extends StatelessWidget
// {
//   @override
//   Widget build(BuildContext context)
//   {
//     return new MaterialApp
//     (
//       title: 'Tinder cards demo',
//       theme: new ThemeData(primarySwatch: Colors.blue),
//       home: new SwipeFeedPage(),
//     );
//   }
// }
