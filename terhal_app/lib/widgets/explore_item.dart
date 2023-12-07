import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/models/user_favorite/user_favorite.dart';
import 'package:terhal_app/utils/constants.dart';

class ExploreItem extends StatefulWidget {
  const ExploreItem({
    super.key,
    required this.recommendation,
    required this.isInFavorites,
    this.onFavoriteTap,
  });

  final Recommendation recommendation;
  final bool isInFavorites;
  final VoidCallback? onFavoriteTap;

  @override
  State<ExploreItem> createState() => _ExploreItemState();
}

class _ExploreItemState extends State<ExploreItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/details', arguments: widget.recommendation),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageWidget(),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextWidget(),
            ),
          ],
        ),
      ),
    );
  }

  bool isInFavorites(UserFavorite userFavorite) {
    return userFavorite.favorites.contains(widget.recommendation.id);
  }

  Widget _buildImageWidget() {
    return widget.recommendation.getPrimaryPlaceImage() != null
        ? Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: SizedBox(
                  height: Get.height * 0.12,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl:
                            widget.recommendation.getPrimaryPlaceImage()!.image,
                        progressIndicatorBuilder: (context, url, progress) =>
                            Center(
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
        : SizedBox(
            width: Get.width * 0.41,
            child: Icon(
              Icons.image_not_supported,
              color: Constants.primaryColor,
              size: Get.width * 0.24,
            ),
          );
  }

  Widget _buildFavoriteIcon() {
    return Container(
      height: 18,
      width: 18,
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
        shape: BoxShape.circle,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: widget.onFavoriteTap,
        child: Icon(
          widget.isInFavorites ? Icons.favorite : Icons.favorite_border,
          color: widget.isInFavorites ? Colors.redAccent : Colors.grey,
          size: 10,
        ),
      ),
    );
  }

  Widget _buildTextWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          widget.recommendation.name,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          widget.recommendation.fullAddress,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
