import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: StreamBuilder(
        stream: firestoreService.getUserCreatedPlans(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                child: ListTile(
                  title: Text(doc["destination"]),
                  subtitle: Text(doc["generatedPlan"]),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
