import 'package:terhal_app/models/category/category.dart';
import 'package:terhal_app/models/place_image/place_image.dart';
import 'package:terhal_app/models/ratings_and_reviews/ratings_and_reviews.dart';

class Recommendation {
  final int id;
  final String name;
  final String description;
  final double reviewsRating;
  final double latitude;
  final double longitude;
  final String fullAddress;
  final bool trending;
  final Category category;
  final List<PlaceImage> placeImages;
  final int ratingsAndReviewsCount;
  final RatingsAndReviews ratingsAndReviews;

  Recommendation({
    required this.id,
    required this.name,
    required this.description,
    required this.reviewsRating,
    required this.latitude,
    required this.longitude,
    required this.fullAddress,
    required this.trending,
    required this.category,
    required this.placeImages,
    required this.ratingsAndReviewsCount,
    required this.ratingsAndReviews,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      reviewsRating: json['reviews_rating'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      fullAddress: json['full_address'],
      trending: json['trending'],
      category: (json['category'] != null
          ? Category.fromJson(json['category'])
          : null)!,
      placeImages: (json['images'] as List<dynamic>)
          .map((imageJson) => PlaceImage.fromJson(imageJson))
          .toList(),
      ratingsAndReviewsCount: json['ratings_and_reviews_count'],
      ratingsAndReviews: (json['ratings_and_reviews'] != null
          ? RatingsAndReviews.fromJson(json['ratings_and_reviews'])
          : null)!,
    );
  }

  PlaceImage? getPrimaryPlaceImage() {
    for (var placeImage in placeImages) {
      if (placeImage.primary) {
        return placeImage;
      }
    }
    return null;
  }
}
