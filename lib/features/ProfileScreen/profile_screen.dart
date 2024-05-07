import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../../core/Widgets/listview.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String status;

  const ProfileScreen({Key? key, required this.userId, required this.status}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String adUserName = '';
  late String adUserImageUrl = '';

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }
  Future<String?> _editUserNameDialog(BuildContext context) async {
    TextEditingController _nameController = TextEditingController();
    File? _selectedImage;
    String? newName;

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: 'Enter new username'),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  File? newImage = await _getImageFromGallery();
                  setState(() {
                    _selectedImage = newImage;
                  });
                },
                child: Text('Select Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  newName = _nameController.text.trim();
                  if (_selectedImage != null) {
                    String imageUrl = await uploadProfilePicture(_selectedImage!);
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
                        .update({'userImage': imageUrl});
                    setState(() {
                      adUserImageUrl = imageUrl;
                    });
                  }
                  Navigator.pop(context, newName);
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> getUserInfo() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: widget.userId)
          .where('status', isEqualTo: widget.status)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          adUserName = snapshot.docs[0].get('userName');
          adUserImageUrl = snapshot.docs[0].get('userImage');
        });
      }
    } catch (e) {
      print('Error getting user info: $e');
    }
  }

  _buildUserImage() {
    return Container(
      width: 50,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(adUserImageUrl),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  void _editProfile() async {
    try {
      String? newName = await _editUserNameDialog(context);
      if (newName != null) {
        setState(() {
          adUserName = newName;
        });
        await updateUserInfoInItems(newName, adUserName, adUserImageUrl);
        // Update the user information in the app bar
        adUserImageUrl = await _getUserImageUrl(widget.userId);
        Navigator.pop(context, {'userName': adUserName, 'userImage': adUserImageUrl});
      }
    } catch (e) {
      print('Error editing profile: $e');
    }
  }

  Future<String> _getUserImageUrl(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        return snapshot.get('userImage');
      } else {
        return ''; // Return empty string if user document doesn't exist
      }
    } catch (e) {
      print('Error getting user image URL: $e');
      return ''; // Return empty string in case of error
    }
  }




  Future<File?> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final firebase_storage.Reference storageRef =
      firebase_storage.FirebaseStorage.instance.ref().child(
        'userImages/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final firebase_storage.UploadTask uploadTask = storageRef.putFile(
        imageFile,
        firebase_storage.SettableMetadata(
          contentType: 'image/jpg',
        ),
      );

      await uploadTask.whenComplete(() => null);
      final String downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  Future<void> updateUserInfoInItems(
      String? newName, String oldName, String oldImageUrl) async {
    try {
      // Update user information in all items posted by the user
      final snapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('id', isEqualTo: widget.userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (final doc in snapshot.docs) {
          String itemId = doc.id;
          await FirebaseFirestore.instance.collection('items').doc(itemId).update({
            'userName': newName ?? oldName,
            'imgPro': adUserImageUrl,
          });
        }
      }
    } catch (e) {
      print('Error updating user info in items: $e');
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
          title: Row(
            children: [
              _buildUserImage(),
              const SizedBox(width: 10),
              Text(adUserName),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _editProfile,
              icon: Icon(Icons.edit),
            ),

          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Items:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('items')
                      .where('id', isEqualTo: widget.userId) // Filter by user ID
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData &&
                        snapshot.data!.docs.isNotEmpty) {
                      final items = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item =
                          items[index].data() as Map<String, dynamic>;
                          return ListViewWidget(
                            docId: items[index].id,
                            itemColor: item['itemColor'] ?? '',
                            urlslist: (item['urlImage'] as List<dynamic>)
                                .cast<String>(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
