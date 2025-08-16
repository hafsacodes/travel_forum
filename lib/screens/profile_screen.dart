import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_forum/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String uid;
  int postCount = 0;
  List<DocumentSnapshot> userPosts = [];
  bool _loadingPosts = true;

  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser!.uid;
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      setState(() => _loadingPosts = true);
      final posts = await _firestore
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        postCount = posts.docs.length;
        userPosts = posts.docs;
      });
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      setState(() => _loadingPosts = false);
    }
  }

  Future<void> fetchProfileData() async {
    await _loadPosts();
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final userDocStream = _firestore.collection('users').doc(uid).snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: fetchProfileData,
        child: StreamBuilder<DocumentSnapshot>(
          stream: userDocStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

            final username = data['username']?.toString() ?? '';
            final bio = data['bio']?.toString() ?? '';
            final email = data['email']?.toString() ?? '';

            // ✅ Now only using `photoUrl` for consistency
            final imageUrl = (data['photoUrl'] != null && (data['photoUrl'] as String).isNotEmpty)
                ? data['photoUrl'] as String
                : '';

            return Column(
              children: [
                const SizedBox(height: 60),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : const AssetImage('assets/profile.jpg')
                      as ImageProvider,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      username.isNotEmpty ? username : 'No Username',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildEditButton(),
                Column(
                  children: [
                    if (bio.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Text(
                          bio,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    if (email.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Text(
                          email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Posts: $postCount',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _loadingPosts
                      ? const Center(child: CircularProgressIndicator())
                      : _buildPostGrid(),
                ),
                const SizedBox(height: 10),
                _buildLogoutButton(),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
          );
          await _loadPosts();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Center(child: Text('Edit Profile')),
      ),
    );
  }

  Widget _buildPostGrid() {
    if (userPosts.isEmpty) {
      return const Center(child: Text('No posts yet'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: userPosts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          final post = userPosts[index];
          final imageUrl = post['imageUrl'] ?? '';
          return Image.network(imageUrl, fit: BoxFit.cover);
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: _signOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Center(child: Text('Logout')),
      ),
    );
  }
}
