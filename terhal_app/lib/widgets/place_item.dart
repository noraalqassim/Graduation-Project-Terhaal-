import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/utils/constants.dart';

class PlaceItem extends StatelessWidget {
  const PlaceItem({
    super.key,
    required this.recommendation,
    required this.isInFavorites,
    this.onFavoriteTap,
  });

  final Recommendation recommendation;
  final bool isInFavorites;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/details', arguments: recommendation),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            _buildImageWidget(),
            _buildTextWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    return recommendation.getPrimaryPlaceImage() != null
        ? Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: recommendation.getPrimaryPlaceImage()!.image,
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
              ),
              Positioned(
                top: 6,
                right: 6,
                child: _buildFavoriteIcon(),
              ),
            ],
          )
        : Center(
            child: Icon(
              Icons.image_not_supported,
              color: Constants.primaryColor,
              size: Get.width * 0.245,
            ),
          );
  }

  Container _buildFavoriteIcon() {
    return Container(
      height: 18,
      width: 18,
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
        shape: BoxShape.circle,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onFavoriteTap,
        child: Icon(
          isInFavorites ? Icons.favorite : Icons.favorite_border,
          color: isInFavorites ? Colors.redAccent : Colors.grey,
          size: 10,
        ),
      ),
    );
  }

  Expanded _buildTextWidget() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              recommendation.name.length > 16
                  ? '${recommendation.name.substring(0, 16)}...'
                  : recommendation.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    recommendation.reviewsRating.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
