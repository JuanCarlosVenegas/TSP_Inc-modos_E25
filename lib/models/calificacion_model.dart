import 'package:cloud_firestore/cloud_firestore.dart';


class RatingModel {
  final String requestId;
  final String fromUserId;
  final String toUserId;
  final double stars;
  final String comment; // obligatorio
  final DateTime timestamp;

  RatingModel({
    required this.requestId,
    required this.fromUserId,
    required this.toUserId,
    required this.stars,
    required this.comment,
    required this.timestamp,
  });

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      requestId: map['requestId'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      stars: (map['stars'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'stars': stars,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}
