
class Direction{
  static const int incoming = 0;
  static const int outgoing = 1;
  static const int system = 2;
}

class Chat{
  final String message;
  final int direction;
  Chat(this.message, this.direction);
}