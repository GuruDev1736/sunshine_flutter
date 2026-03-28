import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/travel_plan_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class BrowsePlansScreen extends StatefulWidget {
  const BrowsePlansScreen({super.key});

  @override
  State<BrowsePlansScreen> createState() => _BrowsePlansScreenState();
}

class _BrowsePlansScreenState extends State<BrowsePlansScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _showFilters = false;
  double _maxBudget = 500000;
  int _maxDuration = 30;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearch(String query) {
    setState(() => _searchQuery = query.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Travel Plans'), elevation: 0),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _updateSearch,
                  decoration: InputDecoration(
                    hintText: 'Search by destination...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _updateSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Toggle
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _showFilters = !_showFilters),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _showFilters
                                ? AppColors.yellow.withAlpha(
                                    (0.2 * 255).toInt(),
                                  )
                                : AppColors.veryLightGrey,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _showFilters
                                  ? AppColors.yellow
                                  : AppColors.lightGrey,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.tune,
                                color: _showFilters
                                    ? AppColors.orange
                                    : AppColors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Filters',
                                style: TextStyle(
                                  color: _showFilters
                                      ? AppColors.orange
                                      : AppColors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filters Panel
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Budget Filter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Max Budget: ₹${_maxBudget.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Slider(
                        value: _maxBudget,
                        min: 10000,
                        max: 500000,
                        divisions: 49,
                        activeColor: AppColors.darkOrange,
                        onChanged: (value) {
                          setState(() => _maxBudget = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Duration Filter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Max Duration: $_maxDuration days',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Slider(
                        value: _maxDuration.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        activeColor: AppColors.orange,
                        onChanged: (value) {
                          setState(() => _maxDuration = value.toInt());
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

          // Plans List
          Expanded(
            child: _searchQuery.isEmpty
                ? StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getAllTravelPlans(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return CustomErrorWidget(
                          message: snapshot.error.toString(),
                          onRetry: () => setState(() {}),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingWidget(
                          message: 'Loading travel plans...',
                        );
                      }

                      final plans = snapshot.data?.docs ?? [];

                      if (plans.isEmpty) {
                        return EmptyStateWidget(
                          title: 'No Plans Found',
                          message: 'Try adjusting your search or filters',
                          icon: Icons.map_outlined,
                        );
                      }

                      return _buildPlansList(plans, context);
                    },
                  )
                : StreamBuilder<List<DocumentSnapshot>>(
                    stream: _firestoreService
                        .searchTravelPlansByDestination(_searchQuery),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return CustomErrorWidget(
                          message: snapshot.error.toString(),
                          onRetry: () => setState(() {}),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingWidget(
                          message: 'Loading travel plans...',
                        );
                      }

                      final plans = snapshot.data ?? [];

                      if (plans.isEmpty) {
                        return EmptyStateWidget(
                          title: 'No Plans Found',
                          message: 'Try adjusting your search or filters',
                          icon: Icons.map_outlined,
                        );
                      }

                      return _buildPlansList(plans, context);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList(
    List<DocumentSnapshot> plans,
    BuildContext context,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final doc = plans[index];
        final plan = TravelPlan.fromMap({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });

        // Apply case-insensitive destination filter
        if (_searchQuery.isNotEmpty &&
            !plan.destination
                .toLowerCase()
                .contains(_searchQuery)) {
          return const SizedBox.shrink();
        }

        // Apply budget and duration filters
        if (plan.budget > _maxBudget ||
            plan.duration > _maxDuration) {
          return const SizedBox.shrink();
        }

        return PlanCard(
          planId: plan.id,
          destination: plan.destination,
          userName: plan.userName,
          startLocation: plan.startLocation,
          budget: plan.budget,
          duration: plan.duration,
          rating: plan.averageRating,
          reviewCount: plan.reviewCount,
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed('/plan-details', arguments: plan.id);
          },
          onSave: () {
            // TODO: Implement save functionality
          },
        );
      },
    );
  }
}
