import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';

class UploadLogScreen extends StatelessWidget {
  const UploadLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Uploads'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseService.getUploadLog(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No recent uploads found.'));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          final documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index].data() as Map<String, dynamic>;
              final timestamp = doc['createdAt'] as Timestamp?;
              final date = timestamp != null
                  ? DateFormat('dd-MM-yyyy, hh:mm a').format(timestamp.toDate())
                  : 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: doc['imageUrl'] != null
                      ? Image.network(
                          doc['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            return progress == null ? child : const CircularProgressIndicator();
                          },
                        )
                      : const Icon(Icons.image_not_supported, size: 50),
                  title: Text(doc['siteId'] ?? 'Unknown Site'),
                  subtitle: Text('Uploaded on: $date\nStatus: ${doc['status'] ?? 'N/A'}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
