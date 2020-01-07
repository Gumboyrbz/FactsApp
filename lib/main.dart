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
  final picUrl = "https://source.unsplash.com/collection/5006127/480x720";
  bool _hide = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final Widget todaysPic = new Image.network(
      picUrl,
      width: size.width,
      height: size.height,
      fit: BoxFit.fill,
    );
    print(size);
    print(todaysPic);
    return Scaffold(
      appBar: AppBar(
        title: Text("Random Number Facts"),
      ),
      backgroundColor: Colors.grey[900],
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          Center(child: todaysPic),
          Column(
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
                          state.item.text,
                        ),
                      );
                    } else if (state is LoadedMultipleFactsState) {
                      return Center(
                        child: allCards(
                          context,
                          state.items,
                        ),
                      );
                    } else if (state is ErrorFactsState) {
                      return allCards(
                        context,
                        state.message,
                      );
                    } else {
                      return buildLoading();
                    }
                  },
                ),
              ),
              Container(
                child: ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: 75.0,
                      height: 60.0,
                      child: RaisedButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              _hide ? Icons.crop_original : Icons.crop_din,
                              size: 40,
                            ),
                            Text(
                              "Hide",
                              style: TextStyle(
                                  // color: Colors.grey[800],
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Open Sans',
                                  fontSize: 30),
                            ),
                          ],
                        ),
                        onPressed: _onChanged,
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 50.0,
                      height: 60.0,
                      child: RaisedButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.share,
                              size: 40,
                            ),
                            Text(
                              "Share",
                              style: TextStyle(
                                  // color: Colors.grey[800],
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Open Sans',
                                  fontSize: 30),
                            ),
                          ],
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  _onChanged() {
    //update with a new color when the user taps button

    setState(() {
      if (_hide == true) {
        _hide = false;
      } else {
        _hide = true;
      }
    });

    //setState(() => (_currentIndex == _colorCount - 1) ? _currentIndex = 1 : _currentIndex += 1);
  }

  Widget allCards(BuildContext context, state) {
    CardController controller;
    final factBloc = BlocProvider.of<FactsBloc>(context);
    var randomNum = new Random().nextInt(10);
    var isWidget = false;
    if (state is List) {
      isWidget = false;
    } else if (state is Widget) {
      isWidget = true;
    }
    return Container(
      // color: Colors.blue,
      height: MediaQuery.of(context).size.height * 0.7,
      child: Opacity(
        opacity: _hide ? 0.0 : 0.95,
        child: new TinderSwapCard(
          orientation: AmassOrientation.BOTTOM,
          totalNum: isWidget ? 1 : state.length,
          stackNum: 3,
          swipeEdge: 4.0,
          animDuration: 400,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.width * 0.9,
          minWidth: MediaQuery.of(context).size.width * 0.8,
          minHeight: MediaQuery.of(context).size.width * 0.8,
          cardBuilder: (context, index) {
            return Card(
              child: isWidget ? state : formatedText(state[index].text),
            );
          },
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
              if (isWidget == true) {
                factBloc.add(GetFacts(10));
              }
              if (isWidget == false) {
                if (index == state.length - 1) {
                  factBloc.add(GetFacts(10));
                }
              }
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
