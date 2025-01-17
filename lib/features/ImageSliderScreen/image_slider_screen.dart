import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tabeeby_app/features/navbar/navbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../HomeScreen/home_screen.dart';
import '../chats/chat.dart';

class ImageSliderScreen extends StatefulWidget {
  final String currentUser;
  final String userId;
  final String title;
  final String itemColor, userNumber, description, address, itemPrice;
  final double lat, lng;
  final List<String> urlslist;
  const ImageSliderScreen({super.key,
    required this.title,
    required this.urlslist,
    required this.itemColor,
    required this.userNumber,
    required this.description,
    required this.address,
    required this.itemPrice,
    required this.lat,
    required this.lng, required this.userId, required this.currentUser,
  });

  @override
  State<ImageSliderScreen> createState() => _ImageSliderScreenState();
}

class _ImageSliderScreenState extends State<ImageSliderScreen> with SingleTickerProviderStateMixin {
  late List<String> links;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  String? url;


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
          title: Text(
            widget.title,
            style: const TextStyle(fontFamily: 'Varela', letterSpacing: 2.0),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NavBar(currentUserId: widget.userId)));
            },
            icon: const Icon(Icons.arrow_back, color: Colors.teal),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 6.0, right: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_pin, color: Colors.black54),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        widget.address,
                        textAlign: TextAlign.justify,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(fontFamily: 'Varela', letterSpacing: 2.0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                height: size.height * 0.5,
                width: size.width,
                child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.urlslist.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            child: Image.network(
                              widget.urlslist[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    )

                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Center(
                  child: Text(
                    '\$ ${widget.itemPrice}',
                    style: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 2.0,
                      fontFamily: 'Bebas',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone_android),
                        const SizedBox(width: 10.0),
                        Text(widget.userNumber),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  widget.description,
                  textAlign: TextAlign.justify,
                  style:  TextStyle(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 20.0,),
              Visibility(
                visible: widget.userId!=widget.currentUser,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 368),
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to chat screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              currentUserId: widget.currentUser,
                              chatUserId: widget.userId,
                            ),
                          ),
                        );
                      },

                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.black54,),
                      ),
                      child: const Text("chat with seller ",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20,),

            ],
          ),
        ),
      ),
    );
  }
}
