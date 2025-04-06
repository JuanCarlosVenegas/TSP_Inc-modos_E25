class PickupRequest {
  final String requestId;
  final String userId;
  final String location;
  final String time;
  final String amount;
  final String wasteType;
  final int quantity;
  final String size;
  String status;
  final DateTime createdAt;
  final String? collectorId;
  final List<String> imageUrls;

  PickupRequest({
    required this.requestId,
    required this.userId,
    required this.location,
    required this.time,
    required this.amount,
    required this.wasteType,
    required this.quantity,
    required this.size,
    required this.status,
    required this.createdAt,
    this.collectorId,
    required this.imageUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'userId': userId,
      'location': location,
      'time': time,
      'amount': amount,
      'wasteType': wasteType,
      'quantity': quantity,
      'size': size,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'collectorId': collectorId,
      'imageUrls': imageUrls,
    };
  }

  factory PickupRequest.fromJson(Map<String, dynamic> json) {
    return PickupRequest(
      requestId: json['requestId'],
      userId: json['userId'],
      location: json['location'],
      time: json['time'],
      amount: json['amount'],
      wasteType: json['wasteType'],
      quantity: json['quantity'],
      size: json['size'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      collectorId: json['collectorId'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
    );
  }

  PickupRequest copyWith({
    String? requestId,
    String? userId,
    String? location,
    String? time,
    String? amount,
    String? wasteType,
    int? quantity,
    String? size,
    String? status,
    DateTime? createdAt,
    String? collectorId,
    List<String>? imageUrls,
  }) {
    return PickupRequest(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      location: location ?? this.location,
      time: time ?? this.time,
      amount: amount ?? this.amount,
      wasteType: wasteType ?? this.wasteType,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      collectorId: collectorId ?? this.collectorId,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}
