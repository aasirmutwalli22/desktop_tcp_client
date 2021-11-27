class Remote {
  final String host;
  final int port;

  Remote(this.host, this.port);

  Remote.from(dynamic val) : this(val['host'] ?? '', val['port'] ?? 0);

  Map<String, Object> toMap() => {
    'host' : host,
    'port' : port,
  };
}