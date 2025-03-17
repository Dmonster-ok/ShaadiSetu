import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'table_details.dart';
import 'user_model.dart';

class ApiServices {
  static final ApiServices _instance = ApiServices._internal();
  factory ApiServices() => _instance;
  ApiServices._internal();

  final String baseUrl =
      'https://67c946910acf98d070898260.mockapi.io/flutlabs/users';

  Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  Future<void> addTmp() async {
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
    await addUser(user: tempUser);
  }

  Future<UserModel?> getUser({required int userId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final apiUser = jsonDecode(response.body);
        return UserModel.fromMap(apiUser);
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('\x1B[31mError: $e\x1B[0m');
      debugPrint('\x1B[31mStackTrace: $stackTrace\x1B[0m');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> apiUsers = jsonDecode(response.body);
        return apiUsers.map((apiUser) {
          final user = UserModel.fromMap(apiUser);
          return {
            ...user.toMap(includeId: true),
            'age': _calculateAge(user.birthDate),
          };
        }).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('\x1B[31mError: $e\x1B[0m');
      debugPrint('\x1B[31mStackTrace: $stackTrace\x1B[0m');
      return [];
    }
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
      final apiData = user.toMap();
      apiData.remove('id');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(apiData),
      );

      return response.statusCode == 201;
    } catch (e, stackTrace) {
      debugPrint('\x1B[31mError: $e\x1B[0m');
      debugPrint('\x1B[31mStackTrace: $stackTrace\x1B[0m');
      return false;
    }
  }

  Future<int> isFavourite({required String userId, required int status}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$userId'),
        headers: headers,
        body: jsonEncode({'favourite': status}),
      );
      return response.statusCode == 200 ? 1 : 0;
    } catch (e, stackTrace) {
      debugPrint('\x1B[31mError: $e\x1B[0m');
      debugPrint('\x1B[31mStackTrace: $stackTrace\x1B[0m');
      return 0;
    }
  }

  Future<bool> updateUser({required UserModel user}) async {
    try {
      if (user.id == null) {
        return false;
      }

      final apiData = user.toMap(includeId: true);
      final response = await http.put(
        Uri.parse('$baseUrl/${user.id}'),
        headers: headers,
        body: jsonEncode(apiData),
      );

      return response.statusCode == 200;
    } catch (e, stackTrace) {
      debugPrint('\x1B[31mError: $e\x1B[0m');
      debugPrint('\x1B[31mStackTrace: $stackTrace\x1B[0m');
      return false;
    }
  }

  Future<void> deleteUser({required String userId}) async {
    try {
      await http.delete(
        Uri.parse('$baseUrl/$userId'),
        headers: headers,
      );
    } catch (e, stackTrace) {
      debugPrint('\x1B[31mError: $e\x1B[0m');
      debugPrint('\x1B[31mStackTrace: $stackTrace\x1B[0m');
    }
  }

  Future<void> deleteAll() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> apiUsers = jsonDecode(response.body);
        for (final apiUser in apiUsers) {
          await deleteUser(userId: apiUser[TableDetails.id]);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('\x1B[31mError: $e\x1B[0m');
      debugPrint('\x1B[31mStackTrace: $stackTrace\x1B[0m');
    }
  }
}
