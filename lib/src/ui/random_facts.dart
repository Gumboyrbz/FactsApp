import 'dart:math';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_facts/src/bloc/bloc.dart';
import 'package:random_facts/src/bloc/facts_bloc.dart';
import 'package:random_facts/src/bloc/facts_state.dart';
import 'package:random_facts/src/resources/numbers_repository.dart';
import 'package:random_facts/src/swipe_cards/flutter_tindercard.dart';
import 'package:share/share.dart';
import 'package:random_facts/src/ui/SizeConfig.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:cached_network_image/cached_network_image.dart';

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
  String _textToBeShared = "Useless Number Facts to share with friends";
  static const String _nameOfApp = "\nFact Brought to you by Random Facts\nDeveloper: Gumboy";
  static const String _appUrl = "https://play.google.com/store/apps/details?id=com.gumboy.random_facts";
  static const String _devLink = "https://gumboyrbz.github.io";
  List<bool> _listTileSelected = List.generate(4, (i) => false);
  String _changeType = "trivia";
  bool _refreshActive = false;

  @override
  Widget build(BuildContext context) {
    final factsBloc = BlocProvider.of<FactsBloc>(context);
    final key = new GlobalKey<ScaffoldState>();
    SizeConfig().init(context);
    int _totalsel = _listTileSelected.length;
    final defaultImage = Image.asset(
      'res/default.jpg', width: SizeConfig.screenWidth, //size.width,
      height: SizeConfig.screenHeight, //size.height,
      fit: BoxFit.fill,
    );

    // final Widget todaysPic = CachedNetworkImage(
    //   imageUrl: picUrl,
    //   width: SizeConfig.screenWidth, //size.width,
    //   height: SizeConfig.screenHeight, //size.height,
    //   fit: BoxFit.fill,
    //   useOldImageOnUrlChange: true,
    //   placeholder: (context, url) => defaultImage,
    //   errorWidget: (context, url, error) => defaultImage,
    // );
    final Widget todaysPic = FadeInImage(
      placeholder: AssetImage('res/default.jpg'),
      image: NetworkImage(
        picUrl,
        // width: size.width,
        // height: size.height,
        // fit: BoxFit.fill,
      ),
      width: SizeConfig.screenWidth, //size.width,
      height: SizeConfig.screenHeight, //size.height,
      fit: BoxFit.fill,
    );

    return Scaffold(
      key: key,
      backgroundColor: Colors.transparent,
      body: Scaffold(
        appBar: AppBar(
          title: Text("Useless Facts"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.loop),
              onPressed: () {
                factsBloc.add(GetFacts(20, _changeType));
              },
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: <Widget>[
              GestureDetector(
                child: UserAccountsDrawerHeader(
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage("res/avatar.png"),
                  ),
                  accountEmail: Text(_devLink),
                  accountName: Text("Gumboy"),
                ),
                onTap: _launchURL,
                onLongPress: () {
                  Clipboard.setData(new ClipboardData(text: _devLink));
                  key.currentState.showSnackBar(new SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: new Text("Copied to Clipboard"),
                  ));
                },
              ),
              Text(
                "Categories",
                style: TextStyle(
                    // color: Colors.grey[800],
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Open Sans',
                    fontSize: 30),
              ),
              formatedCategory(
                  title: "trivia",
                  icon: Icons.help,
                  size: 30,
                  selected: 0,
                  total: _totalsel,
                  factsBloc: factsBloc,
                  context: context),
              formatedCategory(
                  title: "date",
                  icon: Icons.date_range,
                  size: 30,
                  selected: 1,
                  total: _totalsel,
                  factsBloc: factsBloc,
                  context: context),
              formatedCategory(
                  title: "math",
                  icon: Icons.filter_9_plus,
                  size: 30,
                  selected: 2,
                  total: _totalsel,
                  factsBloc: factsBloc,
                  context: context),
              formatedCategory(
                  title: "year",
                  icon: Icons.access_time,
                  size: 30,
                  selected: 3,
                  total: _totalsel,
                  factsBloc: factsBloc,
                  context: context),
            ],
          ),
        ),
        resizeToAvoidBottomPadding: false,
        body: Container(
          child: Stack(
            children: <Widget>[
              Center(child: todaysPic),
              Column(
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Container(
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
                            print("${state.items.length}");
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
                  ),
                  Container(
                    child: ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // ButtonTheme(
                        //   minWidth: 75.0,
                        //   height: 60.0,
                        //   child: RaisedButton(
                        //     shape: new RoundedRectangleBorder(
                        //       borderRadius: new BorderRadius.circular(20.0),
                        //     ),
                        //     child: Row(
                        //       children: <Widget>[
                        //         Icon(
                        //           _hide ? Icons.crop_original : Icons.crop_din,
                        //           size: 40,
                        //         ),
                        //         Text(
                        //           "Hide",
                        //           style: TextStyle(
                        //               // color: Colors.grey[800],
                        //               fontWeight: FontWeight.w700,
                        //               fontStyle: FontStyle.italic,
                        //               fontFamily: 'Open Sans',
                        //               fontSize: 30),
                        //         ),
                        //       ],
                        //     ),
                        //     onPressed: _onChanged,
                        //   ),
                        // ),
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
                            onPressed: _shareImplementation,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _shareImplementation() {
    Share.share(_textToBeShared, subject: _nameOfApp);
  }

  _onRefreshActive(bool active) {
    setState(() {
      _refreshActive = active;
    });
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
    });
  }

  _launchURL() async {
    const url = _devLink;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget allCards(BuildContext context, FactsBloc factsBloc, state) {
    CardController controller;
    // final factsBloc = BlocProvider.of<FactsBloc>(context);
    SizeConfig().init(context);
    var isWidget = false;
    int stacksize = 2;
    if (state is List) {
      isWidget = false;
      stacksize = 3;
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
            stackNum: isWidget ? 3 : stacksize,
            swipeEdge: 4.0,
            animDuration: 400,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.width * 0.9,
            minWidth: MediaQuery.of(context).size.width * 0.8,
            minHeight: MediaQuery.of(context).size.width * 0.8,
            cardBuilder: (context, index) => Card(
              child: isWidget
                  ? state
                  : formatedText(state?.elementAt(index)?.text,
                      center: true,
                      fsize: MediaQuery.of(context).size.width / 16),
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
            swipeCompleteCallback:
                (CardSwipeOrientation orientation, int index) {
              /// Get orientation & index of swiped card!
              if (orientation == CardSwipeOrientation.LEFT ||
                  orientation == CardSwipeOrientation.RIGHT) {
                if (isWidget == true) {
                  factsBloc.add(GetFacts(
                    20,
                    _changeType,
                  ));
                }
                if (isWidget == false) {
                  if (index == state.length - 1) {
                    factsBloc.add(GetFacts(
                      20,
                      _changeType,
                    ));
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
    return formatedText("Have I got facts for you!",
        fsize: MediaQuery.of(context).size.width / 16, center: true);
  }

  Widget buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  Widget formatedCategory(
      {String title: "",
      IconData icon,
      double size = 10,
      double fsize = 10,
      int selected = 0,
      int total = 0,
      FactsBloc factsBloc,
      BuildContext context}) {
    return Container(
      child: ListTile(
        selected: _listTileSelected[selected],
        contentPadding: EdgeInsets.only(left: 30),
        leading: Icon(
          icon,
          size: size,
        ),
        title: Text(
          capitalize(input: title),
          style: Theme.of(context).textTheme.headline5,
        ),
        onTap: () {
          // _listTileSelected[selected] = true;
          setState(() {
            _listTileSelected.asMap().forEach((index, val) {
              _listTileSelected[index] = false;
            });
            _listTileSelected[selected] = true;
            _onChangedType(title);
          });

          factsBloc.add(GetFacts(20, title));
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget formatedText(String displayText,
      {double fsize = 30, bool center = false}) {
    _textToBeShared = displayText + _nameOfApp;
    return Center(
      child: SingleChildScrollView(
        child: Container(
          alignment: center ? AlignmentDirectional.center : null,
          padding: new EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            displayText,
            textAlign: center ? TextAlign.center : null,
            // maxLines: 3,
            // overflow: TextOverflow.ellipsis,
            style: TextStyle(
                // color: Colors.grey[800],
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                fontFamily: 'Open Sans',
                fontSize: fsize),
          ),
        ),
      ),
    );
  }

  String capitalize({String input = ""}) {
    if (input.length == 0) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }
}
