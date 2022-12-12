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
