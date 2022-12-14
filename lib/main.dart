import 'package:autoversa/provider/provider.dart';
import 'package:autoversa/screens/auth_screens/login_page.dart';
import 'package:autoversa/screens/bottom_tab/bottomtab.dart';
import 'package:autoversa/screens/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
      child: ChangeNotifierProvider<LanguageChangeProvider>(
        create: (context) => LanguageChangeProvider(),
        child: Builder(
          builder: (context) => MaterialApp(
            locale: Provider.of<LanguageChangeProvider>(context, listen: true)
                .currentLocale,
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            routes: routes,
          ),
        ),
      ),
    );
  }
}

var routes = <String, WidgetBuilder>{
  Routes.SPLASH: (BuildContext context) => SplashScreen(),
  Routes.bottombar: (BuildContext context) => BottomNavBarScreen(
        index: 1,
      ),
  Routes.loginPage: (BuildContext context) => LoginPage(),
};

class Routes {
  static const SPLASH = "/";
  static const bottombar = "screens/bottom_tab/bottomtab.dart";
  static const loginPage = "screens/auth_screens/login_page.dart";
}
