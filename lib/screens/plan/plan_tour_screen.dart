import 'package:flutter/material.dart';
import '../../services/gemini_service.dart';
import 'generated_plan_screen.dart';

class PlanTourScreen extends StatefulWidget {
  const PlanTourScreen({super.key});

  @override
  State<PlanTourScreen> createState() => _PlanTourScreenState();
}

class _PlanTourScreenState extends State<PlanTourScreen> {
  final TextEditingController startController = TextEditingController();
  final TextEditingController destController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final TextEditingController passengersController = TextEditingController();

  final GeminiService geminiService = GeminiService();

  bool isLoading = false;

  void generatePlan() async {
    setState(() => isLoading = true);

    try {
      String plan = await geminiService.generateTravelPlan(
        startLocation: startController.text,
        destination: destController.text,
        budgetINR: double.tryParse(budgetController.text) ?? 0,
        durationDays: int.tryParse(daysController.text) ?? 1,
        numberOfPassengers: int.tryParse(passengersController.text) ?? 1,
      );

      setState(() => isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GeneratedPlanScreen(plan: plan)),
      );
    } catch (e) {
      setState(() => isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plan Your Tour")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: startController,
              decoration: const InputDecoration(labelText: "Starting Point"),
            ),
            TextField(
              controller: destController,
              decoration: const InputDecoration(labelText: "Destination"),
            ),
            TextField(
              controller: budgetController,
              decoration: const InputDecoration(labelText: "Budget"),
            ),
            TextField(
              controller: daysController,
              decoration: const InputDecoration(labelText: "Days"),
            ),
            TextField(
              controller: passengersController,
              decoration: const InputDecoration(labelText: "Number of Passengers"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: generatePlan,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Generate Plan"),
            ),
          ],
        ),
      ),
    );
  }
}
