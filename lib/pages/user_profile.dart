import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shaadisetu/services/user_model.dart';
import '../components/more_options.dart';
import '../services/api_services.dart';
import '../services/table_details.dart';
import 'package:intl/intl.dart';

import 'add_or_update_user.dart';

class UserProfile extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onRefresh;

  const UserProfile({
    super.key,
    required this.user,
    this.onRefresh,
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final ApiServices _databaseServices = ApiServices();
  late bool isFavourite;

  @override
  void initState() {
    super.initState();
    isFavourite = widget.user[TableDetails.favourite] == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        actions: [
          _moreOptions(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profile(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.grey[700],
                    thickness: 1,
                  ),
                ),
                _favoritButton(),
                Expanded(
                  child: Divider(
                    color: Colors.grey[700],
                    thickness: 1,
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: _userDetails(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String formatDate({String? dateString, required String format}) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.tryParse(dateString) ?? DateTime.now();
      return DateFormat(format).format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future _showEdit() async {
    UserModel userModel = UserModel.fromMap(widget.user);

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
        onUserAdded: () async {
          // Fetch the updated user data
          Map<String, dynamic> updatedUser =
              UserModel.fromMap(widget.user).toMap(includeId: true);

          if (mounted) {
            setState(() {
              widget.user.clear();
              widget.user
                  .addAll(updatedUser); // Update the profile with new data
            });

            widget.onRefresh?.call();
          }

          Navigator.pop(context);
        },
      ),
    );
  }

  Future _showDelete() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _databaseServices.deleteUser(
                  userId: widget.user[TableDetails.id]);
              if (mounted) {
                widget.onRefresh?.call();
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close profile page
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _moreOptions() {
    return MoreOptionsButton(
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            await _showEdit();
            break;
          case 'delete':
            await _showDelete();
            break;
        }
      },
      options: [
        MoreOptionItem(value: 'edit', icon: Icons.edit, label: 'Edit'),
        MoreOptionItem(value: 'delete', icon: Icons.delete, label: 'Delete'),
      ],
    );
  }

  Widget _profile() {
    double pfpSize = 150;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: pfpSize,
            height: pfpSize,
            child: widget.user[TableDetails.profileImage] != null &&
                    File(widget.user[TableDetails.profileImage]).existsSync()
                ? Image.file(
                    File(widget.user[TableDetails.profileImage]),
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/default.png',
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                toTitleCase(widget.user[TableDetails.firstName]),
                softWrap: true,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                toTitleCase(widget.user[TableDetails.lastName]),
                softWrap: true,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _favoritButton() {
    return IconButton(
      style: ButtonStyle(
        iconSize: WidgetStatePropertyAll(40),
        padding: WidgetStateProperty.all(EdgeInsets.all(5)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      onPressed: () async {
        int newStatus = isFavourite ? 0 : 1;
        await _databaseServices.isFavourite(
          userId: widget.user[TableDetails.id],
          status: newStatus,
        );

        setState(() {
          isFavourite = !isFavourite;
        });

        widget.onRefresh?.call();
      },
      icon: Icon(
        isFavourite ? Icons.star : Icons.star_border,
        color: isFavourite ? Colors.deepPurple[300] : Colors.grey,
      ),
    );
  }

  Widget _userDetails() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow('Email:', widget.user[TableDetails.email]),
          _detailRow('Phone:', widget.user[TableDetails.phone]),
          _detailRow('Gender:',
              widget.user[TableDetails.gender] == 0 ? 'Male' : 'Female'),
          _detailRow(
              'Birthdate:',
              formatDate(
                  dateString: widget.user[TableDetails.birthdate],
                  format: 'dd-MM-yyyy')),
          _detailRow('Age:', widget.user[TableDetails.age].toString()),
          _detailRow('Address:', widget.user[TableDetails.address]),
          _detailRow('City:', widget.user[TableDetails.city]),
          _detailRow('Religion:', widget.user[TableDetails.religion]),
          _detailRow('Caste:', widget.user[TableDetails.cast]),
          _detailRow('Profession:', widget.user[TableDetails.profession]),
          _detailRow('Hobbies:', widget.user[TableDetails.hobbies]),
          _detailRow(
              'Created At:',
              formatDate(
                  dateString: widget.user[TableDetails.createdAt],
                  format: 'dd-MM-yyyy hh:mm a')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
