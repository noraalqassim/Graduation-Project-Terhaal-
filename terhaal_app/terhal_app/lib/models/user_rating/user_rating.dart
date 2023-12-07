import 'package:json_annotation/json_annotation.dart';

part 'user_rating.g.dart';

@JsonSerializable()
class UserRating {
  final int? place;
  final int? rating;
  final String? describe;

  const UserRating({this.place, this.rating, this.describe});

  factory UserRating.fromJson(Map<String, dynamic> json) {
    return _$UserRatingFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserRatingToJson(this);
}
