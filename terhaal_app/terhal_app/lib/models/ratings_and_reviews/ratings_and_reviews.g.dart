// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ratings_and_reviews.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RatingsAndReviews _$RatingsAndReviewsFromJson(Map<String, dynamic> json) =>
    RatingsAndReviews(
      oneStar: json['oneStar'] as int,
      twoStar: json['twoStar'] as int,
      threeStar: json['threeStar'] as int,
      fourStar: json['fourStar'] as int,
      fiveStar: json['fiveStar'] as int,
    );

Map<String, dynamic> _$RatingsAndReviewsToJson(RatingsAndReviews instance) =>
    <String, dynamic>{
      'oneStar': instance.oneStar,
      'twoStar': instance.twoStar,
      'threeStar': instance.threeStar,
      'fourStar': instance.fourStar,
      'fiveStar': instance.fiveStar,
    };
