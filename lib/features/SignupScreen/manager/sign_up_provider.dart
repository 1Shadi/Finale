import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../HomeScreen/home_screen.dart';

class SignupProvider extends ChangeNotifier {
  File? _image;
  bool _isLoading = false;
  final GlobalKey<FormState> _signUpFormKey =
      GlobalKey<FormState>(); // Define signUpFormKey

  File? get image => _image;
  bool get isLoading => _isLoading;
  GlobalKey<FormState> get signUpFormKey =>
      _signUpFormKey; // Getter for signUpFormKey

  void setImage(File? image) {
    _image = image;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> getFromCamera(BuildContext context) async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    // ignore: use_build_context_synchronously
    _cropImage(context, pickedFile!.path);
  }

  Future<void> getFromGallery(BuildContext context) async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    // ignore: use_build_context_synchronously
    _cropImage(context, pickedFile!.path);
  }

  Future<void> _cropImage(BuildContext context, String filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    if (croppedImage != null) {
      setImage(File(croppedImage.path));
    }
  }

  void showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Please choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => getFromCamera(context),
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
                onTap: () => getFromGallery(context),
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

  Future<void> submitFormOnSignUp(
    BuildContext context,
    GlobalKey<FormState> signUpFormKey,
    String name,
    String email,
    String phone,
    String password,
    File? image,
    FirebaseAuth auth,
  ) async {
    setLoading(true);
    try {
      final isValid = signUpFormKey.currentState!.validate();
      if (!isValid) {
        setLoading(false);
        return;
      }
      if (image == null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Please pick an image'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        setLoading(false);
        return;
      }

      final UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );
      final User? user = userCredential.user;
      if (user == null) {
        setLoading(false);
        return;
      }

      final ref = FirebaseStorage.instance
          .ref()
          .child('userImages')
          .child('${user.uid}.jpg');
      await ref.putFile(image);
      final userPhotoUrl = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'userName': name.trim(),
          'id': user.uid,
          'userNumber': phone.trim(),
          'userEmail': email.trim(),
          'userImage': userPhotoUrl,
          'time': DateTime.now(),
          'status': 'approved',
        },
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) =>  HomeScreen()));
    } catch (error) {
      setLoading(false);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(error.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
