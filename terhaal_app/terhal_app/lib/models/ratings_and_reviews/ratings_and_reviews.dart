import 'package:json_annotation/json_annotation.dart';

part 'ratings_and_reviews.g.dart';

@JsonSerializable()
class RatingsAndReviews {
  final int oneStar;
  final int twoStar;
  final int threeStar;
  final int fourStar;
  final int fiveStar;

  RatingsAndReviews({
    required this.oneStar,
    required this.twoStar,
    required this.threeStar,
    required this.fourStar,
    required this.fiveStar,
  });

  factory RatingsAndReviews.fromJson(Map<String, dynamic> json) {
    return _$RatingsAndReviewsFromJson(json);
  }
}
