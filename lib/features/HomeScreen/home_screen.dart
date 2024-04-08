import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../SearchProduct/search_product.dart';
import '../../core/Widgets/global_var.dart';
import '../../core/Widgets/listview.dart';
import '../ProfileScreen/profile_screen.dart';
import '../UploadAdScreen/upload_ad_screen.dart';
import '../WelcomeScreen/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    userEmail = FirebaseAuth.instance.currentUser!.email!;
    getMyData();
  }

  Future<void> getMyData() async {
    final userData = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      userImageUrl = userData['userImage'];
      getUserName = userData['userName'];
    });
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
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      sellerId: uid,
                    ),
                  ),
                );
                getMyData(); // Refresh user data after returning from profile screen
              },
              icon: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.person, color: Colors.black),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchProduct()),
                );
              },
              icon: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.search, color: Colors.orange),
              ),
            ),
            IconButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                );
              },
              icon: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.logout, color: Colors.orange),
              ),
            ),
          ],
          title: const Text(
            'Home Screen',
            style: TextStyle(
              color: Colors.black54,
              fontFamily: 'Signatra',
              fontSize: 30,
            ),
          ),
          centerTitle: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.teal],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('items').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final items = snapshot.data!.docs;
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = items[index].data() as Map<String, dynamic>;
                  return ListViewWidget(
                    docId: items[index].id,
                    itemColor: item['itemColor'] ?? '',
                    img1: item['urlImage1'] ?? '',
                    img2: item['urlImage2'] ?? '',
                    img3: item['urlImage3'] ?? '',
                    img4: item['urlImage4'] ?? '',
                    img5: item['urlImage5'] ?? '',
                    userImg: item['imgPro'] ?? '',
                    name: item['userName'] ?? '',
                    date: item['time']?.toDate() ?? DateTime.now(),
                    userId: item['id'] ?? '',
                    itemModel: item['itemModel'] ?? '',
                    postId: item['postId'] ?? '',
                    itemPrice: item['itemPrice'] ?? '',
                    description: item['description'] ?? '',
                    lat: item['lat'] ?? 0.0,
                    lng: item['lng'] ?? 0.0,
                    address: item['address'] ?? '',
                    userNumber: item['userNumber'] ?? '',
                  );
                },
              );
            } else {
              return const Center(
                child: Text('No items found'),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Add Post',
          backgroundColor: Colors.black54,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UploadAdScreen(),
              ),
            );
          },
          child: const Icon(Icons.cloud_upload, color: Colors.white),
        ),
      ),
    );
  }
}
