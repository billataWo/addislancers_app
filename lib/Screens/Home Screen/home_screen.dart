import 'package:addislancers_app/Screens/Chat%20Screen/chat_list_screen.dart';
import 'package:addislancers_app/Screens/Home%20Screen/settings_page.dart';
import 'package:addislancers_app/Screens/Job%20Screen/applied_job_list.dart';
import 'package:addislancers_app/Screens/Job%20Screen/job_detail_page.dart';
import 'package:addislancers_app/Screens/Job%20Screen/postjob_screen.dart';
import 'package:addislancers_app/Screens/Job%20Screen/saved_jobs.dart';
import 'package:addislancers_app/Screens/Profile%20Screen/profile_screen.dart';
import 'package:addislancers_app/Models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badge_pkg;
import 'package:intl/intl.dart';
import 'package:addislancers_app/Screens/Job%20Screen/job_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _userModel;
  int _selectedIndex = 0;
  String _searchQuery = "";
  bool _isSearching = false;
  User? user;
  int _unreadMessageCount = 0;
  List<DocumentSnapshot> _searchResults = [];
  List<DocumentSnapshot> _allJobs = [];

  String? _profilePicUrl;

  @override
  void initState() {
    super.initState();
    _getUserDetails().then((_) {
      setState(() {});
    });
    _searchController.addListener(_onSearchChanged);
    _listenForNewNotification();
    _fetchAllJobs();
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
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (userDoc.exists) {
          setState(() {
            _userModel = UserModel.fromDocument(userDoc);
            _profilePicUrl = _userModel!.profilePic;
          });
        } else {
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

  void _listenForNewNotification() {
    FirebaseFirestore.instance
        .collection('jobs')
        .where('users', arrayContains: _auth.currentUser?.uid)
        .snapshots()
        .listen((notificationSnapshot) {
      int _newNotificationCount = 0;
      for (var notificationData in notificationSnapshot.docs) {
        FirebaseFirestore.instance
            .collection('jobs')
            .doc(notificationData.id)
            .collection('messages')
            .where('isRead', isEqualTo: false)
            .where('senderId', isNotEqualTo: _auth.currentUser?.uid)
            .get()
            .then((messageSnapshot) {
          _newNotificationCount += notificationSnapshot.docs.length;
          setState(() {
            _unreadMessageCount = _newNotificationCount;
          });
        });
      }
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
      _searchQuery = _searchController.text.toLowerCase();
      _isSearching = _searchQuery.isNotEmpty;
      _searchFirestore();
    });
  }

  Future<void> _searchFirestore() async {
    if (_searchQuery.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    QuerySnapshot jobSnapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .where('searchKeywords', arrayContains: _searchQuery)
        .get();

    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('searchKeywords', arrayContains: _searchQuery)
        .get();

    QuerySnapshot companySnapshot = await FirebaseFirestore.instance
        .collection('companies')
        .where('searchKeywords', arrayContains: _searchQuery)
        .get();

    setState(() {
      _searchResults = [
        ...jobSnapshot.docs,
        ...userSnapshot.docs,
        ...companySnapshot.docs
      ];
    });
  }

  Future<void> _fetchAllJobs() async {
    QuerySnapshot jobSnapshot =
        await FirebaseFirestore.instance.collection('jobs').get();

    setState(() {
      _allJobs = jobSnapshot.docs;
    });
  }

  Future<void> _refreshJobs() async {
    await _fetchAllJobs();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jobs updated')),
    );
  }

  String _truncateDescription(String description, int wordLimit) {
    List<String> words = description.split(' ');
    if (words.length > wordLimit) {
      return words.sublist(0, wordLimit).join(' ') + '...';
    }
    return description;
  }

  Widget _getSelectedPage() {
    if (_userModel != null) {
      switch (_selectedIndex) {
        case 0:
          return _buildHomePage();
        case 1:
          return ChatListScreen();
        case 2:
          return _userModel!.role == 'Client'
              ? const PostJobScreen()
              : SavedJobsPage();
        case 3:
          return AppliedJobListPage();
        case 4:
          return const ProfileScreen();
        default:
          return _buildHomePage();
      }
    } else {
      return Center(
          child: CircularProgressIndicator()); // Or a default loading page
    }
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var jobs = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          var title = data['title']?.toString().toLowerCase() ?? "";
          var description = data['description']?.toString().toLowerCase() ?? "";
          return title.contains(_searchQuery.toLowerCase()) ||
              description.contains(_searchQuery.toLowerCase());
        }).toList();

        if (jobs.isEmpty) {
          return Center(child: Text('No jobs found'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            var job = jobs[index];
            var jobData = job.data() as Map<String, dynamic>;
            var jobTitle = jobData['title'];
            var jobDescription = jobData['description'];
            var jobPayment = jobData['payment'];
            var jobTimestamp = jobData['timestamp'] as Timestamp;
            var jobDate =
                DateFormat('dd MMM kk:mm').format(jobTimestamp.toDate());

            return ListTile(
              title: Text(jobTitle),
              subtitle: Text(jobDescription),
              trailing: Text('Payment: $jobPayment\nPosted: $jobDate'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailPage(jobId: job.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
//////////////*//////////////////////*
  /*Widget _buildJobList() {
    if (_allJobs.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshJobs,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _allJobs.length,
        itemBuilder: (context, index) {
          var job = _allJobs[index];
          var jobData = job.data() as Map<String, dynamic>;
          var jobTitle = jobData['title'];
          var jobDescription = _truncateDescription(jobData['description'], 10);
          var jobPayment = jobData['payment'];
          var jobTimestamp = jobData['timestamp'] as Timestamp;
          var jobDate =
              DateFormat('dd MMM kk:mm').format(jobTimestamp.toDate());

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(
                jobTitle,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 2, 36, 149)),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(jobDescription),
                  SizedBox(height: 8),
                  Text(
                    'Payment: $jobPayment',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  SizedBox(height: 4),
                  Text('Posted: $jobDate',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailPage(jobId: job.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }*/

  Widget _buildCategoryAndRecentJobs() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CategoryIcon(
                icon: Icons.computer,
                label: 'Technology',
                color: Color(0xFF013BF9),
              ),
              CategoryIcon(
                icon: Icons.layers,
                label: 'Design',
                color: Color(0xFF013BF9),
              ),
              CategoryIcon(
                icon: Icons.currency_exchange,
                label: 'Marketing',
                color: Color(0xFF013BF9),
              ),
              CategoryIcon(
                icon: Icons.edit_note,
                label: 'Writing',
                color: Color(0xFF013BF9),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Recent Jobs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          JobList(
            allJobs: _allJobs,
            refreshJobs: _refreshJobs,
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            //backgroundColor: Color.fromARGB(255, 4, 29, 113),
            expandedHeight: 100.0,
            //floating: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 50, left: 5.0, right: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileScreen()),
                                );
                              },
                              child: CircleAvatar(
                                backgroundImage: _profilePicUrl != null
                                    ? NetworkImage(_profilePicUrl!)
                                        as ImageProvider
                                    : const AssetImage(
                                        'assets/images/default_profile_pic.jpg'),
                                radius: 25.0,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            // if (_userModel != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userModel != null
                                      ? "Welcome 👋\n${_userModel!.firstName} ${_userModel!.lastName}"
                                      : "Welcome 👋",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 2, 36, 149),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications,
                                    color: Color.fromARGB(255, 2, 36, 149),
                                  ),
                                  onPressed: () {
                                    // Handle notifications icon press
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings,
                                      color: Color.fromARGB(255, 2, 36, 149)),
                                  onPressed: () {
                                    // Handle settings icon press
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingsPage()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            floating: true,
            delegate: MySliverPersistentHeaderDelegate(
              searchController: _searchController,
              unreadMessageCount: _unreadMessageCount,
            ),
          ),
          SliverToBoxAdapter(
            child: _isSearching
                ? _buildSearchResults()
                : _buildCategoryAndRecentJobs(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _userModel == null
            ? const CircularProgressIndicator() // Or a placeholder widget
            : _getSelectedPage(),
      ),
      bottomNavigationBar: _userModel == null
          ? null
          : BottomNavigationBar(
              backgroundColor: const Color.fromRGBO(1, 18, 72, 1),
              items: <BottomNavigationBarItem>[
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                  backgroundColor: Color.fromRGBO(1, 18, 72, 1),
                ),
                BottomNavigationBarItem(
                  icon: badge_pkg.Badge(
                    badgeContent: Text(
                      '$_unreadMessageCount',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 135, 7, 7)),
                    ),
                    showBadge: _unreadMessageCount > 0,
                    child: const Icon(Icons.message),
                  ),
                  label: 'Messages',
                  backgroundColor: const Color.fromRGBO(1, 18, 72, 1),
                ),
                BottomNavigationBarItem(
                  icon: _userModel!.role == 'Client'
                      ? const Icon(Icons.add_circle)
                      : const Icon(Icons.work_history),
                  label:
                      _userModel!.role == 'Client' ? 'Post Job' : 'Saved Jobs',
                  backgroundColor: const Color.fromRGBO(1, 18, 72, 1),
                ),
                BottomNavigationBarItem(
                  icon: _userModel!.role == 'Client'
                      ? const Icon(Icons.list)
                      : const Icon(Icons.work),
                  label: _userModel!.role == 'Client' ? 'List' : 'Applied Jobs',
                  backgroundColor: const Color.fromRGBO(1, 18, 72, 1),
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                  backgroundColor: Color.fromRGBO(1, 18, 72, 1),
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
    );
  }
}

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final int unreadMessageCount;

  MySliverPersistentHeaderDelegate({
    required this.searchController,
    required this.unreadMessageCount,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      //color: Color.fromARGB(255, 4, 29, 113),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search for jobs',
                prefixIcon: Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            if (unreadMessageCount > 0)
              Text(
                '$unreadMessageCount new notifications',
                style: TextStyle(color: Colors.red, fontSize: 16.0),
              ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 100.0;

  @override
  double get minExtent => 100.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const CategoryIcon({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            icon,
            color: color,
            size: 30,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
