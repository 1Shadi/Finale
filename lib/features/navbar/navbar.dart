import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../SearchProduct/search_product.dart';
import '../../core/Widgets/global_var.dart';
import '../HomeScreen/home_screen.dart';
import '../UploadAdScreen/upload_ad_screen.dart';
import '../chats/chat_contact.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key, required this.currentUserId}) : super(key: key);
  final String currentUserId;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      uid = currentUser.uid;
      userEmail = currentUser.email!;
      getMyData();
      _screens = [
        const HomeScreen(),
        MessageSenderScreen(currentUserId: widget.currentUserId),
        // ProfileScreen(sellerId: widget.currentUserId),
        const UploadAdScreen(),
      ];
    }
  }

  Future<void> getMyData() async {
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      userImageUrl = userData['userImage'];
      getUserName = userData['userName'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Current screen
          _screens[_currentIndex],
          // Bottom navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.8),
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    items: const [
                      BottomNavigationBarItem(
                        activeIcon: Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 28,
                        ),
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        activeIcon: Icon(
                          Icons.chat,
                          color: Colors.white,
                          size: 28,
                        ),
                        icon: Icon(
                          Icons.chat,
                        ),
                        label: 'Chats',
                      ),
                      BottomNavigationBarItem(
                        activeIcon: Icon(
                          Icons.cloud_upload,
                          color: Colors.white,
                          size: 28,
                        ),
                        icon: Icon(
                          Icons.cloud_upload,
                          size: 20,
                        ),
                        label: 'Upload',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
