import 'dart:math';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'table_details.dart';
import 'user_model.dart';

class DatabaseServices {
  static final DatabaseServices _instance = DatabaseServices._internal();
  factory DatabaseServices() => _instance;
  DatabaseServices._internal();

  // Singleton instance of the database
  static Database? _db;

  // Getter for the database instance
  Future<Database> get db async {
    if (_db == null || !_db!.isOpen) {
      _db = await _initDatabase(); 
    }
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
    await addUser(user: tempUser);
  }

  Future<void> addUser({required UserModel user}) async {
    final database = await db; // Ensure database is initialized
    await database.insert(TableDetails.tableName, user.toMap());
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final database = await db;
    List<Map<String, dynamic>> users = await database.query(TableDetails.tableName);

    users = users.map((e) => Map<String, dynamic>.from(e)).toList();

    for (var user in users) {
      user['age'] = _calculateAge(user[TableDetails.birthdate]);
    }
    return users;
  }

  int _calculateAge(String birthdate) {
    DateTime birthDate = DateTime.parse(birthdate);
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> updateUser({required UserModel user}) async {
    final database = await db;
    await database.update(
      TableDetails.tableName,
      user.toMap(),
      where: '${TableDetails.id} = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> isFavourite({required int userId, required int status}) async {
    final database = await db;
    int count = await database.rawUpdate('''
      UPDATE ${TableDetails.tableName}
      SET ${TableDetails.favourite} = ?
      WHERE ${TableDetails.id} = ?
    ''', [status, userId]);
    return count;
  }

  Future<void> deleteUser({required int userId}) async {
    final database = await db;
    await database.delete(
      TableDetails.tableName,
      where: '${TableDetails.id} = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteAll() async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete(TableDetails.tableName);
    });
  }
}
