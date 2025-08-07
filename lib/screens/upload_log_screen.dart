// (Imports remain the same)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import 'upload_log_screen.dart';

class UploadScreen extends StatefulWidget {
// ... (rest of the class is unchanged)
// ...

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UploadLogScreen())),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: firebaseService.signOut),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          // ... (FutureBuilder logic is unchanged)
          // ...

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ... (Dropdown and Image container are unchanged)
                  // ...
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (_isUploading)
                    const Center(child: CircularProgressIndicator())
                  else
                    // This button now uses the accent color from your theme
                    ElevatedButton(
                      onPressed: _uploadImage,
                      child: const Text('Upload and Process'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
