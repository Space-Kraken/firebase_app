import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/models/product_dao.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseProvider {
  
  late FirebaseFirestore _firestore;
  // late FirebaseStorage _storage;
  late CollectionReference _productsCollection;

  FirebaseProvider() {
    _firestore = FirebaseFirestore.instance;
    // _storage = FirebaseStorage.instance;
    _productsCollection = _firestore.collection('products');
  }

  Future<void> saveProduc(ProductDAO objDAO) => _productsCollection.add(objDAO.toMap());

  Future<void> updateProduct(ProductDAO objDAO, String documentID) {
    return _productsCollection.doc(documentID).update(objDAO.toMap());
  }

  Future<void> deleteProducts(String documentID){
    return _productsCollection.doc(documentID).delete();
  }

  UploadTask? uploadImage(File image, String fileUri) {
    // File image = File(filePath);
    try{
      final uri = FirebaseStorage.instance.ref(fileUri);
      return uri.putFile(image);
    } on FirebaseException catch(e){
      return null;
    }
  }

  Stream<QuerySnapshot> getAllProducts(){
    return _productsCollection.snapshots();
  }
}