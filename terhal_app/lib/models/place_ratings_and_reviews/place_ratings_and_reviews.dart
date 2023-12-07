import 'package:json_annotation/json_annotation.dart';

part 'place_ratings_and_reviews.g.dart';

@JsonSerializable()
class PlaceRatingsAndReviews {
  final String user;
  final int place;
  final double rating;
  final String review;
  final String date;
  final bool current;

  PlaceRatingsAndReviews({
    required this.user,
    required this.place,
    required this.rating,
    required this.review,
    required this.date,
    required this.current,
  });

  factory PlaceRatingsAndReviews.fromJson(Map<String, dynamic> json) {
    return _$PlaceRatingsAndReviewsFromJson(json);
  }
}
