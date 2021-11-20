class RemoteServer {
  final String name;
  final String host;
  final int port;

  const RemoteServer({required this.name, required this.host, required this.port});

  RemoteServer.from(dynamic val) : this(name: val['name'], host: val['host'], port: val['port']);

  Map<String, Object> toMap() => {
    'name' : name,
    'host' : host,
    'port' : port,
  };

}