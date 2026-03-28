import 'package:flutter/material.dart';

class PlanCard extends StatelessWidget {
  final String destination;
  final String budget;
  final String days;

  const PlanCard({
    super.key,
    required this.destination,
    required this.budget,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: ListTile(
        leading: const Icon(Icons.flight, color: Colors.orange),
        title: Text(destination),
        subtitle: Text("₹$budget | $days Days"),
      ),
    );
  }
}
