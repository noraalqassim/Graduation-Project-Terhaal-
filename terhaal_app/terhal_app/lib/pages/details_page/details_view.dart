import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:terhal_app/controllers/recommendation_controller.dart';
import 'package:terhal_app/controllers/similar_places_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:terhal_app/controllers/user_favorite_controller.dart';
import 'package:terhal_app/widgets/similar_place_item.dart';
import 'package:weather/weather.dart';
import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/utils/constants.dart';
import 'package:terhal_app/widgets/empty_data.dart';
import 'package:terhal_app/widgets/loading.dart';

class DetailsView extends StatefulWidget {
  const DetailsView({
    super.key,
    required this.appLocalizations,
    required this.recommendation,
  });

  final AppLocalizations? appLocalizations;
  final Recommendation recommendation;

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  late WeatherFactory ws;
  late Future<Weather> weatherFuture;
  late Weather weather;
  bool showFullDescription = false;
  final userFavoriteController = Get.put(UserFavoriteController());
  late final SimilarPlaceController similarPlacesController;

  @override
  void initState() {
    super.initState();
    similarPlacesController =
        Get.put(SimilarPlaceController(id: widget.recommendation.id));
    userFavoriteController.updateUserFavorite();
    ws = WeatherFactory(Constants.weatherKEY);
    weatherFuture = queryWeather();
  }

  Future<Weather> queryWeather() async {
    return ws.currentWeatherByLocation(
      widget.recommendation.latitude,
      widget.recommendation.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageWidget(),
            SizedBox(height: Get.height * 0.02),
            _buildDetails(),
            SizedBox(height: Get.height * 0.01),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.grey[200],
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFC8CCD2),
                    Color(0xFF97B2E5),
                    Color(0xFF7CA9FF),
                  ],
                  stops: [0.0, 0.9999, 1.0],
                ),
              ),
              child: _buildWeather(),
            ),
            SizedBox(height: Get.height * 0.01),
            _buildRatingAndReviews(),
            SizedBox(height: Get.height * 0.01),
            const Text(
              "Similar Places",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Get.height * 0.01),
            _buildSimilarPlaces(),
          ],
        ),
      ),
    );
  }

  FutureBuilder<Weather> _buildWeather() {
    return FutureBuilder<Weather>(
      future: weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(5.0),
            child: Loading.circle,
          );
        } else if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(17),
            child: Center(
              child: Text(
                "Error loading weather data!",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          );
        } else {
          weather = snapshot.data!;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CachedNetworkImage(
                imageUrl:
                    "https://openweathermap.org/img/w/${weather.weatherIcon}.png",
                progressIndicatorBuilder: (context, url, progress) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      value: progress.progress,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.areaName!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weather.weatherDescription!.capitalize!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('E, MMM, y').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Sunrise ${weather.sunrise!.hour}:${weather.sunrise!.minute} - ${weather.sunset!.hour}:${weather.sunset!.minute}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Text(
                "${weather.temperature!.celsius!.toStringAsFixed(0)}°C",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildDetails() {
    return Column(
      children: [
        _buildTextWidget(),
        const SizedBox(height: 5),
        _buildFullAddress(),
        _buildDescription(),
      ],
    );
  }

  Row _buildFullAddress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 20,
            ),
            const SizedBox(width: 5),
            Text(
              widget.recommendation.fullAddress,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () {
            Get.toNamed('/details-map', arguments: widget.recommendation);
          },
          child: const Text(
            "Show in map",
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget() {
    return widget.recommendation.getPrimaryPlaceImage() != null
        ? Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.recommendation.getPrimaryPlaceImage()!.image,
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        value: progress.progress,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _buildFavoriteIcon(),
              ),
            ],
          )
        : Center(
            child: Icon(
              Icons.image_not_supported,
              color: Constants.primaryColor,
              size: Get.width * 0.3,
            ),
          );
  }

  Obx _buildFavoriteIcon() {
    return Obx(
      () {
        final isInFavorites = userFavoriteController
                .userFavorite.value?.favorites
                .contains(widget.recommendation.id) ??
            userFavoriteController.userFavorites
                .any((favorite) => favorite.id == widget.recommendation.id);
        return Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
            shape: BoxShape.circle,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              userFavoriteController.toggleFavorite(widget.recommendation.id);
              Get.find<RecommendationController>().fetchRecommendations();
            },
            child: Icon(
              isInFavorites ? Icons.favorite : Icons.favorite_border,
              color: isInFavorites ? Colors.redAccent : Colors.grey,
              size: 15,
            ),
          ),
        );
      },
    );
  }

  Row _buildTextWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.recommendation.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            const Icon(
              Icons.star,
              color: Colors.yellow,
              size: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                widget.recommendation.reviewsRating.toString(),
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column _buildDescription() {
    String description = widget.recommendation.description;
    String displayedText = showFullDescription
        ? description
        : (description.length > 200
            ? '${description.substring(0, 200)}...'
            : description);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        const Text(
          "Description",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          displayedText,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        if (description.length > 200) ...[
          const SizedBox(height: 5),
          InkWell(
            onTap: () {
              setState(() {
                showFullDescription = !showFullDescription;
              });
            },
            child: Text(
              showFullDescription ? "Read Less" : "Read More",
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingAndReviews() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Get.toNamed('/ratings-and-reviews',
              arguments: widget.recommendation),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ratings and reviews",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
        RichText(
          text: TextSpan(
            text: 'Ratings and reviews are verified by ',
            style: DefaultTextStyle.of(context).style,
            children: const [
              TextSpan(
                text: 'Terhal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: ' and are valid for this place only.',
              ),
            ],
          ),
        ),
        SizedBox(height: Get.height * 0.02),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recommendation.reviewsRating.toString(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RatingBar.builder(
                  ignoreGestures: true,
                  minRating: 1,
                  maxRating: 5,
                  itemCount: 5,
                  itemSize: 15,
                  allowHalfRating: true,
                  initialRating: widget.recommendation.reviewsRating,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Constants.primaryColor,
                  ),
                  onRatingUpdate: (value) => {},
                ),
                SizedBox(height: Get.height * 0.01),
                widget.recommendation.ratingsAndReviewsCount > 0
                    ? Text(
                        "${widget.recommendation.ratingsAndReviewsCount} reviews",
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      )
                    : const Text(
                        "No reviews yet",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
              ],
            ),
            SizedBox(width: Get.width * 0.05),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("5"),
                      SizedBox(width: Get.width * 0.02),
                      Expanded(
                        child: LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                          value: widget.recommendation.ratingsAndReviewsCount >
                                  0
                              ? widget.recommendation.ratingsAndReviews
                                      .fiveStar /
                                  widget.recommendation.ratingsAndReviewsCount
                              : 0.0,
                          semanticsLabel: 'Five star rating',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("4"),
                      SizedBox(width: Get.width * 0.02),
                      Expanded(
                        child: LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                          value: widget.recommendation.ratingsAndReviewsCount >
                                  0
                              ? widget.recommendation.ratingsAndReviews
                                      .fourStar /
                                  widget.recommendation.ratingsAndReviewsCount
                              : 0.0,
                          semanticsLabel: 'Four star rating',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("3"),
                      SizedBox(width: Get.width * 0.02),
                      Expanded(
                        child: LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                          value: widget.recommendation.ratingsAndReviewsCount >
                                  0
                              ? widget.recommendation.ratingsAndReviews
                                      .threeStar /
                                  widget.recommendation.ratingsAndReviewsCount
                              : 0.0,
                          semanticsLabel: 'Three star rating',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("2"),
                      SizedBox(width: Get.width * 0.02),
                      Expanded(
                        child: LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                          value: widget.recommendation.ratingsAndReviewsCount >
                                  0
                              ? widget.recommendation.ratingsAndReviews
                                      .twoStar /
                                  widget.recommendation.ratingsAndReviewsCount
                              : 0.0,
                          semanticsLabel: 'Two star rating',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("1"),
                      SizedBox(width: Get.width * 0.02),
                      Expanded(
                        child: LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                          value: widget.recommendation.ratingsAndReviewsCount >
                                  0
                              ? widget.recommendation.ratingsAndReviews
                                      .oneStar /
                                  widget.recommendation.ratingsAndReviewsCount
                              : 0.0,
                          semanticsLabel: 'One star rating',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildSimilarPlaces() {
    return Obx(
      () => SizedBox(
        height: Get.height * 0.3,
        child: similarPlacesController.isLoading.value
            ? Loading.circle
            : similarPlacesController.similarPlaces.isEmpty
                ? EmptyData(
                    text: widget.appLocalizations!.emptyData('Recommendation'))
                : _buildSimilarPlacesGrideView(),
      ),
    );
  }

  Widget _buildSimilarPlacesGrideView() {
    return AnimationLimiter(
      child: GridView.builder(
        primary: false,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          childAspectRatio: 1 / 0.8,
        ),
        itemCount: similarPlacesController.similarPlaces.length,
        itemBuilder: (context, index) {
          final similarPlace = similarPlacesController.similarPlaces[index];
          return AnimationConfiguration.staggeredGrid(
            columnCount: similarPlacesController.similarPlaces.length,
            position: index,
            duration: const Duration(milliseconds: 375),
            child: ScaleAnimation(
              scale: 0.5,
              child: FadeInAnimation(
                child: SimilarPlaceItem(similarPlace: similarPlace),
              ),
            ),
          );
        },
      ),
    );
  }
}
