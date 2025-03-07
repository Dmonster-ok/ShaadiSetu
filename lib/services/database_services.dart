import 'dart:math';
import 'package:flutter/material.dart';
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
      phone: (7000000000 + Random().nextInt(1000000000)).toString(),
      address: 'Unknown',
      city: 'Unknown',
      cast: 'Unknown',
      religion: 'Unknown',
      profession: 'Unknown',
      hobbies: 'None',
      gender: Random().nextBool() ? 0 : 1,
      favourite: Random().nextBool() ? 1 : 0,
      birthDate: DateTime.now()
          .subtract(Duration(days: Random().nextInt(365 * 30)))
          .toIso8601String(),
      createdAt: DateTime.now().toIso8601String(),
      profileImage: '',
    );

    await DatabaseServices().addUser(user: tempUser);
  }

  Future<Map<String, dynamic>> getUser({required int userId}) async {
    final database = await db;
    List<Map<String, dynamic>> users = await database.query(
      TableDetails.tableName,
      where: '${TableDetails.id} = ?',
      whereArgs: [userId],
    );

    return users
        .map((user) {
          return {
            ...user,
            'age': _calculateAge(user[TableDetails.birthdate]),
          };
        })
        .toList()
        .first;
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final database = await db;
    List<Map<String, dynamic>> users = await database.query(
      TableDetails.tableName,
      columns: [
        TableDetails.id,
        TableDetails.profileImage,
        TableDetails.firstName,
        TableDetails.lastName,
        TableDetails.phone,
        TableDetails.city,
        TableDetails.profession,
        TableDetails.birthdate,
        TableDetails.gender,
        TableDetails.favourite,
      ],
    );

    return users.map((user) {
      return {
        ...user,
        'age': _calculateAge(user[TableDetails.birthdate]),
      };
    }).toList();
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

  Future<bool> addUser({required UserModel user}) async {
    try {
      final database = await db;

      final existingUser = await database.query(
        TableDetails.tableName,
        where: '${TableDetails.email} = ? OR ${TableDetails.phone} = ?',
        whereArgs: [user.email, user.phone],
      );
      if (existingUser.isNotEmpty) return false;

      final updatedData = user.toMap();
      updatedData.remove(TableDetails.id);

      await database.insert(
        TableDetails.tableName,
        updatedData,
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint(
          '\x1B[31m ------------------------------------------------------------------\x1B[0m');
      debugPrint('\x1B[31mError: $e\x1B[0m');
      debugPrint('\x1B[31mStackTrace: $stackTrace\x1B[0m');
      return false;
    }
  }

  Future<bool> updateUser({required UserModel user}) async {
    try {
      final database = await db;

      final existingUser = await database.query(
        TableDetails.tableName,
        where:
            '(${TableDetails.email} = ? OR ${TableDetails.phone} = ?) AND ${TableDetails.id} != ?',
        whereArgs: [user.email, user.phone, user.id],
      );

      if (existingUser.isNotEmpty) return false;

      int updatedRows = await database.update(
        TableDetails.tableName,
        user.toMap(),
        where: '${TableDetails.id} = ?',
        whereArgs: [user.id],
      );

      return updatedRows > 0;
    } catch (e) {
      return false;
    }
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
