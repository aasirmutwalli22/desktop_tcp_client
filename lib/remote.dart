class Remote {
  final int id;
  final String host;
  final int port;

  Remote(this.id, this.host, this.port);

  Remote.from(dynamic val) : this(val['id'] ?? 0, val['host'] ?? '', val['port'] ?? 0);

  Map<String, Object> toMap() => {
    'host' : host,
    'port' : port,
  };
}