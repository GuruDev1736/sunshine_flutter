import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String planId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double rating; // 1 to 5
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int helpfulCount;

  ReviewModel({
    required this.reviewId,
    required this.planId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.helpfulCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "reviewId": reviewId,
      "planId": planId,
      "userId": userId,
      "userName": userName,
      "userPhotoUrl": userPhotoUrl,
      "rating": rating,
      "comment": comment,
      "createdAt": Timestamp.fromDate(createdAt),
      "updatedAt": Timestamp.fromDate(updatedAt),
      "helpfulCount": helpfulCount,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      reviewId: map["reviewId"] ?? "",
      planId: map["planId"] ?? "",
      userId: map["userId"] ?? "",
      userName: map["userName"] ?? "",
      userPhotoUrl: map["userPhotoUrl"],
      rating: (map["rating"] ?? 0).toDouble(),
      comment: map["comment"] ?? "",
      createdAt: (map["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map["updatedAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      helpfulCount: map["helpfulCount"] ?? 0,
    );
  }
}
