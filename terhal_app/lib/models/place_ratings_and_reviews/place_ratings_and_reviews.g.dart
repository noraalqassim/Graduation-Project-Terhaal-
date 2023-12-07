// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_ratings_and_reviews.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceRatingsAndReviews _$PlaceRatingsAndReviewsFromJson(
        Map<String, dynamic> json) =>
    PlaceRatingsAndReviews(
      user: json['user'] as String,
      place: json['place'] as int,
      rating: (json['rating'] as num).toDouble(),
      review: json['review'] as String,
      date: json['date'] as String,
      current: json['current'] as bool,
    );

Map<String, dynamic> _$PlaceRatingsAndReviewsToJson(
        PlaceRatingsAndReviews instance) =>
    <String, dynamic>{
      'user': instance.user,
      'place': instance.place,
      'rating': instance.rating,
      'review': instance.review,
      'date': instance.date,
      'current': instance.current,
    };
