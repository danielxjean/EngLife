import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eng_life/services/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';


class DatabaseService {

  String uid;

  DatabaseService({this.uid});

  //collection reference
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final _authService = AuthService();

  Future<void> addPhotoToDb(String imageUrl){
    CollectionReference _ref = userCollection.document(this.uid).collection("photos");
    Map map = {'imageUrl': imageUrl};
    return _ref.add(map);
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    StorageReference _storageReference = FirebaseStorage.instance.ref().child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putFile(imageFile);
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  void setUid(String uid){
    this.uid = uid;
  }
  
}
