import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'table_details.dart';
import 'user_model.dart';

class DatabaseServices {
  static Database? _db;
  static final DatabaseServices instance = DatabaseServices._constructor();

  DatabaseServices._constructor();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'shaadisetu.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${TableDetails.tableName} (
            ${TableDetails.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${TableDetails.profileImage} TEXT,
            ${TableDetails.firstName} TEXT NOT NULL,
            ${TableDetails.lastName} TEXT NOT NULL,
            ${TableDetails.email} TEXT UNIQUE NOT NULL,
            ${TableDetails.phone} TEXT UNIQUE NOT NULL,
            ${TableDetails.address} TEXT NOT NULL,
            ${TableDetails.city} TEXT NOT NULL,
            ${TableDetails.cast} TEXT NOT NULL,
            ${TableDetails.religion} TEXT NOT NULL,
            ${TableDetails.profession} TEXT NOT NULL,
            ${TableDetails.hobbies} TEXT NOT NULL,
            ${TableDetails.gender} INTEGER NOT NULL CHECK(${TableDetails.gender} IN (0, 1, 2)),
            ${TableDetails.favourite} INTEGER DEFAULT 0 CHECK(${TableDetails.favourite} IN (0, 1)),
            ${TableDetails.birthdate} TEXT NOT NULL,
            ${TableDetails.createdAt} TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> addTempUser() async {
    UserModel tempUser = UserModel(
      firstName: 'Temp',
      lastName: 'User',
      email: 'tempuser${Random().nextInt(999999)}@example.com',
      phone: (1000000000 + Random().nextInt(899999999)).toString(),
      address: 'Unknown',
      city: 'Unknown',
      cast: 'Unknown',
      religion: 'Unknown',
      profession: 'Unknown',
      hobbies: 'None',
      gender: Random().nextInt(3),
      favourite: Random().nextBool() ? 1 : 0,
      birthdate: DateTime.now()
          .subtract(Duration(days: Random().nextInt(365 * 30)))
          .toIso8601String(),
      createdAt: DateTime.now().toIso8601String(),
    );
    await addUser(tempUser);
  }

  Future<void> addUser(UserModel user) async {
    final db = await instance.db;
    await db.insert(TableDetails.tableName, user.toMap());
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await instance.db;
    final List<Map<String, dynamic>> maps =
        await db.query(TableDetails.tableName);

    return maps;
  }

  Future<void> updateUser(UserModel user) async {
    final db = await instance.db;
    await db.update(
      TableDetails.tableName,
      user.toMap(),
      where: '${TableDetails.id} = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> isFavourite(int userId, int status) async {
    final db = await instance.db;
    await db.rawUpdate('''
      UPDATE ${TableDetails.tableName}
      SET ${TableDetails.favourite} = ?
      WHERE ${TableDetails.id} = ?
    ''', [status, userId]);
  }

  Future<void> deleteUser(int userId) async {
    final db = await instance.db;
    await db.delete(
      TableDetails.tableName,
      where: '${TableDetails.id} = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteAll() async {
    final db = await instance.db;
    await db.transaction((txn) async {
      await txn.delete(TableDetails.tableName);
    });
  }

  Future<void> closeDatabase() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
