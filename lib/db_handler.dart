import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'remote.dart';
const _tableRemotes = 'remotes';
const _tableChats = 'chats';
const _columnId = 'id';
const _columnHost = 'host';
const _columnPort = 'port';
const _columnMessage = 'message';
const _columnDirection = 'direction';


class DbHandler {
  static Database? database;
  
  static init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');
    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
          await db.execute(
            '''CREATE TABLE $_tableRemotes (
            $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_columnHost TEXT NOT NULL,
            $_columnPort INTEGER NOT NULL)
            ''',);
          await db.execute(
            '''CREATE TABLE $_tableChats (
            $_columnId INTEGER PRIMARY KEY AUTOINCREMENT, 
            $_columnHost TEXT NOT NULL, 
            $_columnPort INTEGER NOT NULL, 
            $_columnMessage TEXT NOT NULL, 
            $_columnDirection INTEGER NOT NULL)
            ''',);
          },
    );
  }
  
  static Future<bool>? addRemote(Remote remote) => database
      ?.insert(_tableRemotes, remote.toMap())
      .then((value) => value != 0);
  
  static Future<bool>? deleteRemote(Remote remote) => database
      ?.delete(_tableRemotes, where: '$_columnHost = ? AND $_columnPort = ? ', whereArgs: [remote.host, remote.port])
      .then((value) => value != 0);

  static Future<bool>? isAvailable(Remote remote) {
    return database
        ?.rawQuery('SELECT COUNT(*) FROM $_tableRemotes WHERE $_columnHost = "${remote.host}" AND $_columnPort = "${remote.port}"')
        .then((value) => value.isNotEmpty);
  }

  static Future<List<Remote>>? get remotes => database
      ?.rawQuery('SELECT * FROM $_tableRemotes')
      .then((value) => value
      .map((e) => Remote.from(e))
      .toList());
}