import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../ForgetPassword/forget_password.dart';
import '../../core/DialogBox/error_dialog.dart';
import '../../core/Widgets/already_have_an_account_check.dart';
import '../../core/Widgets/rounded_button.dart';
import '../../core/Widgets/rounded_input_field.dart';
import '../../core/Widgets/rounded_password_field.dart';
import '../HomeScreen/home_screen.dart';
import '../LoginScreen/login_screen.dart';
import 'background.dart';

class SignupBody extends StatefulWidget {
  @override
  State<SignupBody> createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody> {
  String userPhotoUrl = '';
  File? _image;
  bool _isloading = false;

  final signUpFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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

  void submitFormOnSignUp() async {
    final isValid = signUpFormKey.currentState!.validate();
    if (isValid) {
      if (_image == null) {
        showDialog(
          context: context,
          builder: (context) {
            return ErrorAlertDialog(
              message: 'Please pick an image',
            );
          },
        );
        return;
      }
      setState(() {
        _isloading = true;
      });
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text.trim(),
        );
        final User? user = _auth.currentUser;
        String uid = user!.uid;

        final ref = FirebaseStorage.instance.ref().child('userImages').child('$uid.jpg');
        await ref.putFile(_image!);
        userPhotoUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {
            'userName': _nameController.text.trim(),
            'id': uid,
            'userNumber': _phoneController.text.trim(),
            'userEmail': _emailController.text.trim(),
            'userImage': userPhotoUrl,
            'time': DateTime.now(),
            'status': 'approved',
          },
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } catch (error) {
        setState(() {
          _isloading = false;
        });
        ErrorAlertDialog(message: error.toString());
      }
      setState(() {
        _isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SignupBackground(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: signUpFormKey,
              child: InkWell(
                onTap: () {
                  _showImageDialog(); // Handle the onTap action
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white24,
                  backgroundImage: _image == null ? null : FileImage(_image!),
                  child: _image == null
                      ? Icon(
                    Icons.camera_enhance,
                    size: screenWidth * 0.18,
                    color: Colors.black,
                  )
                      : null,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02,),
            RoundedInputField(
                hintText: 'Name',
                icon: Icons.person,
                onChanged: (value) {
                  _nameController.text = value;
                }),
            RoundedInputField(
                hintText: 'Email',
                icon: Icons.person,
                onChanged: (value) {
                  _emailController.text = value;
                }),
            RoundedInputField(
                hintText: 'Phone Number',
                icon: Icons.phone_android,
                onChanged: (value) {
                  _phoneController.text = value;
                }),
            RoundedPasswordField(
              onChanged: (value) {
                _passwordController.text = value;
              },
            ),
            const SizedBox(height: 5,),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPassword()));
                },
                child: const Text(
                  'Forget Password',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            _isloading
                ? Center(
              child: Container(
                width: 70,
                height: 70,
                child: const CircularProgressIndicator(),
              ),
            )
                : RoundedButton(
              text: 'SIGNUP',
              press: () {
                submitFormOnSignUp();
              },
            ),
            SizedBox(height: screenHeight * 0.03,),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}


