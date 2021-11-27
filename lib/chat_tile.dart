import 'package:flutter/material.dart';

var outgoingMessageAlignment = Alignment.centerRight;
var incomingMessageAlignment = Alignment.centerLeft;
var systemMessageAlignment = Alignment.center;

var outgoingMessageColor = Colors.grey.shade200;
var incomingMessageColor = Colors.indigo.shade50;
var systemMessageColor = Colors.green.shade50;

const outgoingMessageMargin = EdgeInsets.only( top: 4, bottom: 4, right: 8, left: 32,);
const incomingMessageMargin = EdgeInsets.only( top: 4, bottom: 4, right: 32, left: 8,);
const systemMessageMargin = EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 8);

const incomingMessagePadding = EdgeInsets.all(16);
const outgoingMessagePadding = EdgeInsets.all(16);
const systemMessagePadding = EdgeInsets.all(8);

const outgoingMessageBorderRadius = BorderRadius.only(
  topLeft: Radius.circular(16),
  topRight: Radius.circular(16),
  bottomLeft: Radius.circular(16),
  bottomRight: Radius.circular(4),
);
const incomingMessageBorderRadius = BorderRadius.only(
  topLeft: Radius.circular(4),
  topRight: Radius.circular(16),
  bottomLeft: Radius.circular(16),
  bottomRight: Radius.circular(16),
);
var systemMessageBorderRadius = BorderRadius.circular(8);

class ChatTile extends StatelessWidget{
  final Alignment alignment;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color color;
  final BorderRadius borderRadius;
  final void Function()? onLongPress;
  final String message;

  const ChatTile({
    Key? key,
    required this.alignment,
    required this.margin,
    required this.padding,
    required this.color,
    required this.borderRadius,
    required this.message,
    this.onLongPress,
  }) : super(key: key);

  ChatTile.incoming(String message, {Key? key, void Function()? onLongPress,}) : this(
    key: key,
    alignment : incomingMessageAlignment,
    color : incomingMessageColor,
    margin: incomingMessageMargin,
    padding: incomingMessagePadding,
    borderRadius: incomingMessageBorderRadius,
    message: message,
    onLongPress: onLongPress,
  );

  ChatTile.outgoing(String message, {Key? key, void Function()? onLongPress,}) : this(
    key: key,
    alignment : outgoingMessageAlignment,
    color : outgoingMessageColor,
    margin: outgoingMessageMargin,
    padding: outgoingMessagePadding,
    borderRadius: outgoingMessageBorderRadius,
    message: message,
    onLongPress: onLongPress,
  );
  ChatTile.system(String message, {Key? key}) : this(
    key: key,
    alignment : systemMessageAlignment,
    color : systemMessageColor,
    margin: systemMessageMargin,
    padding: systemMessagePadding,
    borderRadius: systemMessageBorderRadius,
    message: message,
  );

  @override
  Widget build(context) {
    return Align(
      alignment: alignment,
      child: Card(
        margin: margin,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        elevation: 0,
        child: InkWell(
          onLongPress: onLongPress,
          borderRadius: borderRadius,
          child: Padding(
            padding: padding,
            child: Text(message),
          ),
        ),
      ),
    );
  }

}