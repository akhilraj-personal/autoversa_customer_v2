import 'dart:convert';
import 'dart:io';

import 'package:autoversa/model/model.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/AppWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socket_io_client/socket_io_client.dart';

class Chat extends StatefulWidget {
  static String tag = '/ChatScreen';
  final String? img;
  final String? name;
  const Chat({this.img, this.name, super.key});

  @override
  State<Chat> createState() => ChatState();
}

class ChatState extends State<Chat> {
  ScrollController scrollController = ScrollController();
  TextEditingController msgController = TextEditingController();
  FocusNode msgFocusNode = FocusNode();
  var msgListing = [];
  var personName = '';
  static const AMSender_id = 1;
  static const AMReceiver_id = 2;
  File? imageCam;
  late Socket socket;

  @override
  void initState() {
    super.initState();
    init();
    initializeSocket();
    getMessages();
  }

  void initializeSocket() async {
    final prefs = await SharedPreferences.getInstance();
    var user = prefs.getString('cust_id');
    print("----+iam here" + user.toString());
    socket = io(dotenv.env['SOCKET_URL'], <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    print("----+iam here");
    socket.connect(); //connect the Socket.IO Client to the Server
    socket.on('connect', (data) {
      print("----+");
      socket.emit('create_room', {"room_id": "DS_" + user!, "user": user});
    });
    socket.on("user_message", (data) {
      createMessage(data);
    });
    socket.on('disconnect', (data) {
      print('disconnected');
    });
    socket.on("error", (data) => print('error' + data.toString()));
  }

  getMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var user = prefs.getString('cust_id');
      await getCustomerMessages(base64.encode(utf8.encode(user!)))
          .then((value) {
        if (value['ret_data'] == "success") {
          for (var message in value['messages']) {
            var msgModel1 = AMMessageModel();
            if (message['csc_message_flag'] == "0") {
              msgModel1.senderId = -1;
              msgModel1.username = message['us_firstname'];
            } else {
              msgModel1.senderId = 1;
            }
            msgModel1.msg = message['csc_message'].toString();
            msgModel1.time = message['csc_created_on'];
            msgListing.insert(0, msgModel1);
          }
        }
        setState(() {});
      });
    } catch (e) {
      print(e.toString());
    }
  }

  createMessage(data) {
    DateFormat formatter = DateFormat('yyyy MMM dd hh:mm a');
    var msgModel1 = AMMessageModel();
    msgModel1.msg = data['message'].toString();
    msgModel1.time = DateTime.now().toString();
    msgModel1.senderId = -1;
    msgModel1.username = data['user'];
    msgListing.insert(0, msgModel1);
    setState(() {});
  }

  Future<void> init() async {
    setStatusBarColor(Colors.white, statusBarIconBrightness: Brightness.light);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  sendClick() async {
    DateFormat formatter = DateFormat('yyyy MMM dd hh:mm a');

    if (msgController.text.trim().isNotEmpty) {
      hideKeyboard(context);
      final prefs = await SharedPreferences.getInstance();
      var user = prefs.getString('cust_id');
      var msgModel = AMMessageModel();
      msgModel.msg = msgController.text.toString();
      msgModel.time = DateTime.now().toString();
      msgModel.senderId = AMSender_id;
      hideKeyboard(context);
      msgListing.insert(0, msgModel);
      msgController.text = '';
      if (mounted) scrollController.animToTop();
      // FocusScope.of(context).requestFocus(msgFocusNode);
      setState(() {});
      socket.emit('new_message_customer', {
        "room_id": "DS_" + user!,
        "user": user,
        "message": msgModel.msg,
        "time": DateTime.now().toString(),
      });
      try {
        Map<String, dynamic> chatdata = {
          "message": msgModel.msg,
          "customer": user,
          "message_type": 1,
          'message_flag': 1
        };
        await saveCustomerMessage(chatdata).then((value) {});
        hideKeyboard(context);
      } catch (e) {
        print(e.toString());
      }
      // if (mounted) scrollController.animToTop();
    } else {
      FocusScope.of(context).requestFocus(msgFocusNode);
    }
    setState(() {});
  }

  Future pickImage(ImageSource source) async {
    try {
      final imageCam = await ImagePicker().pickImage(source: source);
      if (imageCam == null) return;

      final imageTemporary = File(imageCam.path);
      setState(() => this.imageCam = imageTemporary);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: black),
          title: Row(
            children: <Widget>[
              CircleAvatar(
                  backgroundImage: AssetImage(widget.img!), radius: 16),
              8.width,
              Text(widget.name!, style: boldTextStyle()),
            ],
          ),
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              child: ListView.separated(
                separatorBuilder: (_, i) => Divider(color: Colors.transparent),
                shrinkWrap: true,
                reverse: true,
                controller: scrollController,
                itemCount: msgListing.length,
                padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 70),
                itemBuilder: (_, index) {
                  AMMessageModel data = msgListing[index];
                  var isMe = data.senderId == AMSender_id;

                  return ChatMessageWidget(isMe: isMe, data: data);
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding:
                    EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                decoration: BoxDecoration(
                    color: context.cardColor, boxShadow: defaultBoxShadow()),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: msgController,
                      focusNode: msgFocusNode,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration.collapsed(
                        hintText: personName.isNotEmpty
                            ? 'Write to ${widget.name}'
                            : 'Type a message',
                        hintStyle: primaryTextStyle(),
                        fillColor: context.cardColor,
                        filled: true,
                      ),
                      style: primaryTextStyle(),
                      onSubmitted: (s) {
                        sendClick();
                      },
                    ).expand(),
                    IconButton(
                      icon: Icon(Icons.send, size: 25),
                      onPressed: () async {
                        sendClick();
                      },
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.attach_file, size: 25),
                    //   onPressed: () => pickImage(ImageSource.gallery),
                    // ),
                    // IconButton(
                    //   icon: Icon(Icons.camera_alt, size: 25),
                    //   onPressed: () => pickImage(ImageSource.camera),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
