import 'dart:io' show Platform;

import 'package:autoversa/provider/provider.dart';
import 'package:autoversa/screens/auth_screens/login_page.dart';
import 'package:autoversa/screens/bottom_tab/bottomtab.dart';
import 'package:autoversa/screens/splash_screen/splash_screen.dart';
import 'package:autoversa/screens/support/support_screen.dart';
import 'package:autoversa/screens/vehicle/vehicle_add_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart' as lang;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  Stripe.publishableKey = dotenv.env['STRIPE_PAYMENT_PUBLISH_KEY']!;
  if (Platform.isIOS || Platform.isAndroid) {
    try {
      await OneSignal.shared.setAppId("71139c93-b725-4209-9a36-619ce631f943");
      OneSignal.shared.setNotificationWillShowInForegroundHandler(
          (OSNotificationReceivedEvent? event) {
        return event?.complete(event.notification);
      });
    } catch (e) {
      print('${e.toString()}');
    }
  }
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
              lang.S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: lang.S.delegate.supportedLocales,
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
  Routes.vehiclePage: (BuildContext context) => VehicleAddPage(),
  Routes.supportPage: (BuildContext context) => Support(click_id: 1),
};

class Routes {
  static const SPLASH = "/";
  static const bottombar = "screens/bottom_tab/bottomtab.dart";
  static const loginPage = "screens/auth_screens/login_page.dart";
  static const supportPage = "screens/support/support_screen.dart";
  static const otpverification =
      "screens/auth_screens/verification_by_otp_page.dart";
  static const vehiclePage = "screens/vehicle/vehicle_add_page.dart";
}
