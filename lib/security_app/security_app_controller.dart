import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:security_app/security_app/model.dart';

var logger = Logger();

class SecurityAppController extends GetxController {
  SecurityAppController();

  String? latestImageUrl;
  bool isLoading = false;
  FaceRecModel? faceRecResponse;

  fetchLatestImage() async {
    if (isLoading == false) {
      try {
        isLoading = true;
        update();
        final storageRef = FirebaseStorage.instance.ref().child('latest_photo');
        final downloadUrl = await storageRef.getDownloadURL();
        latestImageUrl = downloadUrl;
        logger.f("latestImageUrl: $latestImageUrl");

        // Fetch the URL from Firebase Realtime Database
        String? securityAppUrl = await _fetchSecurityAppUrl();
        update();

        if (securityAppUrl != null) {
          final responseJson = await _checkFaceRecognition(
              "$securityAppUrl/compare_faces?url=$latestImageUrl");
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
}
