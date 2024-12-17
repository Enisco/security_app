import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:security_app/controllers/security_app_controller.dart';
import 'package:security_app/models/image_data_model.dart';

class AllImagesScreen extends StatefulWidget {
  const AllImagesScreen({super.key});

  @override
  State<AllImagesScreen> createState() => _AllImagesScreenState();
}

class _AllImagesScreenState extends State<AllImagesScreen> {
  final controller = Get.put(SecurityAppController());

  @override
  void initState() {
    super.initState();
    controller.fetchAllImagesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Capture Record'),
      ),
      body: GetBuilder<SecurityAppController>(
        init: SecurityAppController(),
        builder: (_) {
          return SizedBox(
            child: controller.isLoading == true
                ? const Center(child: CircularProgressIndicator())
                : controller.allImagesDataList.isEmpty
                    ? const Center(child: Text("Unable to get all the records"))
                    : ListView.builder(
                        itemCount: controller.allImagesDataList.length,
                        itemBuilder: (context, index) {
                          final imageData = controller.allImagesDataList[index];
                          return _imageCard(imageData);
                        },
                      ),
          );
        },
      ),
    );
  }

  Widget _imageCard(ImageDataModel imageData) {
    return Card(
      color: Colors.white,
      child: Container(
        height: 300,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageData.url ?? ""),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 24,
              margin: const EdgeInsets.symmetric(vertical: 3),
              width: MediaQuery.of(context).size.width - 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d, yyyy, h:mm:ss a').format(
                      controller.latestImageData?.timeCreated ?? DateTime.now(),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
