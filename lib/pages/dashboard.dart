import 'package:flutter/material.dart';
import 'package:shaadisetu/components/more_options.dart';
import 'package:shaadisetu/services/filter.dart';
import 'add_or_update_user.dart';
import '../components/search_bar.dart';
import 'user_list.dart';
import '../services/api_services.dart';

class Dashboard extends StatefulWidget {
  final Function(bool) onThemeChanged;
  const Dashboard({super.key, required this.onThemeChanged});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController searchController = TextEditingController();
  final ApiServices _databaseServices = ApiServices();
  final PageController pageController = PageController();
  final Map<String, String> _sortingOptions = {
    "newest": "Newset",
    "oldest": "Oldest",
    "a-z": "Name (A-Z)",
    "z-a": "Name (Z-A)",
    "city": "City",
  };

  String searchQuery = '';
  String sortBy = 'newest';
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isDarkMode = false;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _favoriteUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final allUsers = await _databaseServices.getUsers();
    setState(() {
      _users = filter(
          users: allUsers, searchQuery: searchQuery, sortingMethod: sortBy);
      _favoriteUsers = _users.where((user) => user['favourite'] == 1).toList();
      _isLoading = false;
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
                  isLoading: _isLoading,
                  onRefresh: _loadUsers,
                ),
                UserList(
                  users: _favoriteUsers,
                  title: 'Favorite Users',
                  isLoading: _isLoading,
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
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _sortingOptions.entries.map((e) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: ChoiceChip(
              label: Text(e.value),
              labelStyle: TextStyle(
                  fontSize: sortBy == e.key ? 16 : 14,
                  fontWeight:
                      sortBy == e.key ? FontWeight.bold : FontWeight.w600),
              selected: sortBy == e.key,
              showCheckmark: false,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    sortBy = e.key;
                  });
                  _loadUsers();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // **More Options Menu
  Widget _moreOptionsButton() {
    void deleteAllUsers() async {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete All Users'),
              content: const Text('Are you sure you want to delete all users?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await _databaseServices.deleteAll();
                    _loadUsers();
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          });
    }

    void darkmode() {
      setState(() {
        _isDarkMode = !_isDarkMode;
      });
      widget.onThemeChanged(_isDarkMode);
    }

    return MoreOptionsButton(
      onSelected: (value) {
        switch (value) {
          case 'dark_mode':
            darkmode();
            break;
          case 'delete_all':
            deleteAllUsers();
            break;
          case 'about_us':
            print('About Us');
            break;
        }
      },
      options: [
        MoreOptionItem(
            value: 'dark_mode',
            icon: _isDarkMode ? Icons.light_mode : Icons.dark_mode,
            label: _isDarkMode ? 'Light Mode' : 'Dark Mode'),
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
