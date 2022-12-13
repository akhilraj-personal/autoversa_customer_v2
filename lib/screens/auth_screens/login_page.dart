import 'package:autoversa/screens/auth_screens/verification_by_otp_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../constant/image_const.dart';
import '../../constant/text_style.dart';
import '../../generated/l10n.dart';
import '../../provider/provider.dart';
import '../../services/pre_auth_services.dart';
import '../../utils/app_validations.dart';
import '../../utils/color_utils.dart';
import '../../utils/common_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var country_code = "+971";

  TextEditingController mobileNumber = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  customerLogin() async {
    setState(() {
      FocusScope.of(context).unfocus();
    });
    var in_mobile = mobileNumber.text.toString();
    var valid_number = in_mobile.substring(in_mobile.length - 9);
    Map req = {
      "phone": valid_number,
      "country_code": country_code,
    };
    await customerLoginService(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() => isLoading = false);
        showCustomToast(context, "OTP Send Successfully",
            bgColor: syanColor, textColor: whiteColor);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoginOTPVerification(
                    country_code: country_code.toString(),
                    phone: valid_number.toString(),
                    timer: value['timer'])));
      } else {
        setState(() => isLoading = false);
        showCustomToast(context, value['ret_data'],
            bgColor: changenumberorange, textColor: whiteColor);
        setState(() {});
      }
    }).catchError((e) {
      setState(() => isLoading = false);
      print(e.toString());
      showCustomToast(context, "Application error. Contact support",
          bgColor: changenumberorange, textColor: whiteColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.white,
        ),
        child: Scaffold(
          body: SingleChildScrollView(
              child: Center(
                  child: Container(
                      height: height - 50,
                      width: width,
                      margin: const EdgeInsets.only(top: 50),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                height: 20,
                                width: width,
                                margin: EdgeInsets.only(
                                    left: width * 0.06, right: width * 0.06),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.20,
                                      child: GestureDetector(
                                        onTap: () async {
                                          context
                                              .read<LanguageChangeProvider>()
                                              .changeLocale("en");
                                          setState(() {});
                                        },
                                        child: Text(
                                          'English',
                                          textAlign: TextAlign.end,
                                          style: montserratRegular.copyWith(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: GestureDetector(
                                        onTap: () async {
                                          context
                                              .read<LanguageChangeProvider>()
                                              .changeLocale("ar");
                                          setState(() {});
                                        },
                                        child: Text(
                                          'عربي',
                                          textAlign: TextAlign.end,
                                          style: montserratRegular.copyWith(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            Container(
                                height: height - 70,
                                width: width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      ImageConst.ai_icon,
                                      fit: BoxFit.contain,
                                      width: 115,
                                      height: 50,
                                    ),
                                    SizedBox(height: height * 0.08),
                                    Text(
                                      S.of(context).welcome_text,
                                      style: montserratSemiBold.copyWith(
                                          color: blackColor, fontSize: 21),
                                    ),
                                    SizedBox(height: height * 0.02),
                                    Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Container(
                                            height: height * 0.045,
                                            width: height * 0.37,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                boxShadow: [
                                                  BoxShadow(
                                                      blurRadius: 16,
                                                      color: syanColor
                                                          .withOpacity(.5),
                                                      spreadRadius: 0,
                                                      blurStyle:
                                                          BlurStyle.outer,
                                                      offset: Offset(0, 0)),
                                                ]),
                                          ),
                                          Form(
                                            key: _formKey,
                                            child: Container(
                                                height: height * 0.075,
                                                width: height * 0.4,
                                                decoration: BoxDecoration(
                                                  color: whiteColor,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color: borderGreyColor),
                                                ),
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: width *
                                                                    0.025,
                                                                right: width *
                                                                    0.025),
                                                        child: Text("AE +971")),
                                                    Container(
                                                      height: height * 0.075,
                                                      width: 2.0,
                                                      color: borderGreyColor,
                                                      margin: EdgeInsets.only(
                                                          left: width * 0.025,
                                                          right: width * 0.025),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: width *
                                                                    0.025),
                                                        child: TextFormField(
                                                          controller:
                                                              mobileNumber,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          maxLength: 10,
                                                          style: TextStyle(
                                                              fontSize: 18.0),
                                                          decoration: InputDecoration(
                                                              counterText: "",
                                                              filled: true,
                                                              hintText: S
                                                                  .of(context)
                                                                  .enter_mobile_text,
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 14),
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              fillColor:
                                                                  whiteColor),
                                                          validator: (value) {
                                                            return mobileNumberValidation(
                                                                value, context);
                                                          },
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )),
                                          ),
                                        ]),
                                    SizedBox(height: height * 0.03),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isLoading = true;
                                          if (_formKey.currentState!
                                              .validate()) {
                                            customerLogin();
                                          } else {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        });
                                      },
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Container(
                                            height: height * 0.045,
                                            width: height * 0.37,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                boxShadow: [
                                                  BoxShadow(
                                                      blurRadius: 16,
                                                      color: syanColor
                                                          .withOpacity(.6),
                                                      spreadRadius: 0,
                                                      blurStyle:
                                                          BlurStyle.outer,
                                                      offset: Offset(0, 0)),
                                                ]),
                                          ),
                                          Container(
                                            height: height * 0.075,
                                            width: height * 0.4,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(14)),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  syanColor,
                                                  blueColor,
                                                ],
                                              ),
                                            ),
                                            child: !isLoading
                                                ? Text(
                                                    S
                                                        .of(context)
                                                        .sign_in
                                                        .toUpperCase(),
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Transform.scale(
                                                        scale: 0.7,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: whiteColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: height * 0.03),
                                    Text(
                                      S.of(context).sign_in_alt,
                                      style: montserratRegular.copyWith(
                                          color: blackColor, fontSize: 12),
                                    ),
                                    SizedBox(height: height * 0.04),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.only(
                                            right: height * 0.045 / 2,
                                            left: height * 0.045 / 2,
                                          ),
                                          child: Image.asset(
                                            ImageConst.fb_icon,
                                            fit: BoxFit.contain,
                                            height: height * 0.065,
                                            width: height * 0.065,
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.only(
                                              left: height * 0.045 / 2,
                                              right: height * 0.045 / 2),
                                          child: Image.asset(
                                            ImageConst.g_icon,
                                            fit: BoxFit.contain,
                                            height: height * 0.065,
                                            width: height * 0.065,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )),
                          ])))),
        ));
  }
}
