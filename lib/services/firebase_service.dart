import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;
    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    return doc.data();
  }

  // --- MODIFIED FUNCTION WITH PATH SANITIZATION ---
  Future<String?> uploadImage(File imageFile, String siteId) async {
    if (currentUser == null) return "User not logged in.";
    
    try {
      final fileName = '${DateTime.now().toIso8601String()}.jpg';
      
      // --- THIS IS THE CRITICAL FIX ---
      // Replace invalid path characters like '/' with an underscore '_'
      final sanitizedSiteId = siteId.replaceAll(RegExp(r'[/\\]'), '_');
      
      // This now creates a valid, safe path for Firebase Storage
      final storagePath = 'site_images/$sanitizedSiteId/${currentUser!.uid}/$fileName';
      final ref = _storage.ref().child(storagePath);
      
      UploadTask uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('testDocuments').add({
        'userId': currentUser!.uid,
        'siteId': siteId, // We still save the original, human-readable siteId
        'storagePath': storagePath,
        'imageUrl': downloadUrl,
        'status': 'uploaded',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null; // Success
    } on FirebaseException catch (e) {
      debugPrint("Firebase Error Occurred: ${e.code} - ${e.message}");
      if (e.code == 'permission-denied') {
        return "Permission Denied. Please check your Firebase Storage rules and ensure your app's SHA-1 key is correct in Firebase.";
      }
      return "Firebase Error: ${e.message}";
    } catch (e) {
      debugPrint("A general error occurred during upload: $e");
      return e.toString();
    }
  }

  Stream<QuerySnapshot> getUploadLog() {
    if (currentUser == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('testDocuments')
        .where('userId', isEqualTo: currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }
}
