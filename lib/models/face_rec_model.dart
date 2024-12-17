import 'dart:convert';

FaceRecModel faceRecModelFromJson(String str) =>
    FaceRecModel.fromJson(json.decode(str));

String faceRecModelToJson(FaceRecModel data) => json.encode(data.toJson());

class FaceRecModel {
  final bool? status;
  final String? message;

  FaceRecModel({
    this.status,
    this.message,
  });

  FaceRecModel copyWith({
    bool? status,
    String? message,
  }) =>
      FaceRecModel(
        status: status ?? this.status,
        message: message ?? this.message,
      );

  factory FaceRecModel.fromJson(Map<String, dynamic> json) => FaceRecModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
