import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'comment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Random _random = Random();
  String _searchQuery = '';

  final List<Map<String, dynamic>> mockPosts = [
    {
      'title': 'Exploring the Mountains',
      'description': 'Had an amazing hike in the northern mountains! 🏔️',
      'imageUrl': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
      'likesCount': 0,
      'commentsCount': 0,
      'comments': [],
      'username': 'MountainGoat',
      'profilePic': 'https://randomuser.me/api/portraits/men/2.jpg',
    },
    {
      'title': 'Sunset at the Beach',
      'description': 'Nothing beats this view 🌅',
      'imageUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
      'likesCount': 0,
      'commentsCount': 0,
      'comments': [],
      'username': 'BeachBabe',
      'profilePic': 'https://randomuser.me/api/portraits/women/3.jpg',
    },
    {
      'title': 'City Lights Adventure',
      'description': 'The city never sleeps ✨',
      'imageUrl': 'https://images.unsplash.com/photo-1499346030926-9a72daac6c63',
      'likesCount': 0,
      'commentsCount': 0,
      'comments': [],
      'username': 'CityExplorer',
      'profilePic': 'https://randomuser.me/api/portraits/men/4.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Random values for mock posts
    for (var post in mockPosts) {
      post['likesCount'] = _random.nextInt(200);
      post['commentsCount'] = _random.nextInt(20);
      post['comments'] = List.generate(
        _random.nextInt(4) + 1,
            (index) => {
          'username':
          _fakeUsernames[_random.nextInt(_fakeUsernames.length)],
          'profilePic':
          _fakeProfilePics[_random.nextInt(_fakeProfilePics.length)],
          'comment':
          _fakeComments[_random.nextInt(_fakeComments.length)],
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TravelForum',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            color: Color(0xFF006400),
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search posts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          // Posts List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}'));
                }

                final firestorePosts = snapshot.data!.docs.map((doc) {
                  return {
                    'title': doc['title'] ?? '',
                    'description': doc['description'] ?? '',
                    'imageUrl': doc['imageUrl'] ?? '',
                    'username':
                    doc['username'] ?? 'Unknown User',
                    'profilePic': doc['profilePic'] ??
                        'https://via.placeholder.com/50',
                    'docId': doc.id,
                    'likes': doc['likes'] ?? [],
                    'comments': doc['comments'] ?? [],
                  };
                }).where((post) {
                  return post['title']
                      .toLowerCase()
                      .contains(_searchQuery) ||
                      post['description']
                          .toLowerCase()
                          .contains(_searchQuery);
                }).toList();

                if (firestorePosts.isEmpty) {
                  final filteredMock = mockPosts.where((post) {
                    return post['title']
                        .toLowerCase()
                        .contains(_searchQuery) ||
                        post['description']
                            .toLowerCase()
                            .contains(_searchQuery);
                  }).toList();
                  return _buildPostList(
                      context, filteredMock,
                      isMock: true);
                }
                return _buildPostList(context, firestorePosts);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList(BuildContext context,
      List<Map<String, dynamic>> posts,
      {bool isMock = false}) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture & username
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                      NetworkImage(post['profilePic']),
                      radius: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      post['username'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
              // Post Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15)),
                child: Image.network(
                  post['imageUrl'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                          child: Icon(Icons.broken_image,
                              size: 50)),
                    );
                  },
                ),
              ),
              // Title, description, and actions
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(post['title'],
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(post['description'],
                        style:
                        const TextStyle(fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.favorite_border),
                          onPressed: () {
                            if (!isMock) {
                              _toggleLike(post['docId'],
                                  currentUser!.uid);
                            }
                          },
                        ),
                        Text(
                          isMock
                              ? post['likesCount']
                              .toString()
                              : post['likes'].length
                              .toString(),
                          style: const TextStyle(
                              fontSize: 14),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(
                              Icons.comment_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CommentScreen(
                                      postId: isMock
                                          ? null
                                          : post['docId'],
                                      isMock: isMock,
                                      mockComments: isMock ? List<Map<String, dynamic>>.from(post['comments']) : [],
                                    ),
                              ),
                            );
                          },
                        ),
                        Text(
                          isMock
                              ? post['commentsCount']
                              .toString()
                              : post['comments'].length
                              .toString(),
                          style: const TextStyle(
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleLike(
      String postId, String userId) async {
    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId);
    final postSnapshot = await postRef.get();
    List likes = postSnapshot['likes'] ?? [];
    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }
    await postRef.update({'likes': likes});
  }
}

final List<String> _fakeUsernames = [
  'TravelLover',
  'MountainGoat',
  'BeachBabe',
  'CityExplorer'
];
final List<String> _fakeProfilePics = [
  'https://randomuser.me/api/portraits/women/1.jpg',
  'https://randomuser.me/api/portraits/men/2.jpg',
  'https://randomuser.me/api/portraits/women/3.jpg',
  'https://randomuser.me/api/portraits/men/4.jpg',
];
final List<String> _fakeComments = [
  'Wow! Looks amazing 😍',
  'This is on my bucket list!',
  'Great shot 📸',
  'I wish I was there!',
];
