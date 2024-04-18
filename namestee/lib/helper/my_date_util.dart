import 'package:flutter/material.dart';

class MyDateUtil {
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    final formattedTime = TimeOfDay.fromDateTime(sent).format(context);
    if (now.day == sent.day &&
        sent.month == now.month &&
        sent.year == now.month) {
      return formattedTime;
    }

    return now.year == sent.year
        ? '$formattedTime -${sent.day} ${_getMonth(sent)}'
        : '$formattedTime -${sent.day} ${_getMonth(sent)} ${sent.year}}';
  }

  static String getLastMessagesTime(
      {required BuildContext context,
      required String time,
      bool showYear = false}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if (now.day == sent.day &&
        sent.month == now.month &&
        sent.year == now.month) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }
    return showYear
        ? '${sent.day} ${_getMonth(sent)}/${sent.year}'
        : '${sent.day} ${_getMonth(sent)}';
  }

  static String getLastActiveTime(
      {required BuildContext context, required String lastActive}) {
    final int i = int.tryParse(lastActive) ?? -1;
    if (i == -1) return 'Last Active time not  available';

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();
    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (now.day == time.day &&
        time.month == now.month &&
        time.year == now.month) {
      return 'Last Seen today at $formattedTime';
    }
    if ((now.difference(time).inHours / 24).round() == 1)
      return 'Last Seen yesterday at $formattedTime';

    String month = _getMonth(time);
    return 'Last Seen on ${time.day} $month at $formattedTime';
  }

  static String _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return "Jan";
      case 2:
        return 'Feb';
      case 3:
        return "Mar";
      case 4:
        return 'Apr';
      case 5:
        return "May";
      case 6:
        return 'Jun';
      case 7:
        return "Jul";
      case 8:
        return 'Aug';
      case 9:
        return "Sept";
      case 10:
        return 'Oct';
      case 11:
        return "Nov";
      case 12:
        return 'Dec';
    }
    return 'NA';
  }
}
