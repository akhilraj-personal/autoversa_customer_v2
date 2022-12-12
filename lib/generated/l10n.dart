// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Sign in to your account`
  String get welcome_text {
    return Intl.message(
      'Sign in to your account',
      name: 'welcome_text',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get sign_in {
    return Intl.message(
      'Sign In',
      name: 'sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Verify Me`
  String get verify_me {
    return Intl.message(
      'Verify Me',
      name: 'verify_me',
      desc: '',
      args: [],
    );
  }

  /// `Verify Mobile Number`
  String get verify_mobile_number {
    return Intl.message(
      'Verify Mobile Number',
      name: 'verify_mobile_number',
      desc: '',
      args: [],
    );
  }

  /// `We have send a 6 digit verification code to`
  String get we_have_send_a_6_digit_verification {
    return Intl.message(
      'We have send a 6 digit verification code to',
      name: 'we_have_send_a_6_digit_verification',
      desc: '',
      args: [],
    );
  }

  /// `Change Number`
  String get change_number {
    return Intl.message(
      'Change Number',
      name: 'change_number',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the code below to verify its you`
  String get please_enter_the_code {
    return Intl.message(
      'Please enter the code below to verify its you',
      name: 'please_enter_the_code',
      desc: '',
      args: [],
    );
  }

  /// `Resend OTP`
  String get resend_otp {
    return Intl.message(
      'Resend OTP',
      name: 'resend_otp',
      desc: '',
      args: [],
    );
  }

  /// `Verify Via Call`
  String get verify_via_call {
    return Intl.message(
      'Verify Via Call',
      name: 'verify_via_call',
      desc: '',
      args: [],
    );
  }

  /// `Enter Mobile Number`
  String get enter_mobile_text {
    return Intl.message(
      'Enter Mobile Number',
      name: 'enter_mobile_text',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with`
  String get sign_in_alt {
    return Intl.message(
      'Sign in with',
      name: 'sign_in_alt',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
