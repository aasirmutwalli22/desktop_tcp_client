
import 'remote.dart';

class Direction{
  static const int incoming = 0;
  static const int outgoing = 1;
  static const int system = 2;
}

class Chat{
  final String message;
  final int direction;
  final String host;
  final int port;
  const Chat({required this.message, required this.direction, required this.host, required this.port});
  Chat.fromRemote({required Remote remote, required String message, required int direction,}) :
        this(message: message, direction: direction, host: remote.host, port: remote.port);

  Chat.from(dynamic val) : this(
      message : val['message'] ?? '',
      direction : val['direction'] ?? 0,
      host: val['host'] ?? '',
      port : val['port'] ?? 0);

  Map<String, Object> toMap() => {
    'message': message,
    'direction' : direction,
    'host' : host,
    'port' : port,
  };
}