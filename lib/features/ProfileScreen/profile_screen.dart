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
              icon: Icon(Icons.edit),
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

  const EditProfileScreen({Key? key, required this.sellerId}) : super(key: key);

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
    FirebaseFirestore.instance
        .collection('items')
        .where('id', isEqualTo: widget.sellerId)
        .where('status', isEqualTo: 'approved')
        .get()
        .then((results) {
      oldUserPhotoUrl = results!.docs[0].get('imgPro');
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
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
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
                child: Row(
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
                child: Row(
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

  void _saveChanges() async {
    try {
      String newName = _nameController.text.trim();
      String oldUserName = adUserName;
      setState(() {
        _isUpdating = true;
      });

      // Update user profile information in Firebase Auth
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.updateDisplayName(newName);
        if (_image != null) {
          // Upload the new profile picture and get the download URL
          String imageUrl = await uploadProfilePicture(_image!);
          userPhotoUrl = imageUrl;
          await currentUser.updatePhotoURL(userPhotoUrl);
        }
      }

      // Update user name and image URL in Firestore users collection
      String uid = currentUser?.uid ?? '';
      Map<String, dynamic> userData = {
        'userName': newName,
      };
      if (userPhotoUrl.isNotEmpty) {
        userData['userImage'] = userPhotoUrl;
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).update(userData);

      // Update user name in Firestore items collection
      await updateProfileNameOnExistingPost(oldUserName, newName);

      // Update local state
      setState(() {
        adUserName = newName;
      });

      // Pop the screen
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors
      print('Error updating profile: $e');
      // Show a snackbar or alert dialog to notify the user about the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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

  Future<void> updateProfileNameOnExistingPost(String oldUserName, String newUserName) async {
    try {
      // Fetch the document snapshot
      final snapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Check if the snapshot has data
      if (snapshot.docs.isNotEmpty) {
        // Iterate through the documents
        for (final doc in snapshot.docs) {
          // Check if the document contains the "userName" field
          if (doc.data().containsKey('userName')) {
            // Check if the "userName" field matches the old user name
            if (doc['userName'] == oldUserName) {
              // Update the "userName" field with the new user name
              await doc.reference.update({'userName': newUserName});
            }
          }

          // Check if the document contains the "userImage" field
          if (doc.data().containsKey('userImage')) {
            // Check if the "userImage" field matches the old user image URL
            if (doc['userImage'] == oldUserPhotoUrl) {
              // Update the "userImage" field with the new user image URL
              await doc.reference.update({'userImage': userPhotoUrl});
            }
          }
        }
      }
    } catch (e) {
      print('Error updating profile: $e');
      // Handle any errors
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
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
                    ? Icon(
                        Icons.camera_enhance,
                        color: Colors.black,
                      )
                    : null,
              ),
            ),
            Text('Name'),
            TextField(
              controller: _nameController,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUpdating ? null : _saveChanges,
              child: _isUpdating
                  ? CircularProgressIndicator() // Show loading indicator if updating
                  : Text('Save Changes'),
            ),          ],
        ),
      ),
    );
  }
}
