import 'package:addislancers_app/Screens/Job%20Screen/saved_jobs.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badge_pkg;
import '../Job Screen/postjob_screen.dart';
import '../Profile Screen/profile_screen.dart';
import '../Job Screen/jobListPage.dart';
import 'settings_page.dart';
import '../../Models/user_model.dart';
import '../Job Screen/applied_job_list.dart';
import '../Chat Screen/chat_list_screen.dart';
import '../Auth/login_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _userModel;
  int _selectedIndex = 0; // Default to showing posted jobs
  String _searchQuery = "";
  bool _isSearching = false;
  int _unreadMessageCount = 0;

  // Create a GlobalKey for the Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _searchController.addListener(_onSearchChanged);
    _listenForNewMessages();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getUserDetails() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userModel = UserModel.fromDocument(userDoc);
          });
        } else {
          // Handle the case where the document does not exist
          print("User document does not exist.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User document does not exist.'),
            ),
          );
        }
      } catch (e) {
        print("Error fetching user details: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Error fetching user details. Please try again later.'),
          ),
        );
      }
    }
  }

  void _listenForNewMessages() {
    FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: _auth.currentUser?.uid)
        .snapshots()
        .listen((chatSnapshot) {
      int newMessageCount = 0;
      for (var chatDoc in chatSnapshot.docs) {
        var chatData = chatDoc.data();
        FirebaseFirestore.instance
            .collection('chats/${chatDoc.id}/messages')
            .where('read', isEqualTo: false)
            .where('sender', isNotEqualTo: _auth.currentUser?.uid)
            .snapshots()
            .listen((messageSnapshot) {
          setState(() {
            newMessageCount += messageSnapshot.docs.length;
          });
        });
      }
      setState(() {
        _unreadMessageCount = newMessageCount;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isSearching = false;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;
    });
  }

  Widget _getSelectedPage() {
    if (_selectedIndex == 4 && _userModel != null) {
      return _buildProfilePage();
    }

    if (_isSearching) {
      return JobListPage(searchQuery: _searchQuery);
    }

    switch (_selectedIndex) {
      case 0:
        return JobListPage();
      case 1:
        return ChatListScreen();
      case 2:
        return const PostJobScreen();
      case 3:
        return AppliedJobListPage(); // applied jobs list
      case 4:
        return const ProfileScreen();
      default:
        return JobListPage();
    }
  }

  Widget _buildProfilePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _userModel!.profilePic.isNotEmpty
              ? NetworkImage(_userModel!.profilePic)
              : const AssetImage("images/tmpProfile.jpg") as ImageProvider,
        ),
        const SizedBox(height: 10),
        Text(
          '${_userModel!.firstName} ${_userModel!.lastName}',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 5),
        Text(_userModel!.email),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text(
              'ADDISLANCERS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Color.fromARGB(255, 20, 34, 90),
            elevation: 0,
            floating: true,
            pinned: false,
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 60.0,
              maxHeight: 60.0,
              child: Container(
                color: const Color.fromARGB(255, 20, 34, 90),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _searchQuery = _searchController.text;
                          _isSearching = _searchQuery.isNotEmpty;
                        });
                      },
                    ),
                    IconButton(
                      icon: badge_pkg.Badge(
                        showBadge: _unreadMessageCount > 0,
                        badgeContent: Text(
                          '$_unreadMessageCount',
                          style: const TextStyle(color: Colors.white),
                        ),
                        child: const Icon(Icons.notifications,
                            color: Colors.white),
                      ),
                      onPressed: () {
                        // this is for notification tap
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: _getSelectedPage(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 20, 34, 90),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: badge_pkg.Badge(
              showBadge: _unreadMessageCount > 0,
              badgeContent: Text(
                '$_unreadMessageCount',
                style: const TextStyle(color: Colors.white),
              ),
              child: const Icon(Icons.chat),
            ),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Post Job',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Applied Jobs',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 20, 34, 90),
        child: ListView(
          children: <Widget>[
            if (_userModel != null)
              UserAccountsDrawerHeader(
                accountName: Text(
                  '${_userModel!.firstName} ${_userModel!.lastName}',
                  style: const TextStyle(color: Colors.white),
                ),
                accountEmail: Text(
                  _userModel!.email,
                  style: const TextStyle(color: Colors.white),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: _userModel!.profilePic.isNotEmpty
                      ? NetworkImage(_userModel!.profilePic)
                      : const AssetImage("images/tmpProfile.jpg")
                          as ImageProvider,
                ),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/background.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: Colors.white,
              ),
              title: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bookmark, color: Colors.white),
              title: const Text(
                'Saved Jobs',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedJobsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.payment, color: Colors.white),
              title: const Text(
                'Payment',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // yImplement Payment page navigation
              },
            ),
            ListTile(
              leading: const Icon(Icons.contacts, color: Colors.white),
              title: const Text(
                'Contact Us',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Implement Contact Us page navigation
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('About'),
                      content: const Text(
                        'Developers: \n     Bilata Wodisha\n     Frezer Bizuwerk\n\nApp Version: 1.0.0',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Log Out',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LogIn()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
