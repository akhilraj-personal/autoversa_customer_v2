import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../generated/l10n.dart' as lang;

class DeactivateReason extends StatefulWidget {
  const DeactivateReason({super.key});

  @override
  State<DeactivateReason> createState() => DeactivateReasonState();
}

class DeactivateReasonState extends State<DeactivateReason> {
  bool isCheckboxSelected = false;
  int? option;
  TextEditingController deactivatereasonController = TextEditingController();

  String getOptionText() {
    switch (option) {
      case 1:
        return "No longer using the app";
      case 2:
        return "Found a better auto repairs app";
      case 3:
        return "Dissatisfied with the app's features or services";
      case 4:
        return "Privacy concerns";
      case 5:
        return "Difficulty using the app";
      default:
        return "";
    }
  }

  deleteaccount() async {
    final prefs = await SharedPreferences.getInstance();
    Map req = {
      "custId": prefs.getString('cust_id'),
      "reason": option == 3 ? deactivatereasonController.text : getOptionText(),
    };
    print(req);
    await deactivateaccount(req).then((value) async {
      if (value['ret_data'] == "success") {
        showCustomToast(context, "Account Deactivated",
            bgColor: toastgrey, textColor: white);
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushReplacementNamed(context, Routes.loginPage);
      } else {
        print("ffffffffffffff");
        print(value);
        showCustomToast(context, value['ret_data'],
            bgColor: errorcolor, textColor: white);
      }
    }).catchError((e) {
      print("eeeeeeeeeee");
      print(e.toString());
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: white);
    });
  }

  @override
  void dispose() {
    deactivatereasonController.dispose();
    super.dispose();
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
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            alignment: Alignment.bottomCenter,
            width: width,
            height: height * 0.42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  lightblueColor,
                  syanColor,
                ],
              ),
            ),
            child: ClipPath(
              clipper: SinCosineWaveClipper(
                verticalPosition: VerticalPosition.top,
              ),
              child: Container(
                height: height * 0.81,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      syanColor.withOpacity(0.2),
                      Color.fromARGB(255, 173, 175, 175),
                    ],
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            "Deactivate Reason",
            style: montserratRegular.copyWith(
              fontSize: width * 0.044,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            iconSize: 18,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Reason for deactivating your account",
                      style: montserratSemiBold.copyWith(
                        color: black,
                        fontSize: width * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: option == 1,
                    fillColor: MaterialStateProperty.all(redColor),
                    onChanged: (value) {
                      setState(() {
                        option = value! ? 1 : null;
                        isCheckboxSelected = value;
                      });
                    },
                  ),
                  Text(
                    "No longer using the app",
                    style: montserratRegular.copyWith(fontSize: width * 0.034),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: option == 2,
                    fillColor: MaterialStateProperty.all(redColor),
                    onChanged: (value) {
                      setState(() {
                        option = value! ? 2 : null;
                        isCheckboxSelected = value;
                      });
                    },
                  ),
                  Text(
                    "Found a better auto repairs app",
                    style: montserratRegular.copyWith(fontSize: width * 0.034),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: option == 3,
                    fillColor: MaterialStateProperty.all(redColor),
                    onChanged: (value) {
                      setState(() {
                        option = value! ? 3 : null;
                        isCheckboxSelected = value;
                      });
                    },
                  ),
                  Text(
                    "Dissatisfied with the app's features or services",
                    style: montserratRegular.copyWith(fontSize: width * 0.034),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: option == 4,
                    fillColor: MaterialStateProperty.all(redColor),
                    onChanged: (value) {
                      setState(() {
                        option = value! ? 4 : null;
                        isCheckboxSelected = value;
                      });
                    },
                  ),
                  Text(
                    "Privacy concerns",
                    style: montserratRegular.copyWith(fontSize: width * 0.034),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: option == 5,
                    fillColor: MaterialStateProperty.all(redColor),
                    onChanged: (value) {
                      setState(() {
                        option = value! ? 3 : null;
                        isCheckboxSelected = value;
                      });
                    },
                  ),
                  Text(
                    "Difficulty using the app",
                    style: montserratRegular.copyWith(fontSize: width * 0.034),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: option == 6,
                    fillColor: MaterialStateProperty.all(redColor),
                    onChanged: (value) {
                      setState(() {
                        option = value! ? 6 : null;
                        isCheckboxSelected = value;
                      });
                    },
                  ),
                  Text(
                    "Others",
                    style: montserratRegular.copyWith(fontSize: width * 0.034),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              if (option == 6)
                Padding(
                  padding: const EdgeInsets.only(left: 42.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: white,
                    ),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      minLines: 1,
                      maxLines: 6,
                      maxLength: 230,
                      controller: deactivatereasonController,
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "Enter reason",
                        hintStyle: montserratRegular.copyWith(
                          color: grey,
                          fontSize: width * 0.034,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: black, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: black, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () {
              if (!isCheckboxSelected) {
                showCustomToast(context, "Choose any reason listed above",
                    bgColor: toastgrey, textColor: white);
                return;
              }
              deleteaccount();
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: height * 0.065,
                  width: height * 0.35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        redColor.withOpacity(0.75),
                        redColor.withOpacity(0.75),
                      ],
                    ),
                  ),
                  child: Text(
                    "DEACTIVATE ACCOUNT",
                    style: montserratSemiBold.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
