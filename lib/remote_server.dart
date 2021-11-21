class RemoteServer {
  final String host;
  final int port;

  const RemoteServer({required this.host, required this.port});

  RemoteServer.from(dynamic val) : this(host: val['host'], port: val['port']);

  Map<String, Object> toMap() => {
    'host' : host,
    'port' : port,
  };

}