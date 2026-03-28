import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import '../../models/travel_plan_model.dart';
import '../../services/gemini_service.dart';
import '../../services/firestore_service.dart';
import '../../services/maps_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class CreateTravelPlanScreen extends StatefulWidget {
  const CreateTravelPlanScreen({super.key});

  @override
  State<CreateTravelPlanScreen> createState() => _CreateTravelPlanScreenState();
}

class _CreateTravelPlanScreenState extends State<CreateTravelPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startLocationController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _durationController = TextEditingController();
  final _passengersController = TextEditingController();

  final GeminiService _geminiService = GeminiService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _generatedPlan;
  Map<String, dynamic>? _planData; // Store the plan data structure

  // Duration unit selection
  String _selectedDurationUnit = 'days';
  final List<String> _durationUnits = [
    'mins',
    'hours',
    'days',
    'weeks',
    'months',
  ];

  @override
  void dispose() {
    _startLocationController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _durationController.dispose();
    _passengersController.dispose();
    super.dispose();
  }

  /// Convert duration to days based on selected unit
  int _convertToDays(int value) {
    switch (_selectedDurationUnit) {
      case 'mins':
        return (value / (24 * 60)).ceil();
      case 'hours':
        return (value / 24).ceil();
      case 'days':
        return value;
      case 'weeks':
        return value * 7;
      case 'months':
        return value * 30;
      default:
        return value;
    }
  }

  /// Create fallback route with intermediate points
  List<LatLngPoint> _createFallbackRoute(LatLng start, LatLng end) {
    List<LatLngPoint> points = [];

    // Start point
    points.add(
      LatLngPoint(latitude: start.latitude, longitude: start.longitude),
    );

    // Create intermediate points along the line
    const int intermediatePoints = 5;
    for (int i = 1; i < intermediatePoints; i++) {
      final progress = i / intermediatePoints;
      final lat = start.latitude + (end.latitude - start.latitude) * progress;
      final lng =
          start.longitude + (end.longitude - start.longitude) * progress;
      points.add(LatLngPoint(latitude: lat, longitude: lng));
    }

    // End point
    points.add(LatLngPoint(latitude: end.latitude, longitude: end.longitude));

    return points;
  }

  /// Generate travel plan using Gemini
  Future<void> _generatePlan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final durationValue = int.parse(_durationController.text.trim());
      final durationDays = _convertToDays(durationValue);
      final numberOfPassengers = int.parse(_passengersController.text.trim());

      // Call the new method that generates all sections in parallel
      final planData = await _geminiService.generateCompleteTravelPlan(
        startLocation: _startLocationController.text.trim(),
        destination: _destinationController.text.trim(),
        budgetINR: double.parse(_budgetController.text.trim()),
        durationDays: durationDays,
        numberOfPassengers: numberOfPassengers,
      );

      // Store the complete plan data
      setState(() {
        _generatedPlan = jsonEncode(planData);
        _planData = planData;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Travel plan generated successfully!"),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Save the generated plan to Firestore
  Future<void> _savePlan() async {
    if (_generatedPlan == null) return;

    setState(() => _isLoading = true);

    try {
      final destination = _destinationController.text.trim();
      final startLocation = _startLocationController.text.trim();
      final budget = double.parse(_budgetController.text.trim());
      final durationValue = int.parse(_durationController.text.trim());
      final duration = _convertToDays(durationValue);
      final numberOfPassengers = int.parse(_passengersController.text.trim());

      // Get coordinates with fallback
      LatLng? startCoords = await MapsService.getCoordinatesFromAddress(
        startLocation,
      );
      LatLng? destCoords = await MapsService.getCoordinatesFromAddress(
        destination,
      );

      // Fallback to default India coordinates if geocoding fails
      startCoords ??= const LatLng(20.5937, 78.9629);
      destCoords ??= const LatLng(28.6139, 77.2090);

      List<LatLngPoint> routePoints = [];

      // Try to get polyline points from API
      final polylinePoints = await MapsService.getPolylinePoints(
        start: startCoords,
        end: destCoords,
      );

      if (polylinePoints.isNotEmpty) {
        // Use API polyline points if available
        routePoints = polylinePoints
            .map(
              (latlng) => LatLngPoint(
                latitude: latlng.latitude,
                longitude: latlng.longitude,
              ),
            )
            .toList();
      } else {
        // Fallback: Create route points with intermediate stops
        routePoints = _createFallbackRoute(startCoords, destCoords);
      }

      // Ensure we have at least start and end points
      if (routePoints.isEmpty) {
        routePoints = [
          LatLngPoint(
            latitude: startCoords.latitude,
            longitude: startCoords.longitude,
          ),
          LatLngPoint(
            latitude: destCoords.latitude,
            longitude: destCoords.longitude,
          ),
        ];
      }

      // Extract popular places from the generated plan
      List<PopularPlace> popularPlaces = [];
      try {
        final placeDetails = await _geminiService.extractPlaceDetails(
          _generatedPlan!,
          destination,
        );

        // Convert place names to coordinates
        for (var place in placeDetails) {
          try {
            final placeName = place['name'] as String? ?? 'Unknown';
            final description = place['description'] as String? ?? '';
            final category = place['category'] as String? ?? 'attraction';
            final imageUrl =
                place['imageUrl']
                    as String?; // Get the image URL from Gemini service

            // Try to get coordinates for the place
            LatLng? placeCoords = await MapsService.getCoordinatesFromAddress(
              '$placeName, $destination',
            );

            if (placeCoords != null) {
              popularPlaces.add(
                PopularPlace(
                  name: placeName,
                  description: description,
                  latitude: placeCoords.latitude,
                  longitude: placeCoords.longitude,
                  category: category,
                  imageUrl: imageUrl, // Include the image URL
                ),
              );
            }
          } catch (e) {
            print('Error processing place $place: $e');
          }
        }
      } catch (e) {
        print('Error extracting popular places: $e');
        // Continue without popular places if extraction fails
      }

      final travelPlan = TravelPlan(
        id: const Uuid().v4(),
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        userName: FirebaseAuth.instance.currentUser?.displayName ?? 'User',
        startLocation: startLocation,
        destination: destination,
        budget: budget,
        duration: duration,
        numberOfPassengers: numberOfPassengers,
        description: _generatedPlan!,
        routePoints: routePoints,
        popularPlaces: popularPlaces,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // Store the 10 cards from the plan data
        dayWisePlans: _planData?['dayWisePlans'] ?? [],
        placesList: _planData?['placesList'] ?? '',
        dayWiseBudget: _planData?['dayWiseBudget'] ?? '',
        travelRoute: _planData?['travelRoute'] ?? '',
        transportation: _planData?['transportation'] ?? '',
        hotelsRestaurants: _planData?['hotelsRestaurants'] ?? '',
      );

      final planId = await _firestoreService.saveTravelPlan(travelPlan);

      // Add the plan to user's created plans list
      await _firestoreService.addCreatedPlanToUser(planId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Travel plan saved successfully!"),
          backgroundColor: AppColors.success,
        ),
      );

      // Clear form and generated plan
      _formKey.currentState!.reset();
      setState(() => _generatedPlan = null);
      _startLocationController.clear();
      _destinationController.clear();
      _budgetController.clear();
      _durationController.clear();
      _passengersController.clear();

      // Navigate to plan details
      if (!mounted) return;
      Navigator.of(context).pushNamed('/plan-details', arguments: planId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving plan: ${e.toString()}"),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Travel Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _startLocationController,
                    label: 'Starting Location',
                    hint: 'e.g., Mumbai',
                    prefixIcon: Icons.location_on_outlined,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _destinationController,
                    label: 'Destination',
                    hint: 'e.g., Goa',
                    prefixIcon: Icons.location_on_outlined,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _budgetController,
                    label: 'Budget (in INR)',
                    hint: 'e.g., 50000',
                    prefixIcon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (double.tryParse(value!) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passengersController,
                    label: 'Number of Passengers',
                    hint: 'e.g., 4',
                    prefixIcon: Icons.people_outline,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (int.tryParse(value!) == null) {
                        return 'Enter a valid number';
                      }
                      if (int.parse(value) < 1) {
                        return 'Minimum 1 passenger required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Duration with Unit Selector
                  Row(
                    children: [
                      // Duration Input
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          controller: _durationController,
                          label: 'Duration',
                          hint: 'e.g., 5',
                          prefixIcon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            if (int.tryParse(value!) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Unit Dropdown
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightGrey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedDurationUnit,
                            isExpanded: true,
                            underline: const SizedBox(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            items: _durationUnits.map((unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedDurationUnit = value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Generate Plan with AI',
                      onPressed: _generatePlan,
                      isLoading: _isLoading && _generatedPlan == null,
                    ),
                  ),
                ],
              ),
            ),

            // Generated Plan Display
            if (_generatedPlan != null) ...[
              const SizedBox(height: 32),
              Divider(color: AppColors.lightGrey),
              const SizedBox(height: 16),
              Text(
                'Your Travel Plan',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.veryLightGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Text(
                  _generatedPlan!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Save Plan',
                  onPressed: _savePlan,
                  isLoading: _isLoading,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Edit & Regenerate',
                  onPressed: () => setState(() => _generatedPlan = null),
                  isOutlined: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
