import 'dart:convert';

ImageDataModel imageDataModelFromJson(String str) =>
    ImageDataModel.fromJson(json.decode(str));

String imageDataModelToJson(ImageDataModel data) => json.encode(data.toJson());

class ImageDataModel {
  final String? url;
  final DateTime? timeCreated;

  ImageDataModel({
    this.url,
    this.timeCreated,
  });

  ImageDataModel copyWith({
    String? url,
    DateTime? timeCreated,
  }) =>
      ImageDataModel(
        url: url ?? this.url,
        timeCreated: timeCreated ?? this.timeCreated,
      );

  factory ImageDataModel.fromJson(Map<String, dynamic> json) => ImageDataModel(
        url: json["url"],
        timeCreated: json["timeCreated"] == null
            ? null
            : DateTime.parse(json["timeCreated"]),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "timeCreated": timeCreated?.toIso8601String(),
      };
}
