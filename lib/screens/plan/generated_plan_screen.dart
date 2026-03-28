import 'package:flutter/material.dart';
import 'customize_plan_screen.dart';

class GeneratedPlanScreen extends StatelessWidget {
  final String plan;
  const GeneratedPlanScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generated Plan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: Text(plan))),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              CustomizePlanScreen(plan: plan)));
                },
                child: const Text("Customize Plan"))
          ],
        ),
      ),
    );
  }
}
