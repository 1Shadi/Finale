import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/Widgets/listview.dart';
import '../features/HomeScreen/home_screen.dart';

class SearchProduct extends StatefulWidget {
  const SearchProduct({Key? key}) : super(key: key);

  @override
  State<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  final TextEditingController _searchQueryController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String searchQuery = '';
  bool _isSearching = false;

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search here..',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white, fontSize: 16.0),
      ),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      print(searchQuery);
    });
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _clearSearchQuery();
          },
        ),
        IconButton(
          icon: Icon(Icons.filter_alt),
          onPressed: () async {
            await showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Filter'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Min Price',
                        ),
                      ),
                      TextFormField(
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Max Price',
                        ),
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _startSearch();
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ];
    }
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _addressController.clear();
      _isSearching = false;
    });
  }

  _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  _buildTitle(BuildContext context) {
    return const Text('Search Product');
  }

  _buildBackButton() {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
    );
  }

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
          leading: _isSearching ? const BackButton() : _buildBackButton(),
          title: _isSearching ? _buildSearchField() : _buildTitle(context),
          actions: _buildActions(),
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
        body: _buildFilteredResults()
      ),
    );
  }

  Widget _buildFilteredResults() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          final docs = snapshot.data!.docs.where((doc) {
            final itemModel = doc['itemModel'].toString().toLowerCase();
            final searchQueryLower = searchQuery.toLowerCase();
            return itemModel.contains(searchQueryLower);
          }).toList();

          // Apply additional filtering based on the address if it's provided
          final filteredDocs = docs.where((doc) {
            final address = doc['address'].toString().toLowerCase();
            final filterAddress = _addressController.text.toLowerCase();
            return address.contains(filterAddress);
          }).toList();

          if (filteredDocs.isNotEmpty) {
            return ListView.builder(
              itemCount: filteredDocs.length,
              itemBuilder: (BuildContext context, int index) {
                final item = filteredDocs[index].data();
                final itemColor = item['itemColor'];
                return ListViewWidget(
                  docId: filteredDocs[index].id,
                  itemColor: itemColor is String ? itemColor : '',
                  urlslist: (item['urlImage'] as List<dynamic>).cast<String>(),
                  userImg: item['imgPro'],
                  name: item['userName'],
                  date: item['time'].toDate(),
                  userId: item['id'],
                  itemModel: item['itemModel'],
                  postId: item['postId'],
                  itemPrice: item['itemPrice'],
                  description: item['description'],
                  lat: (item['lat'] as num?)?.toDouble() ?? 0.0,
                  lng: (item['lng'] as num?)?.toDouble() ?? 0.0,
                  address: item['address'],
                  userNumber: item['userNumber'],
                );
              },
            );
          } else {
            return const Center(
              child: Text('No items match the search query and address filter'),
            );
          }
        } else {
          return const Center(
            child: Text('There are no items'),
          );
        }
      },
    );
  }
}
