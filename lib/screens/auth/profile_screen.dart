import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/travel_plan_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              if (!mounted) return;
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _editProfile(UserModel user) {
    Navigator.of(context).pushNamed('/edit-profile', arguments: user);
  }

  void _showAboutUsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkOrange,
                  AppColors.orange,
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'About Us',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sunshine Holiday Packages',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your ultimate travel companion for planning unforgettable journeys. Discover, create, and share amazing travel experiences with our community.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withAlpha((0.9 * 255).toInt()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: AppColors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Version 1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withAlpha((0.8 * 255).toInt()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTermsAndConditionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkOrange,
                  AppColors.orange,
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: AppColors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Terms & Conditions',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '1. User Agreement',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By using Sunshine Holiday Packages, you agree to comply with our terms and conditions.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withAlpha((0.9 * 255).toInt()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '2. Privacy Policy',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We are committed to protecting your personal information and privacy.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withAlpha((0.9 * 255).toInt()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '3. Usage Rights',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Users may use this service for personal travel planning purposes only.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withAlpha((0.9 * 255).toInt()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deletePlan(String planId, String planName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: Text(
          'Are you sure you want to delete "$planName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                // Showing loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deleting plan...'),
                    duration: Duration(seconds: 2),
                  ),
                );

                await _firestoreService.deleteTravelPlan(planId);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plan deleted successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
                // Refresh the profile
                setState(() {});
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting plan: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unsavePlan(String planId, String planName) async {
    try {
      await _firestoreService.removeSavedPlan(planId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan removed from saved!'),
          backgroundColor: AppColors.success,
        ),
      );
      // Refresh the profile
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing plan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              if (value == 'aboutUs') {
                _showAboutUsDialog();
              } else if (value == 'termsAndConditions') {
                _showTermsAndConditionsDialog();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'aboutUs',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 12),
                    Text('About Us'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'termsAndConditions',
                child: Row(
                  children: [
                    Icon(Icons.description_outlined),
                    SizedBox(width: 12),
                    Text('Terms & Conditions'),
                  ],
                ),
              ),
            ],
            onCanceled: () {},
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _firestoreService.getCurrentUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading profile...');
          }

          if (snapshot.hasError) {
            return CustomErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () => setState(() {}),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return const EmptyStateWidget(
              title: 'Profile Not Found',
              message: 'Unable to load your profile',
              icon: Icons.person_outline,
            );
          }

          return Column(
            children: [
              // Profile Header
              Container(
                color: AppColors.darkOrange,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.white,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkOrange,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withAlpha((0.8 * 255).toInt()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Edit Profile',
                        onPressed: () => _editProfile(user),
                        backgroundColor: AppColors.yellow,
                        textColor: AppColors.black,
                      ),
                    ],
                  ),
                ),
              ),

              // Statistics
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.veryLightGrey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Plans Created', user.createdPlanIds.length),
                    _buildStatCard('Plans Saved', user.savedPlanIds.length),
                    _buildStatCard(
                      'Rating',
                      user.averageRating.toStringAsFixed(1),
                    ),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppColors.darkOrange,
                unselectedLabelColor: AppColors.grey,
                indicatorColor: AppColors.darkOrange,
                tabs: const [
                  Tab(text: 'My Plans'),
                  Tab(text: 'Saved Plans'),
                ],
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // My Plans Tab
                    _buildMyPlansTab(user),
                    // Saved Plans Tab
                    _buildSavedPlansTab(user),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, dynamic value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.darkOrange),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  String _getProfileErrorMessage(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.contains('PERMISSION_DENIED') ||
        errorStr.contains('failed-precondition')) {
      return 'Unable to access your plans. This might be a Firestore index issue. If this persists, try logging out and back in.';
    } else if (errorStr.contains('Network')) {
      return 'Network connection error. Please check your internet connection.';
    } else if (errorStr.contains('requires an index')) {
      return 'Firestore is creating an index for your data. This usually takes a few moments. Please try again.';
    } else {
      return 'Unable to load your plans. Please try again later.';
    }
  }

  Widget _buildMyPlansTab(UserModel user) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getUserCreatedPlans(),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const LoadingWidget();
        }

        // Handle error state but check if we have data
        if (snapshot.hasError && !snapshot.hasData) {
          // Log the error for debugging
          print('My Plans Error: ${snapshot.error}');
          print('Stack trace: ${snapshot.stackTrace}');

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getProfileErrorMessage(snapshot.error),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('Try Again'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Firestore Index Issue'),
                              content: const Text(
                                'Your data might require a Firestore composite index. '
                                'Usually this resolves automatically within a few minutes. '
                                'Try refreshing the app in a few moments.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Need Help?'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        final plans = snapshot.data?.docs ?? [];

        if (plans.isEmpty) {
          return EmptyStateWidget(
            title: 'No Plans Yet',
            message: 'Start creating travel plans and explore the world',
            icon: Icons.add_location_alt_outlined,
            actionLabel: 'Create Plan',
            onActionPressed: () => Navigator.pushNamed(context, '/create-plan'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length + 1,
          itemBuilder: (context, index) {
            // Show logout button at the end
            if (index == plans.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              );
            }

            final doc = plans[index];
            final plan = TravelPlan.fromMap({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            });

            return Stack(
              children: [
                PlanCard(
                  planId: plan.id,
                  destination: plan.destination,
                  userName: plan.userName,
                  startLocation: plan.startLocation,
                  budget: plan.budget,
                  duration: plan.duration,
                  rating: plan.averageRating,
                  reviewCount: plan.reviewCount,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/plan-details',
                      arguments: plan.id,
                    );
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: () => _deletePlan(plan.id, plan.destination),
                    tooltip: 'Delete plan',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSavedPlansTab(UserModel user) {
    if (user.savedPlanIds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: EmptyStateWidget(
                title: 'No Saved Plans',
                message: 'Browse and save plans to view them here',
                icon: Icons.bookmark_outline,
                actionLabel: 'Browse Plans',
                onActionPressed: () => Navigator.pushNamed(context, '/browse'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: user.savedPlanIds.length + 1,
      itemBuilder: (context, index) {
        // Show logout button at the end
        if (index == user.savedPlanIds.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          );
        }

        final planId = user.savedPlanIds[index];
        return FutureBuilder<TravelPlan?>(
          future: _firestoreService.getTravelPlanById(planId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LoadingWidget(),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.warning_outlined, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plan Unavailable',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'This saved plan could not be loaded',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plan Not Found',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'This plan may have been deleted',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final plan = snapshot.data!;
            return Stack(
              children: [
                PlanCard(
                  planId: plan.id,
                  destination: plan.destination,
                  userName: plan.userName,
                  startLocation: plan.startLocation,
                  budget: plan.budget,
                  duration: plan.duration,
                  rating: plan.averageRating,
                  reviewCount: plan.reviewCount,
                  isSaved: true,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/plan-details',
                      arguments: plan.id,
                    );
                  },
                  onSave: () => _unsavePlan(plan.id, plan.destination),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: () => _unsavePlan(plan.id, plan.destination),
                    tooltip: 'Unsave plan',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
