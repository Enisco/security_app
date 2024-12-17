import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:security_app/models/face_rec_model.dart';
import 'package:security_app/models/image_data_model.dart';

var logger = Logger();

class SecurityAppController extends GetxController {
  SecurityAppController();

  ImageDataModel? latestImageData;
  List<ImageDataModel> allImagesDataList = [];
  bool isLoading = false;
  FaceRecModel? faceRecResponse;

  fetchLatestImage() async {
    if (isLoading == false) {
      try {
        isLoading = true;
        update();
        final storageRef = FirebaseStorage.instance.ref().child('latest_photo');
        final downloadUrl = await storageRef.getDownloadURL();

        final metadata = await storageRef.getMetadata();
        final latestImageTime = metadata.timeCreated;
        latestImageData = ImageDataModel(
          url: downloadUrl,
          timeCreated: latestImageTime,
        );
        logger.f("latestImageUrl: ${latestImageData?.toJson()}");
        update();

        // Fetch the URL from Firebase Realtime Database
        String? securityAppUrl = await _fetchSecurityAppUrl();

        if (securityAppUrl != null) {
          final responseJson = await _checkFaceRecognition(
              "$securityAppUrl/compare_faces?url=$downloadUrl");
          faceRecResponse = faceRecModelFromJson(jsonEncode(responseJson));

          update();
        } else {
          logger.e('Failed to fetch security app URL.');
          isLoading = false;
          faceRecResponse = FaceRecModel(
              status: false, message: "Face could not be identified");
        }
      } catch (e) {
        isLoading = false;
        logger.e('Error identifying face: $e');
        faceRecResponse =
            FaceRecModel(status: false, message: "Unable to identify face");
      }
      logger.w(faceRecResponse?.toJson());
      update();
    }
  }

  Future<String?> _fetchSecurityAppUrl() async {
    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
      final DataSnapshot snapshot = await dbRef.child('security_app_url').get();

      if (snapshot.exists) {
        final securityAppUrl = snapshot.value as String;
        logger.f("securityAppUrl: $securityAppUrl");
        return securityAppUrl;
      } else {
        logger.w('Key "security_app_url" does not exist.');
        return null;
      }
    } catch (e) {
      logger.e('Error fetching security_app_url: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _checkFaceRecognition(String url) async {
    isLoading = true;
    update();
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      isLoading = false;
      update();
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      isLoading = false;
      update();
      throw Exception(
          'Failed to load data. Status Code: ${response.statusCode}');
    }
  }

  fetchAndSortAllImages() async {
    isLoading = true;
    update();
    try {
      final storageRef = FirebaseStorage.instance.ref().child('data');
      final ListResult result = await storageRef.listAll();

      List<ImageDataModel> imageDataList = [];
      for (Reference ref in result.items) {
        final FullMetadata metadata = await ref.getMetadata();
        final String imageUrl = await ref.getDownloadURL();
        final timeCreated = metadata.timeCreated;

        imageDataList.add(
          ImageDataModel(url: imageUrl, timeCreated: timeCreated),
        );
      }

      // Sort the list by timeCreated in descending order
      imageDataList.sort((a, b) => b.timeCreated!.compareTo(a.timeCreated!));
      isLoading = false;
      allImagesDataList = imageDataList;
      logger.w("allImagesDataList: ${allImagesDataList.length}");
    } catch (e) {
      logger.e("Error getting images list: ${e.toString()}");
      allImagesDataList = [];
    }
    update();
  }
}
