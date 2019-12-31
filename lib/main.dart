import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_facts/src/bloc/bloc.dart';
import 'package:random_facts/src/bloc/facts_bloc.dart';
import 'package:random_facts/src/bloc/facts_state.dart';
import 'package:random_facts/src/resources/numbers_repository.dart';
import 'src/swipe_cards/flutter_tindercard.dart';
import 'package:flutter/services.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Random Facts',
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Random Number Facts"),
      ),
      resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
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
            Container(
              child: ButtonBar(
                // crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ButtonTheme(
                    minWidth: 75.0,
                    height: 60.0,
                    child: RaisedButton(
                      shape: new CircleBorder(
                          // borderRadius: new BorderRadius.circular(50.0),
                          // side: BorderSide(color: Colors.red),
                          ),
                      child: Text(
                        "#",
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Open Sans',
                            fontSize: 30),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  ButtonTheme(
                    minWidth: 50.0,
                    height: 60.0,
                    child: RaisedButton(
                      shape: new CircleBorder(),
                      child: Icon(
                        Icons.shuffle,
                        size: 30.0,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget allCards(BuildContext context, Widget shownWidget) {
    CardController controller;
    final factBloc = BlocProvider.of<FactsBloc>(context);
    var randomNum = new Random().nextInt(6555);

    return Container(
      color: Colors.blue,
      height: MediaQuery.of(context).size.height * 0.7,
      child: new TinderSwapCard(
        orientation: AmassOrientation.BOTTOM,
        totalNum: 6,
        stackNum: 3,
        swipeEdge: 4.0,
        animDuration: 400,
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
            factBloc.add(GetFact(randomNum));
          }
        },
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
