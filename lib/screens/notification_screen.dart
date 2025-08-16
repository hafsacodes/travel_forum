import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // --- Mock data for when Firestore is empty ---
  // We use mock data so the screen doesn't look empty during demos or testing.
  // In production, only real notifications from Firestore will be shown.
  final List<Map<String, dynamic>> mockNotifications = const [
    {
      'username': 'Alex',
      'profilePic': 'https://randomuser.me/api/portraits/men/11.jpg',
      'action': 'liked your post',
      'timestamp': '2 hours ago',
    },
    {
      'username': 'Sophia',
      'profilePic': 'https://randomuser.me/api/portraits/women/21.jpg',
      'action': 'commented: "Looks amazing!"',
      'timestamp': '5 hours ago',
    },
    {
      'username': 'Michael',
      'profilePic': 'https://randomuser.me/api/portraits/men/31.jpg',
      'action': 'started following you',
      'timestamp': '1 day ago',
    },
    {
      'username': 'Emma',
      'profilePic': 'https://randomuser.me/api/portraits/women/32.jpg',
      'action': 'shared your post',
      'timestamp': '2 days ago',
    },
    {
      'username': 'Daniel',
      'profilePic': 'https://randomuser.me/api/portraits/men/45.jpg',
      'action': 'mentioned you in a comment',
      'timestamp': '3 days ago',
    },
    {
      'username': 'Olivia',
      'profilePic': 'https://randomuser.me/api/portraits/women/47.jpg',
      'action': 'liked your profile picture',
      'timestamp': '4 days ago',
    },
    {
      'username': 'James',
      'profilePic': 'https://randomuser.me/api/portraits/men/53.jpg',
      'action': 'reacted ❤️ to your post',
      'timestamp': '5 days ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final firestoreNotifications = snapshot.data!.docs.map((doc) {
            return {
              'username': doc['username'] ?? '',
              'profilePic': doc['profilePic'] ?? '',
              'action': doc['action'] ?? '',
              'timestamp': _formatTimestamp(doc['timestamp']),
            };
          }).toList();

          // If there are no notifications in Firestore → show mock data
          if (firestoreNotifications.isEmpty) {
            return _buildNotificationList(mockNotifications);
          }

          // Otherwise, show real notifications
          return _buildNotificationList(firestoreNotifications);
        },
      ),
    );
  }

  // --- Helper to format Firestore Timestamp into a readable string ---
  static String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = (timestamp as Timestamp).toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // --- Notification list builder ---
  Widget _buildNotificationList(List<Map<String, dynamic>> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(notification['profilePic']),
          ),
          title: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 15),
              children: [
                TextSpan(
                  text: notification['username'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' '),
                TextSpan(text: notification['action']),
              ],
            ),
          ),
          subtitle: Text(notification['timestamp']),
        );
      },
    );
  }
}
