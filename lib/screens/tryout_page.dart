import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/screens/bottom_tab/bottomtab.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupViaGmail extends StatefulWidget {
  final String name;
  final String email;
  const SignupViaGmail({super.key, required this.name, required this.email});

  @override
  State<SignupViaGmail> createState() => SignupViaGmailState();
}

class SignupViaGmailState extends State<SignupViaGmail> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  FocusNode userNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode numberWordFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();
  String emirates = '';
  List<DropdownMenuItem<String>> items = [];
  List data = List<String>.empty();
  var country_code = "+91";
  bool isLoading = false;
  bool isVerifiedClicked = false;
  bool isVerifymeActive = true;
  bool isoffline = false;
  String otppin = '';

  @override
  void initState() {
    super.initState();
    init();
    Future.delayed(Duration.zero, () {
      _getStateList();
      userNameController.text = widget.name;
      emailController.text = widget.email;
    });
  }

  Future<void> init() async {
    //
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getStateList() async {
    Map req = {
      "countryId": 1,
    };
    await getStateList(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          data = value['statelist'];
          print(data);
          items = data
              .map((item) => DropdownMenuItem(
                  child: Text(item['state_name']),
                  value: item['state_id'].toString()))
              .toList();
        });
      } else {
        print("--------------");
        print(value['ret_data']);
      }
    }).catchError((e) {
      print("+++++++++++");
      print(e.toString());
    });
  }

  verify_submit_otp(pin) async {
    setState(() {});
    final prefs = await SharedPreferences.getInstance();
    Map req = {
      "phone": numberController.text.toString(),
      "country_code": country_code,
      "otp": pin,
    };
    print(req);
    print("hjvghdsvfhjvfhjjdf");
    if (pin == null || pin == "") {
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: Text("dddd"),
          action: SnackBarAction(
              label: "hjj", onPressed: scaffold.hideCurrentSnackBar),
        ),
      );
    } else {}
  }

  cust_signup() async {
    setState(() {});
    Map req = {
      "emiratesId": emirates.toString(),
      "fullname": widget.name.toString(),
      "email": widget.email.toString(),
      "phone": numberController.text.toString(),
      "country_coded": country_code.toString(),
      "country": "UAE"
    };
    final prefs = await SharedPreferences.getInstance();
    await customerSignup(req).then((value) {
      if (value['ret_data'] == "success") {
        prefs.setString('name', value['cust_info']['name']);
        prefs.setString('email', value['cust_info']['email']);
        prefs.setString('emirate', value['cust_info']['emirate']);
        prefs.setString('language', value['cust_info']['language']);
        prefs.setString('credits', value['cust_info']['credits']);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavBarScreen(
              index: 1,
            ),
          ),
          (route) => false,
        );
      } else {}
    }).catchError((e) {});
  }

  change_country(country) {
    country_code = country.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "ggggggggggggg",
          textAlign: TextAlign.start,
          overflow: TextOverflow.clip,
        ),
        // actions: [
        //   TextButton(
        //       child: Text("Logout"),
        //       onPressed: () {
        //         final provider =
        //             Provider.of<GoogleSignInProvider>(context, listen: false);
        //         provider.logout(context);
        //       }),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding:
                  EdgeInsets.only(left: 16, right: 16, top: 100, bottom: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: Text("cvvcvcv"),
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField(
                            isExpanded: true,
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1),
                              ),
                              hintText: "fffff",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              filled: true,
                              isDense: false,
                              contentPadding: EdgeInsets.fromLTRB(16, 8, 12, 8),
                            ),
                            items: items,
                            validator: (value) {
                              if (value == null) {}
                            },
                            onChanged: (value) {
                              print(value);
                              emirates = value.toString();
                            },
                          ),
                          SizedBox(height: 15),
                          Container(
                            child: Text("fdfd"),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: userNameController,
                            obscureText: false,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            maxLength: 50,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).requestFocus(emailFocus);
                            },
                            focusNode: userNameFocus,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1),
                              ),
                              hintText: "fffffffffffffff",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              filled: true,
                              isDense: false,
                              contentPadding: EdgeInsets.fromLTRB(16, 8, 12, 8),
                            ),
                            validator: (value) {},
                          ),
                          SizedBox(height: 15),
                          Container(
                            child: Text("bbbbbbbbbb"),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: emailController,
                            obscureText: false,
                            keyboardType: TextInputType.emailAddress,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(numberWordFocus);
                            },
                            focusNode: emailFocus,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1),
                              ),
                              hintText: "vvvvvv",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              enabled: false,
                              filled: true,
                              isDense: false,
                              contentPadding: EdgeInsets.fromLTRB(16, 8, 12, 8),
                            ),
                            validator: (value) {},
                          ),
                          SizedBox(height: 15),
                          Container(
                            child: Text("ffffffffffffff"),
                          ),
                          SizedBox(height: 10),
                          Container(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: <Widget>[
                                  Container(child: Text("AE +971")),
                                  Container(
                                    height: 30.0,
                                    width: 2.0,
                                    color: whiteColor,
                                    margin: EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: numberController,
                                      maxLength: 10,
                                      keyboardType: TextInputType.number,
                                      focusNode: numberWordFocus,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        counterText: "",
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          borderSide: BorderSide(
                                              color: Colors.transparent,
                                              width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          borderSide: BorderSide(
                                              color: Colors.transparent,
                                              width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          borderSide: BorderSide(
                                              color: Colors.transparent,
                                              width: 1),
                                        ),
                                        filled: true,
                                        isDense: false,
                                        contentPadding:
                                            EdgeInsets.fromLTRB(16, 18, 16, 8),
                                      ),
                                      validator: (value) {},
                                    ),
                                  )
                                ],
                              )),
                        ]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ButtonTheme(
                    minWidth: 160.0,
                    height: 65.0,
                    child: MaterialButton(
                      onPressed: isVerifymeActive
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                if (isLoading) return;
                                setState(() => isLoading = true);
                                setState(() => isVerifiedClicked = true);
                                setState(() => isVerifymeActive = false);
                              }
                            }
                          : null,
                      color: whiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                const SizedBox(
                                  width: 24,
                                ),
                              ],
                            )
                          : Text(
                              'Verify Me',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.normal),
                            ),
                      textColor: Color(0xffffffff),
                      height: 40,
                      minWidth: MediaQuery.of(context).size.width,
                    ),
                  ),
                  isVerifiedClicked
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            OtpTextField(
                              numberOfFields: 6,
                              fieldWidth: width * 0.12,
                              clearText: true,
                              focusedBorderColor: syanColor,
                              cursorColor: syanColor,
                              showFieldAsBox: true,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12.0)),
                              onCodeChanged: (String code) {},
                              onSubmit:
                                  (String verificationCode) {}, // end onSubmit
                            ),
                          ],
                        )
                      : Row(),
                  SizedBox(height: 32),
                  isVerifiedClicked
                      ? ButtonTheme(
                          minWidth: 160.0,
                          height: 65.0,
                          child: MaterialButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                cust_signup();
                              }
                            },
                            color: whiteColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Text(
                              "nnnnnnnn",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.normal),
                            ),
                            textColor: Color(0xffffffff),
                            height: 40,
                            minWidth: MediaQuery.of(context).size.width,
                          ))
                      : Row(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: IntrinsicHeight(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        setState(() {});
                      },
                      child: Text(
                        'English',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: Colors.grey,
                      thickness: 2,
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {});
                      },
                      child: Text(
                        'عربي',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: Colors.grey,
                      thickness: 2,
                    ),
                  ],
                )),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
