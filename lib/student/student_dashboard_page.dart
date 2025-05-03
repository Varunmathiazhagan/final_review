import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart'; // Add this dependency
import 'package:flutter/services.dart';
import '../shared/chatbot_component.dart';
import 'student_job_listings_page.dart';
import 'student_internship_listings_page.dart';
import '../shared/ide_helper.dart';

class StudentDashboardPage extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const StudentDashboardPage({Key? key, required this.studentData})
      : super(key: key);

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final ChatbotComponent _chatbotComponent = ChatbotComponent();
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Simulate loading
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _chatbotComponent.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Simulate refreshing data
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDarkMode ? Colors.tealAccent : Colors.blue;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Alumni Connect',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.code),
              onPressed: () => IdeHelper.showJDoodleIDE(context),
              tooltip: 'Open Compiler',
            ),
            IconButton(
              icon: Icon(MdiIcons.briefcase),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentJobListingsPage(
                      studentData: widget.studentData,
                    ),
                  ),
                );
              },
              tooltip: 'Job Listings',
            ),
            IconButton(
              icon: Icon(MdiIcons.briefcaseOutline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentInternshipListingsPage(
                      studentData: widget.studentData,
                    ),
                  ),
                );
              },
              tooltip: 'Internship Listings',
            ),
            IconButton(
              icon: Icon(MdiIcons.accountCircle),
              onPressed: () => Navigator.pushNamed(context, '/student_profile',
                  arguments: widget.studentData),
              tooltip: 'Student Profile',
            ),
          ],
        ),
        drawer: _buildDrawer(context, accentColor),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          color: accentColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _isLoading
                ? _buildLoadingView()
                : _buildDashboardContent(context, accentColor),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _chatbotComponent.openChatBotDialog(context),
          child: Icon(MdiIcons.robot),
          backgroundColor: accentColor,
          tooltip: 'Chat with AI Assistant',
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context, accentColor),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, Color accentColor) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accentColor.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: accentColor,
                image: DecorationImage(
                  image: AssetImage(
                      "assets/images/drawer_bg.jpg"), // Add this image to your assets
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    accentColor.withOpacity(0.7),
                    BlendMode.srcOver,
                  ),
                ),
              ),
              accountName: Text(
                widget.studentData['name'] ?? 'N/A',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(0, 1),
                    )
                  ],
                ),
              ),
              accountEmail: Text(
                widget.studentData['konguEmail'] ?? 'N/A',
                style: TextStyle(
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(0, 1),
                    )
                  ],
                ),
              ),
              currentAccountPicture: Hero(
                tag: 'profile-${widget.studentData['id'] ?? 'user'}',
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(MdiIcons.account, size: 40, color: accentColor),
                ),
              ),
            ),
            ListTile(
              leading: Icon(MdiIcons.home, color: accentColor),
              title: Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(MdiIcons.forum, color: accentColor),
              title: Text('Discussion Forum'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/shared_discussion', arguments: {
                  'userData': widget.studentData,
                  'userType': 'student'
                });
              },
            ),
            ListTile(
              leading: Icon(MdiIcons.accountGroup, color: accentColor),
              title: Text('Connect'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/connect',
                    arguments: widget.studentData);
              },
            ),
            ListTile(
              leading: Icon(MdiIcons.calendarClock, color: accentColor),
              title: Text('Events'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/events');
              },
            ),
            ListTile(
              leading: Icon(MdiIcons.cog, color: accentColor),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Replace with navigation to settings page once created
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Settings coming soon')));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(MdiIcons.logout, color: Colors.red),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildShimmerPlaceholder(height: 100),
          const SizedBox(height: 16),
          _buildShimmerPlaceholder(height: 200),
          const SizedBox(height: 16),
          _buildShimmerPlaceholder(height: 150),
          const SizedBox(height: 16),
          _buildShimmerPlaceholder(height: 180),
          const SizedBox(height: 16),
          _buildShimmerPlaceholder(height: 160),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, Color accentColor) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildWelcomeCard(context),
          const SizedBox(height: 16),
          _buildQuickActions(context, accentColor),
          const SizedBox(height: 16),
          _buildUpcomingEvents(context, accentColor),
          const SizedBox(height: 16),
          _buildJobInternshipSection(context, accentColor),
          const SizedBox(height: 16),
          _buildAnnouncementsSection(context, accentColor),
          const SizedBox(height: 16),
          _buildAlumniHighlights(context, accentColor),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    String greeting;
    final hour = DateTime.now().hour;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.indigo],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${widget.studentData['name']?.split(' ')[0] ?? 'Student'}!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Explore opportunities and stay connected with your alumni network.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color accentColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _ActionButton(
                    color: Colors.blue.shade700,
                    icon: MdiIcons.briefcase,
                    label: 'Jobs',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentJobListingsPage(
                            studentData: widget.studentData,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 12),
                  _ActionButton(
                    color: Colors.teal.shade600,
                    icon: MdiIcons.briefcaseOutline,
                    label: 'Internships',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentInternshipListingsPage(
                            studentData: widget.studentData,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 12),
                  _ActionButton(
                    color: Colors.purple.shade600,
                    icon: MdiIcons.accountSupervisor,
                    label: 'Mentoring',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Mentoring feature coming soon')),
                      );
                    },
                  ),
                  SizedBox(width: 12),
                  _ActionButton(
                    color: Colors.orange.shade600,
                    icon: MdiIcons.calendarClock,
                    label: 'Events',
                    onTap: () {
                      Navigator.pushNamed(context, '/events');
                    },
                  ),
                  SizedBox(width: 12),
                  _ActionButton(
                    color: Colors.deepPurple.shade600,
                    icon: MdiIcons.robot,
                    label: 'AI Chat',
                    onTap: () {
                      _chatbotComponent.openChatBotDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents(BuildContext context, Color accentColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(MdiIcons.calendarClock, color: accentColor),
                    SizedBox(width: 8),
                    Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/events');
                  },
                  child: Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: accentColor,
                  ),
                ),
              ],
            ),
            Divider(),
            _EventItem(
              title: 'Alumni Connect 2023',
              date: 'Oct 15, 2023',
              location: 'Main Auditorium',
              accentColor: accentColor,
              onTap: () {},
            ),
            SizedBox(height: 8),
            _EventItem(
              title: 'Career Fair',
              date: 'Nov 10, 2023',
              location: 'Virtual Event',
              accentColor: accentColor,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInternshipSection(BuildContext context, Color accentColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(MdiIcons.briefcase, color: accentColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Job & Internship Opportunities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentJobListingsPage(
                          studentData: widget.studentData,
                        ),
                      ),
                    );
                  },
                  child: Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: accentColor,
                  ),
                ),
              ],
            ),
            Divider(),
            _OpportunityItem(
              company: 'Google',
              role: 'Software Engineer',
              location: 'Bangalore',
              isNew: true,
              accentColor: accentColor,
              onTap: () {},
            ),
            SizedBox(height: 8),
            _OpportunityItem(
              company: 'Microsoft',
              role: 'Product Management Intern',
              location: 'Hyderabad',
              isNew: false,
              accentColor: accentColor,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsSection(BuildContext context, Color accentColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(MdiIcons.bullhorn, color: accentColor),
                SizedBox(width: 8),
                Text(
                  'Latest Announcements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(),
            _AnnouncementItem(
              title: 'Student-Alumni Mentorship Program',
              subtitle: 'Applications open until Sept 30, 2023',
              accentColor: accentColor,
              onTap: () {},
            ),
            SizedBox(height: 8),
            _AnnouncementItem(
              title: 'Workshop on Industry 4.0',
              subtitle: 'Register before Oct 5, 2023',
              accentColor: accentColor,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlumniHighlights(BuildContext context, Color accentColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(MdiIcons.accountGroup, color: accentColor),
                SizedBox(width: 8),
                Text(
                  'Alumni Highlights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(),
            _AlumniItem(
              name: 'Priya Sharma',
              achievement: 'Secured position at Google, Mountain View',
              avatarColor: Colors.purple,
              onTap: () {},
            ),
            SizedBox(height: 8),
            _AlumniItem(
              name: 'Rahul Verma',
              achievement: 'Published research paper in IEEE',
              avatarColor: Colors.teal,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('LOGOUT'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.7,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.only(bottom: 16),
                  ),
                  Text(
                    'More Options',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Divider(),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _BottomSheetTile(
                          icon: MdiIcons.briefcase,
                          color: Colors.blue,
                          title: 'Jobs',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentJobListingsPage(
                                  studentData: widget.studentData,
                                ),
                              ),
                            );
                          },
                        ),
                        _BottomSheetTile(
                          icon: MdiIcons.briefcaseOutline,
                          color: Colors.green,
                          title: 'Internships',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StudentInternshipListingsPage(
                                  studentData: widget.studentData,
                                ),
                              ),
                            );
                          },
                        ),
                        _BottomSheetTile(
                          icon: MdiIcons.accountSupervisor,
                          color: Colors.purple,
                          title: 'Mentoring',
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Mentoring feature coming soon')),
                            );
                          },
                        ),
                        _BottomSheetTile(
                          icon: MdiIcons.calendarStar,
                          color: Colors.orange,
                          title: 'Events',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/events');
                          },
                        ),
                        _BottomSheetTile(
                          icon: MdiIcons.robot,
                          color: Colors.purple,
                          title: 'Chatbot',
                          onTap: () {
                            Navigator.pop(context);
                            _chatbotComponent.openChatBotDialog(context);
                          },
                        ),
                        _BottomSheetTile(
                          icon: MdiIcons.forum,
                          color: Colors.blue,
                          title: 'Discussion Forum',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/shared_discussion',
                                arguments: {
                                  'userData': widget.studentData,
                                  'userType': 'student'
                                });
                          },
                        ),
                        _BottomSheetTile(
                          icon: MdiIcons.cog,
                          color: Colors.grey[700]!,
                          title: 'Settings',
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Settings coming soon')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, Color accentColor) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        // Handle navigation based on selected index
        switch (index) {
          case 0: // Home - already on dashboard
            break;
          case 1: // Discussion Forum
            Navigator.pushNamed(context, '/shared_discussion', arguments: {
              'userData': widget.studentData,
              'userType': 'student'
            });
            break;
          case 2: // Connect
            Navigator.pushNamed(context, '/connect',
                arguments: widget.studentData);
            break;
          case 3: // More
            _showMoreOptions(context);
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.forum),
          label: 'Discuss',
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.accountGroup),
          label: 'Connect',
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.dotsHorizontal),
          label: 'More',
        ),
      ],
    );
  }
}

// Custom widget for Event Items
class _EventItem extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final Color accentColor;
  final VoidCallback onTap;

  const _EventItem({
    required this.title,
    required this.date,
    required this.location,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(MdiIcons.calendar, color: accentColor, size: 24),
                  SizedBox(height: 4),
                  Text(
                    date.split(',')[0].split(' ')[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(MdiIcons.clockOutline, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(date, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(MdiIcons.mapMarkerOutline,
                          size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(location, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onTap,
              child: Text('Register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget for Job/Internship Opportunities
class _OpportunityItem extends StatelessWidget {
  final String company;
  final String role;
  final String location;
  final bool isNew;
  final Color accentColor;
  final VoidCallback onTap;

  const _OpportunityItem({
    required this.company,
    required this.role,
    required this.location,
    required this.isNew,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  company.substring(0, 1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          role,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isNew)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(company, style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(MdiIcons.mapMarkerOutline,
                          size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(location, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(MdiIcons.chevronRight, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// Custom widget for Announcements
class _AnnouncementItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _AnnouncementItem({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: accentColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: accentColor.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(MdiIcons.bullhornOutline, color: accentColor),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(MdiIcons.arrowRight, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom widget for Alumni Items
class _AlumniItem extends StatelessWidget {
  final String name;
  final String achievement;
  final Color avatarColor;
  final VoidCallback onTap;

  const _AlumniItem({
    required this.name,
    required this.achievement,
    required this.avatarColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: avatarColor,
              child: Text(
                name.substring(0, 1),
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    achievement,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(MdiIcons.arrowRight, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// Custom widget for Bottom Sheet Items
class _BottomSheetTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _BottomSheetTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Icon(MdiIcons.chevronRight, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// Custom widget for Quick Action Buttons
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
