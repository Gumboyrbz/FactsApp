import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/ui/random_facts.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(new RandomFactsApp());
}
