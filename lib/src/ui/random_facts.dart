import 'dart:math';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_facts/src/bloc/bloc.dart';
import 'package:random_facts/src/bloc/facts_bloc.dart';
import 'package:random_facts/src/bloc/facts_state.dart';
import 'package:random_facts/src/resources/numbers_repository.dart';
import 'package:random_facts/src/swipe_cards/flutter_tindercard.dart';

class RandomFactsApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Random Facts',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: BlocProvider(
        create: (BuildContext context) => FactsBloc(NumberRepository()),
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static Random rng = new Random();
  static List<String> picArray = [
    "https://source.unsplash.com/collection/614364/",
    "https://source.unsplash.com/collection/5006127/",
    "https://source.unsplash.com/collection/2080469/",
    "https://source.unsplash.com/collection/8644034/",
    "https://source.unsplash.com/collection/8639264/"
  ];
  static int rndnum = rng.nextInt(picArray.length);
  final picUrl = picArray[rndnum] + "480x720";
  bool _hide = false;

  String _changeType = "trivia";
  @override
  Widget build(BuildContext context) {
    final factsBloc = BlocProvider.of<FactsBloc>(context);

    Size size = MediaQuery.of(context).size;
    final Widget todaysPic = FadeInImage(
      placeholder: AssetImage('res/default.jpg'),
      image: NetworkImage(
        picUrl,
        // width: size.width,
        // height: size.height,
        // fit: BoxFit.fill,
      ),
      width: size.width,
      height: size.height,
      fit: BoxFit.fill,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Useless Number Facts"),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Categories'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.help,
                size: 40,
              ),
              title: formatedText('Trivia'),
              onTap: () {
                factsBloc.add(GetInitial());
                _onChangedType("trivia");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.date_range,
                size: 40,
              ),
              title: formatedText('Date'),
              onTap: () {
                factsBloc.add(GetInitial());
                _onChangedType("date");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.filter_9_plus,
                size: 40,
              ),
              title: formatedText('Math'),
              onTap: () {
                factsBloc.add(GetInitial());
                _onChangedType("math");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.access_time,
                size: 40,
              ),
              title: formatedText('Year'),
              onTap: () {
                factsBloc.add(GetInitial());
                _onChangedType("year");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      // backgroundColor: Colors.grey[900],
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
                      return allCards(context, factsBloc, buildInitial());
                    } else if (state is LoadingFactsState) {
                      return allCards(context, factsBloc, buildLoading());
                    } else if (state is LoadedFactsState) {
                      return Center(
                        child: allCards(
                          context,
                          factsBloc,
                          state.item.text,
                        ),
                      );
                    } else if (state is LoadedMultipleFactsState) {
                      return Center(
                        child: allCards(
                          context,
                          factsBloc,
                          state.items,
                        ),
                      );
                    } else if (state is ErrorFactsState) {
                      return allCards(
                        context,
                        factsBloc,
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
                  mainAxisSize: MainAxisSize.min,
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
    setState(() {
      if (_hide == true) {
        _hide = false;
      } else {
        _hide = true;
      }
    });
  }

  _onChangedType(type) {
    setState(() {
      _changeType = type;
      print(type);
    });
  }

  Widget allCards(BuildContext context, FactsBloc factsBloc, state) {
    CardController controller;
    // final factsBloc = BlocProvider.of<FactsBloc>(context);
    var isWidget = false;
    if (state is List) {
      isWidget = false;
    } else if (state is Widget) {
      isWidget = true;
    }
    return Container(
      // color: Colors.blue,
      height: MediaQuery.of(context).size.height * 0.7,
      child: IgnorePointer(
        ignoring: _hide,
        child: Opacity(
          opacity: _hide ? 0.0 : 0.96,
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
            swipeCompleteCallback:
                (CardSwipeOrientation orientation, int index) {
              /// Get orientation & index of swiped card!
              if (orientation == CardSwipeOrientation.LEFT ||
                  orientation == CardSwipeOrientation.RIGHT) {
                if (isWidget == true) {
                  factsBloc.add(GetFacts(20, _changeType));
                }
                if (isWidget == false) {
                  if (index == state.length - 1) {
                    factsBloc.add(GetFacts(20, _changeType));
                  }
                }
              }
            },
          ),
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
      child: SingleChildScrollView(
        child: Container(
          padding: new EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            displayText,
            textAlign: TextAlign.center,
            // maxLines: 3,
            // overflow: TextOverflow.ellipsis,
            style: TextStyle(
                // color: Colors.grey[800],
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                fontFamily: 'Open Sans',
                fontSize: 30),
          ),
        ),
      ),
    );
  }
}
