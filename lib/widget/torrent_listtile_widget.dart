import 'package:flutter/material.dart';

class TorrentListTileWidget extends StatelessWidget {
  final Widget title;
  final Widget status;
  final Widget progress;
  final List<Widget> buttons;
  final GestureLongPressCallback onLongPress;

  const TorrentListTileWidget({
    Key? key,
    required this.title,
    required this.status,
    required this.progress,
    required this.buttons,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            //title
            DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 16,
              ),
              child: title,
            ),
            //subtitle
            DefaultTextStyle.merge(
              style: TextStyle(color: Colors.grey),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        status,
                        progress,
                      ],
                    ),
                  ),
                  //icons
                  ...buttons
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
