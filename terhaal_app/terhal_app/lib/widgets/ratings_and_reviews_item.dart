import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:terhal_app/models/place_ratings_and_reviews/place_ratings_and_reviews.dart';
import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/utils/constants.dart';

class RatingsAndReviewsItem extends StatefulWidget {
  const RatingsAndReviewsItem(
      {super.key,
      required this.ratingsAndReviews,
      required this.recommendation});

  final PlaceRatingsAndReviews ratingsAndReviews;
  final Recommendation recommendation;

  @override
  State<RatingsAndReviewsItem> createState() => _RatingsAndReviewsItemState();
}

class _RatingsAndReviewsItemState extends State<RatingsAndReviewsItem> {
  @override
  Widget build(BuildContext context) {
    final user = widget.ratingsAndReviews.user;
    List<String> userNames = user.split(' ');
    String firstLetter = userNames.isNotEmpty && userNames[0].isNotEmpty
        ? userNames[0][0].toUpperCase()
        : '';
    String lastLetter = userNames.length > 1 && userNames.last.isNotEmpty
        ? userNames.last[0].toUpperCase()
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.ratingsAndReviews.current)
          SizedBox(height: Get.height * 0.01),
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.blue,
              child: Text(
                "$firstLetter$lastLetter",
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: Get.width * 0.02),
            Text(
              user,
              style: const TextStyle(fontSize: 15),
            ),
            if (widget.ratingsAndReviews.current)
              Container(
                margin: const EdgeInsets.only(left: 5),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Constants.primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  "You",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            if (widget.ratingsAndReviews.current)
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    splashRadius: 20,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "edit",
                        child: const Text("Edit"),
                        onTap: () {
                          Get.toNamed(
                            "/post-ratings-and-reviews",
                            arguments: {
                              "recommendation": widget.recommendation,
                              "rating": widget.ratingsAndReviews.rating,
                              "review": widget.ratingsAndReviews.review,
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (!widget.ratingsAndReviews.current)
          SizedBox(height: Get.height * 0.012),
        Row(
          children: [
            RatingBar.builder(
              ignoreGestures: true,
              minRating: 1,
              maxRating: 5,
              itemCount: 5,
              itemSize: 12,
              allowHalfRating: true,
              initialRating: widget.ratingsAndReviews.rating,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Constants.primaryColor,
              ),
              onRatingUpdate: (value) => {},
            ),
            SizedBox(width: Get.width * 0.02),
            Text(
              widget.ratingsAndReviews.date,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: Get.height * 0.01),
        Text(widget.ratingsAndReviews.review),
      ],
    );
  }
}
