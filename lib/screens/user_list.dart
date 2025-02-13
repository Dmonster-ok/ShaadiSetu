import 'package:flutter/material.dart';
import 'package:shaadisetu/services/table_details.dart';

class UserList extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> users;
  final VoidCallback? onRefresh;

  const UserList({
    super.key,
    this.title = 'Users',
    required this.users,
    required this.onRefresh,
  });

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    return widget.users.isEmpty ? _notFound() : _list();
  }

  Widget _list() {
    return RefreshIndicator(
      onRefresh: () async {
        if (widget.onRefresh != null) {
          Future.delayed(const Duration(milliseconds: 50));
          widget.onRefresh!();
        }
      },
      child: ListView.builder(
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> user = widget.users[index];
          return ListTile(
            title: Text('${user[TableDetails.firstName]} ${user[TableDetails.lastName]}'),
            subtitle: Text(user[TableDetails.email]),
          );
        },
      ),
    );
  }

  Widget _notFound() {
    return Center(
      child: Text(
        'No ${widget.title} found',
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }
}
