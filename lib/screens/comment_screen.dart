import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentScreen extends StatefulWidget {
  final String? postId;
  final bool isMock;
  final List<Map<String, dynamic>> mockComments;

  const CommentScreen({
    super.key,
    this.postId,
    this.isMock = false,
    this.mockComments = const [],
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: widget.isMock
                ? _buildMockComments()
                : _buildFirestoreComments(),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMockComments() {
    return ListView.builder(
      itemCount: widget.mockComments.length,
      itemBuilder: (context, index) {
        final comment = widget.mockComments[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(comment['profilePic']),
          ),
          title: Text(comment['username']),
          subtitle: Text(comment['comment']),
        );
      },
    );
  }

  Widget _buildFirestoreComments() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No comments yet.'));
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(doc['profilePic']),
              ),
              title: Text(doc['username']),
              subtitle: Text(doc['comment']),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildInputField() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _addComment,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (widget.isMock) {
      setState(() {
        widget.mockComments.add({
          'username': 'You',
          'profilePic': 'https://randomuser.me/api/portraits/lego/1.jpg',
          'comment': text,
        });
      });
      _controller.clear();
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'username': user.displayName ?? 'Anonymous',
        'profilePic': user.photoURL ??
            'https://randomuser.me/api/portraits/lego/2.jpg',
        'comment': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }
}
