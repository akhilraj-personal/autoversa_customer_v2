import '../generated/l10n.dart';

mobileNumberValidation(value, context) {
  String pattern = r'(^(?:[+0]9)?[0-9]{8,12}$)';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return ST.of(context).valid_mobile;
  } else if (value.length < 9) {
    return ST.of(context).valid_mobile;
  } else if (!regExp.hasMatch(value)) {
    return ST.of(context).valid_mobile;
  }
  return null;
}

emirateValidation(value, context) {
  if (value == null) {
    return ST.of(context).emirate_error;
  } else {
    return null;
  }
}

addressValidation(value, context) {
  String pattern = r'(^[A-Za-z0-9 _]*[A-Za-z0-9][A-Za-z0-9 _]*$)';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return ST.of(context).address_error;
  } else if (!regExp.hasMatch(value)) {
    return ST.of(context).address_error;
  }
  return null;
}

buildingValidation(value) {
  String pattern = r'(^[A-Za-z0-9 _]*[A-Za-z0-9][A-Za-z0-9 _]*$)';
  RegExp regExp = new RegExp(pattern);
  if (!regExp.hasMatch(value)) {
    return "Enter valid data";
  }
  return null;
}

fullNameValidation(value, context) {
  String pattern = r'^[A-Za-z -]+$';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return ST.of(context).name_error;
  } else if (!regExp.hasMatch(value)) {
    return ST.of(context).name_error;
  }
  return null;
}

plateNumberValidation(value) {
  String pattern = r'^[a-zA-Z0-9 -/]+$';
  RegExp regExp = new RegExp(pattern);
  if (!regExp.hasMatch(value)) {
    return "Enter valid data";
  }
  return null;
}

emailValidation(value, context) {
  String pattern = r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return null;
  } else if (!regExp.hasMatch(value)) {
    return ST.of(context).email_error;
  }
  return null;
}

selectmakeValidation(value) {
  if (value == null) {
    return "Make is required";
  } else {
    return null;
  }
}

selectmodelValidation(value) {
  if (value == null) {
    return "Model is required";
  } else {
    return null;
  }
}

selectvariantValidation(value) {
  if (value == null) {
    return "Variant is required";
  } else {
    return null;
  }
}

selectyearValidation(value) {
  if (value == null) {
    return "Year is required";
  } else {
    return null;
  }
}
