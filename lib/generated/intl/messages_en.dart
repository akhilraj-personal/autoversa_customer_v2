// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "change_number": MessageLookupByLibrary.simpleMessage("Change Number"),
        "data_verify_text":
            MessageLookupByLibrary.simpleMessage("Verifying Data"),
        "enter_mobile_text":
            MessageLookupByLibrary.simpleMessage("Enter Mobile Number"),
        "no_network_text": MessageLookupByLibrary.simpleMessage(
            "Internet connection not available"),
        "please_enter_the_code": MessageLookupByLibrary.simpleMessage(
            "Please enter the code below to verify its you"),
        "resend_otp": MessageLookupByLibrary.simpleMessage("Resend OTP"),
        "sign_in": MessageLookupByLibrary.simpleMessage("Sign In"),
        "sign_in_alt": MessageLookupByLibrary.simpleMessage("Sign in with"),
        "valid_mobile":
            MessageLookupByLibrary.simpleMessage("Please enter a valid number"),
        "verify_me": MessageLookupByLibrary.simpleMessage("Verify Me"),
        "verify_mobile_number":
            MessageLookupByLibrary.simpleMessage("Verify Mobile Number"),
        "verify_via_call":
            MessageLookupByLibrary.simpleMessage("Verify Via Call"),
        "we_have_send_a_6_digit_verification":
            MessageLookupByLibrary.simpleMessage(
                "We have send a 6 digit verification code to"),
        "welcome_text":
            MessageLookupByLibrary.simpleMessage("Sign in to your account")
      };
}
