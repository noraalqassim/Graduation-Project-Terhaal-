import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controllers/firebase_auth_controller.dart';
import 'package:terhal_app/controllers/place_ratings_and_reviews_controller.dart';
import 'package:terhal_app/controllers/user_ratings_and_reviews_controller.dart';
import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/utils/constants.dart';
import 'package:terhal_app/widgets/loading.dart';

class PostRatingsAndReviewsPage extends StatefulWidget {
  const PostRatingsAndReviewsPage({super.key});

  @override
  State<PostRatingsAndReviewsPage> createState() =>
      _PostRatingsAndReviewsPageState();
}

class _PostRatingsAndReviewsPageState extends State<PostRatingsAndReviewsPage> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuthController authController = Get.find();
    final userRatingsAndReviewsController =
        Get.put(UserRatingsAndReviewsController());
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final recommendation = arguments['recommendation'] as Recommendation;
    double rating = arguments['rating'];
    String? review = arguments['review'];
    final user = authController.currentUser!.displayName ?? '';
    List<String> userNames = user.split(' ');
    String firstLetter = userNames.isNotEmpty && userNames[0].isNotEmpty
        ? userNames[0][0].toUpperCase()
        : '';
    String lastLetter = userNames.length > 1 && userNames.last.isNotEmpty
        ? userNames.last[0].toUpperCase()
        : '';
    final TextEditingController reviewController = TextEditingController();
    if (review != null) {
      reviewController.text = review;
    }

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.name.length > 12
                      ? '${recommendation.name.substring(0, 12)}...'
                      : recommendation.name,
                  style: TextStyle(
                    color: Get.textTheme.bodyLarge!.color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  "Rate this place",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Obx(() {
            return userRatingsAndReviewsController.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Loading.circle,
                  )
                : IconButton(
                    icon: const Icon(Icons.send, color: Constants.primaryColor),
                    onPressed: () async {
                      await userRatingsAndReviewsController
                          .postUserRatingsAndReviews(data: {
                        "uid": authController.currentUser!.uid,
                        "rating": {
                          "place": recommendation.id,
                          "rating": rating,
                          "review": reviewController.text,
                        }
                      });
                      await Get.find<PlaceRatingsAndReviewsController>()
                          .fetchPlaceRatings(placeId: recommendation.id)
                          .then((value) => Navigator.pop(context));
                    },
                  );
          }),
        ],
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.04),
        child: Column(
          children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: Get.height * 0.02,
                      ),
                      Text(
                        authController.currentUser!.displayName!,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const Text(
                        "Reviews are public and include your account name and profile photo.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.02),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: RatingBar.builder(
                  itemPadding:
                      EdgeInsets.symmetric(horizontal: Get.width * 0.05),
                  itemSize: 30,
                  minRating: 1,
                  maxRating: 5,
                  itemCount: 5,
                  allowHalfRating: true,
                  initialRating: rating,
                  itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Constants.primaryColor,
                      ),
                  onRatingUpdate: (value) => rating = value),
            ),
            SizedBox(height: Get.height * 0.02),
            FormBuilderTextField(
              name: "review",
              controller: reviewController,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: "Describe your experience (optional)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
