import '../generated/l10n.dart';

mobileNumberValidation(value, context) {
  String pattern = r'(^(?:[+0]9)?[0-9]{8,12}$)';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return S.of(context).valid_mobile;
  } else if (value.length < 9) {
    return S.of(context).valid_mobile;
  } else if (!regExp.hasMatch(value)) {
    return S.of(context).valid_mobile;
  }
  return null;
}

emirateValidation(value, context) {
  if (value == null) {
    return S.of(context).email_error;
  } else {
    return null;
  }
}

fullNameValidation(value, context) {
  String pattern = r'^[A-Za-z -]+$';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return S.of(context).name_error;
  } else if (!regExp.hasMatch(value)) {
    return S.of(context).name_error;
  }
  return null;
}

emailValidation(value, context) {
  String pattern = r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return null;
  } else if (!regExp.hasMatch(value)) {
    return S.of(context).email_error;
  }
  return null;
}
