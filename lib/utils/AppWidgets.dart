import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/model/model.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

String convertDate(date) {
  try {
    return date != null
        ? DateFormat('dd-MM-yyyy').format(DateTime.parse(date))
        : '';
  } catch (e) {
    print(e);
    return '';
  }
}

class CustomTheme extends StatelessWidget {
  final Widget? child;

  CustomTheme({required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: syanColor,
        accentColor: syanColor,
        colorScheme: ColorScheme.light(primary: syanColor),
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
      ),
      child: child!,
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    Key? key,
    required this.isMe,
    required this.data,
  }) : super(key: key);

  final bool isMe;
  final AMMessageModel data;

  @override
  Widget build(BuildContext context) {
    final f = new DateFormat('yyyy MMM dd hh:mm a');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isMe.validate() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          margin: isMe.validate()
              ? EdgeInsets.only(
                  top: 3.0,
                  bottom: 3.0,
                  right: 0,
                  left: (500 * 0.25).toDouble())
              : EdgeInsets.only(
                  top: 4.0,
                  bottom: 4.0,
                  left: 0,
                  right: (500 * 0.25).toDouble()),
          decoration: BoxDecoration(
            color: !isMe ? Colors.blue.withOpacity(0.85) : context.cardColor,
            boxShadow: defaultBoxShadow(),
            borderRadius: isMe.validate()
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))
                : BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topRight: Radius.circular(10)),
            border: Border.all(
                color:
                    isMe ? Theme.of(context).dividerColor : Colors.transparent),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                !isMe
                    ? data.username != ""
                        ? "Agent (" + data.username! + ")"
                        : "Agent"
                    : "Me",
                style: montserratRegular.copyWith(
                    color: !isMe ? white : gray, fontSize: 10),
              ),
              Flexible(
                  child: Text(data.msg!,
                      style: montserratRegular.copyWith(
                          color: !isMe ? white : white))),
              Text(
                f.format(DateTime.parse(data.time!)),
                style: montserratRegular.copyWith(
                    color: !isMe ? white : gray, fontSize: 8),
              )
            ],
          ),
        ),
      ],
    );
  }
}
