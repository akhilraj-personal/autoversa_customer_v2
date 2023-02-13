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

class ST {
  ST();

  static ST? _current;

  static ST get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<ST> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = ST();
      ST._current = instance;

      return instance;
    });
  }

  static ST of(BuildContext context) {
    final instance = ST.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static ST? maybeOf(BuildContext context) {
    return Localizations.of<ST>(context, ST);
  }

  /// `Sign in to Your Account`
  String get welcome_text {
    return Intl.message(
      'Sign in to Your Account',
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

  /// `Enter Valid Number`
  String get valid_mobile {
    return Intl.message(
      'Enter Valid Number',
      name: 'valid_mobile',
      desc: '',
      args: [],
    );
  }

  /// `Verifying Data`
  String get data_verify_text {
    return Intl.message(
      'Verifying Data',
      name: 'data_verify_text',
      desc: '',
      args: [],
    );
  }

  /// `Internet Connection Not Available`
  String get no_network_text {
    return Intl.message(
      'Internet Connection Not Available',
      name: 'no_network_text',
      desc: '',
      args: [],
    );
  }

  /// `OTP Send Successfully`
  String get otp_send_text {
    return Intl.message(
      'OTP Send Successfully',
      name: 'otp_send_text',
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

  /// `Second`
  String get seconds_text {
    return Intl.message(
      'Second',
      name: 'seconds_text',
      desc: '',
      args: [],
    );
  }

  /// `Resend OTP`
  String get resend_otp_text {
    return Intl.message(
      'Resend OTP',
      name: 'resend_otp_text',
      desc: '',
      args: [],
    );
  }

  /// `Verify Via Call`
  String get verify_call_text {
    return Intl.message(
      'Verify Via Call',
      name: 'verify_call_text',
      desc: '',
      args: [],
    );
  }

  /// `Enter Valid OTP`
  String get otp_invalid_text {
    return Intl.message(
      'Enter Valid OTP',
      name: 'otp_invalid_text',
      desc: '',
      args: [],
    );
  }

  /// `Maximum attempt reached. Please try again later.`
  String get max_otp_text {
    return Intl.message(
      'Maximum attempt reached. Please try again later.',
      name: 'max_otp_text',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get dash_intro_text {
    return Intl.message(
      'Welcome',
      name: 'dash_intro_text',
      desc: '',
      args: [],
    );
  }

  /// `Add new vehicle`
  String get new_vehicle_text {
    return Intl.message(
      'Add new vehicle',
      name: 'new_vehicle_text',
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

  /// `We have send a 4 digit verification code to`
  String get send_verification_msg {
    return Intl.message(
      'We have send a 4 digit verification code to',
      name: 'send_verification_msg',
      desc: '',
      args: [],
    );
  }

  /// `mentioned number`
  String get to_mentioned_number {
    return Intl.message(
      'mentioned number',
      name: 'to_mentioned_number',
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

  /// `Register New Account`
  String get register_new_account {
    return Intl.message(
      'Register New Account',
      name: 'register_new_account',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get sign_up {
    return Intl.message(
      'Sign Up',
      name: 'sign_up',
      desc: '',
      args: [],
    );
  }

  /// `Emirates*`
  String get emirates {
    return Intl.message(
      'Emirates*',
      name: 'emirates',
      desc: '',
      args: [],
    );
  }

  /// `Full Name*`
  String get full_name {
    return Intl.message(
      'Full Name*',
      name: 'full_name',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Number*`
  String get mobile_number {
    return Intl.message(
      'Mobile Number*',
      name: 'mobile_number',
      desc: '',
      args: [],
    );
  }

  /// `Enter Valid Name`
  String get name_error {
    return Intl.message(
      'Enter Valid Name',
      name: 'name_error',
      desc: '',
      args: [],
    );
  }

  /// `Enter Valid Email`
  String get email_error {
    return Intl.message(
      'Enter Valid Email',
      name: 'email_error',
      desc: '',
      args: [],
    );
  }

  /// `Choose Emirates`
  String get emirate_error {
    return Intl.message(
      'Choose Emirates',
      name: 'emirate_error',
      desc: '',
      args: [],
    );
  }

  /// `Application Error. Contact Support`
  String get toast_application_error {
    return Intl.message(
      'Application Error. Contact Support',
      name: 'toast_application_error',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Add`
  String get vehicle_add {
    return Intl.message(
      'Vehicle Add',
      name: 'vehicle_add',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Added Successfully`
  String get vehicle_save_toast {
    return Intl.message(
      'Vehicle Added Successfully',
      name: 'vehicle_save_toast',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Already Exist`
  String get vehicle_already_exist {
    return Intl.message(
      'Vehicle Already Exist',
      name: 'vehicle_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Try Another Method`
  String get try_another_method {
    return Intl.message(
      'Try Another Method',
      name: 'try_another_method',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Plate Number`
  String get plate_number {
    return Intl.message(
      'Plate Number',
      name: 'plate_number',
      desc: '',
      args: [],
    );
  }

  /// `Make`
  String get make {
    return Intl.message(
      'Make',
      name: 'make',
      desc: '',
      args: [],
    );
  }

  /// `Model`
  String get model {
    return Intl.message(
      'Model',
      name: 'model',
      desc: '',
      args: [],
    );
  }

  /// `Variant`
  String get variant {
    return Intl.message(
      'Variant',
      name: 'variant',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get year {
    return Intl.message(
      'Year',
      name: 'year',
      desc: '',
      args: [],
    );
  }

  /// `Enter Valid Address`
  String get address_error {
    return Intl.message(
      'Enter Valid Address',
      name: 'address_error',
      desc: '',
      args: [],
    );
  }

  /// `Additional Queries`
  String get additional_queries {
    return Intl.message(
      'Additional Queries',
      name: 'additional_queries',
      desc: '',
      args: [],
    );
  }

  /// `Your message here...`
  String get your_message_here {
    return Intl.message(
      'Your message here...',
      name: 'your_message_here',
      desc: '',
      args: [],
    );
  }

  /// `Press record to start audio recording`
  String get press_record_dialogue {
    return Intl.message(
      'Press record to start audio recording',
      name: 'press_record_dialogue',
      desc: '',
      args: [],
    );
  }

  /// `BOOK NOW`
  String get book_now {
    return Intl.message(
      'BOOK NOW',
      name: 'book_now',
      desc: '',
      args: [],
    );
  }

  /// `Add Address`
  String get add_address {
    return Intl.message(
      'Add Address',
      name: 'add_address',
      desc: '',
      args: [],
    );
  }

  /// `Drop location same as pickup location`
  String get drop_location_same {
    return Intl.message(
      'Drop location same as pickup location',
      name: 'drop_location_same',
      desc: '',
      args: [],
    );
  }

  /// `Select Drop Address`
  String get select_drop_address {
    return Intl.message(
      'Select Drop Address',
      name: 'select_drop_address',
      desc: '',
      args: [],
    );
  }

  /// `Pickup options`
  String get pickup_options {
    return Intl.message(
      'Pickup options',
      name: 'pickup_options',
      desc: '',
      args: [],
    );
  }

  /// `FREE`
  String get free {
    return Intl.message(
      'FREE',
      name: 'free',
      desc: '',
      args: [],
    );
  }

  /// `Select Booking Date`
  String get select_booking_date {
    return Intl.message(
      'Select Booking Date',
      name: 'select_booking_date',
      desc: '',
      args: [],
    );
  }

  /// `Select a Time Slot`
  String get select_a_time_slot {
    return Intl.message(
      'Select a Time Slot',
      name: 'select_a_time_slot',
      desc: '',
      args: [],
    );
  }

  /// `Slot is Full`
  String get slot_is_full {
    return Intl.message(
      'Slot is Full',
      name: 'slot_is_full',
      desc: '',
      args: [],
    );
  }

  /// `No time slot available`
  String get no_time_slot_available {
    return Intl.message(
      'No time slot available',
      name: 'no_time_slot_available',
      desc: '',
      args: [],
    );
  }

  /// `PROCEED`
  String get proceed {
    return Intl.message(
      'PROCEED',
      name: 'proceed',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<ST> {
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
  Future<ST> load(Locale locale) => ST.load(locale);
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
