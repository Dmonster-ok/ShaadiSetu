import 'package:flutter/material.dart';
import 'package:shaadisetu/pages/user_profile.dart';
import '../components/user_tile.dart';
import '../services/database_services.dart';
import '../services/table_details.dart';
import '../services/user_model.dart';
import 'add_or_update_user.dart';

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
  int? _selectedIndex;
  final DatabaseServices _databaseServices = DatabaseServices();

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
      child: ListView.builder(
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedIndex == index;
          Map<String, dynamic> user = widget.users[index];
          return UserTile(
            onRefresh: widget.onRefresh,
            index: index,
            title:
                '${user[TableDetails.firstName]} ${user[TableDetails.lastName]}',
            subtitle:
                '${user[TableDetails.gender] == 0 ? 'Male' : 'Female'} • ${user[TableDetails.age]} years',
            other: 'City: ${user[TableDetails.city]}',
            isSelected: isSelected,
            isFavourite: user[TableDetails.favourite] == 1 ? true : false,
            onFavourite: () async {
              await _databaseServices.isFavourite(
                  userId: user[TableDetails.id],
                  status: user[TableDetails.favourite] == 1 ? 0 : 1);
              widget.onRefresh!();
            },
            extraContent: _extraContent(user),
            onTap: () {
              setState(() {
                _selectedIndex = isSelected ? null : index;
              });
            },
            profileImage: user[TableDetails.profileImage],
            onProfileTap: () async {
              Map<String, dynamic> userData = await _databaseServices.getUser(
                  userId: user[TableDetails.id]);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfile(
                    user: userData,
                    onRefresh: widget.onRefresh,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _extraContent(Map<String, dynamic> user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone: +91-${user[TableDetails.phone]}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            Text(
              'Profession: ${user[TableDetails.profession]}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () async {
                await _showEdit(user[TableDetails.id]);
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete User'),
                    content: const Text('Are you sure you want to delete?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _databaseServices.deleteUser(
                              userId: user[TableDetails.id]);
                          setState(() {
                            widget.users.removeWhere((element) =>
                                element[TableDetails.id] ==
                                user[TableDetails.id]);
                          });
                          _selectedIndex = null;
                          widget.onRefresh!();
                          Navigator.pop(context);
                        },
                        child: const Text('Delete'),
                      )
                    ],
                  ),
                );
              },
              child: const Text('Delete'),
            )
          ],
        )
      ],
    );
  }

  Future _showEdit(int id) async {
    UserModel userModel =
        UserModel.fromMap(await _databaseServices.getUser(userId: id));
    return showModalBottomSheet(
      enableDrag: true,
      showDragHandle: true,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) => UserForm(
        title: 'Edit',
        user: userModel,
        onUserAdded: () {
          widget.onRefresh!();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _notFound() {
    return Center(
      child: Text(
        'No ${widget.title} found',
        style: const TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  String toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
