import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/providers/firebase_provider.dart';
import 'package:firebase_app/screens/add_product_screen.dart';
import 'package:firebase_app/views/add_product_form.dart';
import 'package:firebase_app/views/card_product.dart';
import 'package:flutter/material.dart';

class ListProducts extends StatefulWidget {
  const ListProducts({Key? key}) : super(key: key);

  @override
  _ListProductsState createState() => _ListProductsState();
}

class _ListProductsState extends State<ListProducts> {
  
  late FirebaseProvider _firebaseProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseProvider = FirebaseProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigator.pushNamed(context, 'add-product');
              showModalBottomSheet(
                context: context,
                enableDrag: true,
                isDismissible: true,
                useRootNavigator: true,
                isScrollControlled: true, 
                builder: (ctx) => AddProductForm()
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firebaseProvider.getAllProducts(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document){
                return CardProduct(productDocument: document);
            }).toList()
          );
        }
      ),
    );
  }
}