import 'package:cloud_firestore/cloud_firestore.dart';

class TravelPlan {
  final String id;
  final String userId;
  final String userName;
  final String startLocation;
  final String destination;
  final double budget; // in INR
  final int duration; // in days
  final int numberOfPassengers; // number of travelers
  final String description;
  final List<String> highlights;
  final List<PopularPlace> popularPlaces;
  final List<LatLngPoint> routePoints;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double averageRating;
  final int reviewCount;
  final List<String> dayWiseBreakdown;
  
  // New 10-card structure
  final List<String> dayWisePlans; // Cards 1-5: Day-by-day detailed plans
  final String placesList; // Card 6: Places to visit
  final String dayWiseBudget; // Card 7: Day-wise budget breakdown
  final String travelRoute; // Card 8: Travel route progression
  final String transportation; // Card 9: Transportation comparison
  final String hotelsRestaurants; // Card 10: Hotels and restaurants

  TravelPlan({
    required this.id,
    required this.userId,
    required this.userName,
    required this.startLocation,
    required this.destination,
    required this.budget,
    required this.duration,
    required this.numberOfPassengers,
    required this.description,
    this.highlights = const [],
    this.popularPlaces = const [],
    this.routePoints = const [],
    required this.createdAt,
    required this.updatedAt,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.dayWiseBreakdown = const [],
    this.dayWisePlans = const [],
    this.placesList = '',
    this.dayWiseBudget = '',
    this.travelRoute = '',
    this.transportation = '',
    this.hotelsRestaurants = '',
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "userName": userName,
      "startLocation": startLocation,
      "destination": destination,
      "budget": budget,
      "duration": duration,
      "numberOfPassengers": numberOfPassengers,
      "description": description,
      "highlights": highlights,
      "popularPlaces": popularPlaces.map((p) => p.toMap()).toList(),
      "routePoints": routePoints.map((r) => r.toMap()).toList(),
      "createdAt": Timestamp.fromDate(createdAt),
      "updatedAt": Timestamp.fromDate(updatedAt),
      "averageRating": averageRating,
      "reviewCount": reviewCount,
      "dayWiseBreakdown": dayWiseBreakdown,
      "dayWisePlans": dayWisePlans,
      "placesList": placesList,
      "dayWiseBudget": dayWiseBudget,
      "travelRoute": travelRoute,
      "transportation": transportation,
      "hotelsRestaurants": hotelsRestaurants,
    };
  }

  factory TravelPlan.fromMap(Map<String, dynamic> map) {
    // Safe budget conversion
    double budget = 0;
    final budgetValue = map["budget"];
    if (budgetValue != null) {
      if (budgetValue is String) {
        budget = double.tryParse(budgetValue) ?? 0;
      } else if (budgetValue is num) {
        budget = budgetValue.toDouble();
      }
    }

    // Safe duration conversion
    int duration = 0;
    final durationValue = map["duration"];
    if (durationValue != null) {
      if (durationValue is String) {
        duration = int.tryParse(durationValue) ?? 0;
      } else if (durationValue is num) {
        duration = durationValue.toInt();
      }
    }

    return TravelPlan(
      id: map["id"] ?? "",
      userId: map["userId"] ?? "",
      userName: map["userName"] ?? "",
      startLocation: map["startLocation"] ?? "",
      destination: map["destination"] ?? "",
      budget: budget,
      duration: duration,
      numberOfPassengers: map["numberOfPassengers"] ?? 1,
      description: map["description"] ?? "",
      highlights: List<String>.from(map["highlights"] ?? []),
      popularPlaces:
          (map["popularPlaces"] as List?)
              ?.map((p) {
                if (p is Map<String, dynamic>) {
                  return PopularPlace.fromMap(p);
                }
                return null;
              })
              .whereType<PopularPlace>()
              .toList() ??
          [],
      routePoints:
          (map["routePoints"] as List?)
              ?.map((r) {
                if (r is Map<String, dynamic>) {
                  return LatLngPoint.fromMap(r);
                }
                return null;
              })
              .whereType<LatLngPoint>()
              .toList() ??
          [],
      createdAt: (map["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map["updatedAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      averageRating: (map["averageRating"] ?? 0).toDouble(),
      reviewCount: map["reviewCount"] ?? 0,
      dayWiseBreakdown: List<String>.from(map["dayWiseBreakdown"] ?? []),
      dayWisePlans: List<String>.from(map["dayWisePlans"] ?? []),
      placesList: map["placesList"] ?? '',
      dayWiseBudget: map["dayWiseBudget"] ?? '',
      travelRoute: map["travelRoute"] ?? '',
      transportation: map["transportation"] ?? '',
      hotelsRestaurants: map["hotelsRestaurants"] ?? '',
    );
  }
}

class PopularPlace {
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String category; // e.g., "temple", "beach", "restaurant"
  final double? estimatedBudget; // in INR
  final String? imageUrl;

  PopularPlace({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.estimatedBudget,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "description": description,
      "latitude": latitude,
      "longitude": longitude,
      "category": category,
      "estimatedBudget": estimatedBudget,
      "imageUrl": imageUrl,
    };
  }

  factory PopularPlace.fromMap(Map<String, dynamic> map) {
    return PopularPlace(
      name: map["name"] ?? "",
      description: map["description"] ?? "",
      latitude: (map["latitude"] ?? 0).toDouble(),
      longitude: (map["longitude"] ?? 0).toDouble(),
      category: map["category"] ?? "",
      estimatedBudget: map["estimatedBudget"]?.toDouble(),
      imageUrl: map["imageUrl"],
    );
  }
}

class LatLngPoint {
  final double latitude;
  final double longitude;

  LatLngPoint({required this.latitude, required this.longitude});

  Map<String, dynamic> toMap() {
    return {"latitude": latitude, "longitude": longitude};
  }

  factory LatLngPoint.fromMap(Map<String, dynamic> map) {
    return LatLngPoint(
      latitude: (map["latitude"] ?? 0).toDouble(),
      longitude: (map["longitude"] ?? 0).toDouble(),
    );
  }
}
