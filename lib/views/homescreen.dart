import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:security_app/controllers/security_app_controller.dart';

class SecurityAppHomescreen extends StatefulWidget {
  const SecurityAppHomescreen({super.key});

  @override
  State<SecurityAppHomescreen> createState() => _SecurityAppHomescreenState();
}

class _SecurityAppHomescreenState extends State<SecurityAppHomescreen> {
  final controller = Get.put(SecurityAppController());

  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startFetchingImage();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startFetchingImage() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      controller.fetchLatestImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Security Image App',
        ),
      ),
      body: GetBuilder<SecurityAppController>(
        init: SecurityAppController(),
        builder: (_) {
          return Container(
            height: size.height - 55,
            width: size.width,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  height: 450,
                  child: controller.latestImageData?.url == null
                      ? const Center(child: CircularProgressIndicator())
                      : Image(
                          image: CachedNetworkImageProvider(
                            controller.latestImageData?.url ?? '',
                          ),
                          fit: BoxFit.fitWidth,
                        ),
                ),
                const SizedBox(height: 10),
                Text(
                  DateFormat('EEEE, MMM d, yyyy, h:mm:ss a').format(
                    controller.latestImageData?.timeCreated ?? DateTime.now(),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 80,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      controller.isLoading == true
                          ? const Text(
                              "Face recognition in progress . . .",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              controller.faceRecResponse?.message ?? " ",
                              style: TextStyle(
                                fontSize: 22,
                                color:
                                    controller.faceRecResponse?.status == true
                                        ? Colors.white
                                        : Colors.red.shade900,
                              ),
                            )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
