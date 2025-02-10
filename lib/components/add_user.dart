import 'package:flutter/material.dart';

import '../services/user_model.dart';

class AddUser extends StatefulWidget {
  final VoidCallback onUserAdded;
  final UserModel? user;
  const AddUser({super.key, required this.onUserAdded, this.user});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}