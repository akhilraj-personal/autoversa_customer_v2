import 'package:autoversa/provider/provider.dart';
import 'package:autoversa/screens/bottom_tab/bottomtab.dart';
import 'package:autoversa/screens/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then(
    (_) => runApp(
      const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TabNotifier()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: routes,
      ),
    );
  }
}

var routes = <String, WidgetBuilder>{
  Routes.SPLASH: (BuildContext context) => SplashScreen(),
  Routes.bottombar: (BuildContext context) => BottomNavBarScreen(
        index: 1,
      ),
};

class Routes {
  static const SPLASH = "/";
  static const bottombar = "screens/bottom_tab/bottomtab.dart";
}
