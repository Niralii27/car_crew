import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({Key? key}) : super(key: key);

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  bool _isLoading = true;
  List<DocumentSnapshot> users = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      // Fetch all users from the UsersTbl collection
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('UsersTbl').get();

      setState(() {
        users = querySnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching users: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final isPad = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : users.isEmpty
                  ? const Center(child: Text('No users found'))
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: 16,
                      ),
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final userData =
                              users[index].data() as Map<String, dynamic>;
                          return _buildUserListItem(
                              context, userData, users[index].id, isPad);
                        },
                      ),
                    ),
    );
  }

  Widget _buildUserListItem(BuildContext context, Map<String, dynamic> userData,
      String docId, bool isPad) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(userId: docId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // User Image
              Container(
                width: isPad ? 80 : 60,
                height: isPad ? 80 : 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: userData['UserImage'] != null &&
                          userData['UserImage'] is String
                      ? Image.network(
                          userData['UserImage'],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person,
                                size: 40, color: Colors.grey);
                          },
                        )
                      : const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
              ),

              const SizedBox(width: 16),

              // User Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['UserName'] is String
                          ? userData['UserName']
                          : 'Name not available',
                      style: TextStyle(
                        fontSize: isPad ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData['UserEmail'] is String
                          ? userData['UserEmail']
                          : 'Email not available',
                      style: TextStyle(
                        fontSize: isPad ? 14 : 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData['city'] is String
                          ? userData['city']
                          : 'Location not available',
                      style: TextStyle(
                        fontSize: isPad ? 14 : 12,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: isPad ? 20 : 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? userData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      // Get document from Firestore using document ID
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('UsersTbl')
          .doc(widget.userId)
          .get();

      if (!userDoc.exists) {
        setState(() {
          errorMessage = 'User data not found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching user data: $e';
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return 'Not available';
    }

    try {
      if (timestamp is Timestamp) {
        final DateTime dateTime = timestamp.toDate();
        return DateFormat('dd MMMM yyyy, hh:mm a').format(dateTime);
      } else {
        return 'Invalid date format';
      }
    } catch (e) {
      return 'Date error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPad = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      appBar: AppBar(
        title: Text(userData?['UserName'] ?? 'User Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isPad ? 600 : screenWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: screenHeight * 0.02),

                          // User image
                          Container(
                            width: isPad ? 180 : 120,
                            height: isPad ? 180 : 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: userData?['UserImage'] != null &&
                                      userData?['UserImage'] is String
                                  ? Image.network(
                                      userData!['UserImage'],
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.person,
                                            size: 80, color: Colors.grey);
                                      },
                                    )
                                  : const Icon(Icons.person,
                                      size: 80, color: Colors.grey),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // User name
                          Text(
                            userData?['UserName'] ?? 'Name not available',
                            style: TextStyle(
                              fontSize: isPad ? 28 : 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.01),

                          // User email
                          Text(
                            userData?['UserEmail'] ?? 'Email not available',
                            style: TextStyle(
                              fontSize: isPad ? 16 : 14,
                              color: Colors.grey[600],
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.04),

                          // User information cards
                          isLandscape && isPad
                              ? _buildLandscapeLayout(context)
                              : _buildPortraitLayout(context),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      children: [
        _buildInfoCard(
          context,
          'Contact Information',
          [
            _buildInfoRow(Icons.phone, 'Phone Number',
                userData?['phoneNo'] ?? 'Not provided'),
            _buildInfoRow(Icons.location_city, 'City',
                userData?['city'] ?? 'Not provided'),
            _buildInfoRow(
                Icons.home, 'Address', userData?['address'] ?? 'Not provided'),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          'Account Information',
          [
            _buildInfoRow(
              Icons.calendar_today,
              'Created At',
              userData?['createdAt'] != null
                  ? _formatTimestamp(userData!['createdAt'])
                  : 'Not available',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            'Contact Information',
            [
              _buildInfoRow(Icons.phone, 'Phone Number',
                  userData?['phoneNo'] ?? 'Not provided'),
              _buildInfoRow(Icons.location_city, 'City',
                  userData?['city'] ?? 'Not provided'),
              _buildInfoRow(Icons.home, 'Address',
                  userData?['address'] ?? 'Not provided'),
            ],
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        Expanded(
          child: _buildInfoCard(
            context,
            'Account Information',
            [
              _buildInfoRow(
                Icons.calendar_today,
                'Created At',
                userData?['createdAt'] != null
                    ? _formatTimestamp(userData!['createdAt'])
                    : 'Not available',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    // Convert value to String safely
    String displayValue = 'Not provided';
    if (value != null) {
      if (value is String) {
        displayValue = value;
      } else {
        // Try to convert other types to string
        try {
          displayValue = value.toString();
        } catch (e) {
          displayValue = 'Invalid value';
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
