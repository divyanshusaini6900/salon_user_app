import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService(this._storage);

  final FirebaseStorage _storage;

  Future<String> uploadSelfie({required String userId, required File file}) async {
    final ref = _storage.ref('user_uploads/$userId/selfies/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}
