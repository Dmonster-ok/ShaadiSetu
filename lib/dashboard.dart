import 'package:flutter/material.dart';

import 'components/add_user.dart';
import 'components/search_bar.dart';
import 'components/text_field.dart';
import 'services/database_services.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final int _selectedIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  final DatabaseServices _databaseServices = DatabaseServices.instance;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _favoriteUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final users = await _databaseServices.getUsers();
    setState(() {
      _users = users;
      _favoriteUsers = _users.where((user) => user['favourite'] == 1).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShaadiSetu'),
        actions: [_moreOptionsButton()],
        bottom: searchBar(
          searchController: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
      floatingActionButton: _floatingActionButton(),
      body: const Center(
        child: Text('Dashboard'),
      ),
    );
  }

  // **More Options Menu**
  Widget _moreOptionsButton() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'dark_mode':
            print('Dark mode toggle');
            break;
          case 'delete_all':
            _deleteAllUsers();
            break;
          case 'about_us':
            print('About Us');
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        _popupMenuItem('dark_mode', Icons.dark_mode, 'Dark Mode'),
        _popupMenuItem('delete_all', Icons.delete, 'Delete All Users'),
        _popupMenuItem('about_us', Icons.info, 'About Us'),
      ],
    );
  }

  PopupMenuItem<String> _popupMenuItem(
      String value, IconData icon, String text) {
    return PopupMenuItem<String>(
      value: value,
      child: ListTile(
        leading: Icon(icon),
        title: Text(text),
      ),
    );
  }

  // **Floating Actions Buttons**
  Widget _floatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: _showAddUserModal,
          tooltip: 'Add User',
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: _addTempUser,
          tooltip: 'Add Temp User',
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  // **Show Add User Modal**
  void _showAddUserModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddUser(onUserAdded: _fetchUsers),
    );
  }

  // **Add Temporary User**
  Future<void> _addTempUser() async {
    await _databaseServices.addTempUser();
    await _fetchUsers();
  }

  // **Delete All Users**
  Future<void> _deleteAllUsers() async {
    await _databaseServices.deleteAll();
    await _fetchUsers();
  }
}
