import 'package:flutter/material.dart';

class TorrentListTileWidget extends StatelessWidget {
  final Widget title;
  final Widget status;
  final Widget progress;
  final List<Widget> buttons;
  final GestureLongPressCallback onLongPress;

  const TorrentListTileWidget({
    super.key,
    required this.title,
    required this.status,
    required this.progress,
    required this.buttons,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            //title
            DefaultTextStyle.merge(
              style: const TextStyle(
                fontSize: 16,
              ),
              child: title,
            ),
            //subtitle
            DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.grey),
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
