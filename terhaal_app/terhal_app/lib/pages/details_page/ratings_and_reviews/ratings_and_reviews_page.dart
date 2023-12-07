import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controllers/place_ratings_and_reviews_controller.dart';
import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/pages/details_page/ratings_and_reviews/ratings_and_reviews_view.dart';

class RatingsAndReviewsPage extends StatefulWidget {
  const RatingsAndReviewsPage({super.key});

  @override
  State<RatingsAndReviewsPage> createState() => _RatingsAndReviewsPageState();
}

class _RatingsAndReviewsPageState extends State<RatingsAndReviewsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final recommendation =
        ModalRoute.of(context)!.settings.arguments as Recommendation;
    final placeRatingsAndReviewsController =
        Get.put<PlaceRatingsAndReviewsController>(
      PlaceRatingsAndReviewsController(id: recommendation.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            recommendation.getPrimaryPlaceImage() != null
                ? SizedBox(
                    height: Get.height * 0.05,
                    width: Get.height * 0.05,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: recommendation.getPrimaryPlaceImage()!.image,
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
                  )
                : const SizedBox(),
            SizedBox(width: Get.width * 0.02),
            Text(
              "${recommendation.name.length > 12 ? '${recommendation.name.substring(0, 12)}...' : recommendation.name} Reviews",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Get.textTheme.bodyLarge!.color,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      recommendation.reviewsRating.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Get.textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.star,
                    size: 15,
                    color: Colors.amber,
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: RatingsAndReviewsView(
        recommendation: recommendation,
        placeRatingsAndReviewsController: placeRatingsAndReviewsController,
      ),
    );
  }
}
