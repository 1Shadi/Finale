import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat.dart';

class MessageSenderScreen extends StatefulWidget {
  final String currentUserId;

  const MessageSenderScreen({required this.currentUserId});

  @override
  _MessageSenderScreenState createState() => _MessageSenderScreenState();
}

class _MessageSenderScreenState extends State<MessageSenderScreen> {
  late Future<List<String>> _fetchChatUsersFuture;

  @override
  void initState() {
    super.initState();
    _fetchChatUsersFuture = _fetchChatUsers();
  }

  Future<List<String>> _fetchChatUsers() async {
    try {
      final currentUser = widget.currentUserId;
      print('Current user: $currentUser');

      if (currentUser == null || currentUser.isEmpty) {
        print('Error: currentUser is null or empty');
        return [];
      }

      // Query messages where the current user is the sender or recipient
      final QuerySnapshot senderMessages = await FirebaseFirestore.instance
          .collection('messages')
          .where('sender', isEqualTo: currentUser)
          .get();
      print('Sender messages: ${senderMessages.docs}');

      final QuerySnapshot recipientMessages = await FirebaseFirestore.instance
          .collection('messages')
          .where('recipient', isEqualTo: currentUser)
          .get();
      print('Recipient messages: ${recipientMessages.docs}');

      // Extract unique users from sender and recipient messages
      final Set<String> chatUsers = {};

      // Add recipients from sender messages
      senderMessages.docs.forEach((doc) {
        final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('recipient')) {
          final recipientId = data['recipient'] as String?;
          if (recipientId != null) {
            chatUsers.add(recipientId);
          }
        }
      });

      // Add senders from recipient messages
      recipientMessages.docs.forEach((doc) {
        final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('sender')) {
          final senderId = data['sender'] as String?;
          if (senderId != null) {
            chatUsers.add(senderId);
          }
        }
      });

      print('Fetched chat users: $chatUsers');
      return chatUsers.toList(); // Convert Set to List
    } catch (error) {
      print('Error fetching chat users: $error');
      return []; // Return an empty list in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.teal],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Chats'),
        ),
        body: FutureBuilder<List<String>>(
          future: _fetchChatUsersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final chatUsers = snapshot.data!;
              if (chatUsers.isEmpty) {
                return const Center(child: Text('There are no chats yet',style: TextStyle(fontSize: 24),));
              }
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final users = snapshot.data?.docs ?? [];
                    final userNames = users.map((user) => user.data() as Map<String, dynamic>).toList();
                    List<Widget> userListTiles = [];
                    for (int i = 0; i < chatUsers.length; i++) {
                      print('${widget.currentUserId}');
                      print('${chatUsers[i]}');
                      final userName = userNames[i];
                      userListTiles.add(
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  userName: userName['userName'] ?? '',
                                  currentUserId: widget.currentUserId,
                                  chatUserId: chatUsers[i],
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Container(
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                border: Border.all(color: Colors.grey),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(16),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(userName['userImage']),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 22,),
                                    Text(widget.currentUserId ==chatUsers[i]?'Me': userName['userName'] ?? ''),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: userListTiles,
                    );
                  } else {
                    return const Center(child: Text('No user data available'));
                  }
                },
              );
            } else {
              return const Center(child: Text('Unknown error'));
            }
          },
        ),
      ),
    );
  }
}

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
}
