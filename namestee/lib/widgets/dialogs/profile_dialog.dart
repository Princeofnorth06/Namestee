import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hiichat/main.dart';
import 'package:hiichat/models/chat_user.dart';
import 'package:hiichat/screens/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromARGB(255, 249, 188, 96).withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * 0,
        height: mq.height * 0.365,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(user.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 44, 13, 3),
                    )),
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    size: 25,
                    color: const Color.fromARGB(255, 44, 13, 3),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ViewProfileScreen(user: user)));
                  },
                )
              ],
            ),
            SizedBox(
              height: mq.height * 0.01,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * 0.02),
              child: CachedNetworkImage(
                width: mq.width * 0.5,
                height: mq.height * 0.28,
                fit: BoxFit.cover,
                imageUrl: user.image,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    CircleAvatar(child: Icon(CupertinoIcons.person)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
