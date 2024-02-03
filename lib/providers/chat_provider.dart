import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_app/constants/firestore_constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_chat.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  final key = encrypt.Key.fromUtf8('H4WtkvK4qyehIe2kjQfH7we1xIHFK67e'); //32 length
  final iv = encrypt.IV.fromUtf8('HgNRbGHbDSz9T0CC');
  ChatProvider({
    required this.prefs,
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  String? getPref(String key) {
    return prefs.getString(key);
  }


  String encryptMessage(String text) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ctr, padding: null));
    final encrypted = encrypter.encrypt(text, iv: iv);
    final ciphertext = encrypted.base64;
    return ciphertext;
  }

  String decryptMessage(String text) {
    final decrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ctr, padding: null));
    final decrypted = decrypter.decryptBytes(encrypt.Encrypted.fromBase64(text), iv: iv);
    final decryptedData = utf8.decode(decrypted);
    return decryptedData;
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  void sendMessage(String content, int type, String groupChatId,
      String currentUserId, String peerId) {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChat.toJson(),
      );
    });
  }
}

class TypeMessage{
  static const text = 0;
  static const image = 1;
  static const sticker= 2;
}
