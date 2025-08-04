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
  // State variables
  String? _selectedSiteId;
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // This future will hold the user's data once loaded
  late Future<Map<String, dynamic>?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    // Load user data when the screen is first built
    _userDataFuture = Provider.of<FirebaseService>(context, listen: false).getUserData();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image first.')));
      return;
    }
    if (_selectedSiteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a site.')));
      return;
    }

    setState(() => _isUploading = true);
    final error = await Provider.of<FirebaseService>(context, listen: false).uploadImage(_imageFile!, _selectedSiteId!);
    
    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload successful!')));
        setState(() {
          _imageFile = null; // Clear image on success
        });
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
          // Case 1: Still loading user data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Case 2: Error loading data
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Error: Could not load user data.'));
          }

          // Case 3: Data loaded successfully
          final userData = snapshot.data!;
          
          // --- ROBUST DATA CHECK ---
          // Explicitly check if the 'sites' field exists and is a list.
          if (userData['sites'] == null || userData['sites'] is! List) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Configuration Error: The "sites" field is missing or is not an array in your user profile in the Firestore database.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          // --- END OF CHECK ---

          final List<String> siteList = (userData['sites'] as List<dynamic>).map((site) => site.toString()).toList();

          // Set the initial selected site if it hasn't been set yet
          if (_selectedSiteId == null && siteList.isNotEmpty) {
            _selectedSiteId = siteList[0];
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (siteList.isEmpty)
                    const Text('No sites assigned to this user.', textAlign: TextAlign.center)
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedSiteId,
                      decoration: const InputDecoration(labelText: 'Select Site', border: OutlineInputBorder()),
                      items: siteList.map((String site) {
                        return DropdownMenuItem<String>(value: site, child: Text(site));
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() => _selectedSiteId = newValue);
                      },
                    ),
                  const SizedBox(height: 20),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : const Center(child: Text('No image selected')),
                  ),
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _uploadImage,
                      child: const Text('Upload and Process', style: TextStyle(color: Colors.white)),
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
