import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/utils/constants.dart';

class SimilarPlaceItem extends StatelessWidget {
  const SimilarPlaceItem({super.key, required this.similarPlace});

  final Recommendation similarPlace;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.offAndToNamed('/details', arguments: similarPlace),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            similarPlace.getPrimaryPlaceImage() != null
                ? Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: similarPlace.getPrimaryPlaceImage()!.image,
                          fit: BoxFit.fill,
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                value: progress.progress,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Constants.primaryColor,
                      size: Get.width * 0.165,
                    ),
                  ),
            const SizedBox(height: 2),
            Text(
              similarPlace.name.length > 16
                  ? '${similarPlace.name.substring(0, 16)}...'
                  : similarPlace.name,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
