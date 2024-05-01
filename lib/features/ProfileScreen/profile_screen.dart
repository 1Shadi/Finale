import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/Widgets/global_var.dart';
import '../../core/Widgets/listview.dart';
import '../HomeScreen/home_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfileScreen extends StatefulWidget {
  final String sellerId;

  const ProfileScreen({Key? key, required this.sellerId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
    );
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

  _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(sellerId: widget.sellerId),
      ),
    );
  }

  getResult() {
    FirebaseFirestore.instance
        .collection('items')
        .where('id', isEqualTo: widget.sellerId)
        .where('status', isEqualTo: 'approved')
        .get()
        .then((results) {
      setState(() {
        items = results;
        adUserName = items!.docs[0].get('userName');
        adUserImageUrl = items!.docs[0].get('imgPro');
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getResult();
  }

  QuerySnapshot? items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepOrange,
            Colors.teal,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: _buildBackButton(),
          title: Row(
            children: [
              _buildUserImage(),
              const SizedBox(width: 10),
              Text(adUserName),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editProfile,
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrange,
                  Colors.teal,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('items')
              .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                final items = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = items[index].data() as Map<String, dynamic>;
                    return ListViewWidget(
                      docId: items[index].id,
                      itemColor: item['itemColor'] ?? '',
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
                      urlslist:
                          (item['urlImage'] as List<dynamic>).cast<String>(),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('No items found'),
                );
              }
            } else {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
          },
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final String sellerId;

  const EditProfileScreen({super.key, required this.sellerId});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  File? _image;
  String userPhotoUrl = '';
  late String oldUserPhotoUrl;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: adUserName);
    oldUserPhotoUrl = ''; // Initialize oldUserPhotoUrl
    FirebaseFirestore.instance
        .collection('items')
        .where('id', isEqualTo: widget.sellerId)
        .where('status', isEqualTo: 'approved')
        .get()
        .then((results) {
      setState(() {
        oldUserPhotoUrl = results!.docs[0].get('imgPro');
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _cropImage(pickedFile.path);
    }
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _cropImage(pickedFile.path);
    }
    Navigator.pop(context);
  }

  void _cropImage(String filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    if (croppedImage != null) {
      setState(() {
        _image = File(croppedImage.path);
      });
    }
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String fileName = 'profile_picture_$uid.jpg';

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_pictures/$fileName');

      firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for the upload to complete
      await uploadTask.whenComplete(() {});

      // Get the download URL
      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      throw e; // Rethrow the error to be caught by the caller
    }
  }

  Future<void> updateProfileImageOnExistingPosts(
      String oldImageURL, String newImageURL) async {
    try {
      // Fetch the document snapshots
      final snapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Check if the snapshot has data
      if (snapshot.docs.isNotEmpty) {
        // Iterate through the documents
        for (final doc in snapshot.docs) {
          // Check if the document contains the "userImage" field
          if (doc.data().containsKey('userImage')) {
            // Check if the "userImage" field matches the old profile image URL
            if (doc['userImage'] == oldImageURL) {
              // Update the "userImage" field with the new profile image URL
              await doc.reference.update({'userImage': newImageURL});
            }
          }
        }
      }
    } catch (e) {
      print('Error updating profile image on existing posts: $e');
      // Handle any errors
    }
  }

  void _saveChanges() async {
    try {
      String newName = _nameController.text.trim();
      String oldUserName = FirebaseAuth.instance.currentUser!.displayName ?? '';
      setState(() {
        _isUpdating = true;
      });

      // Update user profile information in Firebase Auth
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        if (_image != null) {
          // Upload the new profile picture and get the download URL
          String imageUrl = await uploadProfilePicture(_image!);
          setState(() {
            userPhotoUrl = imageUrl;
          });
          await currentUser.updatePhotoURL(userPhotoUrl);
        }

        await currentUser.updateProfile(displayName: newName);
      }

      // Update user name and image URL in Firestore users collection
      String uid = currentUser?.uid ?? '';
      Map<String, dynamic> userData = {
        'userName': newName,
      };
      if (userPhotoUrl.isNotEmpty) {
        userData['userImage'] = userPhotoUrl; // Use the userPhotoUrl variable
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(userData);

      // Update user name in Firestore items collection
      await updateProfileImageOnExistingPosts(oldUserPhotoUrl, userPhotoUrl);

      // Update local state
      setState(() {
        // FirebaseAuth.instance.currentUser!.displayName = newName;
        // Remove this line since we already updated the display name using updateProfile method
      });

      // Pop the screen
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors
      print('Error updating profile: $e');
      // Show a snackbar or alert dialog to notify the user about the error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile. Please try again later.'),
        ),
      );
    } finally {
      // Set _isUpdating to false after the update process is complete
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Please choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  _getFromCamera();
                },
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.camera,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      'Camera',
                      style: TextStyle(color: Colors.purple),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  _getFromGallery();
                },
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.image,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      'Gallery',
                      style: TextStyle(color: Colors.purple),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                _showImageDialog(); // Handle the onTap action
              },
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                backgroundImage: _image == null ? null : FileImage(_image!),
                child: _image == null
                    ? const Icon(
                        Icons.camera_enhance,
                        color: Colors.black,
                      )
                    : null,
              ),
            ),
            const Text('Name'),
            TextField(
              controller: _nameController,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUpdating ? null : _saveChanges,
              child: _isUpdating
                  ? const CircularProgressIndicator() // Show loading indicator if updating
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
