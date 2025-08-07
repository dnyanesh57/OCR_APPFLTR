import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import 'upload_log_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late Future<Map<String, dynamic>?> _userDataFuture;
  String? _selectedSiteId;
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userDataFuture = Provider.of<FirebaseService>(context, listen: false).getUserData();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null || _selectedSiteId == null) return;
    setState(() => _isUploading = true);
    final error = await Provider.of<FirebaseService>(context, listen: false).uploadImage(_imageFile!, _selectedSiteId!);
    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload successful!')));
        setState(() => _imageFile = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $error')));
      }
      setState(() => _isUploading = false);
    }
  }

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Could not load user data."));
          }
          final siteList = List<String>.from(snapshot.data!['sites'] ?? []);
          if (_selectedSiteId == null && siteList.isNotEmpty) {
            _selectedSiteId = siteList[0];
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (siteList.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: _selectedSiteId,
                      items: siteList.map((site) => DropdownMenuItem(value: site, child: Text(site))).toList(),
                      onChanged: (value) => setState(() => _selectedSiteId = value),
                      decoration: const InputDecoration(labelText: "Select Site"),
                    ),
                  const SizedBox(height: 20),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: _imageFile != null ? Image.file(_imageFile!, fit: BoxFit.cover) : const Center(child: Text("No image selected")),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(icon: const Icon(Icons.camera_alt), label: const Text('Camera'), onPressed: () => _pickImage(ImageSource.camera)),
                      ElevatedButton.icon(icon: const Icon(Icons.photo_library), label: const Text('Gallery'), onPressed: () => _pickImage(ImageSource.gallery)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (_isUploading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(onPressed: _uploadImage, child: const Text('Upload and Process')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
