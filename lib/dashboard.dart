import 'package:flutter/material.dart';
import 'package:shaadisetu/services/filter.dart';
import 'screens/add_or_update_user.dart';
import 'components/search_bar.dart';
import 'screens/user_list.dart';
import 'services/database_services.dart';
import 'services/table_details.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController searchController = TextEditingController();
  final DatabaseServices _databaseServices = DatabaseServices();
  final PageController pageController = PageController();

  String searchQuery = '';
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _favoriteUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// Fetches users from the database and updates the state
  Future<void> _loadUsers() async {
    List<Map<String, dynamic>> users = filter(
        users: await _databaseServices.getUsers(), searchQuery: searchQuery);
    setState(() {
      _users = users;
      _favoriteUsers = users.where((user) => user['favourite'] == 1).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShaadiSetu'),
        actions: [_moreOptionsButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: searchBar(
            searchController: searchController,
            onChanged: (value) {
              _loadUsers();
              setState(() => searchQuery = value);
            },
          ),
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: [
          UserList(
            users: _users,
            onRefresh: _loadUsers,
          ),
          UserList(
            users: _favoriteUsers,
            title: 'Favorite Users',
            onRefresh: _loadUsers,
          ),
        ],
      ),
      floatingActionButton: _floatingActionButton(),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _floatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () {
            _showBottomSheet();
          },
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () async {
            await _databaseServices.addTempUser();
            _loadUsers(); // Reload users after adding a temp user
          },
          child: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  _showBottomSheet() {
    showModalBottomSheet(
      enableDrag: true,
      showDragHandle: true,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) {
        return UserForm(
          onUserAdded: () {
            _loadUsers();
            Navigator.pop(context);
          },
        );
      },
    );
  }

// **More Options Menu**
  Widget _moreOptionsButton() {
    PopupMenuItem<String> popupMenuItem(
        String value, IconData icon, String text) {
      return PopupMenuItem<String>(
        value: value,
        child: ListTile(
          leading: Icon(icon),
          title: Text(text),
        ),
      );
    }

    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'dark_mode':
            print('Dark mode toggle');
            break;
          case 'delete_all':
            _databaseServices.deleteAll();
            _loadUsers();
            break;
          case 'about_us':
            print('About Us');
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        popupMenuItem('dark_mode', Icons.dark_mode, 'Dark Mode'),
        popupMenuItem('delete_all', Icons.delete, 'Delete All Users'),
        popupMenuItem('about_us', Icons.info, 'About Us'),
      ],
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      showUnselectedLabels: false,
      showSelectedLabels: true,
      currentIndex: _selectedIndex,
      onTap: (index) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _selectedIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.deepPurple[200],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    pageController.dispose();
    super.dispose();
  }
}
