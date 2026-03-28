import 'package:flutter/material.dart';

class CustomizePlanScreen extends StatefulWidget {
  final String plan;
  const CustomizePlanScreen({super.key, required this.plan});

  @override
  State<CustomizePlanScreen> createState() =>
      _CustomizePlanScreenState();
}

class _CustomizePlanScreenState extends State<CustomizePlanScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: widget.plan);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customize Plan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
                child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              decoration:
                  const InputDecoration(border: OutlineInputBorder()),
            )),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, controller.text);
                },
                child: const Text("Save Changes"))
          ],
        ),
      ),
    );
  }
}
