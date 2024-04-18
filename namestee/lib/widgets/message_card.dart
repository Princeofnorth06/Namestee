import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiichat/api/api.dart';
import 'package:hiichat/helper/dialogs.dart';
import 'package:hiichat/helper/my_date_util.dart';
import 'package:hiichat/main.dart';
import 'package:hiichat/models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _orangeMessages() : _amberMessages(),
    );
  }

  //ours message
  Widget _orangeMessages() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * 0.04,
            ),
            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all,
                color: Colors.redAccent,
                size: 20,
              ),
            SizedBox(
              width: 2,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                border: Border.all(color: Colors.black87)),
            margin: EdgeInsets.symmetric(
                vertical: mq.height * 0.01, horizontal: mq.width * 0.04),
            padding: EdgeInsets.all(widget.message.type == Type.text
                ? mq.width * 0.04
                : mq.width * 0.03),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15),
                  )
                : ClipRRect(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.image),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  //others message
  Widget _amberMessages() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      log("updated read message");
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 250, 230, 170),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
                border: Border.all(color: Colors.black87)),
            margin: EdgeInsets.symmetric(
                vertical: mq.height * 0.01, horizontal: mq.width * 0.04),
            padding: EdgeInsets.all(widget.message.type == Type.text
                ? mq.width * 0.04
                : mq.width * 0.03),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15),
                  )
                : ClipRRect(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.image),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.045),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        )
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (BuildContext) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: mq.height * 0.015, horizontal: mq.width * 0.4),
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(8)),
            ),
            widget.message.type == Type.text
                ? _OptionItem(
                    name: 'Copy',
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then(
                        (value) {
                          Navigator.pop(context);
                          Dialogs.showSnackbar(context, 'Text Copied');
                        },
                      );
                    },
                    icon: Icon(
                      Icons.copy_all,
                      color: Colors.orange,
                      size: 26,
                    ))
                : _OptionItem(
                    name: 'Save Image',
                    onTap: () async {
                      await _saveNetworkImage();
                    },
                    icon: Icon(
                      Icons.save,
                      color: Colors.orange,
                      size: 26,
                    )),
            Divider(
              color: Colors.black54,
              endIndent: mq.width * 0.04,
              indent: mq.width * 0.04,
            ),
            if (widget.message.type == Type.text && isMe)
              _OptionItem(
                  name: 'Edit',
                  onTap: () {
                    Navigator.pop(context);
                    _showMessageUpdateDialog();
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.orange,
                    size: 26,
                  )),
            if (isMe)
              _OptionItem(
                  name: 'Delete',
                  onTap: () async {
                    await APIs.deleteMessage(widget.message).then((value) {
                      Navigator.pop(context);
                      widget.message.type == Type.image
                          ? Dialogs.showSnackbar(
                              context, "Image deleted Successfully")
                          : Dialogs.showSnackbar(
                              context, "Message deleted Successfully");
                    });
                  },
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 26,
                  )),
            if (isMe)
              Divider(
                color: Colors.black54,
                endIndent: mq.width * 0.04,
                indent: mq.width * 0.04,
              ),
            _OptionItem(
                name:
                    'Sent At :${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                onTap: () {},
                icon: Icon(
                  Icons.send,
                  color: Colors.orange,
                )),
            _OptionItem(
                name: widget.message.read.isNotEmpty
                    ? 'Read At:  Not Read yet'
                    : 'Read At :${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                onTap: () {},
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Colors.orange,
                ))
          ],
        );
      },
    );
  }

  // _saveLocalImage() async {
  //   RenderRepaintBoundary boundary =
  //       _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //   ui.Image image = await boundary.toImage();
  //   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   if (byteData != null) {
  //     final result =
  //         await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
  //     print(result);
  //   }
  // }

  _saveNetworkImage() async {
    var response = await Dio().get(
      widget.message.msg,
      options: Options(responseType: ResponseType.bytes),
    );

    // Check if the response data is not null and is of type List<int>
    if (response.data != null && response.data is List<int>) {
      final result = await ImageGallerySaver.saveImage(
        response.data,
        quality: 80,
        name:
            "${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}.jpg",
      );
      print(result);

      Navigator.pop(context);

      // Show a snackbar
      Dialogs.showSnackbar(context, 'Image saved successfully!');
    } else {
      Navigator.pop(context);
      Dialogs.showSnackbar(
          context, 'Error: Failed to save image. Response data is not valid.');
    }
  }

  void _showMessageUpdateDialog() {
    String updatedMessage = widget.message.msg;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 5),
              title: Row(
                children: [
                  Icon(
                    Icons.message_outlined,
                    color: Colors.orange,
                    size: 28,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Update Message',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  )
                ],
              ),
              content: TextFormField(
                initialValue: updatedMessage,
                maxLines: null,
                onChanged: (value) => updatedMessage = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    APIs.updateMessage(widget.message, updatedMessage);
                    log('message updated');
                  },
                  child: Text(
                    'Update',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final Icon icon;
  const _OptionItem(
      {super.key, required this.name, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: mq.height * 0.02,
          left: mq.width * 0.05,
          top: mq.height * 0.015,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '   $name',
              style: TextStyle(fontSize: 15, letterSpacing: 0.5),
            ))
          ],
        ),
      ),
    );
  }
}
