import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class termsandCondition extends StatefulWidget {
  const termsandCondition({super.key});

  @override
  State<termsandCondition> createState() => termsandConditionState();
}

class termsandConditionState extends State<termsandCondition> {
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
                      Color.fromARGB(255, 176, 205, 210),
                    ],
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            "Terms & Conditions",
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
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                "Please review the following terms of service prior when working with Autoversa Auto Repairs. These terms of service govern your utilization of features or services on the platforms owned and operated by Autoversa Auto Repairs. This is applicable to all individuals, including visitors, users, and others, who either access or use our website for purposes such as making purchases, registering, and providing feedback. Your ability to access and utilize the website is contingent on your acceptance of and adherence to these terms.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "User Registration",
                style: montserratBold.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "All individuals wishing to access specific features of our platforms may need to register for an account. During registration:",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "● Users must provide accurate, current, and complete information.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "● Users are prohibited from using pseudonyms or impersonating any other individual",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "● Users are responsible for maintaining the confidentiality of their account information, including the password.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "● Any unauthorized use of a user’s account or other security breaches must be immediately reported to Autoversa Auto Repairs.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Payment Terms",
                style: montserratBold.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "● Use valid payment methods acceptable to Autoversa Auto Repairs when making purchases.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "● Ensure timely payment for any products or services acquired.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "● Be responsible for any fees or charges imposed by their banks or credit card providers.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "● Any unauthorized use of a user’s account or other security breaches must be immediately reported to Autoversa Auto Repairs.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Termination of Services",
                style: montserratBold.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Autoversa Auto Repairs retains the right to:",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "● Terminate or suspend any user’s access to our platforms for any reason, including breach of these Terms and Conditions.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "● Discontinue any feature or service at any time",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Refund/Return Policy",
                style: montserratBold.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "For details on returns or refunds, users are advised to refer to our Refund Policy page. All returns or refund requests must comply with the criteria outlined therein.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Service Availability",
                style: montserratBold.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Autoversa Auto Repairs does not guarantee uninterrupted access to our platforms. There may be occasions when the platforms are interrupted for scheduled maintenance or upgrades, emergency repairs, or due to the failure of telecommunications links and equipment.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "User Conduct",
                style: montserratBold.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "All users are expected to act responsibly and respectfully when using our platforms. Any behaviors deemed offensive, harmful, or inappropriate may lead to the suspension or banning of the user.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Dispute Resolution",
                style: montserratBold.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Any disputes arising out of these Terms and Conditions will first attempt to be resolved through mutual discussions. If parties cannot reach an agreement, the dispute will be settled through binding arbitration in Abu Dhabi, UAE.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Waiver and Severability",
                style: montserratBold.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Failure by Autoversa Auto Repairs to enforce any provision of these Terms and Conditions will not be deemed a waiver. If any provision is found unenforceable, the remaining provisions will remain in full effect.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Force Majeure",
                style: montserratBold.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Autoversa Auto Repairs is not liable for any failure to perform its obligations if such failure results from acts beyond its control, including natural disasters, governmental actions, or other disruptions.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Contact Information",
                style: montserratBold.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: montserratRegular.copyWith(
                      fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                        text:
                            "For any concerns, queries, or feedback, users can contact us at "),
                    TextSpan(
                        text: "support@benzuae.com",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " or call "),
                    TextSpan(
                        text: "+971 50 8001387",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "."),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Updates and Notifications",
                style: montserratBold.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Changes to these Terms and Conditions will be communicated on this page. Continued use of the platform after changes are posted constitutes acceptance of the revised terms.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Governing Law",
                style: montserratBold.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "These Terms and Conditions are governed by the laws of Abu Dhabi, UAE.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Limitations on Claims",
                style: montserratBold.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 8),
              Text(
                "Any claims or disputes related to these Terms and Conditions must be filed within one year after such claim or cause of action arises.",
                style: montserratRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
