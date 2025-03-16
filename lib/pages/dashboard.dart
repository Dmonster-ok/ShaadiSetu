import 'package:flutter/material.dart';
import 'package:shaadisetu/components/more_options.dart';
import 'package:shaadisetu/services/filter.dart';
import 'add_or_update_user.dart';
import '../components/search_bar.dart';
import 'user_list.dart';
import '../services/database_services.dart';

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
  String sortBy = 'newest';
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _favoriteUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final allUsers = await _databaseServices.getUsers();
    setState(() {
      _users = filter(
          users: allUsers, searchQuery: searchQuery, sortingMethod: sortBy);
      _favoriteUsers = _users.where((user) => user['favourite'] == 1).toList();
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
              setState(() => searchQuery = value);
              _loadUsers();
            },
          ),
        ),
      ),
      body: Column(
        children: [
          _sort(),
          Expanded(
            child: PageView(
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
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          _bottomNav(),
          Positioned(
            bottom: 30,
            child: FloatingActionButton(
              onPressed: () async {
                await _showBottomSheet();
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  // ** Add users sheet
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
          onUserAdded: () async {
            await _loadUsers();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _sort() {
    Map<String, String> sortingOptions = {
      "newest": "Newset",
      "oldest": "Oldest",
      "a-z": "Name (A-Z)",
      "z-a": "Name (Z-A)",
      "city": "City",
    };

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: sortingOptions.containsKey(sortBy) ? sortBy : sortingOptions.keys.first,
        alignment: Alignment(0, 0),
        elevation: 1,
        icon: Icon(Icons.sort),
        isDense: true,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              sortBy = newValue;
            });
            _loadUsers();
          }
        },
        items: sortingOptions.entries.map((entry) {
          return DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value,style: TextStyle(fontSize: 16),),
          );
        }).toList(),
      ),
    );
  }

  // **More Options Menu
  Widget _moreOptionsButton() {
    return MoreOptionsButton(
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
      options: [
        MoreOptionItem(
            value: 'dark_mode', icon: Icons.dark_mode, label: 'Dark Mode'),
        MoreOptionItem(
            value: 'delete_all', icon: Icons.delete, label: 'Delete All Users'),
        MoreOptionItem(value: 'about_us', icon: Icons.info, label: 'About Us'),
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
