import 'package:flutter/material.dart';
import '../services/table_details.dart';

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
          await Future.delayed(const Duration(milliseconds: 50));
          widget.onRefresh!();
        }
      },
      child: SingleChildScrollView(
        child: ExpansionPanelList.radio(
          children: widget.users.map<ExpansionPanelRadio>((user) {
            return ExpansionPanelRadio(
              canTapOnHeader: true,
              value: user[TableDetails.id],
              headerBuilder: (context, isExpanded) {
                return ListTile(
                  leading: GestureDetector(
                    onTap: () {
                    },
                    child: CircleAvatar(
                      child: Text(user[TableDetails.firstName][0]),
                    ),
                  ),
                  title: Text("${user[TableDetails.firstName]} ${user[TableDetails.lastName]}"),
                  subtitle: Text(user[TableDetails.email]),
                );
              },
              body: SizedBox(height: 100,)
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _notFound() {
    return Center(
      child: Text(
        'No ${widget.title} found',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }
}


