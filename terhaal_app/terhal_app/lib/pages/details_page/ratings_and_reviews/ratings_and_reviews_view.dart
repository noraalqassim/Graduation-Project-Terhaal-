import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controllers/place_ratings_and_reviews_controller.dart';
import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/utils/constants.dart';
import 'package:terhal_app/widgets/empty_data.dart';
import 'package:terhal_app/widgets/loading.dart';
import 'package:terhal_app/widgets/ratings_and_reviews_item.dart';

class RatingsAndReviewsView extends StatefulWidget {
  const RatingsAndReviewsView({
    super.key,
    required this.recommendation,
    required this.placeRatingsAndReviewsController,
  });

  final Recommendation recommendation;
  final PlaceRatingsAndReviewsController placeRatingsAndReviewsController;

  @override
  State<RatingsAndReviewsView> createState() => _RatingsAndReviewsViewState();
}

class _RatingsAndReviewsViewState extends State<RatingsAndReviewsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          if (!widget.placeRatingsAndReviewsController.isLoading.value &&
              widget.placeRatingsAndReviewsController
                      .getCurrentUserPlaceRatings() ==
                  null) {
            return _buildUpdateReviews();
          } else {
            return const SizedBox();
          }
        }),
        Expanded(child: _buildPlaceRatingsAndReviews()),
      ],
    );
  }

  Padding _buildUpdateReviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Rate this place",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("Tell others what you think about this place"),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: RatingBar.builder(
                itemPadding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
                itemSize: 30,
                minRating: 1,
                maxRating: 5,
                itemCount: 5,
                allowHalfRating: true,
                initialRating: 0,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Constants.primaryColor,
                ),
                onRatingUpdate: (value) => {
                  Get.toNamed(
                    "/post-ratings-and-reviews",
                    arguments: {
                      "recommendation": widget.recommendation,
                      "rating": value,
                    },
                  ),
                },
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () => Get.toNamed(
              "/post-ratings-and-reviews",
              arguments: {
                "recommendation": widget.recommendation,
                "rating": 0.0,
              },
            ),
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                "Write a review",
                style: TextStyle(
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlaceRatingsAndReviews() {
    return Obx(
      () => widget.placeRatingsAndReviewsController.isLoading.value
          ? Loading.circle
          : widget.placeRatingsAndReviewsController.placeRatings.isEmpty
              ? const EmptyData(text: "No Data")
              : _buildPlaceRatingsAndReviewsListView(),
    );
  }

  Widget _buildPlaceRatingsAndReviewsListView() {
    return ListView.separated(
      itemCount: widget.placeRatingsAndReviewsController.placeRatings.length,
      separatorBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(left: 10, right: Get.width * 0.9),
        child: const Divider(thickness: 1),
      ),
      itemBuilder: (context, index) {
        final placeRatingsAndReviews =
            widget.placeRatingsAndReviewsController.placeRatings[index];
        return AnimationConfiguration.staggeredGrid(
          columnCount:
              widget.placeRatingsAndReviewsController.placeRatings.length,
          position: index,
          duration: const Duration(milliseconds: 375),
          child: ScaleAnimation(
            scale: 0.5,
            child: FadeInAnimation(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.03),
                child: RatingsAndReviewsItem(
                  ratingsAndReviews: placeRatingsAndReviews,
                  recommendation: widget.recommendation,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
