import 'package:flutter/material.dart';
import 'package:shaadisetu/services/database_services.dart';
import 'package:shaadisetu/services/table_details.dart';

class UserItem extends StatefulWidget {
  final Map<String, dynamic> user;
  const UserItem({super.key, required this.user});

  @override
  State<UserItem> createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  late Map<String, dynamic> user = widget.user;
  static const double _avatarSize = 50;
  bool _isFavorite = false; // State for favorite status

  @override
  void initState() {
    super.initState();
    _isFavorite = user[TableDetails.favourite] == 1;
  }

  Future<void> _toggleFavorite() async {
    int newStatus = _isFavorite ? 0 : 1;

    await DatabaseServices.instance
        .isFavourite(user[TableDetails.id], newStatus);

    setState(() {
      _isFavorite = !_isFavorite;
      user[TableDetails.favourite] = newStatus; // Update local user map
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        leading: Container(
          width: _avatarSize,
          height: _avatarSize,
          decoration: BoxDecoration(
            color: Colors.deepPurple[100],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        title: Text(
          '${user[TableDetails.firstName]} ${user[TableDetails.lastName]}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${user[TableDetails.city]} • ${10} Years'),
        trailing: IconButton(
          icon: Icon(
            _isFavorite ? Icons.star : Icons.star_border,
            color: _isFavorite ? Colors.red : null,
          ),
          onPressed: _toggleFavorite,
        ),
        onTap: () {
          print('---------------------------- User Details ----------------------------');
          print(user);
        },
      ),
    );
  }
}
