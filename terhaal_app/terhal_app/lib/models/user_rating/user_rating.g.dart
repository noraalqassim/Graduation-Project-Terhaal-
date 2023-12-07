// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRating _$UserRatingFromJson(Map<String, dynamic> json) => UserRating(
      place: json['place'] as int?,
      rating: json['rating'] as int?,
      describe: json['describe'] as String?,
    );

Map<String, dynamic> _$UserRatingToJson(UserRating instance) =>
    <String, dynamic>{
      'place': instance.place,
      'rating': instance.rating,
      'describe': instance.describe,
    };
